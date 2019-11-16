unit astronomie;
interface
uses koordinaten;
const J2000_0=2451545;
      JD100=36525;
const pi_180=3.1415926536/180;
const geogr_laenge=7+51/60+11/3600;
      geogr_breite=47;

type himmelskoerper = (sonne, mond, merkur, venus, erde, mars, jupiter, saturn, uranus, neptun, pluto);

const grosse_halbachse{in AE}: array[merkur..pluto] of real =
      (0.3870983098,
       0.7233298200,
       1.0000010178,
       1.5236793419,
       5.2026032092,
       9.5549091915,
       19.2,
       30,
       39.4);
const exzentritaet: array[merkur..pluto,0..1] of real =
      ((0.2056317526, 0.00002),
       (0.0067719164, -0.000048),
       (0.0167086342, -0.000042),
       (0.0934006477, 0.000092),
       (0.0484979255, 0),
       (0.0555481426, 0),
       (0.047, 0),
       (0.009, 0),
       (0.25, 0));
const neigung{gegen Ekliptik, in Grad}: array[mond..pluto, 0..1] of real =
      ((5.145278 {oder 5.1442802}, 0),
       (7.00498625, 0.0019),
       (3.39466189, 0.001),
       (0, 0),
       (1.84972648, -0.0007),
       (1.30326698, 0),
       (2.48887878, 0),
       (0.77, 0),
       (1.77, 0),
       (17.13, 0));
const ekliptikwinkel{in Grad, e=e0+e1*t+e2*tý}: array[0..2] of real =
      (23.439911,-0.013004167,-0.000000164);

{M(t)=M0+t*M1+tý*M2
 t in Julianischen Jahrhunderten (JD100 = 36525d)
   ab J2000.0 (1. 1. 2000 12:00 UT)
 M in Grad
 mittlere Anomalie}
const M: array[himmelskoerper,0..2] of real =
         ((357.52542984, 35999.04944160, -0.00016111),
          (134.96292,477198.86753,0.0092361),
          (174.794652,149472.515304,0),
          (50.407092,58517.803872,0),
          (357.52557600,35999.04974400,0),
          (19.387908,19139.858496,0),
          (20.351304,3034.906668,0),
          (317.875212,1222.116768,0),
          (142.816212,428.502564,0),
          (259.736616,218.466936,0),
          (15.037,144.3716,0));
{W(t)=W0+t*W1+tý*W2
 t in Julianischen Jahrhunderten (JD100 = 36525d)
   ab J2000.0 (1. 1. 2000 12:00 UT)
 W in Grad
 L„nge des Perihels}
const W: array[himmelskoerper,0..2] of real =
         ((282.94030800,1.71977778,0.00030556),
          (218.31617{-M[mond,0]}-134.96292,481267.88088{-M[mond,1]}-477198.86753,-0.0011278{-M[mond,2]}-0.0092361),
          (77.449644,1.556028,0.000306),
          (131.572188,1.408667,0.000306),
          (282.94030800{-180?},1.71977778,0.00030556),
          (336.045276,1.837639,0.000306),
          (14.000760,1.395889,0.000222),
          (92.200896,1.394056,0.000528),
          (170.454348,1.411750,0.009500),
          (45.145656,1.384111,-0.005917),
          (223.3,2,0));

{L(t)=M(t)+W(t): mittlere L„nge}

const Omega: array[merkur..pluto,0..1] of real =
             ((48.331,1.185),
              (76.680,0.900),
              (0,0),
              (49.557,0.771),
              (100.06,0.2),
              (113.07,-0.3),
              (73.75,-0.03),
              (131.24,-0.02),
              (109.6,0));

const F: array[mond..mond,0..2] of real =
         ((93.27283,483202.01873,-0.0032110));
const D: array[mond..mond,0..2] of real =
         ((297.85027,445267.11135,-0.0014306));

{wahre ekliptiale L„nge L_Mond = L + Summe(KL * sin(X))
 X: auf Mond bezogen, M_S=M(Sonne)}
