program EinStein_wuerfelt_nicht;
uses crt;

type TSpieler = (Spieler1, Spieler2);
type TStand = record
              s: TSpieler;
              feld: array[TSpieler, 1 .. 6] of record
                                               x,y: byte; end;
              end;

function wuerfeln: byte;
var w: byte;
begin
 write('Gewrfelte Zahl (oder 0 fr Zufall): '); readln(w);
 if w=0 then w:=random(6)+1;
 writeln('Gewrfelte Zahl                    : ',w);
 wuerfeln:=w;
end;

function schneller(d1,d2: byte; p1,p2: real): real;
var p: real;
begin
 if d1=0 then begin schneller:=1; exit; end;
 if d2=0 then begin schneller:=0; exit; end;
 p:=p1+p2-p1*p2;
 schneller:=(1-p1/p)*schneller(d1,d2-1,p1,p2)+(1-p2/p)*schneller(d1-1,d2,p1,p2)+p1*p2/p*schneller(d1-1,d2-1,p1,p2);
end;


function bewertung(s:TStand): real;
{bewertet fr Spieler s.s, falls anderer an der Reihe}
var chancen: array[TSpieler,1..6] of record
                                  wuerfe: byte; {passende Wrfe}
                                  zuege: byte;  {Abstand zum Ziel}
                                  durch,        {W.-keit durchzukommen}
                                  wert: real;   {Wert des Steins}
                                  end;
    w: real;
    spieler: TSpieler;
    i,j,n,x,y,a,b,z: byte;
    d1,d2: shortint;
    p:real;

