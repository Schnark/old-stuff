unit koordinaten;
interface
type
bahnebene = record
            r, u: real;
            {Abstand von Sonne, Winkel aufsteigender Knoten - Sonne - Planet}
            end;
helio_ekl = record {heliozentrisch ekliptikal}
            r, b, l: real;
            {Abstand von Sonne, Winkel Sonne-Planet gegen Ekliptik,
             Winkel Frhlingspunkt - Sonne - Projektion d. Planets}
            end;
geo_ekl   = record {geozentrisch ekliptikal}
            d, beta, lambda: real;
            {Abstand von Erde, Winkel Erde-Planet gegen Ekliptik,
             Winkel Frhlingspunkt - Erde - Projektion d. Planets}
            end;
geo_aequ  = record {geozentrisch „quatorial}
            d, delta, alpha: real;
            {Abstand von Erde, Winkel Erde-Planet gegen Himmels„quator,
             Winkel Frhlingspunkt - Erde - Projektion d. Planets}
            end;
topo_aequ = record {topozentrisch „quatorial}
            d, delta, alpha: real;
            end;
horizontal= record
            h, A: real;
            {H”he ber Horizont, Azimut}
            end;

procedure bahn_helioekl(x: bahnebene; aufKnoten, neigung: real; var y: helio_ekl);
procedure helioekl_geoekl(x: helio_ekl; erde: helio_ekl; var y: geo_ekl);
procedure geoekl_helioekl(x: geo_ekl; erde: helio_ekl; var y: helio_ekl);
procedure geoekl_geoaequ(x: geo_ekl; ekl: real; var y: geo_aequ);
procedure geoaequ_geoekl(x: geo_aequ; ekl: real; var y: geo_ekl);
procedure geoaequ_topoaequ(x: geo_aequ; ort: geo_aequ; var y: topo_aequ);
procedure topoaequ_geoaequ(x: topo_aequ; ort: geo_aequ; var y: geo_aequ);
procedure topoaequ_horiz(x: topo_aequ; sternzeit, breite: real; var y: horizontal);
procedure horiz_topoaequ(x: horizontal; sternzeit, breite: real; var y: topo_aequ);


implementation
procedure loesen(x,y,z: real; var a,b,r: real);
{x=r*cos(a)*cos(b)
 y=r*sin(a)*cos(b)
 z=r*sin(b)       }
var rho,phi: real;
begin
 r:=sqrt(sqr(x)+sqr(y)+sqr(z));
 rho:=sqrt(sqr(x)+sqr(y));
 if rho=0 then begin
    if z>0 then b:=pi/2; if z=0 then b:=0; if z<0 then b:=-pi/2;
 end else begin
    b:=arctan(z/rho);
 end;
 if (x=0) and (y=0) then begin
    a:=0;
 end else begin
    phi:=2*arctan(y/(abs(x)+rho));
    if x<0 then begin
       a:=pi-phi;
    end else begin
       if y>=0 then a:=phi else a:=2*pi+phi;
    end;
 end;
end;

procedure bahn_helioekl(x: bahnebene; aufKnoten, neigung: real; var y: helio_ekl);
var xx,yy,zz,a,b,r: real;
begin
 xx:=cos(x.u);
 yy:=sin(x.u)*cos(neigung);
 zz:=sin(x.u)*sin(neigung);
 loesen(xx,yy,zz,a,b,r);
 y.r:=x.r;
 y.b:=b;
 y.l:=a+aufKnoten;
end;

procedure helioekl_geoekl(x: helio_ekl; erde: helio_ekl; var y: geo_ekl);
var xx,yy,zz,a,b,r:real;
begin
 xx:=x.r*cos(x.b)*cos(x.l)-erde.r*cos(erde.b)*cos(erde.l);
 yy:=x.r*cos(x.b)*sin(x.l)-erde.r*cos(erde.b)*sin(erde.l);
 zz:=x.r*sin(x.b)-erde.r*sin(erde.b);
 loesen(xx,yy,zz,a,b,r);
 y.d:=r;
 y.beta:=b;
 y.lambda:=a;
end;