const KL: array[1..15] of real =
         (22639.500/3600, {X=M      Groáe Ungleichheit 1}
          -4586.465/3600, {X=L-2*D  Evektion}
          2369.912/3600,  {X=2*D    Variation}
          769.016/3600,   {X=2*M    Groáe Ungleichheit 2}
          -668.146/3600,  {X=M_S    J„hrliche Gleichung}
          -411.608/3600,  {X=2*F    Reduktion auf Ekliptik}
          -211.656/3600,  {X=2*(L-D)}
          -205.962/3600,  {X=M+M_S-2*D}
          191.953/3600,   {X=M+2*D}
          -165.145/3600,  {X=M_S-2*D}
          147.687/3600,   {X=M-M_S}
          -125.154/3600,  {X=D      Parallaktische Gleichung}
          -109.673/3600,  {X=M+M_S}
          -55.173/3600,   {X=2*(F-D)}
          36.123/3600);   {X=3*M    Groáe Ungleichheit 3}
{wahre ekliptiale Breite B_Mond = Summe(KB * sin(X))}
const KB: array[1..6] of real =
          (18461/3600, {X=F}
           1010/3600,  {X=M+F}
           1000/3600,  {X=M-F}
           -624/3600,  {X=F-2*D}
           -199/3600,  {X=M-F-2*D}
           -167/3600); {X=M+F-2*D}

{t: Julianisches Datum}
function exzentritaet_t(k: himmelskoerper; t: real): real;
function neigung_t(k: himmelskoerper; t: real): real;
function ekliptikwinkel_t(t: real): real;
function M_t(k: himmelskoerper; t: real): real;
function W_t(k: himmelskoerper; t: real): real;
function D_t(t: real): real;
function F_t(t: real): real;
function Omega_t(k: himmelskoerper; t: real): real;

function lokale_Sternzeit(t, lambda: real): real;
                          {geogr. L. in ø}

function wahreAnomalie(k: himmelskoerper; t: real): real;
procedure mond_geoekl(t: real; var k: geo_ekl);
procedure daten_t(k: himmelskoerper; t: real; var b: bahnebene; var aK, neigung: real);
procedure helioekl_t(k: himmelskoerper; t: real; var he: helio_ekl);
procedure geoekl_t(k: himmelskoerper; t: real; var ge: geo_ekl);
procedure geoaequ_t(k: himmelskoerper; t: real; var ga: geo_aequ);
procedure topoaequ_t(k: himmelskoerper; t: real; var ta: topo_aequ);
procedure horiz_t(k: himmelskoerper; t: real; var ho: horizontal);

function phase(k: himmelskoerper; t: real): real;




procedure MEZ_GMT(var tag, monat, jahr, stunde, minute: integer);
{MEZ/MESZ -> GMT}
function JD(tag, monat, jahr, stunde, minute: integer; sekunde: real): real;
procedure Datum(jul: real; var tag, monat, jahr, stunde, minute: integer; sekunde: real);

function L(k:himmelskoerper; t:real):real;
{mittlere L„nge, bei Mond wahre L„nge}
function wahre_anomalie(k: himmelskoerper; t:real):real;
{statt M(k, t)}

function ZG(t: real): real; {in Grad}
function mondphase(t: real):real;
function wahre_sonne(t: real):real;

function mod360(x: real):real;
implementation

function tan(x:real): real; begin tan:=sin(x)/cos(x); end;
function arccos(x:real): real;
begin
 if x=1 then begin arccos:=0; exit; end; if x=-1 then begin arccos:=pi; exit; end;
 arccos:=pi/2-arctan(x/sqrt(1-sqr(x)));
end;


function exzentritaet_t(k: himmelskoerper; t: real): real;
begin
 t:= (t-J2000_0)/JD100;
 exzentritaet_t:=exzentritaet[k,0]+t*exzentritaet[k,1];
end;

function neigung_t(k: himmelskoerper; t: real): real;
begin
 t:= (t-J2000_0)/JD100;
 neigung_t:=neigung[k,0]+t*neigung[k,1];