begin
 for spieler:=Spieler1 to Spieler2 do
 for i:=1 to 6 do with chancen[spieler,i] do begin
     {passende Wrfe}
     n:=1;
     j:=i-1;
     while (j>=1) and (s.feld[Spieler,j].x=0) do begin
     inc(n); dec(j); end;
     j:=i+1;
     while (j<=6) and (s.feld[Spieler,j].x=0) do begin
     inc(n); inc(j); end;
     if s.feld[Spieler,i].x=0 then n:=0;
     wuerfe:=n;
 end;
 for i:=1 to 6 do with chancen[Spieler1,i] do if wuerfe<>0 then begin
     {Min. Zge zum Ziel}
     zuege:=s.feld[Spieler1,i].x-1; if zuege<s.feld[Spieler1,i].y-1 then zuege:=s.feld[Spieler1,i].y-1;

     {Bedrohungen}
     durch:=1;
     x:=s.feld[Spieler1,i].x; y:=s.feld[Spieler1,i].y;
     for j:=1 to 6 do if chancen[Spieler2,j].wuerfe<>0 then begin
         a:=s.feld[Spieler2,j].x; b:=s.feld[Spieler2,j].y;
         if (a<=x) and (b<=y) then begin
            z:=a; if z>b then z:=b;
            if (a-x)=(b-y) then d1:=x-a
            else if (a=1) and (y-b>z-1) then d1:=y-b
            else if (b=1) and (x-a>z-1) then d1:=x-a
            else begin d1:=x-a; if y-b<d1 then d1:=y-b; d1:=d1+1; end;
            d2:=abs(x-y-a+b);
            if d2=0 then d2:=1;
            if (a=1) and (y-b>z-1) then d2:=1;
            if (b=1) and (x-a>z-1) then d2:=1;
            if s.s=Spieler1 then p:=1-schneller(d2,d1,chancen[Spieler2,j].wuerfe/6,chancen[Spieler1,i].wuerfe/6)
               else p:=schneller(d1,d2,chancen[Spieler1,i].wuerfe/6,chancen[Spieler2,j].wuerfe/6);
            durch:=durch*p;
         end;
     end;
 end;
 for i:=1 to 6 do with chancen[Spieler1,i] do if wuerfe=0 then begin
     wert:=0; durch:=0; end;

 for i:=1 to 6 do with chancen[Spieler2,i] do if wuerfe<>0 then begin
     {Min. Zge zum Ziel}
     zuege:=5-s.feld[Spieler2,i].x; if zuege<5-s.feld[Spieler2,i].y then zuege:=5-s.feld[Spieler2,i].y;

     {Bedrohungen}
     durch:=1;
     x:=s.feld[Spieler2,i].x; y:=s.feld[Spieler2,i].y;
     for j:=1 to 6 do if chancen[Spieler1,j].wuerfe<>0 then begin
         a:=s.feld[Spieler1,j].x; b:=s.feld[Spieler1,j].y;
         if (x<=a) and (y<=b) then begin
            z:=a; if z<b then z:=b;
            if (a-x)=(b-y) then d1:=a-x
            else if (a=5) and (b-y>5-z) then d1:=b-y
            else if (b=5) and (a-x>5-z) then d1:=a-x
            else begin d1:=a-x; if b-y<d1 then d1:=b-y; d1:=d1+1; end;
            d2:=abs(x-y-a+b);
            if d2=0 then d2:=1;
            if (a=5) and (b-y>5-z) then d2:=1;
            if (b=5) and (a-x>5-z) then d2:=1;
            if s.s=Spieler1 then p:=1-schneller(d2,d1,chancen[Spieler2,i].wuerfe/6,chancen[Spieler1,j].wuerfe/6)
               else p:=schneller(d1,d2,chancen[Spieler1,j].wuerfe/6,chancen[Spieler2,i].wuerfe/6);
            durch:=durch*p;
         end;
     end;
 end;
 for i:=1 to 6 do with chancen[Spieler2,i] do if wuerfe=0 then begin
     wert:=0; durch:=0; end;

 for i:=1 to 6 do with chancen[s.s,i] do if wuerfe<>0 then begin
     wert:=durch;
     for j:=1 to 6 do if chancen[TSpieler(1-ord(s.s)),j].wuerfe<>0 then begin
         wert:=wert*(1-chancen[TSpieler(1-ord(s.s)),j].durch+
                       chancen[TSpieler(1-ord(s.s)),j].durch*
                       (1-schneller(chancen[TSpieler(1-ord(s.s)),j].zuege,zuege,
                       chancen[TSpieler(1-ord(s.s)),j].wuerfe/6,wuerfe/6)));
     end;
 end;
 w:=1;
 for i:=1 to 6 do with chancen[s.s,i] do if wuerfe<>0 then
     w:=w*(1-wert);
 p:=1;
 for i:=1 to 6 do with chancen[Spieler1,i] do if wuerfe<>0 then
     p:=p*(1-durch);
 for i:=1 to 6 do with chancen[Spieler2,i] do if wuerfe<>0 then
     p:=p*(1-durch);
 w:=1-w+0.5*p;
 bewertung:=w;
end;


procedure loesche;
begin
 clrscr;
 writeln('ÚÄÄÄÂÄÄÄÂÄÄÄÂÄÄÄÂÄÄÄ¿');
 writeln('³   ³   ³   ³   ³   ³');
 writeln('ÃÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´');
 writeln('³   ³   ³   ³   ³   ³');
 writeln('ÃÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´');
 writeln('³   ³   ³   ³   ³   ³');
 writeln('ÃÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´');
 writeln('³   ³   ³   ³   ³   ³');
 writeln('ÃÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´');
 writeln('³   ³   ³   ³   ³   ³');
 writeln('ÀÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÙ');
end;

procedure schreibe ( s: TStand );
var i: byte;
    w: real;
begin
 loesche;
 textcolor(red);
 for i:=1 to 6 do with s.feld[Spieler1,i] do
     if x<>0 then begin gotoxy(4*x-1,2*y); write(i); end;
 textcolor(blue);
 for i:=1 to 6 do with s.feld[Spieler2,i] do
     if x<>0 then begin gotoxy(4*x-1,2*y); write(i); end;
 textcolor(lightgray);
 gotoxy(1,13);
 if s.s=Spieler1 then write('Spieler ROT') else write('Spieler BLAU');
 w:=100*bewertung(s);
 write(' (mit Gewinnwahrscheinlichkeit ',w:0:1,' % )');
end;

procedure startaufstellung( var s: TStand );
var stellung: array[1..6] of byte;
    i,j: byte;
