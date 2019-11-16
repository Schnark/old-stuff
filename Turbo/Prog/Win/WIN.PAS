unit win;
interface
uses graph, events, kevents;

const MAXLEN = 20;                {Beschriftugsl„nge          }
                                  {Farben:                    }
const _AKTIV   = black;           {  aktive Titelleiste       }
      _INAKTIV = darkgray;        {inaktive Titelleiste       }
      _OLA     = white;           {Schatten oben   links auáen}
      _OLI     = darkgray;        {Schatten oben   links innen}
      _URA     = black;           {Schatten unten rechts auáen}
      _URI     = white;           {Schatten unten rechts innen}
      _IURA    = darkgray;        {Schatten}
      _IURI    = lightgray;       {Schatten}
      _HGRND   = lightgray;       {Hintergrund eines Fensters}
      _DSK     = blue;            {Hintergrund des Bildschirms}
      _BUTTON  = lightgray;       {Button}
      _EDIT    = white;           {Eingabefeld}
      _MARK    = blue;            {Markierung}
      _MARKEDTEXT = white;        {Schrift bei Markierung}
      _LABEL   = lightgray;       {Beschriftung}
      _CHECK   = white;           {Checkbox}
      _RADIO   = white;           {Radiobutton}
      _TITEL   = red;             {Titelleiste}
      _TITELIN = lightgray;       {inaktive Titelleiste}
      _HINT    = brown;           {Hint-Farbe}

type SymButtonArt = (sb_leer, sb_X, sb_links,sb_rechts,sb_oben,sb_unten);
const SymButton: array[SymButtonArt] of array[1..8] of byte =
                 ((0,0,0,0,0,0,0,0),
                  (128+64+2+1,64+32+4+2,32+16+8+4,8+16,4+8+16+32,2+4+32+64,1+2+64+128,0),
                  (16,32+16,255-128,255,255-128,32+16,16,0),
                  (8,4+8,255-1,255,255-1,4+8,8,0),
                  (16,32+16+8,64+32+16+8+4,255-1,32+16+8,56,56,56),
                  (56,56,56,56,254,124,56,16));

type einord = (e_z, e_m, e_t);

type TRechteck = record x,y,b,h: integer; end;

