program game_of_live;
uses crt, keyb;

const maxx = 80;
const maxy = 50;

const WASCHFRAU = 0;
const KATZE = 1;
const UHR = 2;
const GLEITER = 3;
const KANONE = 4;
const BECHER = 5;
const BIENENSTOCK = 6;
const RPent = 7;
{const 8 = 8;}
const PULSAR = 9;
const KANONE2 = 10;
const GLEIT4 = 11;
const RAUMSCHIFF = 12;
const RAUMSCHIFF2 = 13;
const RAUMSCHIFF3 = 14;
const RAUMSCHIFF4 = 15;
const OFEN = 16;
const KUH = 17;
const HONIG = 18;

var feld: array[0 .. maxy + 1, 0 .. maxx + 1] of shortint;
{var tick: word;}
var t: longint;

procedure init(nr: word; zeile: string);
var l,i: integer;
begin
 l := length(zeile);
for i := 1 to maxx do begin
    if i > l then exit;
    if zeile[i] = '*' then feld[nr, i] := 1;
end;
end;

procedure initspec(motiv: word);
begin
case motiv of

WASCHFRAU: begin
init(3, '   *');
init(4, '   **    *     *     *     *');
init(5, '   ***  * *   * *   * *   * *');
init(6, '   **    *     *     *     *');
init(7, '   *');
end;
KATZE: begin
init(1, '   *  *');
init(2, '   ****');
init(3, '  *    *');
init(4, '  * ** *');
init(5, '  *    *');
init(6, '   ****');
end;
UHR: begin
init(1, ' *');
init(2, '  **');
init(3, '**');
init(4, '  *');
end;
GLEITER: begin
init(1, ' *');
init(2, '  *');
init(3, '***');
end;
KANONE: begin
init(1, '                           *');
init(2, '                           * *');
init(3, '          *                 * *');
init(4, '          **                *  *   **');
init(5, '     **    **               * *    **');
init(6, ' **  **    ***             * *');
init(7, ' **  **    **              *');
init(8, '          **');
init(9, '          *');
end;
BECHER: begin
init(2, '  ** **');
init(3, '  ** **');
init(4, '   * *');
init(5, ' * * * *');
init(6, ' * * * *');
init(7, ' **   **');
end;
BIENENSTOCK: begin
init(7, '                                   **');
init(8, '  * ** ** ** ** ** ** ** ** ** ** * *');
init(9, ' * * ** ** ** ** ** ** ** ** ** **');
init(10, '  *');
end;
RPent: begin
init(22, '                       *');
init(23, '                      ***');
init(24, '                      *');
end;
8: begin
init(3, '  ***');
init(4, '  ***');
init(5, '  ***');
init(6, '     ***');
init(7, '     ***');
init(8, '     ***');
end;
PULSAR:
init(8, '  ***** *****');
KANONE2: begin
init(1, '            **');
init(2, '           *');
init(3, '          *             *');
init(4, ' *        *            **');
init(5, '**        *               **');
init(6, '           *              ***      *');
init(7, '            **            **      **');
init(8, '                       **');
init(9, '                        *');
end;
GLEIT4: begin
init(3, '    ****');
init(5, '  ********');
init(7, '************');
init(9, '  ********');
init(11, '    ****');
end;
RAUMSCHifF: begin
init(1, '   *');
init(2, '    *');
init(3, '*   *');
init(4, ' ****');
end;
RAUMSCHifF2: begin
init(1, '    *');
init(2, '     *');
init(3, '*    *');
init(4, ' *****');
end;
RAUMSCHifF3: begin
init(1, '     *');
init(2, '      *');
init(3, '*     *');
init(4, ' ******');
end;
RAUMSCHifF4: begin
init(3, '     ******');
init(4, '    *     *');
init(5, '          *');
init(6, '         *');
init(8, '           *');
init(9, '            *');
init(10, '*           *');
init(11, ' ************');
init(15, '     ******');
init(16, '    *     *');
init(17, '          *');
init(18, '         *');
end;
OFEN: begin
init(2, '');
init(3, '  *');
init(4, ' ***');
init(5, '    *');
init(6, '     *');
init(7, '      *');
init(8, '       *');
init(9, '        *');
init(10, '         *');
init(11, '          *');
init(12, '           *');
init(13, '            *');
init(14, '             *');
init(15, '              *');
init(16, '               *');
init(17, '                *');
init(18, '                 *');
init(19, '                  *');
init(20, '                   *');
init(21, '                    *');
init(22, '                     *');
init(23, '                      *');
init(24, '                       *');
init(25, '                      **');
end;
KUH: begin
init(4, ' **       **  **  **  **  **  **  **  **   ** ');
init(5, ' **    * ***  **  **  **  **  **  **  **  *  *');
init(6, '     ** *                                 *  ***');
init(7, '     **  ********************************* **   *');
init(8, '     ** *                                 *  ***');
init(9, ' **    * ***  **  **  **  **  **  **  **  *  *');
init(10, ' **       **  **  **  **  **  **  **  **   ** ');
end;
HONIG: begin
init(6, '      ***');
init(7, '     *   *');
init(8, '    *     *');
init(9, '     *   *');
init(10, '      ***');
end;