end;

function ekliptikwinkel_t(t: real): real;
begin
 t:= (t-J2000_0)/JD100;
 ekliptikwinkel_t:=ekliptikwinkel[0]+t*ekliptikwinkel[1]+sqr(t)*ekliptikwinkel[2];
end;

function M_t(k: himmelskoerper; t: real): real;
begin
 t:= (t-J2000_0)/JD100;
 M_t:=M[k, 0]+t*M[k, 1]+sqr(t)*M[k, 2];
end;

function W_t(k: himmelskoerper; t: real): real;
begin
 t:= (t-J2000_0)/JD100;
 W_t:=W[k, 0]+t*W[k, 1]+sqr(t)*W[k, 2];
end;

function D_t(t: real): real;
begin
 t:= (t-J2000_0)/JD100;
 D_t:=D[mond, 0]+t*D[mond, 1]+sqr(t)*D[mond, 2];
end;

function F_t(t: real): real;
begin
 t:= (t-J2000_0)/JD100;
 F_t:=F[mond, 0]+t*F[mond, 1]+sqr(t)*F[mond, 2];
end;

function Omega_t(k: himmelskoerper; t: real): real;
begin
 t:= (t-J2000_0)/JD100;
 Omega_t:=Omega[k,0]+t*Omega[k,1];
end;

function lokale_Sternzeit(t, lambda: real): real;
var t1,t2, GMST_l, GMST_k: real;
begin
 t1:=(int(t+0.5)-0.5-J2000_0)/JD100;
 t2:=frac(t+0.5);
 GMST_l:=   6.6973745583+
         2400.0513369070*t1+
            0.0000258622*sqr(t1)-
            0.000000001722*sqr(t1)*t1;
 GMST_k:=1.00273790936*t2;
 lokale_Sternzeit:=GMST_l+GMST_k+lambda/15;
end;

procedure mond_geoekl(t: real; var k: geo_ekl);
const genau: byte = 15;
var ll,lalt,mm,dd,ff,ms,x, p: real;
    i: byte;
begin
 mm:=M_t(mond, t);
 ll:=mm+W_t(mond, t);
 lalt:=ll;
 dd:=D_t(t);
 ff:=F_t(t);
 if genau>=5 then ms:=M_t(sonne, t);
 for i:=1 to genau do begin
     case i of
      1: x:=mm; 2: x:=lalt-2*dd; 3: x:=2*dd; 4: x:=2*mm; 5: x:=ms;
      6: x:=2*ff; 7: x:=2*(lalt-dd); 8: x:=mm+ms-2*dd; 9: x:=mm+2*dd;
      10: x:=ms-2*dd; 11: x:=mm-ms; 12: x:=dd; 13: x:=mm+ms;
      14: x:=2*(ff-dd); 15: x:=3*mm; end;
      ll:=ll+KL[i]*sin(x*pi_180);
 end;
 k.lambda:=ll-int(ll/360)*360;
 k.beta:=0;
 for i:=1 to 6 do begin
     case i of
     1: x:=ff; 2: x:=mm+ff; 3: x:=mm-ff;
     4: x:=ff-2*dd; 5: x:=mm-ff-2*dd; 6: x:=mm+ff-2*dd; end;
     k.beta:=k.beta+KB[i]*sin(x*pi_180);
 end;
 p:=3423/3600 + 187/3600*cos(mm*pi_180);
 k.d:=4.2635233E-5{Erdradius in AE}/sin(p*pi_180);
end;

function wahreAnomalie(k: himmelskoerper; t: real): real;
var MM, ex: real;
begin
 MM:=M_t(k,t); ex:=exzentritaet_t(k,t);
 wahreAnomalie:=MM+2*ex*sin(pi_180*MM)+5/4*sqr(ex)*sin(2*pi_180*MM);
end;

