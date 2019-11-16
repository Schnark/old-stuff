program geometrie;
uses {geo_def,}geo_dia,crt;

procedure menu;
var ant: char;
begin
 repeat
  clrscr;
  writeln('0. Graphikmodus               0/m/M');
  writeln('1. Definiere Punkt            1/p/P');
  writeln('2.  "     "  Gerade           2/g/G');
  writeln('3.  "     "  Kreis            3/k/K');
  writeln('4. Punkte „ndern              4/„/');
  writeln('5. Ausgabe                    5/a/A');
  writeln('6. Einstellungen              6/e/E');
  writeln('7. Datei ”ffnen               7/”/™');
  writeln('8. Datei speichern            8/s/S');
  writeln('9. Ende                       9/x/X');
  write('--> '); readln(ant);
  case ant of
  '0','m','M': graphikmodus;
  '1','p','P': neup;
  '2','g','G': neug;
  '3','k','K': neuk;
  '4','„','': aendernT;
  '5','a','A': ausgabe;
  '6','e','E': einstellung;
  '7','”','™':;
  '8','s','S':;
  '9','x','X':;
  else write(#7);
  end;
 until ant in ['9','x','X'];
end;

begin
graphikmodus;
menu;
end.