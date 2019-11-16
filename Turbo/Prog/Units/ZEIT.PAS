unit zeit;
interface
const reset = 0; start = 1; pause = 2; weiter = 3; stop = 4;

const sonntag = 0; montag = 1; dienstag = 2; mittwoch = 3; donnerstag = 4; freitag = 5; samstag = 6;
const wochentage: array[0 .. 6] of string[10] = ('Sonntag', 'Montag', 'Dienstag',
                                                 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag');
const wochtentagek: array[0 .. 6] of string[2] = ('SO', 'MO', 'DI', 'MI', 'DO', 'FR', 'SA');

const januar = 1; februar = 2; maerz = 3; april = 4; mai = 5; juni = 6; juli = 7; august = 8; september = 9; oktober = 10;
      november = 11; dezember = 12;
const monate: array[1 .. 12] of string[9] = ('Januar', 'Februar', 'M„rz', 'April', 'Mai', 'Juni', 'Juli', 'August',
                                             'September', 'Oktober', 'November', 'Dezember');
const monatek: array[1 .. 12] of string[3] =('Jan', 'Feb', 'M„r', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt',
                                             'Nov', 'Dez');
const monatslaengen: array[1 .. 12] of byte = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

function timer: longint;
{ Hundertstelsekunden nach Mitternacht}
procedure uhr(wahl: byte);
function uhrlesen: longint;
{Stoppuhr}
function schaltjahr(jahr: integer): boolean;
{Schaltjahr?}
function wochentag(tag, monat, jahr: integer): byte;
{liefert Wochentag}

implementation
uses dos;
var stoppuhr1, stoppuhr2: longint;

function timer: longint;
var h, min, sek, _100: word;
begin
gettime(h, min, sek, _100);
timer := ((longint(h) * 60 + longint(min)) * 60 + longint(sek)) * 100 + longint(_100);
end;

procedure uhr(wahl: byte);
begin
case wahl of
reset: begin stoppuhr1 := 0; stoppuhr2 := 0; end;
start: begin stoppuhr1 := timer; stoppuhr2 := 0; end;
stop: stoppuhr2 := timer - stoppuhr1 + stoppuhr2;
pause: stoppuhr2 := timer - stoppuhr1 + stoppuhr2;
weiter: stoppuhr1 := timer;
end;
end;

function uhrlesen: longint;
begin
uhrlesen := stoppuhr2;
end;

function schaltjahr(jahr: integer): boolean;
begin
 schaltjahr := ( ((jahr mod 4) = 0) and not ((jahr mod 100) = 0) ) or ((jahr mod 400) = 0);
end;

function wochentag;
var c, w: integer;
begin
 if monat > 2 then
  monat := monat - 2
 else
 begin
  monat := monat + 10;
  jahr := jahr - 1;
 end;
 c := trunc(jahr / 100);
 jahr := jahr mod 100;
 w := tag + trunc((13 * monat - 1)/5) + jahr + trunc(jahr/4) + trunc(c/4) + 5*c;
 wochentag := w mod 7;
end;

end.