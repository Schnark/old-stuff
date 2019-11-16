unit flipper_; {$N+,E-}{$G+}
{$DEFINE Test}        {Stack-,öberlauf-ÅberprÅfung,Debug mîglich}
{{$DEFINE Trick}      {Zwischenspeicher irgendwo, wo er nicht stîrt, wobei unklar ist, warum nicht}
{{$DEFINE Spur}       {Kugel hinterlÑsst Spur}

{$IFNDEF Test}
  {$D-,S-,R-,Q-}
{$ELSE}
{$ENDIF}

interface
type real = single;

const automatisch = false;

const sinalpha5_7g:real = 0.3;     {Schwerkraft}
      delta_T:real = 0.025;
      T_18:real = 0.9;

const maxkugeln = 5;               {Maximale Anzahl der Kugeln}
      maxkicker = 3;               {            ... der Kicker}
      maxtunnel = 10;              {            ... der Tunnelein/ausgÑge}
      maxfl = 2; maxfr = 2;        {            ... der Flipper}
const kugelradius = 4;             {Kugelradius}
const zeichnewand: boolean = false;{WÑnde beim Definieren zeichnen?}
      wandfarbe: byte = 1;         {Farben}
      hintergrund: byte = 15;
      ausgabefarbe: byte = 4;
const _oben:real = 0;              {Rand, oben und links immer 0}
      _unten:real = 300;
      _links:real = 0;
      _rechts:real = 300;
      sichabs = 10;                {Abstand zu 2. Ebene}

const blinkperiode = 9;

var linkstask, rechtstask: longint;{Task beim Bewegen der Flipper}

var schleifenende: boolean;

type TKugel = object               {Kugel}
     x,y: real;                    {Ort}
     altx,alty: integer;
     hintergrund: pointer;
     vx,vy: real;                  {Geschwindigkeit}
     nr: byte;
     aktiv: boolean;
     unsichtbar: byte;             {0,2: sichtbar; 1: dauernd unsichtbar;
                                    3: unsichtbar fÅr diesen Schritt;
                                    4: auf anderer Ebene, trotzdem sichtbar}
     procedure einwerfen(xx,yy,vvx,vvy: real);
     procedure entfernen;
     procedure zeichne;
     procedure verstecke(art: byte);
     procedure kollision;
     procedure schwerkraft;
     procedure move;
     procedure schritt;
     end;

     PKugel = ^TKugel;

type TForm = (eckig, rund, bahn, segment {=Bahn, au·en aktiv});
type
     PWand = ^TWand;

     TFlaeche = object
     wand: PWand;
     task: longint;
     korrektur: boolean;
     aktiv: boolean;
     form: TForm;
     x1,y1: real; {links unten (eckig), bzw. Mitte (rund, bahn)}
     x2,y2: real; {links oben (eckig), bzw. Start-,Endwinkel (bahn)}
     r: real; {Breite (eckig), bzw. Radius (rund, bahn)}
     phi: real; {Winkel bei eckig}
     xmin,xmax,ymin,ymax: real; {Vorauswahl}
     exakt: boolean;
     function innen(var x,y: real): boolean;
     end;

     PFlaeche = ^TFlaeche;

     TWand = object
     flaeche: PFlaeche;
     v: real; {Sto·geschw. }
     ny: real; {Reflexion: -1: elastisch ... 0 inelastisch}
     my: real; {Reibung}
     constructor init;
     function getphi(x,y: real): real; virtual; {Tangentenwinkel}
     procedure getv(x,y: real; var vx,vy: real); virtual; {Sto·geschw.}
     procedure kollision(k: PKugel);
     procedure zeichne;
     end;


type PFlipper=^TFlipper;

     TFlipper = object (TWand)
     fu, fk: PFlipper;
     oben: boolean;
     links: boolean;
     xd,yd: real; {Drehpunkt}
     l: real; {LÑnge}
     phimin, phimax: real;
     phi: real;
     omega,omega0: real; {aktuelle, maximale Drehgeschw.}
     altx1,alty1,altx2,alty2: integer;
     tsk: boolean; {aktiviert Taskmanager}
     constructor init;
     function getphi(x,y: real): real; virtual; {Tangentenwinkel}
     procedure getv(x,y: real; var vx,vy: real); virtual; {Sto·geschw.}
     procedure zeichne;
     procedure drehe;
     procedure om;
     procedure reset;
     end;

type TLampe = object
     x,y,r: integer;
     nr: byte;
     farbe: byte;
     an: boolean; {falls blinkend: an o. aus}
     farbe2: byte;{falls blinkend: 2. Farbe}
     procedure init(xx,yy,rr: integer;n,f:byte);
     procedure zeichne;
     procedure setze(f: byte);
     procedure blinkend(f: byte); {initialisiert Blinken}
     end;
     PLampe = ^TLampe;

var waende: array[1 .. 4] of PWand;
{--------------------------------------------------------------------------------------
                   Funktionen und Prozeduren zur
                  DEFINITION VON WéNDEN, FLéCHEN, ...                             }

function waende_aus_datei(name: string; var speicher: array of PWand): integer;
{  Liest die WÑnde aus Datei ein,
   gibt Anzahl der gespeicherten WÑnde bwz. -1 bei Fehler zurÅck}

function inflliste(wand: PWand; form: TForm; x1,y1,x2,y2,r: real):PFlaeche;
{                  Zeiger auf zugehîrige Wand oder nil
                                Form         Koordinaten
   -> Zeiger auf FlÑche
   FÅgt neue FlÑche in Liste ein}

function neuwand(form: TForm; x1,y1,x2,y2,r,v,ny,my: real): PWand;
{                Form         Koordinaten   Sto·geschw., Reflexion, Reibung
   -> Zeiger auf Wand
   FÅgt neue Wand in Liste ein}
procedure vollwand(x1,y1,x2,y2,d, v,ny,my:real);
{                  Koordinaten, Dicke, v,ny,my wie oben
   FÅgt ganze gerade Wand in Liste ein, Zeiger in waende[1..4]}
procedure vollbahn(x,y,r,a,b,d, v,ny,my:real);
{                  Mittelpunkt  v,ny,my wie oben
                       Radius, Dicke
                         Anfang, Ende
   FÅgt ganze gebogene Wand in Liste ein, Zeiger in waende[1..4]}

procedure killwand(w: PWand);
{  Entfernt Wand aus Liste}

procedure kicker(w: PWand; t1: integer; vv: real; versch: PWand; t2: integer);
{  Kennzeichnet Wand als Kicker}

procedure tunnel(w: PWand);
{  Definiert Wand als Tunnelwand}
procedure tunneleingang(w: PWand);
{  Ersetzt Wand durch Tunnelein-/-ausgang
           v>0: Kugel nicht sichtbar, solange im Tunnel
           v<0: Kugel sichtbar, solange im Tunnel}
procedure tunnelnotausgang(w: PWand);
{  Ersetzt Wand durch Tunnelausgang}

procedure neuflipper(x,y,ll,pmin,pmax,o: real; li: boolean; ny,my:real);
{                    Drehpunkt,       Drehgeschw., links?   ny,my wie oben
                         LÑnge, min., max. Winkel
   FÅgt neuen Flipper ein}

procedure wandtask(nr: longint; w: PWand);
{  FÅgt FlÑche einer Wand Aufgabennummer hinzu}

{---------------------------------------------------------------------------------
                        Funktionen und Prozeduren zum
                          INITIALISIEREN / BEENDEN                              }
procedure init(maxx,maxy: real; bild:string);
{  Bereitet Bildschirm vor}
procedure ende;
{  RÑumt Bildschirm auf}
procedure resetkicker(nr: byte);
{  setzt Kicker nr (bei 0 alle) zurÅck}
procedure resetausgabe(zeilen,laenge: integer);

{------------------------------------------------------------------------------------
                       Funktionen und Prozeduren zum
                                WARTEN                                          }
function warte(t: byte; nr: longint; k:PKugel): longint;
{  Ruft nach t/18 s Aufgabe auf (liefert ID zurÅck)}
procedure killzeit(id: longint);
{  Entfernt Zeit aus Warteschlange}
procedure resetzeiten;
{  Entfernt alle Zeiten aus Warteschlange}

{----------------------------------------------------------------------------------
                    Funktionen und Prozeduren zum
                  EINWERFEN / ENTFERNEN VON KUGELN                             }
function kugeleinwurf(x,y,vx,vy: real):PKugel;
{  Wirft neue Kugel an Ort mit Geschw. ein}
procedure entfernen(k:PKugel);
{  Entfernt Kugel}
procedure einschuss(x,y,v, maxv, maxdy: real);
{  Einschuss einer Kugel Åber Steuerung-Taste
   x,y:Ort v: VerhÑltnis Geschw. - Dauer d. Tastendrucks
   maxv: Maximale Geschw.
   maxdy: zieht Kugel nach unten}

procedure neueinschuss(l: PLampe; t, t_blink: integer);
{  Erlaubt Neueinschuss bei Kugelverlust bis Zeit t
   wird bei Lampe l angezeigt, t_blink ist Warnzeit vor Ende}

{-------------------------------------------------------------------------------
                       Prozeduren und Funktionen zur
                                 TEXTAUSGABE                                        }

procedure ausgabe(zeile: integer; s: string);
{  Gibt Text in Zeile aus}
function tostr(z,n: word): string;
{  str(z:n) als Funktion}

{--------------------------------------------------------------------------------
                                  SCHLEIFE                                         }
type TRetSchleife = (normal, return);
                             {"Return the ball"}
function schleife: TRetSchleife;
{  Kugel- und Flipperbewegungen}

{-----------------------------------------------------------------------------------}
type TTaskmng = procedure(nr: longint; k: PKugel);
var taskmng: TTaskmng;


implementation
uses graph, xpicture;

const tunneltask = -3*(maxkugeln+maxkicker+1);
const tunnelnotaus = tunneltask-maxtunnel;
const neuein_task = tunnelnotaus-1;

var kickerliste: array[1 .. maxkicker] of record
                 kicker: PWand;
                 t: integer; {Wartezeit}
                 v: real;
                 verschluss: PWand;
                 t_: integer;
                 timerid: longint;
                 end;
var tunnelphi: array[1..maxtunnel] of PWand;

var neu_lampe: PLampe;
    neu_blinkzeit: integer;
    neu_timer: longint;
    neu_farbeaus: byte;
    neu_moeglich: boolean;

procedure kicker(w: PWand; t1: integer; vv: real; versch: PWand; t2: integer);
var i: byte;
begin
 i:=1;
 while (i<=maxkicker) and (kickerliste[i].kicker<>nil) do inc(i);
 if i>maxkicker then exit;
 versch^.flaeche^.aktiv:=false;
 with kickerliste[i] do begin
      kicker:=w; t:=t1; v:=vv; verschluss:=versch; t_:=t2;
 end;
 wandtask(-3*(i+maxkugeln),w);
end;

procedure resetkicker;
var i: byte;
begin
if nr = 0 then for i:=1 to maxkicker do resetkicker(i)
else with kickerliste[nr] do begin
     wandtask(-3*(nr+maxkugeln),kicker);
     timerid:=-1;
     if verschluss<>nil then begin
        verschluss^.flaeche^.aktiv:=false;
        verschluss^.zeichne;
     end;
end;
end;

procedure taskmanager(nr: longint; k: PKugel);
var kickernr: byte;
    phiv,phi: real;
begin
 if nr>=-maxkugeln then taskmng(nr,k)
 else begin
 if nr>tunneltask then begin
    {Kicker}
    kickernr:= (-nr div 3)-maxkugeln;
    case -nr mod 3 of
    0: begin
         kickerliste[kickernr].kicker^.flaeche^.task:=0;
         kickerliste[kickernr].timerid:=warte(kickerliste[kickernr].t,nr-1,k);
       end;
    1: begin
         kickerliste[kickernr].kicker^.v:=kickerliste[kickernr].v;
         kickerliste[kickernr].timerid:=warte(kickerliste[kickernr].t_,nr-1,k);
       end;
    2: begin
         if kickerliste[kickernr].verschluss<>nil then begin
            kickerliste[kickernr].verschluss^.flaeche^.aktiv:=true;
            kickerliste[kickernr].verschluss^.zeichne;
         end;
         kickerliste[kickernr].kicker^.flaeche^.task:=nr+2;
         kickerliste[kickernr].kicker^.v:=0;
         kickerliste[kickernr].timerid:=-1;
       end;
    end;
 end else begin
    {Tunnel}
    if (nr<=tunneltask) and (nr>tunnelnotaus) then begin
       if k^.x>=_rechts+sichabs then
          phi:=tunnelphi[tunneltask-nr+1]^.getphi(k^.x-_rechts-sichabs,k^.y)
       else
          phi:=tunnelphi[tunneltask-nr+1]^.getphi(k^.x,k^.y);
       if k^.vx=0 then phiv:=pi/2 else phiv:=arctan(-k^.vy/k^.vx);
       if (k^.vx<0) or ((k^.vx=0) and (k^.vy>0)) then phiv:=phiv+pi;
       phi:=sin(phiv+phi);
       if (phi>0) and (k^.x>=_rechts+sichabs) then begin
          k^.x:=k^.x-_rechts-sichabs;
          k^.verstecke(0);
       end;
       if (phi<0) and (k^.x<=_rechts) then begin
          k^.x:=k^.x+_rechts+sichabs;
          if tunnelphi[tunneltask-nr+1]^.v>0 then k^.verstecke(1)
                                             else k^.verstecke(4);
       end;
    end;
    if nr=tunnelnotaus then begin
       k^.x:=k^.x-_rechts-sichabs;
       k^.verstecke(0);
    end;
    if nr=neuein_task then
       if not neu_lampe^.an then begin   {Warnung vor Ende}
          neu_lampe^.an:=true;
          neu_timer:=warte(neu_blinkzeit, neuein_task, nil);
       end else begin
          neu_lampe^.an:=false;
          neu_moeglich:=false;
          if neu_lampe^.farbe<>neu_farbeaus then begin
             neu_lampe^.farbe2:=neu_lampe^.farbe;
             neu_lampe^.setze(neu_farbeaus);
          end;
       end;
 end;
 end;
end;


type pf_list = ^f_list;
     f_list = record
     f: PFlaeche;
     next: pf_list;
     end;
var flaechenliste: pf_list;
var multiball: byte;
var kugelbild: pointer;
    zwischens: pointer;
var imagesizek: word;


procedure TKugel.einwerfen;
begin
inc(multiball);
hintergrund:=nil;
x:=xx; y:=yy; vx:=vvx; vy:=vvy;
aktiv:=true; unsichtbar:=0;
end;

procedure TKugel.entfernen;
begin
dec(multiball);
if hintergrund<>nil then begin
   putimage(altx,alty,hintergrund^,orput);
   freemem(hintergrund, imagesizek); end;
aktiv:=false;
end;

procedure TKugel.verstecke;
begin
 unsichtbar:= art;
 if ((unsichtbar and 1) <> 0) and (hintergrund<>nil) then begin
       putimage(altx,alty,hintergrund^,orput);
       freemem(hintergrund, imagesizek);
       hintergrund:=nil;
 end;
end;

procedure TKugel.zeichne;
var x1,y1,x2,y2,x3,y3,_x,_y,dx,dy: integer;
begin
 if (unsichtbar and 1) <> 0 then begin
    unsichtbar:=(unsichtbar xor (unsichtbar shr 1)) and 3;
    {$IFDEF Spur} putpixel(round(x-_rechts-sichabs),round(y),red);{$ENDIF}
    exit;
 end;
 x1:=altx; y1:=alty; x2:=round(x)-kugelradius; y2:=round(y)-kugelradius;
 if unsichtbar=4 then x2:=round(x-_rechts-sichabs)-kugelradius;
 if x2<0 then x2:=0; if y2<0 then y2:=0;
 if (x1=x2) and (y1=y2) and (hintergrund<>nil) then exit;
 x3:=x1; if x2<x3 then x3:=x2; y3:=y1; if y2<y3 then y3:=y2;
 dx:=x1+x2-2*x3+2*kugelradius; dy:=y1+y2-2*y3+2*kugelradius;
 _x:=x3; _y:=y3;
 if (dx<4*kugelradius) and (dy<4*kugelradius) then begin
    {$IFDEF Trick}
    _x:=480-2*kugelradius; _y:=640-2*kugelradius;
    {$ELSE}
    _x:=640-4*kugelradius; _y:=480-4*kugelradius;
    {$ENDIF}
    getimage(x3,y3,x3+dx,y3+dy,zwischens^);
    putimage(_x,_y,zwischens^,normalput);
 end;
 if hintergrund=nil then getmem(hintergrund, imagesizek)
 else putimage(_x+x1-x3,_y+y1-y3,hintergrund^,orput);
 {$IFDEF Spur} putpixel(_x+x1-x3+kugelradius,_y+y1-y3+kugelradius,red); {$ENDIF}

 getimage(_x+x2-x3,_y+y2-y3,_x+x2-x3+2*kugelradius,_y+y2-y3+2*kugelradius,hintergrund^);
 putimage(_x+x2-x3,_y+y2-y3,kugelbild^,andput);
 if (dx<4*kugelradius) and (dy<4*kugelradius) then begin
    getimage(_x,_y,_x+dx,_y+dy,zwischens^);
    putimage(x3,y3,zwischens^,normalput);
 end;
 altx:=x2; alty:=y2;
end;

procedure TKugel.kollision;
var p: pf_list;
begin
p:=flaechenliste;
while p<>nil do begin
      if p^.f^.aktiv then
      if p^.f^.innen(x,y) then begin
         if p^.f^.wand<>nil then p^.f^.wand^.kollision(PKugel(@self));
         if p^.f^.task<>0 then taskmanager(p^.f^.task,PKugel(@self));
      end;
      p:=p^.next;
end;
end;

procedure TKugel.schwerkraft;
begin
 vy:=vy+delta_T*sinalpha5_7g;
end;

procedure TKugel.move;
begin
 x:=x+delta_T*vx;
 y:=y+delta_T*vy;
end;

procedure TKugel.schritt;
begin
 kollision; if not aktiv then exit;
 schwerkraft;
 move;
 if y<_oben then begin y:=_oben+kugelradius+0.5; if vy<0 then vy:=-0.4*vy; end;
 if x<_links then begin x:=_links+kugelradius+0.5; if vx<0 then vx:=-0.4*vx; end;
 if (x>_rechts) and (x<_rechts+sichabs/2) then
    begin x:=_rechts-kugelradius-0.5; if vx>0 then vx:=-0.4*vx; end;
 if (x>=_rechts+sichabs/2) and (x<_rechts+sichabs) then
    begin x:=_rechts+sichabs+kugelradius+0.5; if vx<0 then vx:=-0.4*vx; end;
 if x>2*_rechts+sichabs then
    begin x:=2*_rechts+sichabs-kugelradius-0.5; if vx>0 then vx:=-0.4*vx; end;
 if y>_unten then begin
    taskmng(-multiball,@self);
    flipper_.entfernen(@self);
    exit;
 end;
 (*zeichne;*)
end;

function TFlaeche.innen;
var s,l,d: real;
var x2_x1,y2_y1,s_l,r_d: real;
var sgn: shortint;
begin
 if (x<xmin) or (x>xmax) or (y<ymin) or (y>ymax) then begin innen:=false; exit; end;
 case form of
 eckig: begin
        if not exakt then begin
           x2_x1:=x2-x1; y2_y1:=y2-y1;
           s:=x2_x1*(x-x1)+y2_y1*(y-y1);
           l:=sqr(x2_x1)+sqr(y2_y1);
           if (s<0) or (s>l) then begin innen:=false; exit; end;
           d:=-((x-x1)*y2_y1-(y-y1)*x2_x1)/sqrt(l);
           if (d<0) or (d>r) then begin innen:=false; exit; end;
        end;
        innen:=true;
        if korrektur then begin
           if exakt then
              if x1=x2 then begin
                 if y2>y1 then sgn:=-1 else sgn:=1;
                 d:=sgn*(x-x1);
              end else begin
                 if x2>x1 then sgn:=1 else sgn:=-1;
                 d:=sgn*(y-y1);
              end;
           if (d>0) and (d<r-0.5) then begin
              if exakt then begin
                 if x1=x2 then
                    x:=r*sgn+x1
                 else
                    y:=r*sgn+y1;
              end else begin
                 r_d:=r/d; s_l:=s/l;
                 x:=r_d*(x-x1)+(1-r_d)*s_l*x2_x1+x1;
                 y:=r_d*(y-y1)+(1-r_d)*s_l*y2_y1+y1;
              end;
           end;
        end;
        end;
 rund: begin
       d:=sqr(x-x1)+sqr(y-y1);
       if d > sqr(r) then begin innen:=false; exit; end
          else innen:=true;
       if korrektur then
          d:=sqrt(d);
          if (d>0) and (d < r-0.5) then begin
             r_d:=r/d;
             x:=r_d*(x-x1)+x1;
             y:=r_d*(y-y1)+y1;
          end;
       end;
 bahn,segment: begin
       l:=sqr(x-x1)+sqr(y-y1);
       if l > sqr(r) then begin innen:=false; exit; end;
       if l < sqr(r-kugelradius-0.5) then begin innen:=false; exit; end;

       if x1=x then s:= pi/2 else s:=arctan((y1-y)/(x-x1));
       if (x1>x) or ((x1=x) and (y>y1)) then s:=s+pi;
       if s<0 then s:=s+2*pi;
       if s<x2 then s:=s+2*pi;
       if s>y2 then begin
          if y2<x2 then s:=s-2*pi;
          if s>y2 then begin innen:=false; exit; end;
       end;
       innen:=true;
       if korrektur then begin
             d:=sqrt(l);
             if (form=segment) and (d < r-0.5) then begin
                x:=r/d*(x-x1)+x1;
                y:=r/d*(y-y1)+y1;
             end;
             if (form=bahn) and (d > r-kugelradius+0.5) then begin
                x:=(r-kugelradius)/d*(x-x1)+x1;
                y:=(r-kugelradius)/d*(y-y1)+y1;
             end;
       end;
       end;
 end;
end;

constructor TWand.init;
begin
end;

function TWand.getphi;
var phi: real;
begin
 with flaeche^ do
 case form of
 eckig: begin
        getphi:=flaeche^.phi;
        end;
 rund,segment: begin
       if y1=y then phi:=pi/2 else phi:=arctan((x-x1)/(y1-y));
       if (y1<y) or ((y1=y) and (x<x1)) then phi:=phi+pi;
       flaeche^.phi:=phi;
       getphi:=phi;
       end;
 bahn: begin
       if y1=y then phi:=pi/2 else phi:=arctan((x-x1)/(y1-y));
       if (y1>y) or ((y1=y) and (x>x1)) then phi:=phi+pi;
       flaeche^.phi:=phi;
       getphi:=phi;
       end;
 end;
end;

procedure TWand.getv;
var phi: real;
begin
 if v<=0.001 then begin vx:=0; vy:=0; end else begin
 phi:=flaeche^.phi;(*getphi(x,y);*)
 vx:=v*sin(phi); vy:=-v*cos(phi); end;
end;

procedure TWand.kollision;
var vx, vy, altvx, altvy: real;
    phiv: real;
    phi,s_2,c_2,sc: extended;
begin
 phi:=getphi(k^.x,k^.y);
 if k^.vx=0 then phiv:=pi/2 else phiv:=arctan(-k^.vy/k^.vx);
 if (k^.vx<0) or ((k^.vx=0) and (k^.vy>0)) then phiv:=phiv+pi;
 if sin(phiv+phi)>0 then exit;
 getv(k^.x,k^.y,vx,vy);
(* if sin(phiv+phi)>-0.01 then begin k^.vx:=k^.vx+vx; k^.vy:=k^.vy+vy; exit; end;*)

 altvx:=k^.vx; altvy:=k^.vy;
 asm
  FLD [phi]                       (* phi *)
  db $CD,$35,$FB {FSINCOS}        (* cos sin *)
  FLD ST(1)                       (* sin cos sin *)
  FMUL ST(0), ST(1)               (* sc  cos sin *)
  FSTP [sc]                       (* cos sin *)
  FMUL ST(0), ST(0)               (* c_2 sin *)
  FSTP [c_2]                      (* sin *)
  FMUL ST(0), ST(0)               (* s_2 *)
  FSTP [s_2]
 end;
 k^.vx:=(1+(ny-1)*s_2+(my-1)*c_2)*altvx
          -(ny-my)*sc*altvy+vx;
 k^.vy:=(1+(ny-1)*c_2+(my-1)*s_2)*altvy
          -(ny-my)*sc*altvx+vy;
end;

procedure TWand.zeichne;
begin
 if not zeichnewand then exit;
 with flaeche^ do begin
 if aktiv then setcolor(wandfarbe) else setcolor(hintergrund);
 case form of
 eckig: begin
        line(round(x1),round(y1),round(x2),round(y2));
        end;
 rund: begin
       circle(round(x1),round(y1),round(r-kugelradius-0.5));
       end;
 bahn: begin
       arc(round(x1),round(y1),round(x2/pi*180),round(y2/pi*180),round(r));
       end;
 segment: begin
       arc(round(x1),round(y1),round(x2/pi*180),round(y2/pi*180),round(r-kugelradius-0.5));
       end;
 end; end;
end;

constructor TFlipper.init;
begin
end;

function TFlipper.getphi;
var phi_: real;
begin
if flaeche^.form=rund then
   with flaeche^ do begin
   if y1=y then phi_:=pi/2 else phi_:=arctan((x-x1)/(y1-y));
   if (y1<y) or ((y1=y) and (x<x1)) then phi_:=phi_+pi;
   getphi:=phi_;
end else
    if links=oben then getphi:=-phi else getphi:=pi-phi;
end;

procedure TFlipper.getv;
var vv: real;
begin
 vv:=sqrt(sqr(x-xd)+sqr(y-yd))*omega(*sin(omega)/cos(omega*);
 vx:=-vv*sin(phi); vy:=-vv*cos(phi);
 omega:=-omega;
end;

procedure TFlipper.zeichne;
begin
 setcolor(hintergrund);
 line(altx1,alty1,altx2,alty2);
 with flaeche^ do
 begin
 altx1:=round(x1); alty1:=round(y1); altx2:=round(x2); alty2:=round(y2);
 setcolor(black); line(altx1,alty1,altx2,alty2);
 end;
end;

procedure TFlipper.drehe;
var x,y: real;
begin
phi:=phi+delta_T*omega;
if phi>=phimax then begin phi:=phimax; omega:=0; end;
if phi<=phimin then begin phi:=phimin; omega:=0; end;
x:=xd+l*cos(phi); y:=yd-l*sin(phi);
with flaeche^ do
     if links then begin x1:=x; y1:=y; end else begin x2:=x; y2:=y; end;
with fu^.flaeche^ do
     if not links then begin x1:=x; y1:=y; end else begin x2:=x; y2:=y; end;
fu^.phi:=phi;
with fk^.flaeche^ do
     begin x1:=x; y1:=y; end;
fk^.phi:=phi;
zeichne;
end;

procedure TFlipper.om;
var plus: boolean;
begin
 if links then
    plus:= (mem[$40:$17] and 2 <> 0)
 else
    plus:= (mem[$40:$17] and 1 = 0);
 if plus and (phi<phimax) then if omega<0 then omega:=0 else omega:=omega0;
 if not plus and (phi>phimin) then if omega>0 then omega:=0 else omega:=-omega0;
 if (linkstask<>0) and tsk and links and plus and (phi=phimin) then taskmanager(linkstask,nil);
 if (rechtstask<>0) and tsk and not links and not plus and (phi=phimax) then taskmanager(rechtstask,nil);
 if omega<>0 then drehe;
end;

procedure TFlipper.reset;
begin
 if links then omega:=(phimin-phi)/delta_T else omega:=(phimax-phi)/delta_T;
 drehe;
end;

procedure TLampe.init;
begin
 x:=xx; y:=yy; r:=rr; nr:=n; setze(f); zeichne;
end;

procedure TLampe.zeichne;
begin
 if nr<>0 then begin setcolor(nr); setfillstyle(solidfill,nr); end
 else begin setcolor(farbe); setfillstyle(solidfill,farbe); end;
 pieslice(x,y,0,360,r);
end;

procedure TLampe.setze;
begin
 farbe:=f;
 if nr<>0 then setpalette(nr,f) else zeichne;
end;

type plampenkette = ^tlampenkette;
     tlampenkette = record
     l: PLampe;
     next: plampenkette;
     end;
var lampenkette: plampenkette;

procedure TLampe.blinkend(f: byte);
var k:PLampenkette;
begin
 new(k); k^.next:=lampenkette; lampenkette:=k;
 k^.l:=PLampe(@self); farbe2:=f; an:=true;
end;


function inflliste(wand: PWand; form: TForm; x1,y1,x2,y2,r: real):PFlaeche;
var f: pf_list;
    phi: real;
    d,dx,dy: real;
begin
 new(f);
 new(f^.f);
 f^.f^.wand:=wand; f^.f^.form:=form; f^.f^.x1:=x1; f^.f^.y1:=y1;
 f^.f^.x2:=x2; f^.f^.y2:=y2; f^.f^.r:=r;
 if form=eckig then begin
    if x1=x2 then phi:= pi/2 else phi:=arctan((y2-y1)/(x2-x1));
    if (x1<x2) or ((x1=x2) and (y1<y2)) then phi:=phi+pi;
    f^.f^.phi:=phi;
 end;

 f^.f^.korrektur:=false; f^.f^.task:=0;
 f^.f^.aktiv:=true;

 f^.f^.exakt:=false;
 with f^.f^ do
 case form of
 eckig: begin
          xmin:=x1; if x2<xmin then xmin:=x2;
          xmax:=x1; if x2>xmax then xmax:=x2;
          ymin:=y1; if y2<ymin then ymin:=y2;
          ymax:=y1; if y2>ymax then ymax:=y2;
          if ((x1=x2) and (y1<y2)) or (x1>x2) then d:=-r else d:=r;
          if x1=x2 then begin
             dx:=d; dy:=0;
          end else begin
             dx:=-d*((y2-y1)/(x2-x1)/sqrt(1+sqr((y2-y1)/(x2-x1))));
             dy:=d/sqrt(1+sqr((y2-y1)/(x2-x1)));
          end;
          if x1+dx<xmin then xmin:=x1+dx; if x2+dx<xmin then xmin:=x2+dx;
          if x1+dx>xmax then xmax:=x1+dx; if x2+dx>xmax then xmax:=x2+dx;
          if y1+dy<ymin then ymin:=y1+dy; if y2+dy<ymin then ymin:=y2+dy;
          if y1+dy>ymax then ymax:=y1+dy; if y2+dy>ymax then ymax:=y2+dy;
          if (x1=x2) or (y1=y2) then exakt:=true;
        end;
 rund: begin
         xmin:=x1-r; xmax:=x1+r; ymin:=y1-r; ymax:=y1+r;
       end;
 bahn: begin
         xmin:=x1-r; xmax:=x1+r; ymin:=y1-r; ymax:=y1+r;
       end;
 segment: begin
         xmin:=x1-r; xmax:=x1+r; ymin:=y1-r; ymax:=y1+r;
          end;
 end;

 inflliste:=f^.f;
 f^.next:=flaechenliste;
 flaechenliste:=f;
end;

function neuwand(form: TForm; x1,y1,x2,y2,r,v,ny,my: real): PWand;
var w:PWand;
begin
new(w,init); neuwand:=w;
if (form=rund) or (form=segment) then r:=r+kugelradius+0.5;
if form=eckig then r:=kugelradius+0.5;
w^.flaeche:=inflliste(w,form,x1,y1,x2,y2,r);
w^.flaeche^.korrektur:=true;
w^.v:=v; w^.ny:=ny; w^.my:=my;
if zeichnewand then w^.zeichne;
end;

procedure vollwand(x1,y1,x2,y2,d, v,ny,my:real);
var dx,dy: real;
begin
 waende[1]:=neuwand(rund, x1,y1,0,0,d/2,v,ny,my);
 if zeichnewand then waende[1]^.zeichne;
 waende[4]:=neuwand(rund, x2,y2,0,0,d/2,v,ny,my);
 if zeichnewand then waende[4]^.zeichne;
 if x1>x2 then d:=-d;
 if (x1=x2) and (y1>y2) then d:=-d;
 if x1=x2 then begin
    dx:=d/2; dy:=0;
 end else begin
    dx:=d/2*((y2-y1)/(x2-x1)/sqrt(1+sqr((y2-y1)/(x2-x1))));
    dy:=d/2/sqrt(1+sqr((y2-y1)/(x2-x1)));
 end;
 waende[2]:=neuwand(eckig, x1-dx,y1+dy,x2-dx,y2+dy,0,v,ny,my);
 if zeichnewand then waende[2]^.zeichne;
 waende[3]:=neuwand(eckig, x2+dx,y2-dy,x1+dx,y1-dy,0,v,ny,my);
 if zeichnewand then waende[3]^.zeichne;
end;

procedure vollbahn(x,y,r,a,b,d, v,ny,my:real);
begin
 waende[2]:=neuwand(bahn,x,y,a,b,r-d/2, v,ny,my);
 if zeichnewand then waende[2]^.zeichne;
 waende[3]:=neuwand(segment,x,y,a,b,r+d/2, v,ny,my);
 if zeichnewand then waende[3]^.zeichne;
 waende[1]:=neuwand(rund,x+r*cos(a),y-r*sin(a),0,0,d/2,v,ny,my);
 if zeichnewand then waende[1]^.zeichne;
 waende[4]:=neuwand(rund,x+r*cos(b),y-r*sin(b),0,0,d/2,v,ny,my);
 if zeichnewand then waende[4]^.zeichne;
end;

procedure killwand(w: PWand);
var f,f_: pf_list;
begin
f:=flaechenliste;
if f^.f^.wand=w then begin
   f_:=f; flaechenliste:=f_^.next;
end else begin
    while f^.next^.f^.wand<>w do f:=f^.next;
    f_:=f^.next;
    f^.next:=f_^.next;
end;
dispose(f_);
dispose(w);
end;

function neuteilflipper(xx,yy,lll,pp,min,max,oo: real; lin,ob: boolean; n,m:real): PFlipper;
var f:PFlipper;
    x1,y1,x2,y2: real;
begin
new(f,init); neuteilflipper:=f;
if lin=ob then begin x2:=xx; y2:=yy; x1:=xx+lll*cos(pp); y1:=yy-lll*sin(pp); end
      else begin x1:=xx; y1:=yy; x2:=xx+lll*cos(pp); y2:=yy-lll*sin(pp); end;
f^.flaeche:=inflliste(f,eckig,x1,y1,x2,y2,kugelradius);
with f^.flaeche^ do begin
 xmin:=xx-lll-kugelradius-0.5; xmax:=xx+lll+kugelradius+0.5;
 ymin:=yy-lll-kugelradius-0.5; ymax:=yy+lll+kugelradius+0.5; exakt:=false;
end;
f^.flaeche^.korrektur:=true;
f^.ny:=n; f^.my:=m;
with f^ do begin
altx1:=round(x1); alty1:=round(y1); altx2:=round(x2); alty2:=round(y2);
xd:=xx; yd:=yy; oben:=ob; links:=lin; l:=lll; phi:=pp;
phimin:=min; phimax:=max; omega:=0; omega0:=oo; end;
end;

var flipperl: array[1 .. maxfl] of PFlipper;
    flipperr: array[1 .. maxfr] of PFlipper;
    fl, fr: byte;

procedure neuflipper(x,y,ll,pmin,pmax,o: real; li: boolean; ny,my:real);
var f: PFlipper;
    p: real;
begin
 if li then inc(fl) else inc(fr);
 if li then p:=pmin else p:=pmax;
 f:=neuteilflipper(x,y,ll,p,pmin,pmax,o,li,true,ny,my);
 f^.fu:=neuteilflipper(x,y,ll,p,pmin,pmax,o,li,false,ny,my);
 f^.fk:=neuteilflipper(x,y,ll,p,pmin,pmax,o,li,not li,ny,my);
 with f^.fk^.flaeche^ do begin form:=rund; r:=1; end;
 if li then flipperl[fl]:=f else flipperr[fr]:=f;
 f^.zeichne;
 if (li and (fl=1)) or (not li and (fr=1)) then f^.tsk:=true else f^.tsk:=false;
end;

procedure wandtask(nr: longint; w: PWand);
begin
w^.flaeche^.task:=nr;
end;

var kugeln: array[1..maxkugeln] of record k: TKugel; benutzt: boolean; end;

function kugeleinwurf(x,y,vx,vy: real):PKugel;
var i: byte;
begin
if multiball=maxkugeln then begin kugeleinwurf:=nil; exit; end;
for i:=1 to maxkugeln do
    if not kugeln[i].benutzt then break;
kugeleinwurf:=@(kugeln[i].k);
kugeln[i].k.einwerfen(x,y,vx,vy);
kugeln[i].benutzt:=true;
kugeln[i].k.nr:=i;
if multiball<>1 then delta_T:=delta_T/(multiball-1)*multiball;
end;

procedure entfernen(k:PKugel);
begin
kugeln[k^.nr].benutzt:=false;
k^.entfernen;
if multiball<>0 then delta_T:=delta_T/(multiball+1)*multiball;
end;

procedure kugelstoss;
var i,j: integer;
    d: real;
    x1,y1,x2,y2: real;
    vs1,vs2,vp1,vp2: real;
begin
for i :=1 to maxkugeln-1 do
    if kugeln[i].benutzt then
    for j:=i+1 to maxkugeln do
        if kugeln[j].benutzt then begin
        d:=sqr(kugeln[i].k.x-kugeln[j].k.x)+sqr(kugeln[i].k.y-kugeln[j].k.y);
        if d<=sqr(2*kugelradius+1) then begin
           d:=sqrt(d);
           x1:=kugeln[i].k.x; x2:=kugeln[j].k.x;
           y1:=kugeln[i].k.y; y2:=kugeln[j].k.y;
           vs1:=-(kugeln[i].k.vx*(x2-x1)+kugeln[i].k.vy*(y1-y2))/d;
           vs2:=-(kugeln[j].k.vx*(x1-x2)+kugeln[j].k.vy*(y2-y1))/d;
           if vs1+vs2>0 then begin
              vp1:=(kugeln[i].k.vx*(y2-y1)+kugeln[i].k.vy*(x2-x1))/d;
              vp2:=(kugeln[j].k.vx*(y1-y2)+kugeln[j].k.vy*(x1-x2))/d;
              kugeln[i].k.vx:=(vs2*(x2-x1)+vp1*(y2-y1))/d;
              kugeln[i].k.vy:=(vs2*(y1-y2)+vp1*(x2-x1))/d;
              kugeln[j].k.vx:=(vs1*(x1-x2)+vp2*(y1-y2))/d;
              kugeln[j].k.vy:=(vs1*(y2-y1)+vp2*(x1-x2))/d;
           end;
           if d<2*kugelradius+0.5 then begin
              x1:=(x1+x2)/2; y1:=(y1+y2)/2;
              d:=(2*kugelradius+1)/d;
              kugeln[i].k.x:=d*(kugeln[i].k.x-x1)+x1;
              kugeln[i].k.y:=d*(kugeln[i].k.y-y1)+y1;
              kugeln[j].k.x:=d*(kugeln[j].k.x-x1)+x1;
              kugeln[j].k.y:=d*(kugeln[j].k.y-y1)+y1;
           end;
        end;
        end;
end;

procedure kugelnbewegen;
var i: integer;
begin
for i:=1 to maxkugeln do if kugeln[i].benutzt then kugeln[i].k.schritt;
if multiball>1 then kugelstoss;
for i:=1 to maxkugeln do if kugeln[i].benutzt then kugeln[i].k.zeichne;
end;

var zeiten: array[1..5] of record
    zeit: longint;
    z_nr: longint;
    z_k: PKugel;
    id: longint;
    end;
zeit_id: longint;
function warte;
var z: longint; i,j: byte;
begin
z:=meml[$40:$6C]+t;
if z=0 then z:=1;
i:=1;
while (i<=5) and (zeiten[i].zeit<>0) do inc(i);
if i=6 then begin warte:=-1; exit; end;
inc(zeit_id); zeit_id:=zeit_id mod 4096;
for j:=i downto 1 do
    if (j>1) and (zeiten[j-1].zeit>=z) then zeiten[j]:=zeiten[j-1] else break;
with zeiten[j] do begin
zeit:=z; z_nr:=nr; z_k:=k; id:=zeit_id;
end;
warte:=zeit_id;
end;

procedure killzeit(id: longint);
var i: byte;
begin
 i:=1;
 while (i<=5) and (zeiten[i].id<>id) do inc(i);
 if i=6 then exit;
 for i:=i to 4 do zeiten[i]:=zeiten[i+1];
 zeiten[5].zeit:=0;
end;

procedure einschuss(x,y,v, maxv, maxdy: real);
var t: longint;
    k: PKugel;
    dy: real;
begin
 k:=kugeleinwurf(x,y, 0, 0);
 if k=nil then exit;
 if automatisch then k^.vy:=-2/3*maxv
 else begin
 k^.zeichne;
 repeat until (mem[$40:$17] and 4) <> 0;
 t:=meml[$40:$6C];
 repeat
   dy:=v*(meml[$40:$6C]-t)/maxv*maxdy;
   if dy>maxdy then dy:=maxdy;
   k^.y:=y+round(dy); k^.zeichne;
 until (mem[$40:$17] and 4) = 0;
 t:=meml[$40:$6C]-t;
 v:=v*t; if v>maxv then v:=maxv;
 k^.vy:=-v;
 end;
end;

function schleife: TRetSchleife;
var zeit: longint absolute $40:$6C;
    i: byte;
    farbe: byte;
    timer, blinkzeit: longint;
    zaehler: longint;
    z_nr: longint; z_k: PKugel;
    l: PLampenkette;

var laus,raus: boolean;
    tl,tr: longint;
procedure automatik;
var an: boolean;
    i: byte;
    a,b,c,d,t,topt: real;
begin
  an:=false;
  for i:=1 to maxkugeln do with kugeln[i] do if benutzt then
      if k.x>flipperl[1]^.xd then begin
         a:=sqr(k.vx)+sqr(k.vy);
         b:=2*(k.x-flipperl[1]^.xd)*k.vx+2*(k.y-flipperl[1]^.yd)*k.vy;
         c:=sqr(k.x-flipperl[1]^.xd)+sqr(k.y-flipperl[1]^.yd)
            -sqr(flipperl[1]^.l+kugelradius);
         d:=sqr(b)-4*a*c;
         if d>=0 then begin
            t:=(-b+sqrt(d))/(2*a);
            if (t>0) and (k.y+t*k.vy<flipperl[1]^.yd)
               and (sqr(k.x-flipperl[1]^.xd)+sqr(k.y-flipperl[1]^.xd)<sqr(flipperl[1]^.l))
               then t:=0;
            if ((not an) or (t<topt)) and (t>=0) then begin
               topt:=t;
               an:=true;
            end;
         end;
      end;
  if an and
     (topt<=1.1*(flipperl[1]^.phimax-flipperl[1]^.phimin)/flipperl[1]^.omega0) then
      mem[$40:$17]:=mem[$40:$17] or 2
     else mem[$40:$17]:=mem[$40:$17] and not 2;

  an:=false;
  for i:=1 to maxkugeln do with kugeln[i] do if benutzt then
      if k.x<flipperr[1]^.xd then begin
         a:=sqr(k.vx)+sqr(k.vy);
         b:=2*(k.x-flipperr[1]^.xd)*k.vx+2*(k.y-flipperr[1]^.yd)*k.vy;
         c:=sqr(k.x-flipperr[1]^.xd)+sqr(k.y-flipperr[1]^.yd)
            -sqr(flipperr[1]^.l+kugelradius);
         d:=sqr(b)-4*a*c;
         if d>=0 then begin
            t:=(-b+sqrt(d))/(2*a);
            if (t>0) and (k.y+t*k.vy<flipperr[1]^.yd)
               and (sqr(k.x-flipperr[1]^.xd)+sqr(k.y-flipperr[1]^.xd)<sqr(flipperr[1]^.l))
               then t:=0;
            if ((not an) or (t<topt)) and (t>=0) then begin
               topt:=t;
               an:=true;
            end;
         end;
      end;
  if an and
     (topt<=1.1*(flipperr[1]^.phimax-flipperr[1]^.phimin)/flipperr[1]^.omega0) then
      mem[$40:$17]:=mem[$40:$17] or 1
     else mem[$40:$17]:=mem[$40:$17] and not 1;
end;

procedure automatik_;
var i: byte;
    li,re: boolean;
    d: real;
begin
  li:=false;
  if not laus then
  for i:=1 to maxkugeln do with kugeln[i] do if benutzt then
      if (k.x>flipperl[1]^.xd) and
         ((k.y>=flipperl[1]^.flaeche^.y1-flipperl[1]^.l/sqrt(2)) or
         ((k.vy>=0)and(k.vy<=1.5*k.vx))) then begin
         d:=sqr(k.x-flipperl[1]^.xd)+sqr(k.y-flipperl[1]^.yd);
         if (d <= sqr(flipperl[1]^.l+1.5*kugelradius)) and
            (d >= sqr(flipperl[1]^.l/2)) then
            li:=true;
      end;
  if (flipperl[1]^.phi=flipperl[1]^.phimax) then begin
     if laus then begin
         li:=true;
         if zeit-tl>6 then li:=false;
     end else begin
         laus:=true;
         tl:=zeit;
         if not li then dec(tl,3);
         li:=true;
     end;
  end;
  if laus and
     (flipperl[1]^.phi=flipperl[1]^.phimin)
     then laus:=false;
  if li then mem[$40:$17]:=mem[$40:$17] or 2
        else mem[$40:$17]:=mem[$40:$17] and not 2;

  re:=false;
  if not raus then
  for i:=1 to maxkugeln do with kugeln[i] do if benutzt then
      if (k.x<flipperr[1]^.xd) and
         ((k.y>=flipperr[1]^.flaeche^.y2-flipperr[1]^.l/sqrt(2)) or
         ((k.vy>=0)and(k.vy<=-1.5*k.vx))) then begin
         d:=sqr(k.x-flipperr[1]^.xd)+sqr(k.y-flipperr[1]^.yd);
         if (d <= sqr(flipperr[1]^.l+1.5*kugelradius)) and
            (d >= sqr(flipperr[1]^.l/2)) then
            re:=true;
      end;
  if (flipperr[1]^.phi=flipperr[1]^.phimin) then begin
     if raus then begin
         re:=true;
         if zeit-tr>6 then re:=false;
     end else begin
         raus:=true;
         tr:=zeit;
         if not re then dec(tr,3);
         re:=true;
     end;
  end;
  if raus and
     (flipperr[1]^.phi=flipperr[1]^.phimax)
     then raus:=false;
  if re then mem[$40:$17]:=mem[$40:$17] or 1
        else mem[$40:$17]:=mem[$40:$17] and not 1;
end;

begin
schleifenende:=false; laus:=false; raus:=false;
timer:=zeit; blinkzeit:=timer+1;
repeat until (zeit<>timer) {and (zeit mod 2 = 0)};
repeat
 timer:=zeit;
 zaehler:=0;
 if timer-blinkzeit>=blinkperiode then begin
    blinkzeit:=blinkzeit+blinkperiode;
    l:=lampenkette;
    while l<>nil do begin
       if l^.l^.an then begin
          farbe:=l^.l^.farbe;
          l^.l^.setze(l^.l^.farbe2);
          l^.l^.farbe2:=farbe;
          inc(zaehler);
       end;
       l:=l^.next;
    end;
 end;
 if zeiten[1].zeit<>0 then if timer>=zeiten[1].zeit then begin
    z_nr:=zeiten[1].z_nr; z_k:=zeiten[1].z_k;
    for i:=2 to 5 do zeiten[i-1]:=zeiten[i];
    zeiten[5].zeit:=0; taskmanager(z_nr,z_k);
    inc(zaehler);
 end;
 repeat
  if automatisch then automatik;
  for i:=1 to fl do flipperl[i]^.om;
  for i:=1 to fr do flipperr[i]^.om;
  kugelnbewegen;
  inc(zaehler);
 until (zeit<>timer) {and (zeit mod 2 = 0)};
 delta_T:=(delta_T+(zeit-timer)*T_18/zaehler)/2;
 {if (mem[$40:$17] and 4 = 4) then delta_T:=delta_T+0.0001;
 if (mem[$40:$17] and 8 = 8) then delta_T:=delta_T-0.0001;}
 if delta_T>0.07 then delta_T:=0.07;
until schleifenende;

for i:=1 to fl do flipperl[i]^.reset;
for i:=1 to fr do flipperr[i]^.reset;
if neu_moeglich then begin
   killzeit(neu_timer);
   neu_lampe^.an:=false;
   neu_moeglich:=false;
   if neu_lampe^.farbe<>neu_farbeaus then begin
      neu_lampe^.farbe2:=neu_lampe^.farbe;
      neu_lampe^.setze(neu_farbeaus);
   end;
   schleife:=return;
end else begin
   for i:=1 to maxkicker do with kickerliste[i] do
       if timerid<>-1 then begin killzeit(timerid); timerid:=-1; end;
   schleife:=normal;
end;
end;

procedure init(maxx,maxy: real; bild:string);
begin
_links:=0; _oben:=0;
_rechts:=maxx; _unten:=maxy;
if bild='' then begin
   setfillstyle(solidfill, white);
   bar(round(_links),round(_oben),round(_rechts),round(_unten));
   zeichnewand:=true;
end else showimage(round(_links),round(_oben),bild);
end;

procedure ende;
begin
readln;
closegraph;
end;

var ausgabelaenge: integer;
    zeilenhoehe: integer;
procedure resetausgabe(zeilen,laenge: integer);
begin
 ausgabelaenge:=laenge;
 zeilenhoehe:=(textheight('|')*3) div 2;
 setfillstyle(solidfill, white);
 bar(round(_rechts)+2,     round(_oben),
     round(_rechts)+laenge,round(_oben)+zeilen*zeilenhoehe);
end;

procedure ausgabe(zeile: integer; s: string);
begin
setfillstyle(solidfill, white);
bar(round(_rechts)+2,round(_oben)+(zeile-1)*zeilenhoehe,
    round(_rechts)+ausgabelaenge,round(_oben)+zeile*zeilenhoehe);
setcolor(ausgabefarbe);
outtextxy(round(_rechts)+3,round(_oben)+2+(zeile-1)*zeilenhoehe,s);
end;

function tostr(z,n: word): string;
var s: string;
begin
 str(z:n,s); tostr:=s;
end;

procedure tunnel;
begin
 w^.flaeche^.xmin:=w^.flaeche^.xmin+_rechts+sichabs;
 w^.flaeche^.xmax:=w^.flaeche^.xmax+_rechts+sichabs;
 w^.flaeche^.x1:=w^.flaeche^.x1+_rechts+sichabs;
 if w^.flaeche^.form=eckig then
    w^.flaeche^.x2:=w^.flaeche^.x2+_rechts+sichabs;
end;

procedure tunneleingang;
var f: PFlaeche;
    nr: byte;
begin
 nr:=1;
 while (nr<=maxtunnel) and (tunnelphi[nr]<>nil) do inc(nr);
 if nr>maxtunnel then exit;
 tunnelphi[nr]:=w;
 w^.flaeche^.task:=tunneltask+1-nr;
 w^.flaeche^.korrektur:=false;
 with w^.flaeche^ do
   f:=inflliste(nil, form, x1,y1,x2,y2,r);
 f^.task:=tunneltask+1-nr;
 tunnel(w);
 w^.flaeche^.wand:=nil;
end;

procedure tunnelnotausgang;
begin
 tunnel(w); wandtask(tunnelnotaus,w); w^.flaeche^.korrektur:=false;
 w^.flaeche^.wand:=nil;
 dispose(w);
end;

procedure neueinschuss(l: PLampe; t, t_blink: integer);
begin
 neu_lampe:=l;
 neu_blinkzeit:=t_blink;
 neu_timer:=warte(t-t_blink,neuein_task,nil);
 neu_farbeaus:=l^.farbe;
 neu_moeglich:=true;
 l^.an:=false;
 l^.setze(l^.farbe2); l^.farbe2:=neu_farbeaus;
end;

function waende_aus_datei(name: string; var speicher: array of PWand): integer;
{Syntax:
#Kommentar
andere Zeilen: Wanddekleration
Typ Koordinaten Daten Optionen

Typ            Koordinaten
ec: eckig      x1 y1 x2 y2
ru: rund       x y r
ba: bahn       x y r start ende
se: segment    x y r start ende
vw: vollwand   x1 y1 x2 y2 d
vb: vollbahn   x y r start ende d

Daten
v ny my

Optionen
Bezeichner, bei vw/vb gefolgt von Nummern, ohne Leerzeichen
k: killwand
s: in speicher
t: tunnel
e: tunneleingang
x: tunnelnotausgang
n: wandtask             z.B. n104; : wandtask(4, w[1]);
m: merken fÅr Kicker

!: Beginn weiterer Daten
ki w t1 v versch t2
   ^      ^: Nummern der WÑnde (Reihenfolge d. m), 0 fÅr nil
fl / fr: Flipper links / rechts
fl x y l pmin pmax o ny my
}
var f: text;
    zeile: string;
    leerpos: byte;
    element: string;
    c: char;
    fehler: integer;
    typ: TForm;
    x1,x2,y1,y2,r,d: real;
    v,ny,my: real;
    nr: integer;
    default,menge: set of 1..4;
    w: byte;
    task: longint;
    kick: array[0..2*maxkicker] of PWand;
    kicknr:  byte;
    weiter: boolean;
    wand,t1,versch,t2: byte;
    links: boolean;

procedure readele;
begin
 leerpos:=pos(' ',zeile);
 element:=copy(zeile, 1, leerpos-1);
 delete(zeile, 1, leerpos); while zeile[1]=' ' do delete(zeile,1,1);
end;
function readreal: real;
var r: real;
begin
 readele;
 val(element, r, fehler);
 readreal:=r;
end;
function readbyte: byte;
var b: byte;
begin
 readele;
 val(element, b, fehler);
 readbyte:=b;
end;

begin
assign(f,name);
{$I-}
 reset(f);
 if IOResult<>0 then begin waende_aus_datei:=-1; exit; end;
{$I+}
 nr:=0; kicknr:=1; weiter:=false; kick[0]:=nil;
 while not (eof(f) or weiter) do begin
  readln(f, zeile);
  if zeile[1]='!' then weiter:=true;
  if not ((zeile[1]='#') or (zeile[1]='!')) then begin
   zeile:=zeile+' ';
   readele;
   c:=upcase(element[1]); if (c='V') and (upcase(element[2])='W') then c:='W';
   case c of
   'E': typ:=eckig;
   'R': typ:=rund;
   'B': typ:=bahn;
   'S': typ:=segment;
   'V','W':;
   else begin waende_aus_datei:=-1; exit; end;
   end;

   x1:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   y1:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;

   if c in ['E','W'] then begin
    x2:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
    y2:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   end else begin
    r:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   end;
   if c in ['B','S','V'] then begin
    x2:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
    y2:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   end;
   if c in ['V','W'] then begin
    d:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   end;
   if c='E' then r:=0;
   if c='R' then begin x2:=0; y2:=0; end;

   v:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   ny:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   my:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;

   if c in ['E','R','B','S'] then waende[1]:=neuwand(typ,x1,y1,x2,y2,r,v,ny,my);
   if c='V' then vollbahn(x1,y1,r,x2,y2,d, v,ny,my);
   if c='W' then vollwand(x1,y1,x2,y2,d, v,ny,my);

   if c in ['V','W'] then default:=[1..4] else begin default:=[1]; waende[1]^.zeichne; end;
   zeile:=zeile+'#';

   while zeile<>'#' do begin
    c:=upcase(zeile[1]); delete(zeile,1,1);
    menge:=[];
    while zeile[1] in ['1'..'4'] do begin
     val(zeile[1], w, fehler); menge:=menge+[w];
     delete(zeile,1,1);
    end;
    if menge=[] then menge:=default;
    case c of
    'K': for w:=1 to 4 do if w in menge then killwand(waende[w]);
    'S': for w:=1 to 4 do if w in menge then begin speicher[nr]:=waende[w]; inc(nr); end;
    'T': for w:=1 to 4 do if w in menge then tunnel(waende[w]);
    'E': for w:=1 to 4 do if w in menge then tunneleingang(waende[w]);
    'X': for w:=1 to 4 do if w in menge then tunnelnotausgang(waende[w]);
    'M': for w:=1 to 4 do if w in menge then begin kick[kicknr]:=waende[w]; inc(kicknr); end;
    'N': begin leerpos:=pos(';',zeile);
               element:=copy(zeile, 1, leerpos-1);
               delete(zeile, 1, leerpos);
               val(element, task, fehler); if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
               for w:=1 to 4 do if w in menge then wandtask(task,waende[w]);
         end;
    end;
   end;
  end;
 end;
 if weiter then
 while not eof(f) do begin
  readln(f, zeile);
  if not (zeile[1]='#') then begin
   zeile:=zeile+' ';

   readele;
   c:=upcase(element[1]); if c='F' then c:=upcase(element[2]);
   if c = 'K' then begin
   wand:=readbyte; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   t1:=readbyte; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   v:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   versch:=readbyte; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
   t2:=readbyte; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;

   kicker(kick[wand],t1,v,kick[versch],t2);
   end;
   if c in ['L','R'] then begin
      links:=(c='L');

      x1:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
      y1:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
      r:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
      x2:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
      y2:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
      d:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
      ny:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;
      my:=readreal; if fehler<>0 then begin waende_aus_datei:=-1; exit; end;

      neuflipper(x1,y1,r,x2,y2,d,links,ny,my);
   end;
  end;
 end;
 close(f);
 waende_aus_datei:=nr;
end;

procedure resetzeiten;
var i: byte;
begin
for i:=1 to 5 do zeiten[i].zeit:=0;
end;

var treiber, modus, fehler: integer;
var i: byte;

begin
neu_moeglich:=false;
multiball:=0; (*noch keine Kugel*)
resetzeiten;
for i:=1 to maxkicker do kickerliste[i].timerid:=-1;
lampenkette:=nil;

treiber := VGA; modus:=VGAHi;
InitGraph(treiber, modus, 'P:\TURBO\GRAPH');
fehler := GraphResult;
if fehler <> grOk then begin
   Writeln('Grafikfehler: ', GraphErrorMsg(fehler), ' (', -fehler, ')');
   readln; halt; end;

setfillstyle(solidfill,white);
bar(0,0,2*kugelradius,2*kugelradius);
setfillstyle(solidfill,black); setcolor(black);
pieslice(kugelradius,kugelradius,0,360,kugelradius);
imagesizek:=imagesize(0,0,2*kugelradius,2*kugelradius);
getmem(kugelbild, imagesizek);
getimage(0,0,2*kugelradius,2*kugelradius,kugelbild^);
getmem(zwischens, imagesize(0,0,4*kugelradius-1,4*kugelradius-1));
end.