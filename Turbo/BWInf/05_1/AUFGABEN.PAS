program aufgaben_suche;
uses crt;
(* Maximale Anzahl der Aufgaben und BÑnde *)
const maxmax = 50; buchmax = 20;
type feld = array[1 .. maxmax] of boolean;
(* gesammelte Aufgaben *)
var schueler: feld;
(* Aufgaben in BÅchern *)
var buecher: array[1 .. buchmax, 1 .. maxmax] of boolean;
(* tatsÑchliche Anzahlen *)
var aufgaben, baende: integer;
var min, max, buchzahl: integer;
var erfolg: boolean;

function zahl (var zeile: string): integer;
(* spaltet eine Zahl von der Zeile ab *)
var kommapos, z, dummy: integer;
begin
kommapos := pos(',', zeile);
if kommapos = 0 then
begin 
 val(zeile, z, dummy);
 zahl := z;
 zeile := '';
end
else
begin
 val(copy(zeile, 1, kommapos - 1), z, dummy);
 zahl := z;
 zeile := copy(zeile, kommapos + 1, length(zeile));
end;
end;

procedure lesen;
(* liest die Daten aus einer Datei *)
var i, j, anr: integer;
var dateiname, zeile: string;
var datei: text;
begin
for i := 1 to maxmax do
begin
 schueler[i] := false;
 for j := 1 to buchmax do
  buecher[j,i] := false;
end;
baende := 0;
aufgaben := 0;

write('Welche Datei enthÑlt die Daten? ');
readln(dateiname);
assign(datei, dateiname);
reset(datei);

readln(datei,zeile);
(* Aufgabennummern in der ersten Zeile sind schon bekannt *)
repeat
 anr := zahl(zeile);
 schueler[anr] := true;
 if anr > aufgaben then aufgaben := anr;
until zeile = '';

repeat
 baende := baende + 1;
 readln(datei, zeile);
 repeat
  anr := zahl(zeile);
  buecher[baende, anr] := true;
  if anr > aufgaben then aufgaben := anr;
 until zeile = '';
until eof(datei);
close(datei);
end;

function alle (bekannt: feld): boolean;
(* sind alle Aufgaben jetzt bekannt? *)
var i: integer;
var kennen: boolean;
begin
 kennen := true;
 for i := 1 to aufgaben do
  (* wenn es eine unbekannte Aufgabe gibt, sind noch nicht alle bekannt *)
  if not bekannt[i] then kennen := false;
alle := kennen;
end;

procedure dazu(buchnr: integer; var bekannt: feld);
(* kauft ein Buch dazu *)
var i: integer;
begin
 for i := 1 to aufgaben do
  (* alle Aufgaben aus diesem Buch sind bekannt *)
  if buecher[buchnr, i] then bekannt[i] := true;
end;

function kaufen (anzahl: integer; ausgabe: boolean): boolean;
(* kauft anzahl BÅcher *)
(* bekannte Aufgaben *)
var bekannt: feld;
(* AbstÑnde der Buchnummern (von 0 bis anzahl-1) *)
var abstand: array[0 .. maxmax - 1] of integer;
var i, nr, naechstes, hinten, gekauft, summe: integer;
var fertig, ende: boolean;
begin
 (* zunÑchst die ersten BÅcher kaufen *)
 for i := 0 to anzahl - 1 do
  abstand[i] := 1;
 
 repeat
  (* zu den bekannten Aufgaben ... *)
  for i := 1 to aufgaben do
   bekannt[i] := schueler[i];
  
  naechstes := 0;
  gekauft := 0;
  repeat
   naechstes := naechstes + abstand[gekauft];
   (* ... immer das nÑchste Buch dazu kaufen *)
   dazu(naechstes, bekannt);
   gekauft := gekauft + 1;
  until gekauft = anzahl;
 
  fertig := alle(bekannt);
  if fertig and ausgabe then
  begin
   (* Wenn alle Aufgaben bekannt sind und das Ergebnis 
      ausgegeben werden soll, werden die Buchnummern aufgelistet. *)
   nr := 0;
   for i := 0 to anzahl - 1 do
   begin
    nr := nr + abstand[i];
    write(nr);
    if i <> anzahl - 1 then write(', ') else writeln('.');
   end;
  end;
 
  if not fertig then
  begin
   (* andere Auswahl an BÅchern treffen, genauer Ablauf siehe Dokumentation *)
   hinten := 1;
   repeat
    ende := true;
    abstand[anzahl - hinten] := abstand[anzahl - hinten] + 1;
    summe := 0;
    for i := 0 to anzahl - 1 do
     summe := summe + abstand[i];
    if summe > baende then
    begin
     abstand[anzahl - hinten] := 1;
     hinten := hinten + 1;
     ende := false;
    end;
   until ende or (hinten > anzahl);
   (* aufgeben, wenn alle Mîglichkeiten durchprobiert sind *)
   if not ende then fertig := true;
  end;
 until fertig;
 kaufen := alle(bekannt);
end;

begin (* Hauptprogramm *)
clrscr;
(* Daten einlesen *)
lesen;

if alle(schueler) then
 (* alle Aufgaben sind schon bekannt *)
 writeln('Es sind schon alle Aufgaben bekannt!')
else
 if not kaufen(baende, false) then
  (* keine Mîglichkeit alle Aufgaben zu finden *)
  writeln('Es ist unmîglich, alle Aufgaben zu finden!')
 else
 begin
  (* BinÑrsuche zur erforderlichen Anzahl *)
  min := 0;
  max := baende;
  repeat
   buchzahl := trunc((min + max) / 2);
   erfolg := kaufen(buchzahl, false);
   if erfolg then
    max := trunc((min + max) / 2)
   else
    min := trunc((min + max) / 2);
  until max - min <= 1;
  (* max enthÑlt nun die erforderliche Anzahl *)
  (* Ausgabe *)
  write('Kaufe ', max, ' BÑnde, nÑmlich ');
  erfolg := kaufen(max, true);
 end;
readln;
end.
