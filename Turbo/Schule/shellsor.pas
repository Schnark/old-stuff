program shellsort;
uses crt, zeit;

const nmax = 64000;
var a: array[1 .. nmax] of byte;
    n,i,t,t1,t2,t3: longint;
    h,j,vers: byte;

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
clrscr;
randomize;
write('n ( <= ',nmax,'): ');
readln(n);
write('Versuche: '); readln(vers);
t1 := 0; t2 := 0; t3 := 0;

for j := 1 to vers do begin
 for i := 1 to n do a[i] := random(255);
 t := timer;
 shell;
 t1 := t1+ timer-t;

 t := timer;
 shell;
 t2 := t2+ timer-t;

 for i := 1 to n div 2 do begin h := a[i]; a[i] := a[n-i+1]; a[n-i+1] := h; end;
 t := timer;
 shell;
 t3 := t3+ timer-t;
end;
 writeln(t1/vers:0:3,' Hundertstel-Sekunden');
 writeln(t2/vers:0:3,' Hundertstel-Sekunden (sortiert)');
 writeln(t3/vers:0:3,' Hundertstel-Sekunden (verkehrt sortiert)');

 readln;
{for i := 1 to n do begin
 write(a[i]:6);
 if i mod 12 = 0 then writeln;
 if i mod 264 = 0 then readln;
end;
readln;}
end.