type PElement = ^TElement;
     MouseHandler = procedure(s: PElement; e: mouseevent);
     KeyHandler = procedure(s: PElement; e: keyevent);
     OtherHandler = procedure(s: PElement);

     PWindow = ^TWindow;
     TElement = object
     x, y, breite, hoehe: integer;   {Position und Breite}
     inhalt: pchar;                  {Beschriftung}
     hint: pchar;                    {Hinweis}
     showhint: boolean;              {Hinweis anzeigen?}
     aktiv, sichtbar, gewaehlt, gedrueckt: boolean;
     {aktiv (anw„hlbar) / inaktiv (gesperrt)
            sichtbar / unsichtbar
                      gew„hlt (reagiert auf Tastatur)
                                gedrckt (MouseDown)}
     fenster: PWindow;              {Fenster des Elements}
     align: PElement;               {Element, dessen untere rechte Ecke relativ zur u. r. Ecke ist}
     relativ_zu: PElement;          {Objekt, zu dem x, y relativ sind / nil}
     selbst: PElement;              {Zeiger auf sich selbst}

     MouseClickHand: MouseHandler;

     constructor init(r: TRechteck; i: pchar; f: PWindow);
     procedure zeichne;     {zeichnen des Objekts}
     procedure zeichne_(xx,yy:integer); virtual;
     function abs_x: integer; virtual;       {absoluter x-Wert}
     function abs_y: integer; virtual;       {absoluter y-Wert}
     function innen(xx, yy: integer): boolean;  {Punkt innerhalb des Objekts?}
     procedure aendernr(r: TRechteck);
     procedure aendernx(xx: integer);    {„ndern der x-Position  }
     procedure aenderny(yy: integer);    {  "     "  y-Position  }
     procedure aendernb(b: integer); virtual;    {  "     "  Breite      }
     procedure aendernh(h: integer); virtual;    {  "     "  H”he        }
     procedure aenderni(i: pchar);{  "     "  Beschriftung}
     procedure aktivieren(a: boolean);   { (de-)aktivieren}
     procedure zeigen(s: boolean);       { (un-)sichtbar machen}
     procedure grosseAenderung; virtual;
     procedure kleineAenderung; virtual;
     procedure schranke(ein: boolean); virtual; {Zeichenbereich ein-/entschr„nken}
     procedure OnMouseStay(e: mouseevent);  virtual;    {Event-Handler}
     procedure OnMouseStayEnd(e: mouseevent); virtual;   {Event-Handler}
     procedure OnMouseMoveTo(e: mouseevent); virtual;    {Event-Handler}
     procedure OnMouseLeave(e: mouseevent); virtual;
     procedure OnMouseEnter(e: mouseevent); virtual;
     procedure OnMouseDown(e: mouseevent); virtual;      {Event-Handler}
     procedure OnMouseUp(e: mouseevent); virtual;        {Event-Handler}
     procedure OnMouseClick(e: mouseevent); virtual;     {Event-Handler}
     procedure OnMouseDBClick(e: mouseevent); virtual;   {Event-Handler}
     procedure OnMouseDragStart(e: mouseevent); virtual; {Event-Handler}
     procedure OnMouseDragTo(e: mouseevent); virtual;    {Event-Handler}
     procedure OnMouseDragDrop(e: mouseevent); virtual;  {Event-Handler}
     procedure OnMouseDragStop(e: mouseevent); virtual;  {Event-Handler}

     procedure OnKeydown(e: keyevent); virtual;
     procedure OnKeyup(e: keyevent); virtual;
     procedure OnKeyascii(e: keyevent); virtual;
     procedure OnKeyspec(e: keyevent); virtual;

     procedure OnGetFocus; virtual;
     procedure OnLoseFocus; virtual;

     procedure einordnen(art: einord);

     destructor fertig;
     end;

     PObjektschlange = ^Objektschlange;
     objektschlange = record
                      el: PElement;
                      next: PObjektschlange;
                      end;

     TWindow = object(TElement)
     acceptmouse, acceptkey: PObjektschlange; {alle Objekte, die fr Maus /
                                              Tastatur (als Ring) offen sind}
     zeichneschlange: PObjektschlange;
     ueberlappend: boolean; {berlappen sich Elemente des Fensters?}
     min_b, min_h: integer; {kleinste Breite/H”he}
     constructor init(r: TRechteck; i: pchar; var f: PWindow);
     procedure zeichne;
     procedure zeichne_(xx,yy:integer); virtual;
     procedure grosseAenderung; virtual;
     procedure kleineAenderung; virtual;

     procedure OnMouseDown(e: mouseevent); virtual;
     procedure OnMouseUp(e: mouseevent);  virtual;
     procedure OnMouseClick(e: mouseevent); virtual;     {Event-Handler}
     procedure OnMouseDragStart(e: mouseevent); virtual;
     procedure OnMouseDragStop(e: mouseevent);  virtual;

     procedure OnKeydown(e: keyevent); virtual;
     procedure OnKeyup(e: keyevent); virtual;
     procedure OnKeyascii(e: keyevent); virtual;
     procedure OnKeyspec(e: keyevent); virtual;

     procedure OnGetFocus; virtual;
     procedure OnLoseFocus; virtual;

     procedure einordnen_m(p: PElement);
     procedure einordnen_t(p: PElement);
     procedure einordnen_z(p: PElement);
     function finden_m(xx, yy: integer): PElement; {Findet das Objekt bei
                                                    (x,y) (nil fr Fenster)}
     function finden_t: PElement; {Findet das Objekt, das fr Taste offen ist}
     procedure weiter_t(vor: boolean);
     destructor fertig;
     end;

