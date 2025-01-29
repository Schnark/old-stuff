program shellsort;
uses crt, graph, graph2, zeit;

const nmax = 60000 div 2;
var a: array[1 .. nmax] of byte;
    n,i,t,t1,t2,t3: longint;
    h,j,vers: byte;
    x,y1,y2,y3,xalt,y1alt,y2alt,y3alt: integer;

procedure shell;
{sortiert a[1..n] nach Shellsort}
var h,i,j: longint;
    v: byte;
begin
h := 0;
repeat h := 3*h+1; until h>n;

repeat
 h := h div 3;

 for i := h+1 to n do begin
  v := a[i]; j := i;
  while (j>h) and (a[j-h]>v) do begin
   a[j] := a[j-h];
   j := j-h;
  end;
  a[j] := v;
 end;

until h = 1;
end;

begin
n := 0;
{clrscr;} init;
x := 0; y1 := getmaxy-1; y2 := getmaxy-1; y3 := getmaxy-1;
randomize;
{write('n ( <= ',nmax,'): ');
readln(n);
write('Versuche: '); readln(vers);}
vers := 7;
repeat
 n := n + 2000;
 {writeln(n,':');}
 t1 := 0; t2 := 0; t3 := 0;

 for j := 1 to vers do begin
  for i := 1 to n do a[i] := random(255);
  t := timer;
  shell;
  t1 := t1+ timer-t;

  t := timer;
  shell;
  t2 := t2+ timer-t;

  for i := 1 to n div 2 do begin
   h := a[i];
   a[i] := a[n-i+1];
   a[n-i+1] := h;
  end;
  t := timer;
  shell;
  t3 := t3+ timer-t;
 end;
{  writeln('   ',t1/vers:0:3,' Hundertstel-Sekunden');
  writeln('   ',t2/vers:0:3,' Hundertstel-Sekunden (sortiert)');
  writeln('   ',t3/vers:0:3,' Hundertstel-Sekunden (verkehrt sortiert)');}
  xalt := x; y1alt := y1; y2alt := y2; y3alt := y3;
  x := round(n / nmax * getmaxx);
  y1 := getmaxy-round(t1/vers / 200 * getmaxy);
  y2 := getmaxy-round(t2/vers / 200 * getmaxy);
  y3 := getmaxy-round(t3/vers / 200 * getmaxy);
  setcolor(red); line(xalt,y1alt, x,y1);
  setcolor(blue); line(xalt,y2alt, x,y2);
  setcolor(green); line(xalt,y3alt, x,y3);
until n > nmax-2000;
  readln;
  closegraph;
end.