procedure daten_t(k: himmelskoerper; t: real; var b: bahnebene; var aK, neigung: real);
var MM, ex, wA: real;
begin
 if k=sonne then begin b.r:=0; b.u:=0; ak:=0; neigung:=0; exit; end;
 MM:=M_t(k,t); ex:=exzentritaet_t(k,t);
 wA:=MM+2*ex*sin(pi_180*MM)+5/4*sqr(ex)*sin(2*pi_180*MM);

 ak:=Omega_t(k,t);
 neigung:=neigung_t(k,t);
 b.u:=wA+W_t(k,t)-ak;
 b.r:=grosse_halbachse[k]*(1-ex*cos(pi_180*MM)-sqr(ex)/2*(cos(2*pi_180*MM)-1));
end;

procedure helioekl_t(k: himmelskoerper; t: real; var he: helio_ekl);
var b: bahnebene;
    aK, neig: real;
    ge: geo_ekl;
    e: helio_ekl;
begin
 if k=mond then begin
    helioekl_t(erde,t,e);
    geoekl_t(k,t, ge);
    geoekl_helioekl(ge, e, he);
    exit; end;
 if k=sonne then begin
    he.r:=0; he.b:=0; he.l:=0;
    exit; end;
 daten_t(k, t, b, ak, neig);
 bahn_helioekl(b, ak, neig, he);
end;

procedure geoekl_t(k: himmelskoerper; t: real; var ge: geo_ekl);
var he: helio_ekl;
    e: helio_ekl;
begin
 if k=mond then begin mond_geoekl(t, ge); exit; end;
 helioekl_t(erde, t, e);
 helioekl_t(k, t, he);
 helioekl_geoekl(he, e, ge);
end;

procedure geoaequ_t(k: himmelskoerper; t: real; var ga: geo_aequ);
var ge: geo_ekl;
begin
 geoekl_t(k, t, ge);
 geoekl_geoaequ(ge, ekliptikwinkel_t(t), ga);
end;

procedure topoaequ_t(k: himmelskoerper; t: real; var ta: topo_aequ);
var ga: geo_aequ;
    ort: geo_aequ;
begin
 geoaequ_t(k, t, ga);
 ort.d:=0.000042635;
 ort.delta:=geogr_breite;
 ort.alpha:=lokale_sternzeit(t, geogr_laenge);
 geoaequ_topoaequ(ga, ort, ta);
end;

procedure horiz_t(k: himmelskoerper; t: real; var ho: horizontal);
var ta: topo_aequ;
begin
 topoaequ_t(k, t, ta);
 topoaequ_horiz(ta, lokale_sternzeit(t, geogr_laenge), geogr_breite, ho);
end;

function phase(k: himmelskoerper; t: real): real;
var heK: helio_ekl;
    geK, geS: geo_ekl;
begin
 helioekl_t(k, t, heK);
 geoekl_t(k, t, geK);
 geoekl_t(sonne, t, geS);
 phase:=arccos( (sqr(geK.d)+sqr(heK.r)-sqr(geS.d))/(2*geK.d*heK.r) )/pi_180;
end;








procedure MEZ_GMT(var tag, monat, jahr, stunde, minute: integer);
begin
 stunde:=stunde-1;
 if {Sommerzeit, nachbessern} monat in [4..9] then stunde:=stunde-1;
 if stunde<0 then begin stunde:=stunde+24; tag:=tag-1; end;
 if tag<0 then begin monat:=monat-1; tag:=31; {Nachbessern} end;
 if monat<0 then begin monat:=12; jahr:=jahr-1; end;
end;

function JD(tag, monat, jahr, stunde, minute: integer; sekunde: real): real;
var k: integer;
    j,d: real;
begin
  k:=0;
  if (monat>2) and
     ( (jahr mod 4 = 0) and (not (jahr mod 100 = 0) or (jahr mod 400 = 0)))
     then k:=1;
  j:=jahr-1601;
  d:=2305812.5;
  d:=d+j*365;
  d:=d+int(j/4)-int(j/100)+int(j/400);
  d:=d+int(30.6*monat+0.53/sqr(monat-1.5)-32.3)+tag+k;
  d:=d+(stunde+minute/60+sekunde/3600)/24;
  JD:=d;
