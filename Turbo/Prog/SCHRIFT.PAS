program schrift;
{BOLD, EURO, GOTH, LCOM, LITT, SANS, SCRI, SIMP, TRIP, TSCR}
uses graph, graph2;
begin
init;
SetTextStyle(font('TSCR'), HorizDir, 2);
OutTextXY(10, 10, 'The quick brown fox');
OutTextXY(10, 60, 'jumps over the lazy dog.');
OutTextXY(10, 110, '12"$/)? „š*–');
OutTextXY(10, 160, 'Franz jagt mit einem');
OutTextXY(10, 210, 'komplett verwahrlosten');
OutTextXY(10, 260, 'Taxi quer durch Bayern.');
readln;
closegraph;
end.