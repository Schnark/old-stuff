program chator;
uses crt;

(* Maximalanzahl der Chatonen *)
const maxmax = 10;

var getratscht: boolean;

(* tatsÑchliche Anzahl der Chatonen *)
var max: integer;

(* true, wenn dem Chatone 1 der Chatone 2 sympathisch ist *)
var symp: array[1 .. maxmax, 1 .. maxmax] of boolean;

(* true, wenn eine Nachricht von Chatone 1 an Chatone 2
   auch dem Chatonen 3 zu Ohren kommt                   *)
var tratsch: array [1 .. maxmax, 1 .. maxmax, 1 .. maxmax] of boolean;

function name (nr: integer): char;
(* gibt den Namen eines Chatonen aus *)
begin
name := chr(nr + 64);
end;

function nummer (name: string): integer;
(* gibt die Nummer eines Chatonen aus *)
begin
nummer := ord(char(name[1])) - 64;
end;

procedure init;
(* initialisiert die Felder *)
var i, j, k, nr1, nr2: integer;
var dateiname, sympath: string;
var datei: text;
begin

 (* alle Werte auf false setzen *)
 for i := 1 to maxmax do
  for j := 1 to maxmax do
   symp[i, j] := false;

 for i := 1 to maxmax do
  for j := 1 to maxmax do
   for k := 1 to maxmax do
    tratsch[i, j, k] := false;

 (* Freundschaftsnetz aufbauen *)
 
 (* Datei mit Daten einlesen *)
 write('Welche Datei enthÑlt die Daten? ');
 readln(dateiname);
 assign(datei,dateiname);
 reset(datei);

 max := 0; (* noch keine Chatonen *)
 repeat
  readln(datei,sympath);
  nr1 := nummer(copy(sympath, 1, 1)); 
  nr2 := nummer(copy(sympath, 2, 1));
  (* Anzahl der Chatonen evt. nach oben korrigieren *)
  if nr1 > max then max := nr1;
  if nr2 > max then max := nr2;
  (* als sympathisch markieren *)
  symp[nr1, nr2] := true;
 until eof(datei);
 close(datei);

 (* Jeder Chatone schreibt seinen Freunden eine Nachricht *)
 for i := 1 to max do
  for j := 1 to max do
   tratsch[i, j, j] := symp[i, j];

end;

function erzaehlen(von, nach, ueber: integer): boolean;
(* Chatone "ueber" erzÑhlt all seinen Freunden,
   was der Chatone "von" dem Chatonen "nach" geschrieben hat *)
var erzaehlt: boolean;
var i: integer;
begin
 (* Noch hat der Chator "ueber" nichts weitererzaehlt. *)
 erzaehlt := false;
 for i := 1 to max do
  if symp[ueber, i] then
   (* Nun erfahren alle seine Freunde, die es noch nicht wissen,
      was der Chatone "von" dem Chatonen "nach" geschrieben hat. *)
   if not tratsch[von, nach, i] then 
   begin
    tratsch[von, nach, i] := true;
    erzaehlt := true;
   end;
 erzaehlen := erzaehlt;
end;

function tratschen: boolean;
(* Jeder Tratsch wird von denen weitererzÑhlt, die davon gehîrt haben *)
var getratscht: boolean;
var i, j, k: integer;
begin
 (* Noch hat keiner getratscht, ... *)
 getratscht := false;

 for i := 1 to max do
 for j := 1 to max do
  if symp[i, j] then
   (*... aber jeder Chatone "k", der wei·, was der Chatone "i"
     dem Chatonen "j" ursprÅnglich geschrieben hat (au·er "i" selbst), ... *)
   for k := 1 to max do
    if tratsch[i, j, k] and (k <> i) then
     (* ... erzÑhlt es allen seinen Freunden weiter. *)
     if erzaehlen(i, j, k) then getratscht := true;
 tratschen := getratscht;
end;

procedure ausgabe;
(* gibt Tratschpartner und Themen aus *)
var briefe: char;
var i, j, k: integer;
var stoff: boolean;
var datei: text;
begin
 write('Sollen Briefe erstellt werden (j,n)? ');
 readln(briefe);
 briefe := upcase(briefe);

 for i := 1 to max do
 for j := 1 to max do
 begin
  (*Wenn einem Chatonen ein anderer sympatisch ist, beginnt er zu tratschen
    (und eventuell Briefe zu schreiben), ...                             *)
  if symp[i, j] then
  begin
   (* Gibt es GesprÑchsstoff? *)
   stoff := false;
   for k := 1 to max do
    if (k <> i) and not tratsch[i, j, k] then stoff := true;

   (* Nur tratschen, wenn es GesprÑchsstoff gibt. *)
   if stoff then
   begin
    if briefe = 'J' then 
    begin
     (* Die Briefe haben den Dateinamen Absender_EmpfÑnger.TXT *)
     assign(datei,name(i) + '_' + name(j) + '.TXT'); 
     rewrite(datei);
     writeln(datei,'Hallo ',name(j),'!');
    end;
    write(name(i), ' an ', name(j), ': ');

    for k := 1 to max do
    begin 
     (* ... und zwar Åber alle,
        die davon nichts erfahren (und nicht Åber sich selbst). *)
     if (k <> i) and not tratsch[i, j, k] then
     begin 
      write(name(k), ' ');
      if briefe = 'J' then 
       writeln(datei, 'Was Sie unbedingt Åber ', name(k), ' wissen sollten:');
     end;
    end;
    if briefe = 'J' then 
    begin
     writeln(datei, 'Ihr ', name(i));
     close(datei);
    end;
    writeln;
   end;
  end;
 end;
 writeln;
end;

begin (*Hauptprogramm*)
clrscr;
(* initialisiere die Felder *)
init;

(* Solange es etwas zu tratschen gibt, wird getratscht. *)
repeat
 getratscht := tratschen;
until not getratscht;

(* Mîgliche Tratschpartner werden ausgegeben *)
ausgabe;
readln;
end.
