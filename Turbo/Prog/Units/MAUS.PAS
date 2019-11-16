unit maus;
interface

type mauszeiger=array[1..2,1..16] of word;
{Grafikmauszeiger}

procedure mausinit;
{Initialisiert die Maus (beim Start automatisch)}
procedure mauson;
{schaltet die Maus ein}
procedure mausoff;
{schaltet die Maus aus}
procedure lade(name:string; var feld:mauszeiger);
{L„dt einen Mauszeiger aus einer Datei}
procedure mausgraphik(seg, ofs, x,y: word);
{richtet Grafikmauszeiger (bei seg:ofs) ein; (x,y) ist die Spitze}
procedure mausarea(o, u, l, r: integer);
{beschr„nkt die Maus auf ein Gebiet}
procedure mausset(x, y: integer);
{setzt die Maus}
function mausget(var x, y: integer): integer;
{gibt Ort und Taste zurck}

implementation
uses dos;

procedure mausinit;
var reg: registers;
begin
   reg.ax := $0;
   intr($33,reg);
end;

procedure mauson;
var reg: registers;
begin
   reg.ax := $1;
   intr($33,reg);
   reg.ax := $3;
   intr($33,reg);
end;

procedure mausoff;
var reg: registers;
begin
   reg.ax := $2;
   intr($33,reg);
end;

procedure lade(name:string; var feld:mauszeiger);
var f: file of mauszeiger;
begin
 assign(f,name);
 reset(f);
 read(f,feld);
 close(f);
end;

procedure mausgraphik(seg, ofs, x,y: word);
var reg: registers;
begin
   reg.ax:=$9;
   reg.bx:=x;
   reg.cx:=y;
   reg.es:=seg;
   reg.dx:=ofs;
   intr($33,reg);
end;

procedure mausarea(o, u, l, r: integer);
var reg: registers;
begin
   reg.ax := $7;
   reg.cx := l;
   reg.dx := r;
   intr($33,reg);
   reg.ax := $8;
   reg.cx := o;
   reg.dx := u;
   intr($33,reg);
end;

procedure mausset(x, y: integer);
var reg: registers;
begin
   reg.ax := $4;
   reg.cx := x;
   reg.dx := y;
   intr($33,reg);
end;

function mausget(var x, y: integer): integer;
var reg: registers;
    taste: integer;
begin
   reg.ax := $3;
   intr($33,reg);
   x := reg.cx;
   y := reg.dx;
   taste := reg.bx;
   {if taste <> 0 then
      repeat
         reg.ax := $6;
         intr($33,reg);
      until reg.bx <> 0;}
   mausget := taste;
end;

begin;
mausinit;
end.