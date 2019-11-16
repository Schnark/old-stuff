program klebende_kugeln;
uses graph;
const maxk = 1000;                      {Maximale Kugelanzahl}
type kugel = record
     x,y,r: real;                       {Mittelpunkt und Radius}
     end;
var kugeln: array[1 .. maxk] of kugel;  {Daten aller Kugeln}
    anzahl: integer;                    {Aktuelle Anzahl an Kugeln}
    i: integer;
    treiber,modus: integer;
    anzkugeln, anzstart: integer;
    groesse, abweichung: real;

function zufall(x,s: real): real;
{Zufallszahl}
var r: real;
begin
repeat r:=random; until r <> 0;
zufall := 0.75*s*ln(1/r-1) + x;
end;

function koll(x,y,r, vx,vy: real; var tmin: real):boolean;
{Ermittelt ob und an welcher Position (-> tmin) diese Kugel auf ihrem Weg
 mit einer anderen Kugel zusammenst”át}
var i: integer;
    xx,yy,rr,d,t,s: real;
begin
 tmin := 1.1;
 for i := 1 to anzahl do
 begin
  xx := kugeln[i].x; yy := kugeln[i].y; rr := kugeln[i].r;

  if (vx <> 0) or (vy <> 0) then
     t := (vx*(xx-x)+vy*(yy-y))/(vx*vx+vy*vy)
  else
     t := 0;

  d := sqrt( sqr(xx-(x+t*vx)) + sqr(yy-(y+t*vy)) );

  if d <= rr+r then begin
   s := sqrt( sqr(rr+r) - d*d );

   if (vx*vx+vy*vy) <> 0 then s := s/sqrt( vx*vx + vy*vy ) else s := t;

   if t-s >= 0 then t := t-s else t := t+s;
   if (t>=0) and (t < tmin) then tmin := t;
  end;
 end;
 if tmin>1 then koll := false else koll := true;
end;

procedure zeichne(x,y,r: real; nr: integer);
{Zeichnet die Kugel (Mittelpunkt, Radius, Nummer -> Farbe}
const nr_pro_farb = 10; {Nummern pro Farbe}
var xx,yy: integer;
    rr,f: word;

begin
 f := 1+((nr-1) div nr_pro_farb) mod 14;
 setcolor(f); setfillstyle(solidfill, f);  {Farbe}
 xx := getmaxx div 2 + round(x); yy := getmaxy div 2 - round(y); rr := round(r);
 pieslice(xx,yy,0,360,rr);
end;

procedure setze(anz: integer; x,y,sxy, r,sr: real);
{Erzeugt Startkugel(n); Mittelpunkt und Radius mit zuf„lliger Abweichung}
var i: integer;
    xx,yy,rr: real;
    dummy: real;
begin
 for i := 1 to anz do
 begin
  repeat
   xx := zufall(x,sxy); yy := zufall(y,sxy); rr := zufall(r,sr);
  until not koll(xx,yy,rr, 0,0, dummy)
            and (abs(xx)<getmaxx div 2) and (abs(yy)<getmaxy div 2);
  {Zuf„llige Kugel, die nicht mit anderen zusammenst”át
   und auf dem Bildschirm Platz findet}

  kugeln[i].x := xx; kugeln[i].y := yy; kugeln[i].r := rr;
  anzahl := i;
  zeichne(xx,yy,rr,i);
 end;
end;

procedure start(d,sd, v,sv, r,sr: real; var x,y, vx,vy, rr: real);
{L„sst eine Kugel im Abstand von ca. d vom Ursprung aus auf diesen starten}
var dd, vv: real;
    winkel: real;
    dummy: real;
begin
repeat
 repeat dd := zufall(d,sd); until dd >= 0;
 repeat vv := zufall(v,sv); until vv >= 0;
 repeat rr := zufall(r,sr); until rr >= 0;
 winkel := 2*pi*random;
 {Zuf„lliger Abstand, Geschwindigkeit, Radius, Winkel}
 x := dd*cos(winkel); vx := -v*cos(winkel);
 y := dd*sin(winkel); vy := -v*sin(winkel);
 {Ort (nach dd, winkel) und Geschw. (auf Nullpunkt gerichtet)}
until not koll(x,y,rr,0,0, dummy);
end;

procedure beschl(x,y,sv: real; var vx,vy: real);
{Ver„ndert die Geschwindigkeit zuf„llig}
var v,w,wv: real;
begin
 vx := zufall(vx-x/100,sv);
 vy := zufall(vy-y/100,sv);
 {auf Nullpunkt gerichtet, in der N„he nur kleine "bewusste" Žnderung}
end;

procedure eine_kugel(dx,sd, v,sv, rx,sr:real);
{bewegt eine Kugel bis ans Ziel}
var x,y,vx,vy,r: real;
    d,xx,yy,rr: real;
    tmin: real;
begin
 start(dx,sd, v,sv, rx,sr, x,y,vx,vy,r);   {erzeugt Kugel}

 while not koll(x,y,r, vx,vy, tmin) do begin
  x := x+vx; y := y+vy;
  beschl(x, y, 1, vx, vy);                 {bewegt Kugel}
 end;

 vx := tmin * vx; vy := tmin * vy;
 x := x + vx; y := y + vy;                 {bewegt Kugel nur ein Stck}

 anzahl := anzahl + 1;

 kugeln[anzahl].x := x; kugeln[anzahl].y := y; kugeln[anzahl].r := r;
 zeichne(x,y,r,anzahl);                    {zeichnet Kugel}
end;

begin
 {Werteeingabe}
 write('Anzahl der Kugeln (h”chstens ',maxk,'): '); readln(anzkugeln);
 if anzkugeln > maxk then anzkugeln := maxk;
 write('Anzahl der Startkugeln: '); readln(anzstart);
 write('Durchschnittlicher Radius (ca. 5): '); readln(groesse);
 write('Abweichung vom Radius: '); readln(abweichung);

 randomize;
 treiber := detect;
 initgraph(treiber,modus,'');
 setbkcolor(white); cleardevice;                   {weiáer Hintergrund}

 setze(anzstart, 0,0,20, groesse,abweichung);      {Startkugeln}

 for i := anzahl+1 to anzkugeln do begin
  eine_kugel(400,50, 20,10, groesse,abweichung);   {Kugeln}
 end;

 write(#7);
 readln;
 closegraph;
end.