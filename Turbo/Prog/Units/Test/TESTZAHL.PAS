program test;
uses zahlen;
var a, b, i: integer;
begin
readln(a);
readln(b);
writeln('ggT: ', ggT(a, b));
writeln('kgV: ', kgV(a, b));
if prim(a) then writeln(a,' ist prim.');
for i := 1 to 100 do
if prim(i) then write(i,'  ');
writeln;
readln(a);
b := faktor(a, i);
repeat
writeln(b,'^',i);
b := faktor(0,i);
until b = 1;
readln;
end.