type THintergrund = object(TElement)
     benutzter_ende: boolean;           {Benutzter will beenden}
     farbe: word;
     constructor init(f: word);
     procedure zeichne;
     procedure zeichne_(xx,yy:integer); virtual;

     procedure OnMouseDown(e: mouseevent);      virtual;
     procedure OnMouseUp(e: mouseevent);        virtual;
     procedure OnMouseDragStart(e: mouseevent); virtual;
     procedure OnMouseDragTo(e: mouseevent); virtual;

     procedure OnKeydown(e: keyevent); virtual;
     procedure OnKeyup(e: keyevent); virtual;
     procedure OnKeyascii(e: keyevent); virtual;
     procedure OnKeyspec(e: keyevent); virtual;

     destructor fertig;
     end;

type TButton = object(TElement)
     constructor init(r: TRechteck; i: pchar; f: PWindow);
     procedure zeichne_(xx,yy:integer); virtual;
     end;

type TSymButton = object(TButton)
     symbol: array[1..8] of byte;
     constructor init(r: TRechteck; art: SymButtonArt; f: PWindow);
     procedure zeichne_(xx,yy:integer); virtual;
     end;

type TEdit = object(TElement)
     cursorpos, markend: word; {markend=cursorpos -> keine Markierung}
     { T e x t
      0 1 2 3 4}
     start: word;
     mausmark: boolean;
     constructor init(r: TRechteck; i: pchar; f: PWindow);
     procedure zeichnecursor(onoff: boolean); virtual;
     procedure zeichne_(xx,yy:integer); virtual;
     procedure OnMouseDown(e: mouseevent); virtual;      {Event-Handler}
     procedure OnMouseDBClick(e: mouseevent); virtual;
     procedure OnMouseDragStart(e: mouseevent); virtual; {Event-Handler}
     procedure OnMouseDragTo(e: mouseevent); virtual;
     procedure OnMouseDragDrop(e: mouseevent); virtual;  {Event-Handler}

     procedure OnKeySpec(e: keyevent); virtual;
     procedure OnKeyASCII(e: keyevent); virtual;

     procedure OnGetFocus; virtual;
     procedure OnLoseFocus; virtual;
     end;

type TLabel = object(TElement)
     constructor init(r: TRechteck; i: pchar; f: PWindow);
     procedure zeichne_(xx,yy:integer); virtual;
     end;

type TCheck = object(TElement)
     checked: boolean;
     constructor init(r: TRechteck; i: pchar; f: PWindow);
     procedure zeichne_(xx,yy:integer); virtual;
     procedure OnMouseClick(e: mouseevent); virtual;     {Event-Handler}
     procedure aendernc(c:boolean);
     end;

type PRadio = ^TRadio;
     TRadio = object(TCheck)
     naechster: PRadio;
     constructor init(r: TRechteck; i: pchar; f: PWindow);
     procedure zeichne_(xx,yy:integer); virtual;
     procedure OnMouseClick(e: mouseevent); virtual;     {Event-Handler}
     end;

type TFrame = object(TElement)
     constructor init(r: TRechteck; i: pchar; f: PWindow);
     procedure zeichne_(xx,yy:integer); virtual;
     end;

type T3D = object(TElement)
     tief: boolean;
     constructor init(r: TRechteck; t: boolean; f: PWindow);
     procedure zeichne_(xx,yy:integer); virtual;
     end;


type PScrollBar = ^TScrollBar;
     TPos = record
      position: integer;
      min, max: integer;
      d_klein, d_gross: integer;
     end;

     TScrollButton = object(TSymButton)
      groesser: boolean;
      sb: PScrollBar;
      procedure OnMouseClick(e: mouseevent); virtual;
     end;
     PScrollButton = ^TScrollButton;

     TScrollLeiste = object(T3D)
      groesser: boolean;
      sb: PScrollBar;
      procedure OnMouseClick(e: mouseevent); virtual;
     end;
     PScrollLeiste = ^TScrollLeiste;

     TScrollSchieber = object(T3D)
      sb: PScrollBar;
      procedure OnMouseDragStart(e: mouseevent); virtual;
      procedure OnMouseDragTo(e: mouseevent); virtual;
      procedure OnMouseDragDrop(e: mouseevent); virtual;
     end;
     PScrollSchieber = ^TScrollSchieber;

     TScrollBar = object(TElement)
      ausrichtung: boolean; {true: waagerecht}
      ochandle: boolean; {aendernp -> OnChange}
      p: TPos;
      sb1, sb2: PScrollButton;
      sl1, sl2: PScrollLeiste;
      ss: PScrollSchieber;
      bezug: PElement;

      OnChangeHand: OtherHandler;

      constructor init(r: TRechteck; a: boolean; pp: TPos; f: PWindow);
      procedure aendernb(b: integer); virtual;    {  "     "  Breite      }
      procedure aendernh(h: integer); virtual;    {  "     "  H”he        }
      procedure aktivieren(a: boolean);   { (de-)aktivieren}
      procedure zeigen(s: boolean);       { (un-)sichtbar machen}
      procedure aendernp(pp: TPos);

      procedure einordnen(art: einord);

      destructor fertig;
     end;