end;

procedure Datum(jul: real; var tag, monat, jahr, stunde, minute: integer; sekunde: real);
var a,b,c,d,e,f,tb:real;
begin
 a:=int(jul+0.5);
 b:=int((a-1867216.25)/36524.25);
 c:=1525+a+b-int(b/4);
 d:=int((c-122.1)/365.25);
 e:=int(365.25*d);
 f:=int((c-e)/30.6001);
 tag:=trunc(c-e-int(30.6001*f)+jul+0.5-a);
 monat:=trunc(f-1-12*int(f/14));
 jahr:=trunc(d-4715-int((7+monat)/10));
 tb:=frac(jul+0.5);
 stunde:=trunc(tb*24);
 minute:=trunc(frac(tb*24)*60);
 sekunde:=frac(frac(tb*24)*60)*60;
end;

function L(k:himmelskoerper; t:real):real;
const genau: byte = 15;
var ll,lalt,mm,dd,ff,ms,x: real;
    i: byte;
begin
 t:=t/JD100;
 mm:=M[k,0]+M[k,1]*t+M[k,2]*t*t;
 ll:=mm+W[k,0]+W[k,1]*t+W[k,2]*t*t;
 if k=mond then begin
  lalt:=ll;
  dd:=D[k,0]+D[k,1]*t+D[k,2]*t*t;
  if genau>=6 then ff:=F[k,0]+F[k,1]*t+F[k,2]*t*t;
  if genau>=5 then ms:=M[sonne,0]+M[sonne,1]*t+M[sonne,2]*t*t;
  for i:=1 to genau do begin
      case i of
      1: x:=mm; 2: x:=lalt-2*dd; 3: x:=2*dd; 4: x:=2*mm; 5: x:=ms;
      6: x:=2*ff; 7: x:=2*(lalt-dd); 8: x:=mm+ms-2*dd; 9: x:=mm+2*dd;
      10: x:=ms-2*dd; 11: x:=mm-ms; 12: x:=dd; 13: x:=mm+ms;
      14: x:=2*(ff-dd); 15: x:=3*mm; end;
      ll:=ll+KL[i]*sin(x*pi_180);
  end;
 end;
 L:=ll-int(ll/360)*360;
end;

function wahre_anomalie(k: himmelskoerper; t:real):real;
var MM:real;
begin
 t:=t/JD100;
 MM:=M[k,0]+M[k,1]*t+M[k,2]*t*t;
 wahre_anomalie:={MM+}2*exzentritaet[k,0]*sin(pi_180*MM)+5/4*sqr(exzentritaet[k,0])*sin(2*pi_180*MM);
end;

function ZG(t: real): real;
var M_S,L_S,ekl,te_2: real;
begin
 L_S:=L(sonne,t);
 t:=t/JD100;
 M_S:=M[sonne,0]+t*M[sonne,1]+sqr(t)*M[sonne,2];
 ekl:=ekliptikwinkel[0]+ekliptikwinkel[1]*t+ekliptikwinkel[2]*t*t;
 te_2:=sqr(tan(pi_180*0.5*ekl));
 ZG:=(-2*exzentritaet[erde,0]*sin(pi_180*M_S)-5/4*sqr(exzentritaet[erde,0])*sin(pi_180*2*M_S)
     +te_2*sin(pi_180*L_S)-0.5*sqr(te_2)*sin(pi_180*4*L_S)+1/3*te_2*sqr(te_2)*sin(pi_180*6*L_S))
     /pi_180;
end;

function mondphase(t: real):real;
begin
 mondphase:=mod360( wahre_anomalie(erde, t)+L({sonne}erde, t)-L(mond, t) );
end;

function wahre_sonne(t: real):real;
begin
 wahre_sonne:=mod360(frac(t)*360+ZG(t)+90+geogr_Laenge);
end;

function mod360(x: real):real;
begin
 x:=( trunc(x) mod 360 ) + frac(x);
 if x<0 then x:=x+360; mod360:=x;
end;

end.