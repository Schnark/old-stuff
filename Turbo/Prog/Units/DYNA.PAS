unit dyna;
interface
type listenzeiger = ^listenelement;
     listenelement = record
                     inhalt: pointer;
                     naechster: listenzeiger;
                     end;
type liste = listenzeiger;

type vergleich = function(x1, x2: pointer): boolean;

function len(l: liste): integer;
{gibt die L„nge der Liste aus}
function get(l: liste; nr: integer): pointer;
{gibt den Inhalt eines Elements aus}
procedure add(var l: liste; wert: pointer);
{fgt ein Element hinten an}
procedure change(l: liste; nr: integer; wert: pointer);
{„ndert den Wert eines Elements}
procedure ins(var l: liste; nr: integer; wert: pointer);
{fgt vor einem Element ein anderes ein}
procedure del(var l: liste; nr: integer);
{entfernt ein Element}
procedure setlen(var l: liste; laenge: integer);
{„ndert die L„nge der Liste}
procedure stecksort(var l: liste; kleiner: vergleich);
{sortiert die Liste
 nach der angegebenen Vergleichsfunktion mit dem Stecksort}

implementation
const INTERN: boolean = false;
{intern => keine šberprfung der Eingabe}

function len(l: liste): integer;
var anzahl: integer;
    zeiger: listenzeiger;
begin
anzahl := 0;
zeiger := l;
while zeiger <> nil do
begin
 zeiger := zeiger^.naechster;
 inc(anzahl);
end;
len := anzahl;
end;

function get(l: liste; nr: integer): pointer;
var i: integer;
    zeiger: listenzeiger;
begin
if not INTERN then if nr > len(l) then begin get := nil; exit; end;
zeiger := l;
for i := 2 to nr do
 zeiger := zeiger^.naechster;
get := zeiger^.inhalt;
end;

procedure add(var l: liste; wert: pointer);
var zeiger, neu: listenzeiger;
begin
if l = nil then
begin
 new(l);
 zeiger := l;
end
else
begin
 zeiger := l;
 while zeiger <> nil do
 begin
  neu := zeiger;
  zeiger := zeiger^.naechster;
 end;
 new(neu^.naechster);
 zeiger := neu^.naechster;
end;
zeiger^.inhalt := wert;
zeiger^.naechster := nil;
end;

procedure change(l: liste; nr: integer; wert: pointer);
var zeiger: listenzeiger;
    i: integer;
begin
if not INTERN then if nr > len(l) then exit;
zeiger := l;
for i := 2 to nr do
 zeiger := zeiger^.naechster;
zeiger^.inhalt := wert;
end;

procedure ins(var l: liste; nr: integer; wert: pointer);
var zeiger, neu: listenzeiger;
    i: integer;
begin
if not INTERN then if nr > len(l) then begin add(l, wert); exit; end;
zeiger := l;
for i := 2 to nr-1 do
 zeiger := zeiger^.naechster;
new(neu);
neu^.inhalt := wert;
if nr = 1 then
begin
 neu^.naechster := l;
 l := neu;
end
else
begin
 neu^.naechster := zeiger^.naechster;
 zeiger^.naechster := neu;
end;
end;

procedure del(var l: liste; nr: integer);
var zeiger, loesche: listenzeiger;
    i: integer;
begin
if not INTERN then if nr > len(l) then exit;
zeiger := l;
for i := 2 to nr-1 do
 zeiger := zeiger^.naechster;
loesche := zeiger^.naechster;
if nr = 1 then
begin
 loesche := l;
 l := l^.naechster;
end
else
 zeiger^.naechster := loesche^.naechster;
dispose(loesche);
end;

procedure setlen(var l: liste; laenge: integer);
var zeiger, loesche: listenzeiger;
    ll, i: integer;
begin
ll := len(l);
if laenge = ll then exit;
if laenge < ll then
begin
 zeiger := l;
 for i := 1 to laenge - 1 do
  zeiger := zeiger^.naechster;
 loesche := zeiger^.naechster;
 if laenge = 0 then loesche := l else zeiger^.naechster := nil;
 while loesche <> nil do
 begin
  zeiger := loesche^.naechster;
  dispose(loesche);
  loesche := zeiger;
 end;
 if laenge = 0 then l := nil;
end
else
 for i := 1 to laenge - ll do
  add(l, nil);
end;

procedure stecksort(var l: liste; kleiner: vergleich);
var i, j, n: integer;
    v: pointer;
    internalt: boolean;
begin
 internalt:=INTERN; INTERN:=true;
 n:=len(l);
 for i := 2 to n do begin
  v := get(l, i); j := i; del(l, i);
  while (j>1) and kleiner(v, get(l, j-1)) do dec(j);
  ins(l, j, v);
 end;
 INTERN:=internalt;
end;

end.