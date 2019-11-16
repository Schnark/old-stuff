unit zahlen {theorie};
interface
function ggT(a, b:integer): integer;
function kgV(a, b:integer): integer;
function prim(p: integer): boolean;
function faktor(zahl: integer; var potenz: integer): integer;
implementation
var speicher: integer;

function ggT(a, b:integer): integer;
begin
repeat
if a > b then a := a mod b else b := b mod a;
until a*b = 0;
ggT := a + b;
end;

function kgV(a, b:integer): integer;
begin
kgV := a * b div ggT(a, b);
end;

function prim(p: integer): boolean;
var i: integer;
begin
if p = 2 then begin prim := true; exit; end;
if (trunc(p / 2) * 2 = p) or (p = 1) then begin prim := false; exit; end;
i := 3;
while i * i <= p do
begin
 if trunc(p / i) * i = p then begin prim := false; exit; end;
 i := i + 2;
end;
prim := true;
end;

function faktor(zahl: integer; var potenz: integer): integer;
var teiler: integer;
    ende: boolean;
begin
 if zahl <= 0 then zahl := speicher;
 ende := false;
 if zahl = 1 then
 begin
  potenz := 0;
  faktor := 1;
  speicher := 1;
  ende := true;
 end;
 teiler := 2;
 while not ende do
 begin
  if prim(teiler) then
  begin
   if zahl mod teiler = 0 then
   begin
    potenz := 0;
    repeat
     potenz := potenz + 1;
     zahl := zahl div teiler;
    until zahl mod teiler <> 0;
    speicher := zahl;
    faktor := teiler;
    ende := true;
   end;
  end;
  teiler := teiler + 1;
 end;
end;

end.