type TRelativ = object(TElement)
                echte_breite, echte_hoehe: integer;
                x_start, y_start: integer;
                constructor init(r: TRechteck; f: PWindow);
                procedure aendernxs(xs: integer);
                procedure aendernys(ys: integer);
                procedure aendernb(b: integer); virtual;    {  "     "  Breite      }
                procedure aendernh(h: integer); virtual;    {  "     "  H”he        }
                function abs_x: integer; virtual;       {absoluter x-Wert}
                function abs_y: integer; virtual;       {absoluter y-Wert}
                procedure schranke(ein: boolean); virtual;
                procedure grosseAenderung; virtual;
                end;
     PRelativ = ^TRelativ;

type TScrollfeld = object(TRelativ)
                   sb1, sb2: PScrollBar;
                   noetig1, noetig2: boolean;
                   constructor init(r: TRechteck; eb,eh: integer; f: PWindow);
                   procedure noetig(var b, h: integer);
                   procedure aendernx(xx: integer);    {„ndern der x-Position  }
                   procedure aenderny(yy: integer);    {  "     "  y-Position  }
                   procedure aendernb(b: integer); virtual;    {  "     "  Breite      }
                   procedure aendernh(h: integer); virtual;    {  "     "  H”he        }
                   procedure einordnen(art: einord);
                   destructor fertig;
                   end;
     PScrollFeld = ^TScrollfeld;


procedure ausg(ein: boolean);
procedure zeichne3D(x,y,b,h: integer; farbe: byte; tief: boolean);


implementation
uses graph2, maus, winverw, strings, bereiche;
var ausgabe: shortint;


procedure ausg(ein: boolean);
begin
 if ein then inc(ausgabe) else dec(ausgabe);
end;

procedure TScrollFeldChangeX(s: PElement); far;
begin
 PScrollFeld(PScrollBar(s)^.bezug)^.aendernxs(PScrollBar(s)^.p.position);
end;

procedure TScrollFeldChangeY(s: PElement); far;
begin
 PScrollFeld(PScrollBar(s)^.bezug)^.aendernys(PScrollBar(s)^.p.position);
end;


{$I WIN_ELE.INC}
{$I WIN_EVNT.INC}
{$I WIN_DRAW.INC}
{$I WIN_INIT.INC}

procedure THintergrund.zeichne;
var d: PDiaver;
begin
 if not (sichtbar and (ausgabe>=0)) then exit;
 mausoff;
 schranke(true);
 zeichne_(0,0);
 schranke(false);

 d:=getunten;
 if d<>nil then d^.dia^.zeichne;

 mauson;
end;

destructor THintergrund.fertig;
begin
 mausoff;
 closegraph;
 TElement.fertig;
end;

procedure TCheck.aendernc;
begin
 checked := c;
 kleineAenderung;
end;

