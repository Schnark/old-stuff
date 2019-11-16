program testzeit;
uses crt, dos, zeit;
var zeichen: char;
var ende: boolean;
var jahr, monat, tag, wochentag:word;
begin
writeln(timer);

ende := false;
repeat
zeichen := readkey;
case zeichen of
'r': uhr(reset);
's': uhr(start);
'p': uhr(pause);
'w': uhr(weiter);
'e': begin uhr(stop); writeln(uhrlesen); end;
't': writeln(timer);
'x': ende := true;
end;
until ende;
getdate(jahr, monat, tag, wochentag);
writeln(wochentage[wochentag],', der ',tag,'. ',monate[monat],' ',jahr);
writeln(wochentage[zeit.wochentag(tag, monat, jahr)]);
readln(jahr);
if schaltjahr(jahr) then write('Schaltjahr') else write('kein Schaltjahr');
readln;
end.