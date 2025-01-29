program museum_mit_waechter;
uses graph, graph2;
const Dwinkel=0.01;
      Dstrecke=1;
const wandfarbe=white;
      sehfarbe=blue;
      wegfarbe=red;
type museumsplan = text;
type Polygon = record
               anzahl: 3..100;
               ecken: array[1..100] of record
                                       x, y: real;
                                       end;
               end;
type museum = record
              umriss: Polygon;
              anzahl: 0..50;
              loecher: array[1..50] of Polygon;
              end;
    Zmuseum = ^museum;

type streckung = record
                 minx, miny, sx, sy: real;
                 end;

var sintab, costab: array[0..628] of real;

procedure tab;
var n: integer;
begin
for n:=0 to 628 do begin
    sintab[n]:=sin(n/100); costab[n]:=cos(n/100);
end;
end;

procedure koord(x,y: real; s: streckung; var xx, yy: integer);
begin
 xx:=5+round((x-s.minx)*s.sx);
 yy:=-5+getmaxy-round((y-s.miny)*s.sy);
end;


procedure lesePolygon(var d: museumsplan; var p: Polygon);
var zeile, zeile1, zeile2: string;
    position: byte;
    fehler: integer;
    i: byte;
begin
 repeat readln(d, zeile) until zeile<>'';
 position:=pos('olygon',zeile);
 if position=0 then begin write('Fehler: ',zeile); halt; end;
 zeile1:=copy(zeile, position+6, 255);
 val(zeile1, p.anzahl, fehler);
 if fehler<>0 then begin write('Fehler: ',zeile); halt; end;
 for i:=1 to p.anzahl do begin
     readln(d, zeile);
     position:=pos(' ',zeile);
     if position=0 then begin write('Fehler: ',zeile); halt; end;
     zeile1:=copy(zeile, 1, position-1); zeile2:=copy(zeile, position+1, 255);
     val(zeile1, p.ecken[i].x, fehler);
     if fehler<>0 then begin write('Fehler: ',zeile); halt; end;
     val(zeile2, p.ecken[i].y, fehler);
     if fehler<>0 then begin write('Fehler: ',zeile); halt; end;
 end;
end;

procedure leseMuseum(datei: string; m: Zmuseum);
var d: museumsplan;
begin
 assign(d, datei);
 reset(d);
 lesePolygon(d, m^.umriss);
 m^.anzahl:=0;
 while not eof(d) do begin
       inc(m^.anzahl);
       lesePolygon(d, m^.loecher[m^.anzahl]);
 end;
 close(d);
end;

procedure leseNachtwaechter(datei: string; var n: Polygon);
var d: museumsplan;
begin
 assign(d, datei);
 reset(d);
 lesePolygon(d, n);
 close(d);
end;

procedure zeichnePolygon(p: Polygon; var s: streckung);
var maxx,maxy: real;
    x,y: integer;
    i: byte;
begin
 with s do begin
 if sx=0 then begin
    maxx:=p.ecken[1].x; minx:=maxx;
    maxy:=p.ecken[1].y; miny:=maxy;
    for i:=2 to p.anzahl do begin
        with p.ecken[i] do begin
             if x>maxx then maxx:=x;
             if x<minx then minx:=x;
             if y>maxy then maxy:=y;
             if y<miny then miny:=y;
        end;
    end;
    sx:=(getmaxx-10)/(maxx-minx); sy:=(getmaxy-10)/(maxy-miny);
 end;

 koord(p.ecken[p.anzahl].x,p.ecken[p.anzahl].y,s,x,y);
 moveto(x,y);
 for i:=1 to p.anzahl do begin
     koord(p.ecken[i].x,p.ecken[i].y,s,x,y);
     lineto(x,y);
     end;
 end;
end;

procedure zeichneMuseum(m: Zmuseum; var s: streckung);
var i: byte;
begin
 s.sx:=0;
 setcolor(wandfarbe);
 setlinestyle(solidln,0,thickwidth);
 zeichnePolygon(m^.umriss, s);
 for i:=1 to m^.anzahl do zeichnePolygon(m^.loecher[i], s);
 setlinestyle(solidln,0,normwidth);
end;

procedure zeichneSicht(x,y: integer);
var dx,dy: real;
    winkel: real;
    xx,yy: integer;
    n: integer;
begin
 winkel:=0;
 repeat
    dx:=costab[round(100*winkel)]; dy:=sintab[round(100*winkel)];
    n:=1;
    repeat
       xx:=round(x+n*dx); yy:=round(y+n*dy);
       inc(n)
    until getpixel(xx,yy)=wandfarbe;
    dec(n,2); line(x,y, round(x+n*dx), round(y+n*dy));
    winkel:=winkel+Dwinkel;
 until winkel>2*pi;
end;

procedure zeichneSichtStrecke(x1,y1, x2,y2: integer);
var x,y: integer;
    dx,dy, d: real;
    n, nmax: integer;
begin
 dx:=x2-x1; dy:=y2-y1; {d:=sqrt(sqr(dx)+sqr(dy));
 nmax:=round(d/Dstrecke); if nmax=0 then nmax:=1;}nmax:=10;
 dx:=dx/nmax; dy:=dy/nmax;
 for n:=0 to nmax do begin
     x:=round(x1+n*dx); y:=round(y1+n*dy);
     zeichneSicht(x,y);
 end;
end;

procedure zeichneSichtWeg(n: polygon; s: streckung);
var x1,x2,y1,y2: integer;
    i: byte;
begin
 setcolor(sehfarbe);
 koord(n.ecken[n.anzahl].x,n.ecken[n.anzahl].y,s,x1,y1);
 koord(n.ecken[1].x,n.ecken[1].y,s,x2,y2);
 zeichneSichtStrecke(x1,y1,x2,y2);
 for i:=1 to n.anzahl-1 do begin
     koord(n.ecken[i].x,n.ecken[i].y,s,x1,y1);
     koord(n.ecken[i+1].x,n.ecken[i+1].y,s,x2,y2);
     zeichneSichtStrecke(x1,y1,x2,y2);
 end;
end;

var mzeiger: Zmuseum;
    nachtwaechter: polygon;
    s: streckung;


begin
tab;
new(mzeiger);
leseMuseum('C:\TURBO\PROGRAMME\BWINF062\MUSEUM01.TXT',mzeiger);
leseNachtwaechter('C:\TURBO\PROGRAMME\BWINF062\NW0105.TXT',nachtwaechter);
init;
zeichneMuseum(mzeiger,s);
zeichneSichtWeg(nachtwaechter,s);
setcolor(wegfarbe); setlinestyle(solidln, 0, thickwidth);
zeichnePolygon(nachtwaechter,s);
readln;
closegraph;
end.