procedure TScrollBar.aendernp;
var l,l1,l2,lges: integer;
begin
 if ausrichtung then lges:=breite-sb1^.breite-sb2^.breite
  else lges:=hoehe-sb1^.hoehe-sb2^.hoehe;
 l:= round(lges * (pp.d_gross/(pp.max-pp.min+pp.d_gross)));
 if l<4 then l:=4; if l>lges then l:=lges;
 if pp.min = pp.max then l1:=0
    else l1:= round( (pp.position-pp.min)/(pp.max-pp.min) * (lges-l));
 l2:= lges-l-l1;

 if ausrichtung then begin                    {obere/rechte Leiste}
    sl1^.breite:=l1; end
 else
    sl1^.hoehe:=l1;

                                              {Schieber}
 if ausrichtung then ss^.x:=sb1^.breite+l1 else ss^.y:=sb1^.hoehe+l1;
 if ausrichtung then ss^.breite:=l else ss^.hoehe:=l;

 if ausrichtung then begin                    {untere/linke Leiste}
    sl2^.x:=ss^.x+l;
    sl2^.breite:=l2; end
 else begin
    sl2^.y:=ss^.y+l;
    sl2^.hoehe:=l2; end;


 with p do begin
      position:=pp.position;
      min:=pp.min; max:=pp.max;
      d_gross:=pp.d_gross; d_klein:=pp.d_klein; end;

 grosseAenderung;
 if ochandle then if @OnChangeHand<>nil then OnChangeHand(selbst);
end;

procedure TScrollBar.aendernb(b: integer);
begin
if ausrichtung then begin
   sb2^.x:=sb2^.x+b-breite;
   b:=b-sb1^.breite-sb2^.breite;
   breite:=breite-sb1^.breite-sb2^.breite;
   sl1^.breite:=round(sl1^.breite/breite*b);
   sl2^.breite:=round(sl2^.breite/breite*b);
   ss^.breite:=b-sl1^.breite-sl2^.breite;
   ss^.x:=sl1^.x+sl1^.breite; sl2^.x:=ss^.x+ss^.breite;
   inherited aendernb(b+sb1^.breite+sb2^.breite);
end else begin
   ss^.breite:=b;
   sb1^.breite:=b;
   sb2^.breite:=b;
   sl1^.breite:=b;
   sl2^.breite:=b;
   inherited aendernb(b);
end;
end;

procedure TScrollBar.aendernh(h: integer);
begin
if ausrichtung then begin
   ss^.hoehe:=h;
   sb1^.hoehe:=h;
   sb2^.hoehe:=h;
   sl1^.hoehe:=h;
   sl2^.hoehe:=h;
   inherited aendernh(h);
end else begin
   sb2^.y:=sb2^.y+h-hoehe;
   h:=h-sb1^.hoehe-sb2^.hoehe;
   hoehe:=hoehe-sb1^.hoehe-sb2^.hoehe;
   sl1^.hoehe:=round(sl1^.hoehe/hoehe*h);
   sl2^.hoehe:=round(sl2^.hoehe/hoehe*h);
   ss^.hoehe:=h-sl1^.hoehe-sl2^.hoehe;
   ss^.y:=sl1^.y+sl1^.hoehe; sl2^.y:=ss^.y+ss^.hoehe;
   inherited aendernh(h+sb1^.hoehe+sb2^.hoehe);
end;
end;

procedure TScrollBar.aktivieren(a: boolean);
begin
 ss^.aktiv:=a;
 sb1^.aktiv:=a;
 sl1^.aktiv:=a;
 sl2^.aktiv:=a;
 sb2^.aktiv:=a;
 inherited aktivieren(a);
end;

procedure TScrollBar.zeigen(s: boolean);
begin
 ss^.sichtbar:=s;
 sb1^.sichtbar:=s;
 sl1^.sichtbar:=s;
 sl2^.sichtbar:=s;
 sb2^.sichtbar:=s;
 inherited zeigen(s);
end;

procedure TScrollBar.einordnen(art: einord);
begin
 if (art=e_z) or (art=e_m) then begin
    ss^.einordnen(art);
    sb1^.einordnen(art); sb2^.einordnen(art);
    sl1^.einordnen(art); sl2^.einordnen(art);
 end else
 inherited einordnen(art);
end;

destructor TScrollBar.fertig;
begin
 ss^.fertig;
 sl2^.fertig;
 sl1^.fertig;
 sb2^.fertig;
 sb1^.fertig;
 inherited fertig;
end;

procedure TRelativ.aendernxs;
begin
x_start:=xs;
grosseAenderung;
end;

