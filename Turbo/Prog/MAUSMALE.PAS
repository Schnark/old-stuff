program mauszeiger_malen;
uses graph,graph2,maus;
var feld: array[1..16,1..16] of 0..3;
    name:string;
    x,y,taste:integer;
    i,j:integer;
    modus:integer;

procedure laden(name:string);
var f: file of word;
    wert: word;
    zeile,spalte:integer;
begin
 assign(f,name);
 reset(f);
 for zeile:=1 to 16 do begin
     read(f,wert);
     for spalte:=16 downto 1 do begin
         feld[spalte,zeile]:=2*(wert mod 2);
         wert:=wert div 2;
         end;
 end;
 for zeile:=1 to 16 do begin
     read(f,wert);
     for spalte:=16 downto 1 do begin
         feld[spalte,zeile]:=feld[spalte,zeile]+(wert mod 2);
         wert:=wert div 2;
         end;
 end;
 close(f);
end;

procedure speichern(name:string);
var f: file of word;
    wert: word;
    zeile,spalte:integer;
begin
 assign(f,name);
 rewrite(f);
 for zeile:=1 to 16 do begin
     wert:=0;
     for spalte:=1 to 16 do
         wert:=2*wert+(feld[spalte,zeile] div 2);
     write(f,wert);
 end;
 for zeile:=1 to 16 do begin
     wert:=0;
     for spalte:=1 to 16 do
         wert:=2*wert+(feld[spalte,zeile] mod 2);
     write(f,wert);
 end;
 close(f);
end;

procedure raster;
var i,j:integer;
begin
 setfillstyle(solidfill,red);
 bar(0,0,getmaxx,getmaxy);
 for i:=1 to 16 do
     for j:=1 to 16 do begin
         setcolor(black);
         setfillstyle(solidfill,((feld[i,j]*15) mod 26) mod 16);
         bar3d(50+20*i,50+20*j,70+20*i,70+20*j,0,false);
         putpixel(i,j,((feld[i,j]*15) mod 26) mod 16);
     end;
end;




begin
write('Datei: '); readln(name);
if name<>'' then
   laden(name)
else
   for i:=1 to 16 do for j:=1 to 16 do feld[i,j]:=2;
modus:=0;
init;

repeat
 raster;
 mauson;
 repeat
  taste:=mausget(x,y);
 until taste<>0;
 i:=(x-50) div 20; j:=(y-50) div 20;
 if (0<i) and (i<17) and (0<j) and (j<17) then
          if modus=0 then feld[i,j]:=taste-1 else feld[i,j]:=4-taste
 else
          modus:=1-modus;
 mausoff;
until taste=4;
closegraph;
write('Name: '); readln(name);
if name<>'' then speichern(name);
end.