unit funktionen;
interface

const epsilon:real=0.0001;
type funktion=function(x:real):real;
function nullstelle(a,b: real; f: funktion):real;

implementation

function nullstelle(a,b: real; f: funktion):real;
var m:real;
begin
if f(a)*f(b)>0 then exit;
m:=(a+b)/2;
repeat
 if f(a)*f(m)<=0 then b:=m else a:=m;
 m:=(a+b)/2;
until abs(f(m))<epsilon;
 nullstelle:=m;
end;

end.