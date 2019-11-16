uses astronomie,funktionen;
{$F+}function f(t: real):real;{$F-}begin f:=mondphase(t)-180; end;
var t: real;
    d,m,j,h,min: integer; s: real;
begin
writeln(JD(15,3,2006,0,37,0)-JD(13,2,2006,05,45,0):0:5);
d:=14;m:=3;j:=2006;h:=0;min:=0;s:=0;   {Vollmond 14.1.2006 10:49 = 180ø
                                                 13.2.2006  5:45
                                                 15.3.2006  0:37}
MEZ_GMT(d,m,j,h,min);
t:=JD(d,m,j,h,min,s)-J2000_0;
{write(ZG(t)/360*24*60:0:5)};
{s:=6+wahre_sonne(t)/360*24;
h:=trunc(s); min:=trunc(60*(s-h)); s:=s-h-min/60;
write(' ',h,':',min,':',s:0:1,' ');}
t:=nullstelle(t,t+2,f);
datum(J2000_0+t+1/24{GMT->MEZ},d,m,j,h,min,s);
write(d,'. ',m,'. ',j,' ',h,':',min,':',s:0:1,' : ');
write(mondphase(t):0:5); readln
end.