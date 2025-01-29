program schweizer_kaese;
uses crt, graph;

(* K„sekantenl„nge *)
const kante = 20;

(* Modus 1: Ein Versuch mit Benutzerein- und detaillierten Ausgaben
   Modus 2: Erstellen eines Schaubildes:
   Durchflusswahrscheinlichkeit in Abh„ngigkeit von p               *)
const modus = 2;

(* Fr Schaubild: Schrittweite fr p und jeweilige Anzahl der Versuche *)
const pdif = 0.02; versuche = 20;

(* K„se: 0 = K„se, 1 = Luft, 2 = Wasser *)
var kaese: array[0 .. kante + 1, 0 .. kante + 1, 0 .. kante + 1] of integer;
var p, wahrsch : real;
var erfolg, nr : integer;
var a : boolean;

procedure molkerei(p : real);
(* erzeugt den K„se mit "K„sewahrscheinlichkeit" p *)
var i, j, k, fuellung : integer;
begin
 randomize;
 (*Alle K„se-"eckchen" werden zuf„llig gefllt.*)
 for i := 1 to kante do
 for j := 1 to kante do
 for k := 1 to kante do
 begin
  if random <= p then fuellung := 0 else fuellung := 1;
  kaese[i, j, k] := fuellung;
 end;
end;

procedure fuellen;
(* In alle Luftl”cher der oberen Schicht wird Wasser gefllt. *)
var i, j : integer;
begin
 for i := 1 to kante do
 for j := 1 to kante do
  if kaese[i, j, 1] = 1 then kaese[i, j, 1] := 2;
end;

function umgebung(x, y, z : integer) : boolean;
(* l„sst Wasser von (x,y,z) zu den Nachbarn flieáen *)
var geflossen : boolean;
begin
 geflossen := false;
 (* Wenn in einem der Nachbarn Luft ist, flieát Wasser hinein. *)
 if kaese[x, y, z - 1] = 1 then 
 begin
  kaese[x, y, z - 1] := 2;
  geflossen := true;
 end;
 if kaese[x, y, z + 1] = 1 then
 begin
  kaese[x, y, z + 1] := 2;
  geflossen := true;
 end;
 if kaese[x - 1, y - 1, z] = 1 then
 begin 
  kaese[x - 1, y - 1, z] := 2;
  geflossen := true;
 end;
 if kaese[x - 1, y + 1, z] = 1 then 
 begin
  kaese[x - 1, y + 1, z] := 2;
  geflossen := true;
 end;
 if kaese[x + 1, y - 1, z] = 1 then 
 begin
  kaese[x + 1, y - 1, z] := 2;
  geflossen := true;
 end;
 if kaese[x + 1, y + 1, z] = 1 then
 begin
  kaese[x + 1, y + 1, z] := 2;
  geflossen := true;
 end;
 umgebung := geflossen;
end;

function fliessen: boolean;
(* l„sst Wasser flieáen *)
var geflossen, gefuellt: boolean;
var i, j, k: integer;
begin
 geflossen := false;
 (* Alle K„se-"eckchen" werden untersucht, ... *)
 for i := 1 to kante do 
 for j := 1 to kante do 
 for k := 1 to kante do
 begin
  (* ... ob sie Wasser enthalten, ... *)
  if kaese[i, j, k] = 2 then
  begin
   (* ... das in die Nachbar-"eckchen" flieáen kann. *)
   gefuellt := umgebung(i, j, k);
   if gefuellt then geflossen := true;
  end;
 end;
 fliessen := geflossen;
end;

function unten: boolean;
(* schaut, ob in der unteren Schicht Wasser ist. *)
var i, j: integer;
begin
 for i := 1 to kante do
 for j := 1 to kante do
 begin
  if kaese[i, j, kante] = 2 then
  begin
   unten := true;
   exit;
  end;
 end;
 unten := false;
end;

function test (p:real): boolean;
var geflossen, ergebnis: boolean;
begin
 (* Der K„se wird erzeugt, ... *)
 if modus = 1 then writeln('Erzeuge K„se...');
 molkerei(p);

 (* ... mit Wasser gefllt, ... *)
 if modus = 1 then writeln ('Flle K„se mit Wasser...');
 fuellen;

 (* ... das dann durch den K„se flieát ... *)
 if modus = 1 then writeln('Lasse Wasser flieáen...');
 repeat
  geflossen := fliessen;
 until not geflossen;

 (*... und vielleicht unten ankommt.*)
 if modus = 1 then writeln('Schaue, ob es tropft...');
 ergebnis := unten;
 if modus = 1 then 
  if ergebnis then writeln('Es tropft!') else writeln('Alles trocken!');
 test := ergebnis;
end;

procedure bild;
const pfad='';
var i: integer;
var treiber, modus: integer;
begin
 (* Grafikbildschirm *)
 treiber := detect;
 initgraph(treiber, modus, pfad);
 (* weiáer Hintergrund *)
 setcolor(white);
 bar (0, 0, getmaxx, getmaxy);
 (* Achsen *)
 setcolor(darkgray);
 line (5, getmaxy - 5, getmaxx - 5, getmaxy - 5);
 line (5, getmaxy - 5, 5, 5);

 (* Achsenskalierung (Einteilung 0,1) *)
 for i := 0 to 10 do
 begin
  line (5 + trunc(0.5+i / 10 * (getmaxx - 10)), getmaxy, 
        5 + trunc(0.5 + i / 10 * (getmaxx - 10)), getmaxy - 10);
  line (0, getmaxy - 5 - trunc(0.5 + i / 10 * (getmaxy - 10)), 
        10, getmaxy - 5 - trunc(0.5 + i / 10 * (getmaxy - 10)));
 end;
 (* Startpunkt *)
 moveto(5, 5);
end;

procedure punkt (xx, yy: real);
(* Markiert den Punkt (xx, yy) im Diagramm *)
var x, y: integer;
begin
 (* Die Koordinaten werden umgerechnet, ... *)
 x := trunc(5.5 + xx * (getmaxx - 10));
 y := trunc(getmaxy - 4.5 - yy * (getmaxy - 10));
 (* ... vom vorherigen Punkt wird eine Strecke gezeichnet ... *)
 setcolor(blue);
 lineto (x, y);
 (* ... und der Punkt wird markiert. *)
 setcolor(red);
 circle (x, y, 3);
end;

begin (* Hauptprogramm *)

if modus = 1 then
begin
 (* Nach Wahrscheinlichkeit fragen und K„se testen
  (Ausgaben bernimmt test)                        *)
 clrscr;
 write('Wahrscheinlichkeit fr K„se: ');
 readln(p);
 a := test(p);
 readln;
end
else
begin
 (* Bildschirm initialisieren *)
 bild;
 p := 0; 
 repeat
  (* fr jede Wahrscheinlichkeit einige Versuche durchfhren und
     Durchflusswahrscheinlichkeit berechnen und im Diagramm eintragen *)
  erfolg := 0;
  for nr := 1 to versuche do
   if test(p) then erfolg := erfolg + 1;
  wahrsch := erfolg / versuche;
  punkt(p, wahrsch);
  p := p + pdif;
 until p > 1.0001;
 readln;
 closegraph;
end;
end.