begin
for i:=1 to 6 do stellung[i]:=0;
writeln('Startaufstellung Spieler ROT');
writeln('Eingabe (Stein an Spitze, zwei Steine darunter (links nach rechts),');
writeln(' untere drei Steine (links nach rechts); 0 fr Zufall');
write('1. Stein: '); readln(stellung[1]);
if stellung[1]<>0 then for i:=2 to 6 do begin
   write(i,'. Stein: '); readln(stellung[i]); end
else
   for i:=1 to 6 do repeat
       j:=random(6)+1;
       if stellung[j]=0 then stellung[j]:=i;
       until stellung[j]=i;
for i:=1 to 6 do begin
{   1 5,3
    2 4,4
    3 5,4
    4 5,5
    5 4,5
    6 5,5  }
    s.feld[Spieler1,stellung[i]].x:=i+3*((6-i) div 3)+2*((6-i) div 5)-1;
    s.feld[Spieler1,stellung[i]].y:=6-(6-i) div 3 - (6-i) div 5-1;
end;
for i:=1 to 6 do stellung[i]:=0;
writeln;

writeln('Startaufstellung Spieler BLAU');
writeln('Eingabe (Stein an Spitze, zwei Steine darber (rechts nach links),');
writeln(' obere drei Steine (rechts nach links); 0 fr Zufall');
write('1. Stein: '); readln(stellung[1]);
if stellung[1]<>0 then for i:=2 to 6 do begin
   write(i,'. Stein: '); readln(stellung[i]); end
else
   for i:=1 to 6 do repeat
       j:=random(6)+1;
       if stellung[j]=0 then stellung[j]:=i;
       until stellung[j]=i;
for i:=1 to 6 do begin
{   1 1,3
    2 2,2
    3 1,2
    4 3,1
    5 2,1
    6 1,1  }
    s.feld[Spieler2,stellung[i]].x:=7-i-3*((6-i) div 3)-2*((6-i) div 5);
    s.feld[Spieler2,stellung[i]].y:=1+(6-i) div 3 + (6-i) div 5;
end;
end;

function computer( s: TStand; w: byte; it: shortint; var z_: byte; var c: char): real;
{Der Computer macht einen Zug}

var s_: TStand;
    z: array[1..2] of byte;
    i,j: byte;
    d: shortint;
    erlaubt: array[1..2,1..3] of boolean;
                      {s w d}
    wert: array[1..2,1..3] of real;
    maxw: real;
    maxi, maxj: byte;
begin
 z[1]:=w; while (z[1]>=1) and (s.feld[s.s,z[1]].x=0) do dec(z[1]);
 z[2]:=w; while (z[2]<=6) and (s.feld[s.s,z[2]].x=0) do inc(z[2]);
 for i:=1 to 2 do for j:=1 to 3 do erlaubt[i,j]:=true;
 if z[1]=0 then for j:=1 to 3 do erlaubt[1,j]:=false;
 if (z[2]=7) or (z[2]=z[1]) then for j:=1 to 3 do erlaubt[2,j]:=false;
 for i:=1 to 2 do for j:=1 to 3 do if erlaubt[i,j] then begin
  if (ord(s.s)*4+1=s.feld[s.s,z[i]].x) and (j<>1) then erlaubt[i,j]:=false;
  if (ord(s.s)*4+1=s.feld[s.s,z[i]].y) and (j<>2) then erlaubt[i,j]:=false;
 end;

 for i:=1 to 2 do for j:=1 to 3 do if erlaubt[i,j] then begin
   if s.s=Spieler1 then d:=-1 else d:=+1;
   s_:=s;
   if j>=2 then s_.feld[s.s,z[i]].x:=s_.feld[s.s,z[i]].x+d;
   if odd(j) then s_.feld[s.s,z[i]].y:=s_.feld[s.s,z[i]].y+d;
   {Schlagen}
   for d:=1 to 6 do with s_.feld[s.s,d] do
     if (d<>z[i]) and (x=s_.feld[s.s,z[i]].x) and (y=s_.feld[s.s,z[i]].y) then s_.feld[s.s,d].x:=0;
   for d:=1 to 6 do with s_.feld[TSpieler(1-ord(s.s)),d] do
     if (x=s_.feld[s.s,z[i]].x) and (y=s_.feld[s.s,z[i]].y) then s_.feld[TSpieler(1-ord(s.s)),d].x:=0;
   wert[i,j]:=bewertung(s_);
   if it=-1 then wert[i,j]:=random;
   if (it>=1) and (abs(wert[i,j])<0.99) then
   begin wert[i,j]:=0;
        s_.s:=TSpieler(1-ord(s.s));
        for w:=1 to 6 do wert[i,j]:=wert[i,j]+1-computer(s_,w,it-1,z_,c);
        wert[i,j]:=wert[i,j]/6; end;
 end;
 maxw:=-1;
 for i:=1 to 2 do for j:=1 to 3 do if erlaubt[i,j] then
     if wert[i,j]>maxw then begin
        maxw:=wert[i,j]; maxi:=i; maxj:=j;
     end;
 computer:=maxw;
 z_:=z[maxi]; if maxj=1 then c:='s'; if maxj=2 then c:='w'; if maxj=3 then c:='d';
