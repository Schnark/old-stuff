{Include-Datei: Berechnen, Ausgabe}
procedure koordinaten(xvon,yvon:real; var x,y: integer);
begin
x:=round( (xvon-koordsys.xmin)/(koordsys.xmax-koordsys.xmin) * getmaxx);
y:=round( (yvon-koordsys.ymax)/(koordsys.ymin-koordsys.ymax) * getmaxy);
end;

procedure koordzurueck(xvon,yvon:integer; var x,y: real);
begin
x:=xvon/getmaxx*(koordsys.xmax-koordsys.xmin)+koordsys.xmin;
y:=yvon/getmaxy*(koordsys.ymin-koordsys.ymax)+koordsys.ymax;
end;


procedure punkt.aktualisiere;
var t,rx1,ry1,rx2,ry2,dx,dy,D:real;
   {t,rx1,ry1        ,dx,dy,D,}a,b,c:real;
   x1,x2,y1,y2,r1,r2,aa,bb:real;
begin
 if aenderung=aenderungsnr then exit;
 definiert:=true;
 case konstr.konstruktion of
      ko: begin
           x:=konstr.xk; y:= konstr.yk;
          end;
      gg: begin
           konstr.g1^.aktualisiere;
           konstr.g2^.aktualisiere;
           if not konstr.g1^.definiert or not konstr.g2^.definiert then
              definiert:=false
           else begin
                dx:=konstr.g2^.svx-konstr.g1^.svx;
                dy:=konstr.g2^.svy-konstr.g1^.svy;
                rx1:=konstr.g1^.rvx; ry1:=konstr.g1^.rvy;
                rx2:=konstr.g2^.rvx; ry2:=konstr.g2^.rvy;
                D:=rx1*ry2-rx2*ry1;
                if D<>0 then begin
                   t:=(dx*ry1-dy*rx1)/D;
                   x:=konstr.g2^.svx+t*rx2;
                   y:=konstr.g2^.svy+t*ry2;
                end
                else
                    definiert:=false;
           end;
          end;
      gk: begin
           konstr.g^.aktualisiere;
           konstr.k^.aktualisiere;
           if not konstr.g^.definiert or not konstr.k^.definiert then
              definiert:=false
           else begin
                dx:=konstr.g^.svx-konstr.k^.mx;
                dy:=konstr.g^.svy-konstr.k^.my;
                rx1:=konstr.g^.rvx; ry1:=konstr.g^.rvy;
                a:=sqr(rx1)+sqr(ry1);
                b:=2*(rx1*dx+ry1*dy);
                c:=sqr(dx)+sqr(dy)-sqr(konstr.k^.r);
                D:=sqr(b)-4*a*c;
                if D<0 then
                   definiert:=false
                else begin
                     D:=sqrt(D);
                     if konstr.nrgk=1 then t:=-b+D else t:=-b-D;
                     t:=t/(2*a);
                     x:=t*rx1+konstr.g^.svx;
                     y:=t*ry1+konstr.g^.svy;
                end;
           end;
          end;
      kk: begin
           konstr.k1^.aktualisiere;
           konstr.k2^.aktualisiere;
           if not konstr.k1^.definiert or not konstr.k2^.definiert then
              definiert:=false
           else begin
                {Kreise sind definiert}
                x1:=konstr.k1^.mx; x2:=konstr.k2^.mx;
                y1:=konstr.k1^.my; y2:=konstr.k2^.my;
                r1:=konstr.k1^.r;  r2:=konstr.k2^.r;
                if y1<>y2 then begin
                   {verschiedene y-Werte}
                   aa:=(sqr(r1)-sqr(r2)+sqr(x2)-sqr(x1)+sqr(y2)-sqr(y1))/(2*y2-2*y1);
                   bb:=(x1-x2)/(y2-y1);
                   {y=aa+bb*x}
                   a:=1+sqr(bb); b:=2*((aa-y1)*bb-x1); c:=sqr(aa-y1)+sqr(x1)-sqr(r1);
                   D:=sqr(b)-4*a*c;
                   if D<0 then
                      definiert:=false
                   else begin
                      D:=sqrt(D);
                      if konstr.nrkk=1 then t:=-b+D else t:=-b-D;
                      t:=t/(2*a);
                      x:=t;
                      y:=aa+bb*t;
                   end;
                end
                else begin
                   {gleiche y-Werte}
                   aa:=sqr(r1)-sqr(r2)+sqr(x1)-sqr(x2);
                   bb:=2*x2-2*x1;
                   t:=bb/aa;
                   x:=t;
                   a:=1; b:= -2*y1; c:=sqr(y1)-sqr(r1)+sqr(t-x1);
                   D:=sqr(b)-4*a*c;
                   if D<0 then
                      definiert:=false
                   else begin
                      D:=sqrt(D);
                      if konstr.nrkk=2 then t:=-b+D else t:=-b-D;
                      t:=t/(2*a);
                      y:=t;
                   end;
                end;
           end;
          end;
      ms: begin
           konstr.p1^.aktualisiere;
           konstr.p2^.aktualisiere;
           if not konstr.p1^.definiert or not konstr.p2^.definiert then
              definiert:=false
           else begin
                x:=(konstr.p1^.x+konstr.p2^.x)/2;
                y:=(konstr.p1^.y+konstr.p2^.y)/2;
           end;
          end;
      mk: begin
           konstr.kk^.aktualisiere;
           if not konstr.kk^.definiert then
              definiert:=false
           else
                x:=konstr.kk^.mx; y:= konstr.kk^.my;
          end;
 end;
 inherited aktualisiere;
