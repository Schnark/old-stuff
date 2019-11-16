 program wortsuche;
 uses crt;
 const feld : array[1 .. 8, 1 .. 20] of char = ('ASDFERFGTHZJUKIJERTX'
                                               ,'TIERNKMENOAERSOIMMEL'
                                               ,'KJHZRUINNVHMGSHEBOLE'
                                               ,'OKDFJRUEHZCCRBOHDARI'
                                               ,'IRGENSJISEREMIELIERN'
                                               ,'LPOUJNASHZRTEUFIFNEF'
                                               ,'EHSZEURKITAMROFNIASF'
                                               ,'AGREHZTUECJNBHEEIOWT');
 var wort:string;
 var laenge, pos: integer;
 var zeile, spalte, richtung: integer;
 var zeilex, spaltex: integer;
 var anzahl: integer;

 procedure schreibe;
 var zeile, spalte: integer;
 begin
  for zeile := 1 to 8 do
   for spalte := 1 to 20 do
   begin
    gotoxy(spalte, zeile);
    write(feld[zeile, spalte])
   end;
 end;

 procedure markiere(zeile, spalte, farbe: integer);
 begin
 gotoxy(spalte, zeile);
 textcolor(farbe);
 write(feld[zeile, spalte]);
 textcolor(black);
 if farbe <> black then delay(500);
 end;

 begin
 textcolor(black);
 textbackground(white);
 clrscr;
 write('Gesuchtes Wort (in Groábuchstaben): ');
 readln(wort);
 laenge := length(wort);
 anzahl := 0;
 clrscr;
 schreibe;
 for zeile := 1 to 8 do
  for spalte := 1 to 20 do
  begin
   pos := 1;
   if feld[zeile, spalte] = wort[pos] then
   begin
    markiere(zeile, spalte, green);
    for richtung := 1 to 8 do
    begin
     spaltex := spalte; zeilex := zeile; pos := 1;
     while (0 < spaltex) and (0 < zeilex)
            and (spaltex <= 20) and (zeilex <= 8) and (pos <= laenge) do
     begin
      if feld[zeilex, spaltex] <> wort[pos] then
      begin
       markiere(zeilex, spaltex, blue);
       break;
      end;
      markiere(zeilex, spaltex, green);
      pos := pos + 1;
      case richtung of
       1: spaltex := spaltex + 1;
       2: begin spaltex := spaltex + 1; zeilex := zeilex + 1; end;
       3: zeilex := zeilex + 1;
       4: begin spaltex := spaltex - 1; zeilex := zeilex + 1; end;
       5: spaltex := spaltex - 1;
       6: begin spaltex := spaltex - 1; zeilex := zeilex - 1; end;
       7: zeilex := zeilex - 1;
       8: begin spaltex := spaltex + 1; zeilex := zeilex - 1; end;
      end; {case}
     end; {while}
     if pos > laenge then {Schleifenende, weil gefunden}
     begin
      anzahl := anzahl + 1;
      sound(440); readln; nosound;
     end;
     schreibe;
    end; {for richtung}
   end {if then}
   else
    markiere(zeile, spalte, blue);
    markiere(zeile, spalte, black);
  end; {for zeile, spalte}
 gotoxy(2,10);
 writeln('''',wort,''' wurde ',anzahl,' Mal gefunden.');
 readln;
 textcolor(lightgray);
 textbackground(black);
 clrscr;
 end.