end;

function schritt( var s: TStand ): boolean;
const iterationen=0;
var w,z: byte;
    c: char;
    b,b2: boolean;
    d: shortint;
    verboten: boolean;
begin
 b:=false;
 schreibe(s);
 writeln;
 w:=wuerfeln;
 (* writeln(computer(s,w,2,z,c),' mit ',z,', ',c); *)
 write('Zu ziehender Stein (0 fr Computer): '); readln(z);
 if z<>0 then begin
 repeat
  {Prfe z}
  verboten:=s.feld[s.s,z].x=0;
  if z<w then for d:=w downto z+1 do if s.feld[s.s,d].x<>0 then verboten:=true;
  if z>w then for d:=w to z-1 do if s.feld[s.s,d].x<>0 then verboten:=true;
  if verboten then begin gotoxy(1,17); clreol; write('Neueingabe: '); readln(z); end;
 until not verboten;
 gotoxy(1,17); clreol;
 write('Richtung: (w)aagerecht, (s)enkrecht, (d)iagonal: '); readln(c);
 {Prfe c}
 repeat
  verboten:=false;
  if (ord(s.s)*4+1=s.feld[s.s,z].x) and (c<>'s') then verboten:=true;
  if (ord(s.s)*4+1=s.feld[s.s,z].y) and (c<>'w') then verboten:=true;
  if not (c in ['s','w','d']) then verboten:=true;
  if verboten then begin gotoxy(1,18); clreol; write('Neueingabe: '); readln(c); end;
 until not verboten;
 end else begin writeln(100*computer(s,w,iterationen,z,c):0:1); if iterationen>0 then delay(2000); end;
 {Ziehe}
 if s.s=Spieler1 then d:=-1 else d:=+1;
 if (c='w') or (c='d') then inc(s.feld[s.s,z].x,d);
 if (c='s') or (c='d') then inc(s.feld[s.s,z].y,d);
 {Schlagen}
 for d:=1 to 6 do with s.feld[s.s,d] do
     if (d<>z) and (x=s.feld[s.s,z].x) and (y=s.feld[s.s,z].y) then s.feld[s.s,d].x:=0;
 for d:=1 to 6 do with s.feld[TSpieler(1-ord(s.s)),d] do
     if (x=s.feld[s.s,z].x) and (y=s.feld[s.s,z].y) then s.feld[TSpieler(1-ord(s.s)),d].x:=0;

 with s.feld[s.s,z] do if ((x=1) and (y=1)) or ((x=5) and (y=5)) then b:=true;
 {im Ziel ?}

 s.s:=TSpieler(1-ord(s.s));
 b2:=false;
 for z:=1 to 6 do if s.feld[s.s,z].x<>0 then b2:=true; {Ausgerottet ?}
 if not b2 then b:=true;

 if b then begin
    s.s:=TSpieler(1-ord(s.s));
    schreibe(s); write(' hat gewonnen!');
 end;
 schritt:=b;
end;

var s: TStand;


begin
clrscr;
randomize;
startaufstellung(s);
repeat until schritt(s);
readln;
end.
