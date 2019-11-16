unit kalender;
interface
type TDatum = record
              tag, monat: shortint;
              jahr: integer;
              stunde, minute: shortint;
              sekunde: real;
              end;
   zeitzone = record
              differenz: real;
              sommerzeit: boolean;
              end;
   intDatum = record
              d: TDatum;    {GMT}
              ZZ: zeitzone;
              end;

const MEZ: zeitzone = (differenz:-1;sommerzeit:true);

function sommerzeit(d: TDatum): boolean;
{Sommerzeit zu angegebenem Datum (lokale Zeit) gÅltig?}
procedure toGMT(d: TDatum; z: zeitzone; var iD: intDatum);
{Ñndert angegebene Zeit in GMT um}
function JD(d: intDatum): real;
{liefert das Julianische Datum (GMT)}
procedure datum(jd: real; var d: intDatum);
{lierert Datum zu Julianischem Datum (GMT)}

implementation
uses zeit;

function sommerzeit(d: TDatum): boolean;
{noch nicht fertig}
begin
 if d.monat in [1..2,11..12] then begin sommerzeit:=false; exit; end;
 if d.monat in [4..9] then begin sommerzeit:=true; exit; end;
 if d.monat=3 then begin
    if d.tag<=24 then begin sommerzeit:=false; exit; end;
    {if an d.tag oder spÑter im MÑrz noch ein Sonntag then
        sommerzeit:=true
    else
        sommerzeit:=false;}
 end else {d.monat=10} begin
    if d.tag<=24 then begin sommerzeit:=true; exit; end;
 end;
end;

procedure toGMT(d: TDatum; z: zeitzone; var iD: intDatum);
var dt, s, m: real;
begin
 iD.ZZ:=z;
 dt:=z.differenz;
 if z.sommerzeit and sommerzeit(d) then dt:=dt-1;
 s:=d.stunde+dt; if s<0 then begin s:=s+24; d.tag:=d.tag-1; end;
 d.stunde:=trunc(s);
 m:=d.minute+60*frac(s); d.minute:=trunc(m);
 d.sekunde:=d.sekunde+60*frac(m);
 if d.sekunde>=60 then begin d.sekunde:=d.sekunde-60; d.minute:=d.minute+1; end;
 if d.minute>=60 then begin d.minute:=d.minute-60; d.stunde:=d.stunde+1; end;
 if d.stunde>=24 then begin d.stunde:=d.stunde-24; d.tag:=d.tag+1; end;
 if (d.tag>=monatslaengen[d.monat]) or ((d.monat=2) and (d.tag=29) and not schaltjahr(d.jahr))
    then begin d.monat:=d.monat+1; d.tag:=1; end;
 if d.tag=0 then begin
            d.monat:=d.monat-1;
            if d.monat=0 then begin d.monat:=12; d.jahr:=d.jahr-1; end;
            d.tag:=monatslaengen[d.monat];
            if (d.monat=2) and not schaltjahr(d.jahr) then d.tag:=28;
            end;
 if d.monat=13 then begin d.monat:=1; d.jahr:=d.jahr+1; end;
 iD.d:=d;
end;

function JD(d: intDatum): real;
var k: integer;
    j,dd: real;
begin
 with d.d do begin
  k:=0;
  if (monat>2) and
     ( (jahr mod 4 = 0) and (not (jahr mod 100 = 0) or (jahr mod 400 = 0)))
     then k:=1;
  j:=jahr-1601;
  dd:=2305812.5;
  dd:=dd+j*365;
  dd:=dd+int(j/4)-int(j/100)+int(j/400);
  dd:=dd+int(30.6*monat+0.53/sqr(monat-1.5)-32.3)+tag+k;
  dd:=dd+(stunde+minute/60+sekunde/3600)/24;
 end;
  JD:=dd;
end;

procedure datum(jd: real; var d: intDatum);
var a,b,c,dd,e,f,tb:real;
begin
 a:=int(jd+0.5);
 b:=int((a-1867216.25)/36524.25);
 c:=1525+a+b-int(b/4);
 dd:=int((c-122.1)/365.25);
 e:=int(365.25*dd);
 f:=int((c-e)/30.6001);
 with d.d do begin
 tag:=trunc(c-e-int(30.6001*f)+jd+0.5-a);
 monat:=trunc(f-1-12*int(f/14));
 jahr:=trunc(dd-4715-int((7+monat)/10));
 tb:=frac(jd+0.5);
 stunde:=trunc(tb*24);
 minute:=trunc(frac(tb*24)*60);
 sekunde:=frac(frac(tb*24)*60)*60;
 end;
end;


end.