end;

procedure gerade.aktualisiere;
var ax,ay,l:real;
begin
 if aenderung=aenderungsnr then exit;
 definiert:=true;
 case konstr.konstruktion of
      p2: begin
           konstr.p1^.aktualisiere;
           konstr.p2^.aktualisiere;
           if not konstr.p1^.definiert or not konstr.p2^.definiert then
              definiert:=false
           else begin
                svx:=konstr.p1^.x; svy:=konstr.p1^.y;
                rvx:=konstr.p2^.x-konstr.p1^.x;
                rvy:=konstr.p2^.y-konstr.p1^.y;
                if (rvx=0) and (rvy=0) then definiert:=false;
           end;
          end;
      pa: begin
           konstr.gp^.aktualisiere;
           if not konstr.gp^.definiert then
              definiert:=false
           else begin
                rvx:=konstr.gp^.rvx; rvy:=konstr.gp^.rvy;
                ax:=rvy;ay:=-rvx;
                l:=sqrt(sqr(ax)+sqr(ay));
                l:=konstr.d/l;
                svx:=ax*l+konstr.gp^.svx;
                svy:=ay*l+konstr.gp^.svy;
           end;
          end;
      pp: begin
           konstr.g^.aktualisiere;
           konstr.p^.aktualisiere;
           if not konstr.g^.definiert or not konstr.p^.definiert then
              definiert:=false
           else begin
                rvx:=konstr.g^.rvx; rvy:=konstr.g^.rvy;
                svx:=konstr.p^.x; svy:=konstr.p^.y;
           end;
          end;
      sp: begin
           konstr.g^.aktualisiere;
           konstr.p^.aktualisiere;
           if not konstr.g^.definiert or not konstr.p^.definiert then
              definiert:=false
           else begin
                rvx:=-konstr.g^.rvy; rvy:=konstr.g^.rvx;
                svx:=konstr.p^.x; svy:=konstr.p^.y;
           end;
          end;
      tp: begin
           konstr.k^.aktualisiere;
           konstr.pt^.aktualisiere;
           if not konstr.k^.definiert or not konstr.pt^.definiert then
              definiert:=false
           else begin
                write(#7);
           end;
          end;
      wh: begin
           konstr.g1^.aktualisiere;
           konstr.g2^.aktualisiere;
           if not konstr.g1^.definiert or not konstr.g2^.definiert then
              definiert:=false
           else begin
                write(#7);
           end;
          end;
      ww: begin
           konstr.gw^.aktualisiere;
           konstr.pw^.aktualisiere;
           if not konstr.gw^.definiert or not konstr.pw^.definiert then
              definiert:=false
           else begin
                write(#7);
           end;
          end;
 end;
 inherited aktualisiere;
end;

procedure kreis.aktualisiere;
begin
 if aenderung=aenderungsnr then exit;
 definiert:=true;
 case konstr.konstruktion of
      mr: begin
           konstr.p^.aktualisiere;
           if not konstr.p^.definiert then
              definiert:=false
           else begin
                mx:=konstr.p^.x; my:=konstr.p^.y;
                r:=konstr.r;
           end;
          end;
      mp: begin
           konstr.p1^.aktualisiere;
           konstr.p2^.aktualisiere;
           if not konstr.p1^.definiert or not konstr.p2^.definiert then
              definiert:=false
           else begin
                mx:=konstr.p1^.x; my:=konstr.p1^.y;
                r:=sqrt(sqr(konstr.p1^.x-konstr.p2^.x)
                       +sqr(konstr.p1^.y-konstr.p2^.y));
           end;
          end;
 end;
 inherited aktualisiere;
end;

procedure punkt.ausgabe;
begin
if not sichtbar then exit;
inherited ausgabe;
write(name:3);
if definiert then writeln('  (',x:5:2,'|',y:5:2,')')
             else writeln('  (nicht definiert)');
end;

procedure gerade.ausgabe;
begin
if not sichtbar then exit;
inherited ausgabe;
write(name:3);
if definiert then writeln('  (',svx:5:2,'|',svy:5:2,')+t*(',rvx:5:2,'|',rvy:5:2,')')
             else writeln('  (nicht definiert)');
end;

procedure kreis.ausgabe;
begin
if not sichtbar then exit;
inherited ausgabe;
write(name:3);
if definiert then writeln('  (',mx:5:2,'|',my:5:2,')  ',r:5:2)
             else writeln('  (nicht definiert)');
end;

procedure punkt.zeichne;
var xx,yy: integer;
begin
if not sichtbar then exit;
inherited zeichne;
if not definiert then exit;
koordinaten(x,y,xx,yy);
setcolor(koordsys.pfarbe);
setfillstyle(solidfill, koordsys.pfarbe);
pieslice(xx,yy, 0,360, 2);
end;

procedure gerade.zeichne;
var x1,x2,y1,y2: integer;
    a,b: real;
begin
if not sichtbar then exit;
inherited zeichne;
if not definiert then exit;
setcolor(koordsys.gfarbe);
if abs(rvx)<abs(rvy) then begin
 a:=(svy-koordsys.ymin)/rvy;
 b:=(koordsys.ymax-svy)/rvy;
end
else begin
 a:=(svx-koordsys.xmin)/rvx;
 b:=(koordsys.xmax-svx)/rvx;
end;
koordinaten(svx-a*rvx,svy-a*rvy,x1,y1);
koordinaten(svx+b*rvx,svy+b*rvy,x2,y2);
line(x1,y1,x2,y2);
end;

procedure kreis.zeichne;
var x, y: integer;
begin
if not sichtbar then exit;
inherited zeichne;
if not definiert then exit;
koordinaten(mx,my,x,y);
setcolor(koordsys.kfarbe);
ellipse(x,y, 0,360, round(r/(koordsys.xmax-koordsys.xmin)*getmaxx),
                    round(r/(koordsys.ymax-koordsys.ymin)*getmaxy));
end;


function punkt.koordin;
var xx,yy:real;
begin
 if not sichtbar or not definiert then begin koordin:=false; exit; end;
 koordzurueck(xk,yk,xx,yy);
 if sqr(xx-x)+sqr(yy-y)<=sqr(eps) then koordin:=true else koordin:=false;
end;

function gerade.koordin;
var xx,yy,t:real;
begin
 if not sichtbar or not definiert then begin koordin:=false; exit; end;
 koordzurueck(xk,yk,xx,yy);
 t:=(svy-yy)*rvx-(svx-xx)*rvy;
 t:=t/(sqr(rvx)+sqr(rvy));
 t:=sqrt(sqr(t*rvx)+sqr(t*rvy));
 if t<=eps then koordin:=true else koordin:=false;
end;

function kreis.koordin;
var xx,yy:real;
begin
 if not sichtbar or not definiert then begin koordin:=false; exit; end;
 koordzurueck(xk,yk,xx,yy);
 if abs(sqrt(sqr(xx-mx)+sqr(yy-my))-r)<=eps then koordin:=true else koordin:=false;
end;