procedure TRelativ.aendernys;
begin
y_start:=ys;
grosseAenderung;
end;

function TRelativ.abs_x;
begin
 if relativ_zu=nil then abs_x:=x-x_start else abs_x:=x-x_start+relativ_zu^.abs_x;
end;

function TRelativ.abs_y;
begin
 if relativ_zu=nil then abs_y:=y-y_start else abs_y:=y-y_start+relativ_zu^.abs_y;
end;

procedure TRelativ.aendernb;
begin
 if x_start+b>echte_breite then
    if echte_breite-b>=0 then aendernxs(echte_breite-b) else aendernxs(0);
 inherited aendernb(b);
end;

procedure TRelativ.aendernh;
begin
 if y_start+h>echte_hoehe then
    if echte_hoehe-h>=0 then aendernys(echte_hoehe-h) else aendernys(0);
 inherited aendernh(h);
end;

procedure TRelativ.schranke;
begin
 if relativ_zu<>nil then relativ_zu^.schranke(ein);
 if ein then einschraenken(inherited abs_x,inherited abs_y,inherited abs_x+breite,inherited abs_y+hoehe) else entschraenken;
end;

procedure TRelativ.grosseAenderung; begin fenster^.kleineAenderung; end;

procedure TScrollFeld.noetig;
begin
 noetig1:=false; noetig2:=false;
 if echte_breite>b then begin noetig1:=true; h:=h-sb1^.hoehe; end;
 if echte_hoehe>h then begin noetig2:=true; b:=b-sb2^.breite; end;
 if not noetig1 and (echte_breite>b) then begin noetig1:=true; h:=h-sb1^.hoehe; end;
 if not noetig2 and (echte_hoehe>h) then begin noetig2:=true; b:=b-sb2^.breite; end;
end;

procedure TScrollFeld.aendernx;
begin
 sb1^.aendernx(xx);
 sb2^.aendernx(xx+breite);
 inherited aendernx(xx);
end;

procedure TScrollFeld.aenderny;
begin
 sb1^.aenderny(yy+hoehe);
 sb2^.aenderny(yy);
 inherited aenderny(yy);
end;

procedure TScrollFeld.aendernb;
var h: integer;
    p: TPos;
begin
 if sb2^.sichtbar then b:=b+sb2^.breite; {da nicht ganze alte Breite sichtbar}
 h:=hoehe; if sb1^.sichtbar then h:=h+sb1^.hoehe;
 noetig(b,h);
 sb1^.zeigen(noetig1); sb2^.zeigen(noetig2);
 if not noetig1 then sb1^.p.position:=0; if not noetig2 then sb2^.p.position:=0;
 inherited aendernb(b); inherited aendernh(h);
 sb1^.aenderny(y+h); sb2^.aendernx(x+b);
 sb1^.aendernb(b); sb2^.aendernh(h);
 sb1^.ochandle:=false; sb2^.ochandle:=false;
 p:=sb1^.p; p.max:=echte_breite-breite; p.d_gross:=breite; sb1^.aendernp(p);
 p:=sb2^.p; p.max:=echte_hoehe-hoehe; p.d_gross:=hoehe; sb2^.aendernp(p);
 sb1^.ochandle:=true; sb2^.ochandle:=true;
end;

procedure TScrollFeld.aendernh;
var b: integer;
    p: TPos;
begin
 if sb1^.sichtbar then h:=h+sb1^.hoehe; {da nicht ganze alte H”he sichtbar}
 b:=breite; if sb2^.sichtbar then b:=b+sb2^.breite;
 noetig(b,h);
 sb1^.zeigen(noetig1); sb2^.zeigen(noetig2);
 if not noetig1 then sb1^.p.position:=0; if not noetig2 then sb2^.p.position:=0;
 inherited aendernb(b); inherited aendernh(h);
 sb1^.aenderny(y+h); sb2^.aendernx(x+b);
 sb1^.aendernb(b); sb2^.aendernh(h);
 sb1^.ochandle:=false; sb2^.ochandle:=false;
 p:=sb1^.p; p.max:=echte_breite-breite; p.d_gross:=breite; sb1^.aendernp(p);
 p:=sb2^.p; p.max:=echte_hoehe-hoehe; p.d_gross:=hoehe; sb2^.aendernp(p);
 sb1^.ochandle:=true; sb2^.ochandle:=true;
