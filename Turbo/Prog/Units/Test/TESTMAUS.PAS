program maustest;
{$define graph}
uses crt,
{$ifdef graph}
graph, graph2,
{$endif}
maus;
var x, y, taste, altx, alty: integer;
var tastes: string;
{$ifdef graph}
var mz: mauszeiger;
var i: integer;
{$endif}

begin
{$ifdef graph}
init;
for i:=1 to getmaxy div 10 do begin setcolor(random(16)); setfillstyle(solidfill,random(16));
                                    bar(0,10*i-10,getmaxx,10*i); end;
setcolor(black);
lade('ziel.mmz',mz);
mausgraphik(seg(mz),ofs(mz),9,9);
{$else}
clrscr;
{$endif}
mauson;
altx := 0; alty := 0;
repeat
 repeat
  taste := mausget(x, y);
 until taste <> 0;
 repeat until (mausget(x, y) <> taste) or (x <> altx) or (y <> alty);
 mausoff;
 {$ifdef graph}
 str(taste, tastes); outtextxy(x, y, tastes);
 {$else}
 gotoxy(x div 8 + 1, y div 8 + 1); write(taste);
 {$endif}
 mauson;
 if taste = 2 then mausset(altx, alty) else begin altx := x; alty := y; end;
until taste = 4;
mausoff;
delay(1000);
{$ifdef graph}
closegraph;
{$endif}
end.