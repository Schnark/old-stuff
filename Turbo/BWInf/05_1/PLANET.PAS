program planet;
uses crt;
var aa, da: real;
var a, monate, tagek, lmonate, n, z: integer;

function ggT (a, b: integer): integer;
(* ggT-Bestimmung nach euklidischem Algorithmus *)
begin
 while a * b <> 0 do
 begin
  if a >= b then
   a := a mod b
  else
   b := b mod a;
 end;
 ggT := a + b;
end;

procedure schaltjahre (aa: real; var n, z: integer);
(* gibt Schaltjahrregel aus *)
var dmin, v1, v2, v3, v4, d1, d2, d3, d4: real;
var a, b, ggTab, aopt, bopt, nr: integer;
begin
 dmin := 100; (* Startwert *)
 a := 1;
 repeat
  if a = 1 / aa then
  begin
   (* Optimum gefunden *)
   aopt := a; bopt := a; nr := 1; break;
  end;
  for b := 1 to trunc((a - 1) / (a * aa - 1)) do
  begin
   ggTab := ggT(a, b);
   (* verschiedene Schaltjahrregeln mit Abweichungen *)
   v1 := (b - ggTab + a) / (a * b);
   v2 := (b - ggTab + a - 1) / (a * b);
   v3 := (b - ggTab + 1) / (a * b);
   v4 := (b - ggTab) / (a * b);
   d1 := abs(aa - v1);
   d2 := abs(aa - v2);
   d3 := abs(aa - v3);
   d4 := abs(aa - v4);
   (* wenn bessere Schaltjahrregel, dann Åbernehmen *)
   if (d1 < dmin) or ((d1 = dmin) and (a * b < aopt * bopt)) then
   begin
    aopt := a; bopt := b;
    dmin := d1;
    nr := 1;
   end;
   if (d2 < dmin) or ((d2 = dmin) and (a * b < aopt * bopt)) then
   begin
    aopt := a; bopt := b;
    dmin := d2;
    nr := 2;
   end;
   if (d3 < dmin) or ((d3 = dmin) and (a * b < aopt * bopt)) then
   begin
    aopt := a; bopt := b;
    dmin := d3;
    nr := 3;
   end;
   if (d4 < dmin) or ((d4 = dmin) and (a * b < aopt * bopt)) then
   begin
    aopt := a; bopt := b;
    dmin := d4;
    nr := 4;
   end;
  end;
  a := a + 1;
 until ((a > 30) and (dmin < 1 / 1000)) or (a > 1000);

 (* Ausgabe der Schaltjahrregel 
    und Bestimmung des tatsÑchlichen VerhÑltnisses *)
 write('Ein Schaltjahr ist ein Jahr, das ');
 case nr of
  1: begin
      if aopt <> bopt then
       writeln('durch ', aopt, ' oder ', bopt, ' teilbar ist.')
      else
       writeln('durch ', aopt, ' teilbar ist.');
      z := bopt - ggT(aopt, bopt) + aopt;
     end;
  2: begin
      if aopt <> bopt then
       if bopt > 1 then
       begin
        write('durch ', aopt, ' oder ', bopt, ', aber nicht durch ');
        writeln(aopt * bopt, ' teilbar ist.');
       end
       else
        writeln('nicht durch ', aopt, ' teilbar ist.')
      else
      begin
       write('durch ', aopt, ', aber nicht durch ');
       writeln(aopt * bopt, ' teilbar ist.');
      end;
      z := bopt - ggT(aopt, bopt) + aopt - 1;
     end;
  3: begin
      if aopt <> bopt then
      begin
       write('durch ', aopt, ' und nicht durch ', bopt);
       writeln(' teilbar ist, oder das durch ', aopt * bopt, ' teilbar ist.');
      end
      else
       writeln('durch ', aopt * bopt, ' teilbar ist.');
      z := bopt - ggT(aopt, bopt) + 1;
     end;
  4: begin
      if aopt <> bopt then
       writeln('durch ', aopt, ' und nicht durch ', bopt, ' teilbar ist.')
      else
       writeln('nicht existiert. Es gibt keine Schaltjahre.');
      z := bopt - ggT(aopt, bopt)
     end;
 end;
 n := aopt * bopt;
end;

begin (* Hauptprogramm *)

 clrscr;
 (* Eingabe von a *)
 write('a= ');
 readln(aa);
 a := trunc(aa);
 (* Anzahl der Monate *)
 monate := trunc(a / 30 + 0.5);
 if monate = 0 then monate := 1;
 (* Tage in einem kurzen Monat *)
 tagek := trunc(a / monate);
 (* Anzahl der langen Monate *)
 lmonate := a - monate * tagek;
 (* Ausgabe der Monatszahlen *)
 write(monate - lmonate, ' Monate mit ', tagek, ' Tagen');
 if lmonate > 0 then
  writeln(', ', lmonate, ' mit ', tagek + 1, '.')
 else
  writeln('.');

 (* Schaltjahrregel *)
 if aa-a <> 0 then
 begin
  writeln('In Schaltjahren hat ein Monat einen Tag mehr als sonst.');
  schaltjahre(aa - a, n, z);
 end
 else
 begin
  z := 0; n := 1;
 end;

 (* absolute Abweichung und Ausgabe *)
 da := abs(aa - a - z / n);
 if da = 0 then
  writeln('Der Kalender ist exakt!')
 else
  writeln('Nach ca. ', trunc(1 / da + 0.5),
          ' Jahren weicht der Kalender um einen Tag ab.');
readln;
end.