end;

procedure TScrollFeld.einordnen(art: einord);
begin
 if (art=e_z) or (art=e_m) then begin
    sb1^.einordnen(art); sb2^.einordnen(art);
 end;
 inherited einordnen(art);
end;

destructor TScrollFeld.fertig;
begin
 sb1^.fertig; sb2^.fertig;
 inherited fertig;
end;

procedure TWindow.zeichne;
var d: PDiaver;
    vp: viewporttype;
begin
 if not (sichtbar and (ausgabe>=0)) then exit;
 mausoff;
 schranke(true);
 getviewsettings(vp);
 zeichne_(abs_x-vp.x1,abs_y-vp.y1);
 schranke(false);

 d:=finden_verw(fenster);
 if (d<>nil) and (d^.hoeher<>nil) then d^.hoeher^.dia^.zeichne;

 mauson;
end;

procedure TWindow.grosseAenderung;
begin
 gethintergrund^.zeichne;
end;
procedure TWindow.kleineAenderung;
begin
 zeichne;
end;

procedure TWindow.einordnen_z;
var os: PObjektschlange;
begin
 new(os);
 os^.el:=p;
 os^.next:=zeichneschlange;
 zeichneschlange:=os;
end;

procedure TWindow.einordnen_m;
var os: PObjektschlange;
begin
 new(os);
 os^.el:=p;
 os^.next:=acceptmouse;
 acceptmouse:=os;
end;

procedure TWindow.einordnen_t;
var osneu, os1, os2: PObjektschlange;
begin
 new(osneu);
 osneu^.el:=p;
 if acceptkey=nil then begin
    osneu^.next:=osneu;
    acceptkey:=osneu;
    p^.gewaehlt:=true;
    exit;
 end;
 os1:=acceptkey^.next; os2:=acceptkey;
 while os1<>acceptkey do begin
       os1:=os1^.next;
       os2:=os2^.next;
 end;
 os2^.next:=osneu;
 osneu^.next:=acceptkey;
end;

function TWindow.finden_m;
var p: Pobjektschlange;
begin
 p:=acceptmouse;
 while p<>nil do begin
       if p^.el^.innen(xx,yy) then begin
          finden_m:=p^.el;
          exit;
       end;
       p:=p^.next;
 end;
 finden_m:=nil;
end;

function TWindow.finden_t;
begin
 if acceptkey<>nil then finden_t:=acceptkey^.el else finden_t:=nil;
end;

procedure TWindow.weiter_t;
var alt, os: PObjektschlange;
begin
 acceptkey^.el^.gewaehlt:=false; acceptkey^.el^.zeichne;
 alt:=acceptkey;
 if vor then
    repeat acceptkey:=acceptkey^.next; until
                                    acceptkey^.el^.aktiv or (acceptkey=alt)
 else begin
    repeat
      os:=acceptkey;
      while os^.next<>acceptkey do os:=os^.next;
      acceptkey:=os;
    until acceptkey^.el^.aktiv or (acceptkey=alt);
 end;
 acceptkey^.el^.gewaehlt:=true;
 acceptkey^.el^.zeichne;
end;

destructor TWindow.fertig;
var alt: PObjektschlange;
begin
 while acceptmouse<>nil do begin
       alt:=acceptmouse;
       acceptmouse:=acceptmouse^.next;
       dispose(alt);
 end;
 while zeichneschlange<>nil do begin
       alt:=zeichneschlange;
       zeichneschlange:=zeichneschlange^.next;
       dispose(alt);
 end;
 alt:=acceptkey;
 while alt^.next<>acceptkey do alt:=alt^.next;
 alt^.next:=nil;
 while acceptkey<>nil do begin
       alt:=acceptkey;
       acceptkey:=acceptkey^.next;
       dispose(alt);
 end;
 TElement.fertig;
end;

begin

ausgabe := 0;
c_onoff:=false;
end.