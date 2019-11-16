program test3D;
uses graph,graph2,crt,keyb;
const epsilon = 1;
const xx: array[1..8] of real = (1,1,-1,-1,1,1,-1,-1);
      yy: array[1..8] of real = (-1,1,1,-1,-1,1,1,-1);
      zz: array[1..8] of real = (-1,-1,-1,-1,1,1,1,1);
const a1: array[1..12] of byte = (1,3,1,6,3,6,4,7,1,8,5,7);
      a2: array[1..12] of byte = (2,4,2,5,2,7,3,8,5,4,6,8);
      a3: array[1..12] of byte = (3,1,6,1,6,3,7,4,8,1,7,5);
      ff: array[1..12] of byte = (1,1,2,2,3,3,4,4,5,5,6,6);

type TPoint = record
     x,y,z: real;
     cull: boolean;
     x_,y_,z_: real;
     xBS,yBS: integer;
end;
type TKamera = record
     x,y,z: real;
     wx,wy: real;
end;
type PKetteP = ^TKetteP;
     TKetteP = record
     P: TPoint;
     naechster: PKetteP;
end;
type TFlaeche = record
     P1,P2,P3: PKetteP;
     d: real;
     cull: boolean;
     farbe: byte;
end;
type PKetteF = ^TKetteF;
     TKetteF = record
     F: TFlaeche;
     naechster: PKetteF;
end;

type TWelt = object
     punkte: PKetteP;
     flaechen: PKetteF;
     constructor init(p:PKetteP; f:PKetteF);
     procedure bewege;
     procedure cullP;
     procedure cullP2;
     procedure berechne(K: TKamera);
     procedure BS;
     procedure cullF;
     procedure abstand;
     procedure zeichne;
     procedure render(K: TKamera);
     destructor fertig;
end;

var welt: TWelt;
    K: TKamera;
    punkt1,punkt2: PKetteP;
    flaeche1,flaeche2: PKetteF;
    punkte: array[1..8] of PKetteP;
    i: integer;
    t,s: byte;
    ende: boolean;