procedure geoekl_helioekl(x: geo_ekl; erde: helio_ekl; var y: helio_ekl);
var xx,yy,zz,a,b,r:real;
begin
 xx:=x.d*cos(x.beta)*cos(x.lambda)+erde.r*cos(erde.b)*cos(erde.l);
 yy:=x.d*cos(x.beta)*sin(x.lambda)+erde.r*cos(erde.b)*sin(erde.l);
 zz:=x.d*sin(x.beta)+erde.r*sin(erde.b);
 loesen(xx,yy,zz,a,b,r);
 y.r:=r;
 y.b:=b;
 y.l:=a;
end;

procedure geoekl_geoaequ(x: geo_ekl; ekl: real; var y: geo_aequ);
var xx,yy,zz,a,b,r:real;
begin
 xx:=cos(x.beta)*cos(x.lambda);
 yy:=cos(ekl)*cos(x.beta)*sin(x.lambda)-sin(ekl)*sin(x.beta);
 zz:=sin(ekl)*cos(x.beta)*sin(x.lambda)+cos(ekl)*sin(x.beta);
 loesen(xx,yy,zz,a,b,r);
 y.d:=x.d;
 y.alpha:=a;
 y.delta:=b;
end;

procedure geoaequ_geoekl(x: geo_aequ; ekl: real; var y: geo_ekl);
var xx,yy,zz,a,b,r:real;
begin
 xx:=cos(x.delta)*cos(x.alpha);
 yy:=cos(ekl)*cos(x.delta)*sin(x.alpha)+sin(ekl)*sin(x.delta);
 zz:=cos(ekl)*sin(x.delta)-sin(ekl)*cos(x.delta)*sin(x.alpha);
 loesen(xx,yy,zz,a,b,r);
 y.d:=x.d;
 y.lambda:=a;
 y.beta:=b;
end;

procedure geoaequ_topoaequ(x: geo_aequ; ort: geo_aequ; var y: topo_aequ);
var xx,yy,zz,a,b,r:real;
begin
 xx:=x.d*cos(x.delta)*cos(x.alpha)-ort.d*cos(ort.delta)*cos(ort.alpha);
 yy:=x.d*cos(x.delta)*sin(x.alpha)-ort.d*cos(ort.delta)*sin(ort.alpha);
 zz:=x.d*sin(x.delta)-ort.d*sin(ort.delta);
 loesen(xx,yy,zz,a,b,r);
 y.d:=r;
 y.alpha:=a;
 y.delta:=b;
end;

procedure topoaequ_geoaequ(x: topo_aequ; ort: geo_aequ; var y: geo_aequ);
var xx,yy,zz,a,b,r:real;
begin
 xx:=x.d*cos(x.delta)*cos(x.alpha)+ort.d*cos(ort.delta)*cos(ort.alpha);
 yy:=x.d*cos(x.delta)*sin(x.alpha)+ort.d*cos(ort.delta)*sin(ort.alpha);
 zz:=x.d*sin(x.delta)+ort.d*sin(ort.delta);
 loesen(xx,yy,zz,a,b,r);
 y.d:=r;
 y.alpha:=a;
 y.delta:=b;
end;

procedure topoaequ_horiz(x: topo_aequ; sternzeit, breite: real; var y: horizontal);
var xx,yy,zz,a,b,r,t:real;
begin
 t:=sternzeit-x.alpha;
 xx:=sin(breite)*cos(x.delta)*cos(t)-cos(breite)*sin(x.delta);
 yy:=cos(x.delta)*sin(t);
 zz:=sin(breite)*sin(x.delta)+cos(breite)*cos(x.delta)*cos(t);
 loesen(xx,yy,zz,a,b,r);
 y.A:=a;
 y.h:=b;
end;

procedure horiz_topoaequ(x: horizontal; sternzeit, breite: real; var y: topo_aequ);
var xx,yy,zz,a,b,r:real;
begin
 xx:=cos(breite)*sin(x.h)+sin(breite)*cos(x.h)*cos(x.A);
 yy:=cos(x.h)*sin(x.A);
 zz:=sin(breite)*sin(x.h)-cos(breite)*cos(x.h)*cos(x.A);
 loesen(xx,yy,zz,a,b,r);
 y.d:=10;
 y.alpha:=sternzeit-a;
 y.delta:=b;
end;

end.