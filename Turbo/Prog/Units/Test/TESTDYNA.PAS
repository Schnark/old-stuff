program dynatest;
uses crt, dyna;

var liste1: liste;
    ant: char;
    pos, zahl: integer;
    wert: ^integer;

begin
new(liste1);
liste1 := nil;
repeat
clrscr;
for pos := 1 to len(liste1) do
begin
 wert := get(liste1, pos);
 if wert = nil then write('    x') else write(wert^: 5);
end;
writeln;
writeln;
writeln('1. Eingabe');
writeln('2. Ausgabe');
writeln('3. „ndern');
writeln('4. L„nge');
writeln('5. l”schen');
writeln('6. L„nge „ndern');
writeln('7. Ende');
readln(ant);
case ant of
'1':
    begin
     write('Position (0 fr Ende): ');
     readln(pos);
     write('Wert: ');
     readln(zahl);
     new(wert);
     wert^ := zahl;
     if pos = 0 then add(liste1, wert) else ins(liste1, pos, wert);
    end;
'2':
    begin
     write('Position: ');
     readln(pos);
     wert := get(liste1, pos);
     if wert <> nil then write(wert^) else write('Nicht vorhanden');
     readln;
    end;
'3':
    begin
     write('Position: ');
     readln(pos);
     write('Wert: ');
     readln(zahl);
     new(wert);
     wert^ := zahl;
     change(liste1, pos, wert);
    end;
'4':
    begin
     write(len(liste1));
     readln;
    end;
'5':
    begin
     write('Position: ');
     readln(pos);
     del(liste1, pos);
    end;
'6':
    begin
     write('L„nge: ');
     readln(pos);
     setlen(liste1, pos);
    end;
end;
until ant = '7';
setlen(liste1, 0);
end.