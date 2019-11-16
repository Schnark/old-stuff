uses dos;
var d:DateTime;
    l:longint;
begin
write('Tag:     '); readln(d.day);
write('Monat:   '); readln(d.month);
write('Jahr:    '); readln(d.year);
write('Stunde:  '); readln(d.hour);
write('Minute:  '); readln(d.min);
write('Sekunde: '); readln(d.sec);
packtime(d,l);
{$Q-}
write(l,'; ', l -d.sec div 2 -d.min*32 -d.hour*2048
                -d.day*65536 -d.month*2097152 -(d.year-1980)*33554432);
readln
end.