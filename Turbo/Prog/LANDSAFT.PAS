program landschaft;
uses graph, graph2;

var a: array[0 .. 128, 0 .. 128] of integer;
var i, j, d, m, n, s, h, schritt: integer;
var x,y: integer;

begin
d:=30; m:=0;
randomize;
write('Stufe (1-7): '); readln(n);

a[0, 0] := integer(random(30)) - 10;        {Startwerte}
a[128, 0] := integer(random(30)) - 40;
a[0, 128] := random(60) + 50;
a[128, 128] := integer(random(60)) - 10;

schritt := 128;
for i := 1 to n do begin
 schritt := schritt div 2;
 y := 0;
 repeat
  x := schritt;
  repeat
   a[x, y] := (a[x - schritt, y] + a[x + schritt, y]) div 2 - schritt div 2 + random(schritt);
   x := x + 2 * schritt;
  until x = 128 + schritt;
  y := y + 2 * schritt;
 until y > 128;
 x := 0;
 repeat
  y := schritt;
  repeat
   a[x, y] := (a[x, y - schritt] + a[x, y + schritt]) div 2 - schritt div 2 + 2 * random(schritt);
   y := y + 2 * schritt;
  until y > 128;
  x := x + schritt;
 until x > 128;
end;

{Maximum und Minimum}
h := 0;
for i := 0 to 128 do
 for j := 0 to 128 do
  if a[i, j] > h then
     h := a[i, j];

s := 50;
for i := 0 to 128 do
 for j := 0 to 128 do
  if a[i, j] < s then s := a[i, j];

writeln('Tiefster Punkt: ', s);
writeln('H”chster Punkt: ', h);
write('Seeh”he: '); readln(s);
write('Schneegrenze: '); readln(h);

init;
y := 0;
repeat
 x := 0;
 repeat
  IF a[x, y] > h THEN setcolor(7) ELSE setcolor(2);
  IF (a[x, y] < s + 1) AND (a[x, y] > s) THEN setcolor(4);
  IF a[x, y] <= s THEN setcolor(8);
  line(4 * x + y + m, 350 - d - y - a[x, y], 4 * (x + schritt) + y + m, 350 - d - y - a[x + schritt, y]);
  x := x + schritt;
 UNTIL x = 128;
 y := y + schritt
UNTIL y > 128;

x := 0;
repeat
 y := 0;
 repeat
  IF a[x, y] > h THEN setcolor(7) ELSE setcolor(2);
  IF (a[x, y] < s + 1) AND (a[x, y] > s) THEN setcolor(4);
  IF a[x, y] <= s THEN setcolor(8);
  LINE(4 * x + y + m, 350 - d - y - a[x, y], 4 * x + schritt + y + m, 350 - d - y - schritt - a[x, schritt + y]);
  y := y + schritt;
 UNTIL y = 128;
 x := x + schritt;
UNTIL x > 128;

x := schritt;
setcolor(1);

repeat
 y := schritt;
 repeat
  IF a[x, y] <= s THEN
   FOR i := -schritt div 2 TO schritt div 2 do
    LINE (4 * x + y - 2 * schritt + i + m, 350 - d - y - s - i, 4 * x + y + 2 * schritt + i + m, 350 - d - y - s - i);
  y := y + schritt;
 UNTIL y > 128 - schritt;
 x := x + schritt;
UNTIL x > 128 - schritt;


readln;

closegraph;
end.