end;
end;

procedure zufall(start: longint; z: real);
var i,j:integer;
begin
randSeed:=start;
for i := maxx div 2 - 5 to maxx div 2 + 5 do
    for j := maxy div 2 - 5 to maxy div 2 + 5 do
        if random < z then feld[j, i] := 1;
end;

function umgeb(x, y: integer): shortint;
var i,j, s: shortint;
begin
s:=0;
for i := -1 to 1 do
    for j := -1 to 1 do
        if feld[x + i, y + j] >= 1 then inc(s);
umgeb := s;
end;

procedure neu;
var i,j: integer;
    a,b: shortint;
begin
for i := 1 to maxy do
    for j := 1 to maxx do begin
        a := feld[i, j];
        b := umgeb(i, j);
        if a = 1 then begin
           if (b < 3) or (b > 4) then feld[i, j] := 2; end
        else
           if b = 3 then feld[i, j] := -1;
    end;

for i := 1 to maxy do
    for j := 1 to maxx do begin
        a := feld[i, j];
        if a = -1 then feld[i, j] := 1;
        if a = 2 then feld[i, j] := 0;
    end;
end;

procedure anzeige;
var i,ii,j: integer;
    a,b: shortint;
begin
{delay(1000);}
{clrscr;}
for ii := 0 to (maxy-1) div 2 do begin
    i:=ii*2+1;
    for j := 1 to maxx do begin
        a := feld[i, j];
        if i < maxy then b := feld[i + 1, j] else b := 0;
        gotoXY(j, (i + 1) div 2);
        if (j<>80) or (((i+1) div 2)<>25) then
        if a = 1 then
           if b = 1 then write('Û') else write('ß')
        else
           if b = 1 then write('Ü') else write(' ');
    end;
end;
{gotoXY(70,25);
write(tick);}
end;

var i,j:integer;

begin
for i:=0 to maxy+1 do for j:=0 to maxx+1 do feld[i,j]:=0;
randomize; t := randSeed;{}
{t:=688525836;{}
{t:=254349853;{}
{t:=269357609;{}
{t:=941623834;{}
initspec(kanone);{}
{zufall(t, 1);{}
{zufall(t, 0.3);{}
{zufall(t,0.9);{}
{init(9, '          ********');{}
{init(9, '          **********');{}
{init(12, '          ****************');{}

{init(16,'               * * * * * * * * * * *');
init(17,'                * * * * * * * * * *');
init(18,'               * * * * * * * * * * *');
init(19,'                * * * * * * * * * *');
init(20,'               * * * * * * * * * * *');
init(21,'                * * * * * * * * * *');
init(22,'               * * * * * * * * * * *');
init(23,'                * * * * * * * * * *');
init(24,'               * * * * * * * * * * *');
init(25,'                * * * * * * * * * *');
init(26,'               * * * * * * * * * * *');
{}
hidecursor;
repeat
 anzeige; delay(150);
 neu;
 {inc(tick);}
until keypressed;
{writeln(t);}
showcursor;
readln;
end.
