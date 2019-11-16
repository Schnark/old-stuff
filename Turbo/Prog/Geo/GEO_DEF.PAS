unit geo_def;

interface

type namenstr = string[3];

type Tkoordsys = record
     xmin, ymin, xmax, ymax: real;
     achsen: boolean;
     hgrund, afarbe: byte;
     pfarbe, gfarbe, kfarbe: byte;
     statfarbe: byte;
     end;
var koordsys: Tkoordsys;

type objekt = object
     name: namenstr;
     sichtbar: boolean;
     definiert: boolean;
     aenderung: byte;
     constructor init;
     procedure aktualisiere; virtual;
     procedure ausgabe; virtual;
     procedure zeichne; virtual;
     function koordin(xk,yk:integer; eps:real):boolean; virtual;
     destructor fertig;
     end;
type pobjekt = ^objekt;

type punkt_k = (ko, gg, gk, kk, ms, mk);
               {Koordiaten, Kreis-Kreis
                    Gerade-Gerade,  Mittelpunkt Kreis
                        Gerade-Kreis
                                Mitte 2 Punkte}
type gerade_k = (p2, pa, pp, sp, tp, wh, ww);
                {2 Punkte,   Senkrechte, Winkel
                     Parallele (Abstand)
                         Parallele (Punkt)
                                 Tangente
                                     Winkelhalbierende}
type kreis_k = (mr, mp);
               {Radius
                    durch Punkt}
type

     ppunkt = ^punkt;
     pgerade = ^gerade;
     pkreis = ^kreis;

     konstruktionp = record
     case konstruktion: punkt_k of
      ko: (xk, yk: real);
      gg: (g1, g2: pgerade);
      gk: (g: pgerade; k: pkreis; nrgk: 1..2);
      kk: (k1, k2: pkreis; nrkk: 1..2);
      ms: (p1, p2: ppunkt);
      mk: (kk: pkreis);
     end;

     konstruktiong = record
     case konstruktion: gerade_k of
      p2: (p1, p2: ppunkt);
      pa: (gp: pgerade; d: real);
      pp, sp: (g: pgerade; p: ppunkt);
      tp: (k: pkreis; pt: ppunkt; nr:1..2);
      wh: (g1, g2: pgerade);
      ww: (gw: pgerade; pw: ppunkt; winkel: real);
     end;

     konstruktionk = record
     case konstruktion: kreis_k of
      mr: (p: ppunkt; r: real);
      mp: (p1, p2: ppunkt);
     end;

     punkt = object(objekt)
      x, y: real;
      konstr: konstruktionp;
      constructor init;
      procedure aktualisiere; virtual;
      procedure ausgabe; virtual;
      procedure zeichne; virtual;
      function koordin(xk,yk:integer; eps:real):boolean; virtual;
      destructor fertig;
     end;

     gerade = object(objekt)
      svx, svy, rvx, rvy: real;
      konstr: konstruktiong;
      constructor init;
      procedure aktualisiere; virtual;
      procedure ausgabe; virtual;
      procedure zeichne; virtual;
      function koordin(xk,yk:integer; eps:real):boolean; virtual;
      destructor fertig;
     end;

     kreis = object(objekt)
      mx, my, r: real;
      konstr: konstruktionk;
      constructor init;
      procedure aktualisiere; virtual;
      procedure ausgabe; virtual;
      procedure zeichne; virtual;
      function koordin(xk,yk:integer; eps:real):boolean; virtual;
      destructor fertig;
     end;

type ppliste = ^pliste;
     pgliste = ^gliste;
     pkliste = ^kliste;

     pliste = record
              p: ppunkt;
              naechster: ppliste;
              end;
     gliste = record
              g: pgerade;
              naechster: pgliste;
              end;
     kliste = record
              k: pkreis;
              naechster: pkliste;
              end;

procedure koordinaten(xvon,yvon:real;var x,y:integer);
procedure koordzurueck(xvon,yvon:integer; var x,y:real);
procedure incaenderung;

implementation
uses graph;

var aenderungsnr: byte;

constructor objekt.init; begin name:=''; sichtbar:=true; aenderung:=(aenderungsnr+254) mod 255; end;
destructor objekt.fertig; begin end;

constructor punkt.init; begin inherited init; end;
destructor punkt.fertig; begin inherited fertig; end;

constructor gerade.init; begin inherited init; end;
destructor gerade.fertig; begin inherited fertig; end;

constructor kreis.init; begin inherited init; end;
destructor kreis.fertig; begin inherited fertig; end;

procedure objekt.aktualisiere; begin aenderung:=aenderungsnr; end;
procedure objekt.ausgabe; begin aktualisiere; end;
procedure objekt.zeichne; begin aktualisiere; end;
function objekt.koordin; begin koordin:=false; end;

procedure incaenderung;
begin
aenderungsnr:=(aenderungsnr+1) mod 255;
end;

{$I GEORECH.INC}
begin
aenderungsnr:=0;
end.