procedure dreieck(x1,y1, x2,y2, x3,y3: integer; farbe: byte);
var poly: ARRAY[1..3] of pointtype;
begin
setcolor(farbe);
setfillstyle({emptyfill}solidfill, farbe);
poly[1].x := x1; poly[2].x := x2; poly[3].x := x3;
poly[1].y := y1; poly[2].y := y2; poly[3].y := y3;
fillpoly(3,poly);
if graphresult=grNoScanMem then write(#7);
end;

procedure rechneBS(var x,y: integer; x1,y1,z1: real);
const x0 = 319; y0 = 240;
const xf = 64; yf = 48;
begin
x := round(x0 + xf*x1*epsilon/z1);
y := round(y0 - yf*y1*epsilon/z1);
end;

procedure zeichneF(flaeche: PKetteF);
var x1,x2,x3: real;
    y1,y2,y3: real;
    z1,z2,z3: real;
    x,y,z: real;
    _x,_y,_z: real;
    x1_,x2_,x3_: integer;
    y1_,y2_,y3_: integer;
    num: 0 .. 2;
begin
  if flaeche^.F.cull then begin
   x1 := flaeche^.F.P1^.P.x_;
   y1 := flaeche^.F.P1^.P.y_;
   z1 := flaeche^.F.P1^.P.z_;
   x2 := flaeche^.F.P2^.P.x_;
   y2 := flaeche^.F.P2^.P.y_;
   z2 := flaeche^.F.P2^.P.z_;
   x3 := flaeche^.F.P3^.P.x_;
   y3 := flaeche^.F.P3^.P.y_;
   z3 := flaeche^.F.P3^.P.z_;
   if z1 <= 0 then begin
    if z2 <= 0 then begin
     {z1,z2 <= 0; z3 > 0}
     if z3 <= 0 then exit;
     num := 2;
     x := x3; y := y3; z := z3;
     x3 := x1; y3 := y1; z3 := z1;
     x1 := x; y1 := y; z1 := z;
    end
    else begin
     if z3 <= 0 then begin
      {z1,z3 <= 0; z2 > 0}
      num := 2;
      x := x1; y := y1; z := z1;
      x1 := x2; y1 := y2; z1 := z2;
      x2 := x; y2 := y; z2 := z;
     end
     else begin
      {z1 <= 0; z2,z3 > 0}
      num := 1;
     end;
    end;
   end
   else begin
    if z2 <= 0 then begin
     if z3 <= 0 then begin
      {z2,z3 <= 0; z1 > 0}
      num := 2;
     end
     else begin
      {z2 <= 0; z1,z3 > 0}
      num := 1;
      x := x2; y := y2; z := z2;
      x2 := x1; y2 := y1; z2 := z1;
      x1 := x; y1 := y; z1 := z;
     end;
    end
    else begin
     if z3 <= 0 then begin
      {z3 <= 0; z1,z2 > 0}
      num := 1;
      x := x3; y := y3; z := z3;
      x3 := x1; y3 := y1; z3 := z1;
      x1 := x; y1 := y; z1 := z;
     end
     else begin
      {z1,z2,z3 > 0}
      num := 0;
     end;
    end;
   end;
   case num of
   0: begin
       if flaeche^.F.P1^.P.cull then begin
        x1_ := flaeche^.F.P1^.P.xBS;
        y1_ := flaeche^.F.P1^.P.yBS;
        end
       else rechneBS(x1_,y1_, x1,y1,z1);
       if flaeche^.F.P2^.P.cull then begin
        x2_ := flaeche^.F.P2^.P.xBS;
        y2_ := flaeche^.F.P2^.P.yBS;
        end
       else rechneBS(x2_,y2_, x2,y2,z2);
       if flaeche^.F.P3^.P.cull then begin
        x3_ := flaeche^.F.P3^.P.xBS;
        y3_ := flaeche^.F.P3^.P.yBS;
        end
       else rechneBS(x3_,y3_, x3,y3,z3);
       dreieck(x1_,y1_, x2_,y2_, x3_,y3_, flaeche^.F.farbe);
      end;
   1: begin
       x := x2 + (epsilon-z2)*(x1-x2)/(z1-z2);
       y := y2 + (epsilon-z2)*(y1-y2)/(z1-z2);
       z := epsilon;
       _x := x3 + (epsilon-z3)*(x1-x3)/(z1-z3);
       _y := y3 + (epsilon-z3)*(y1-y3)/(z1-z3);
       _z := epsilon;
       if flaeche^.F.P2^.P.cull then begin
        x2_ := flaeche^.F.P2^.P.xBS;
        y2_ := flaeche^.F.P2^.P.yBS;
        end
       else rechneBS(x2_,y2_, x2,y2,z2);
       if flaeche^.F.P3^.P.cull then begin
        x3_ := flaeche^.F.P3^.P.xBS;
        y3_ := flaeche^.F.P3^.P.yBS;
        end
       else rechneBS(x3_,y3_, x3,y3,z3);
       rechneBS(x1_,y1_, x,y,z);
       dreieck(x1_,y1_, x2_,y2_, x3_,y3_, flaeche^.F.farbe);

       rechneBS(x2_,y2_, _x,_y,_z);
       dreieck(x1_,y1_, x2_,y2_, x3_,y3_, flaeche^.F.farbe);
      end;
   2: begin
       x2 := x1 + (epsilon-z1)*(x2-x1)/(z2-z1);
       y2 := y1 + (epsilon-z1)*(y2-y1)/(z2-z1);
       z2 := epsilon;
       x3 := x1 + (epsilon-z1)*(x3-x1)/(z3-z1);
       y3 := y1 + (epsilon-z1)*(y3-y1)/(z3-z1);
       z3 := epsilon;
       if flaeche^.F.P1^.P.cull then begin
        x1_ := flaeche^.F.P1^.P.xBS;
        y1_ := flaeche^.F.P1^.P.yBS;
        end
       else rechneBS(x1_,y1_, x1,y1,z1);
       rechneBS(x2_,y2_, x2,y2,z2);
       rechneBS(x3_,y3_, x3,y3,z3);
       dreieck(x1_,y1_, x2_,y2_, x3_,y3_, flaeche^.F.farbe);
      end;
   end;
  end;
end;

(* sp„ter ERGŽNZEN *)
constructor TWelt.init;
begin
punkte := p;
flaechen := f;
graph2.init;
end;

(* sp„ter ERGŽNZEN *)
procedure TWelt.bewege;
begin
end;

(* sp„ter ERGŽNZEN *)
procedure TWelt.cullP;
var punkt: PKetteP;
begin
 punkt := punkte;
 while punkt <> nil do begin
  punkt^.P.cull := true;
  punkt := punkt^.naechster;
 end;
end;

(* sp„ter ERGŽNZEN *)
procedure TWelt.cullP2;
var punkt: PKetteP;
begin
 punkt := punkte;
 while punkt <> nil do begin
  if punkt^.P.z_ <= 0 then
  punkt^.P.cull := false;
  punkt := punkt^.naechster;
 end;
end;

procedure TWelt.berechne(K: TKamera);
var punkt: PKetteP;
var x,y,z: real;
    xn,yn,zn: real;
    sx,sy,cx,cy: real;
begin
 punkt := punkte;
 cx := cos(K.wx); sx := sin(K.wx);
 cy := cos(K.wy); sy := sin(K.wy);
 while punkt <> nil do begin
  if punkt^.P.cull then begin
   x := punkt^.P.x;
   y := punkt^.P.y;
   z := punkt^.P.z;

   x := x - K.x; y := y - K.y; z := z - K.z;

   xn := x; yn := y*cx - z*sx; zn := y*sx + z*cx;

   x := xn*cy + zn*sy; y := yn; z := zn*cy - xn*sy;

   punkt^.P.x_ := x;
   punkt^.P.y_ := y;
   punkt^.P.z_ := z;
  end;
  punkt := punkt^.naechster;
 end;
end;

procedure TWelt.BS;
var punkt: PKetteP;
    x1,y1,z1: real;
    x,y: integer;
begin
 punkt := punkte;
 while punkt <> nil do begin
  if punkt^.P.cull then begin
   x1 := punkt^.P.x_;
   y1 := punkt^.P.y_;
   z1 := punkt^.P.z_;
   rechneBS(x,y, x1,y1,z1);
   punkt^.P.xBS := x;
   punkt^.P.yBS := y;
  end;
  punkt := punkt^.naechster;
 end;
end;

(* sp„ter ERGŽNZEN *)
procedure TWelt.cullF;
var flaeche: PKetteF;
begin
 flaeche := flaechen;
 while flaeche <> nil do begin
  if flaeche^.F.P1^.P.cull or flaeche^.F.P2^.P.cull or flaeche^.F.P3^.P.cull then
   flaeche^.F.cull := true
  else
   flaeche^.F.cull := false;
  flaeche := flaeche^.naechster;
 end;
end;

procedure TWelt.abstand;
var flaeche: PKetteF;
    a,b,c: real;
    x1,x2,x3: real;
    y1,y2,y3: real;
    z1,z2,z3: real;
    d: real;
begin
 flaeche := flaechen;
 while flaeche <> nil do begin
  if flaeche^.F.cull then begin
   x1 := flaeche^.F.P1^.P.x_;
   y1 := flaeche^.F.P1^.P.y_;
   z1 := flaeche^.F.P1^.P.z_;
   x2 := flaeche^.F.P2^.P.x_;
   y2 := flaeche^.F.P2^.P.y_;
   z2 := flaeche^.F.P2^.P.z_;
   x3 := flaeche^.F.P3^.P.x_;
   y3 := flaeche^.F.P3^.P.y_;
   z3 := flaeche^.F.P3^.P.z_;
   a := y1*(z2-z3) + y2*(z3-z1) + y3*(z1-z2);
   b := x1*(z2-z3) + x2*(z3-z1) + x3*(z1-z2);
   c := x1*(y2-y3) + x2*(y3-y1) + x3*(y1-y2);
   d := a*x1 + b*y1 + c*z1;
   flaeche^.F.d := abs(d/sqrt(a*a+b*b+c*c));
  end;
  flaeche := flaeche^.naechster;
 end;
end;

procedure TWelt.zeichne;
var flaeche: PKetteF;
var dmax: real;
    max: PKetteF;
begin
 cleardevice;
 repeat
  dmax := -0.5;
  flaeche := flaechen;
  while flaeche <> nil do begin
   if dmax < flaeche^.F.d then begin
    dmax := flaeche^.F.d;
    max := flaeche;
   end;
   flaeche := flaeche^.naechster;
  end;
  if dmax >= 0 then begin
   zeichneF(max);
   max^.F.d := -1;
  end;
 until dmax < 0;
end;

procedure TWelt.render;
begin
 bewege;
 cullP;
 berechne(K);
 cullP2;
 cullF;
 BS;
 abstand;
 zeichne;
end;

destructor TWelt.fertig;
var loescheP: PKetteP;
    loescheF: PKetteF;
begin
 while punkte <> nil do begin
 loescheP := punkte;
 punkte := loescheP^.naechster;
 dispose(loescheP);
 end;
 while flaechen <> nil do begin
 loescheF := flaechen;
 flaechen := loescheF^.naechster;
 dispose(loescheF);
 end;
 closegraph;
end;

begin
punkt2 := nil;
for i := 1 to 8 do begin
 new(punkt1);
 punkt1^.naechster := punkt2;
 with punkt1^.P do begin
  x := xx[i]*5; {5 = 1.5}
  y := yy[i]*5; {5 = 1.5}
  z := zz[i]*5; {5 = 6}
 end;
 punkte[i] := punkt1;
 punkt2 := punkt1;
end;
flaeche2 := nil;
for i := 1 to 12 do begin
 new(flaeche1);
 flaeche1^.naechster := flaeche2;
 with flaeche1^.F do begin
  P1 := punkte[a1[i]];
  P2 := punkte[a2[i]];
  P3 := punkte[a3[i]];
  farbe := ff[i];
 end;
 flaeche2 := flaeche1;
end;
welt.init(punkt1,flaeche1);

K.x := 0; K.y := 0; K.z := 0; K.wx := 0; K.wy := 0;

ende := false;
welt.render(K);
repeat
 tasten(t,s);
 if t = 0 then begin
  case s of
   K_LEFT: K.wy := K.wy + 0.1;
   K_RIGHT: K.wy := K.wy - 0.1;
   K_PUP: if K.wx<0.5 then K.wx := K.wx + 0.05;
   K_PDOWN: if K.wx>-0.7 then K.wx := K.wx - 0.05;
   K_POS1: K.wx := 0;
   K_UP: begin K.z := K.z +1*cos(K.wy); K.x := K.x -1*sin(K.wy); end;
   K_DOWN: begin K.z := K.z -0.5*cos(K.wy); K.x := K.x +0.5*sin(K.wy); end;
   else;
  end;
 end;
 if t = 27 then ende := true else welt.render(K);
until ende;
welt.fertig;
end.