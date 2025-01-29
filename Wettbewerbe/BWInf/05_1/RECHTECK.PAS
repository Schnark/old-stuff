program rechteckszaehler;
uses crt;

type rechteck = record
 x1, y1, x2, y2: integer;
end;

(* Maximale Anzahl der Rechtecke *)
const maxmax = 5;

(* Striche und Ecken *)
const waagerecht = 5; senkrecht = 10;
const lu = 3; ru = 6; ro = 12; lo = 9;

(* Anzahl der Rechtecke *)
var max: integer;
(* Speicher fÅr Rechtecke *)
var rechtecke: array[1 .. maxmax] of rechteck;
(* "Anzeigetafel" *)
var feld: array[1 .. 30, 1 .. 20] of integer;
var i, j, nr: integer;

procedure lesen;
var dateiname, daten: string;
var x1s, x2s, y1s, y2s: string;
var datei: text;
var kommapos, dummy: integer;
begin
 max := 0; (* noch kein Rechteck *)
 (* lesen der Daten in der Datei *)
 write('Welche Datei enthÑlt die Rechteckdaten? ');
 readln(dateiname);
 assign(datei,dateiname);
 reset(datei);
 while not eof(datei) and not (maxmax = max) do
 begin
  max := max + 1;
  (* Lesen der Daten und Aufteilen an den Kommata *)
  readln(datei, daten);
  kommapos := pos(',', daten);
  x1s := copy(daten,1, kommapos - 1); 
  daten := copy(daten, kommapos + 1,length(daten));
  kommapos := pos(',', daten);
  y1s := copy(daten,1, kommapos - 1); 
  daten := copy(daten, kommapos + 1,length(daten));
  kommapos := pos(',', daten);
  x2s := copy(daten,1, kommapos - 1); 
  daten := copy(daten, kommapos + 1,length(daten));
  y2s := daten;
  (* Speichern der Daten *)
  with rechtecke[max] do begin
   val(x1s,x1,dummy);
   val(x2s,x2,dummy);
   val(y1s,y1,dummy);
   val(y2s,y2,dummy);
  end;
 end;
 close(datei);
end;

procedure einfuegen;
(* fÅgt alle Rechtecke in das Raster ein *)
var i, j, xx1, xx2, yy1, yy2: integer;
begin
(* alle Rechtecke werden eingefÅgt *)
for i := 1 to max do
 begin
 with rechtecke[i] do
 begin
  xx1 := x1; xx2 := x2;
  yy1 := y1; yy2:= y2 ;
 end;
 (* Die Ober- und Unterseite wird eingefÅgt. *)
 for j := xx1 + 1 to xx2 - 1 do
 begin
  feld[j, yy1] := feld[j, yy1] or waagerecht;
  feld[j, yy2] := feld[j, yy2] or waagerecht;
 end;
 (* Die linke und die rechte Seite wird eingefÅgt. *)
 for j := yy1 + 1 to yy2 - 1 do
 begin
  feld[xx1, j] := feld[xx1, j] or senkrecht;
  feld[xx2, j] := feld[xx2, j] or senkrecht;
 end;
 (* Die Ecken werden eingefÅgt. *)
 feld[xx1, yy1] := feld[xx1, yy1] or lu;
 feld[xx1, yy2] := feld[xx1, yy2] or lo;
 feld[xx2, yy1] := feld[xx2, yy1] or ru;
 feld[xx2, yy2] := feld[xx2, yy2] or ro;
 end;
end;

function zeichen (x, y:integer): char;
(* gibt zu einer Zahl
   das entsprechende Zeichen (Strich, Ecke, Verzweigung) aus *)
begin
case feld[x, y] of
  0: zeichen := ' ';
  3: zeichen := '¿';
  5: zeichen := 'ƒ';
  6: zeichen := 'Ÿ';
  7: zeichen := '¡';
  9: zeichen := '⁄';
 10: zeichen := '≥';
 11: zeichen := '√';
 12: zeichen := 'ø';
 13: zeichen := '¬';
 14: zeichen := '¥';
 15: zeichen := '≈';
end;
end;

procedure zeichnen;
(* zeichnet alle Rechtecke *)
var x, y: integer;
begin
 for x := 1 to 30 do
 for y := 1 to 20 do
 begin
  (* An jede Stelle wird das entsprechende Zeichen geschrieben. *)
  gotoxy(x + 5, 23 - y);
  write(zeichen(x, y));
 end;
end;

procedure markieren (x1, y1, x2, y2: integer);
(* Markiert ein Rechteck in der Zeichnung *)
var x, y: integer;
begin
 (* Rechteck mit rot markieren *)
 textcolor(red);
 (* Es werden alle 4 Seiten des Rechtecks
    wie in der Prozudur zeichnen gezeichnet.*)
 for x := x1 to x2 do 
 begin
  gotoxy(x + 5, 23 - y1);
  write(zeichen(x, y1));
 end;
 for x := x1 to x2 do
 begin
  gotoxy(x + 5, 23 - y2);
  write(zeichen(x, y2));
 end;
 for y := y1 to y2 do
 begin
  gotoxy(x1 + 5, 23 - y);
  write(zeichen(x1, y));
 end;
 for y := y1 to y2 do
 begin
  gotoxy(x2 + 5,23 - y);
  write(zeichen(x2, y));
 end;
 textcolor(lightgray);
end;

function zaehlen: integer;
(* Bestimmt die Zahl der Rechtecke *)
var x, y, i, j, k, anzahl: integer;
var falsch: boolean;
begin
 anzahl := 0;
 (* Alle Ecken werden ÅberprÅft, ... *)
 for x := 1 to 30 do
 for y := 1 to 20 do
 begin
  (* ... ob sie eine linke, untere Ecke sein kînnen. *)
  if (feld[x, y] and lu) = lu then
   for i := x + 1 to 30 do
   for j := y + 1 to 20 do
   begin
    (* Alle Ecken oberhalb und rechts davon werden untersucht,
       ob sie die restlichen Ecken bilden kînnen, ...          *)
    if (feld[x, j] and lo) = lo then
     if ((feld[i, y] and ru) = ru) and ((feld[i, j] and ro) = ro) then
      (* ... und ob sie mit Kanten verbunden sind. *)
      falsch := false;
      for k := x + 1 to i - 1 do
      begin
       if (feld[k, y] and waagerecht) <> waagerecht then falsch := true;
       if (feld[k, j] and waagerecht) <> waagerecht then falsch := true;
      end;
      for k := y + 1 to j - 1 do
      begin
       if (feld[x, k] and senkrecht) <> senkrecht then falsch := true;
       if (feld[i, k] and senkrecht) <> senkrecht then falsch := true;
      end;
      if not falsch then
      begin
       (* Das gefundene Rechteck wird gezÑhlt, markiert und aufgelistet. *)
       anzahl := anzahl + 1;
       markieren(x, y, i, j);
       gotoxy(40, anzahl mod 23 + 1);
       write('((', x, ', ', y, '), (', i, ', ', j, '))');
       delay(1000);
       zeichnen;
      end;
   end;
 end;
 zaehlen := anzahl;
end;


begin (* Hauptprogramm *)
 clrscr;
 lesen;
 clrscr;
 for i := 1 to 30 do
 for j := 1 to 20 do
  feld[i, j] := 0;
 einfuegen;
 zeichnen;
 delay(1000);
 nr := zaehlen;
 gotoxy(40, nr mod 23 + 3);
 write(nr, ' Rechtecke');
 readln;
 clrscr;
end.
