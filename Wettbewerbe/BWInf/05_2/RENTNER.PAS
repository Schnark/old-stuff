program rentner_norderfrierum;
uses crt;
const maxgaeste = 25;
      laenge = 1000;
      zeltbreite = 1;

type zeichenkette = string[15];
type TRentner = record
     name: zeichenkette;
     pos: real;
     end;
type alleRentner = array[1 .. maxgaeste] of TRentner;
     Tanzahl = array[1 .. maxgaeste+1] of byte;

var rentner: alleRentner;
    i: integer;
    modus, gaeste: integer;
    umzuege,erster_umzug: integer;
    p: real;

function abschnittnr(einteilung: integer; pos: real): integer;
{Liefert die Nummer des Abschnitts, in dem pos liegt (Rand -> nÑchster Absch.}
begin
 abschnittnr := 1+trunc( einteilung * pos/laenge );
end;

procedure strand(nr: integer; naechster: boolean);
{Zeichnet den Strand}
var i,y: integer;
    pos,ende,abschnitt: integer;
begin
 y := wherey;
 textcolor(red);
 if naechster then ende := nr+1 else ende := nr;
 for i := 0 to ende do begin
  pos := 1+round(79* i/ende);
  gotoxy(pos,y);
  write('€');                           {rote Balken markieren Abschnitte}
 end;
 if y = 25 then y := 24;            {letzte Zeile -> Bildschirm gescrollt}

 for i := 1 to nr do begin
  pos := 1+round(79* rentner[i].pos/laenge);
  if chr(mem[SegB800:2*(80*(y-1)+pos-1)])='€' then
   begin
    textcolor(red);  {Wenn der Name einen Trennstrich Åberdeck, wird er rot.}
    abschnitt := abschnittnr(ende,rentner[i].pos);
    if not( (rentner[i].pos-zeltbreite/2 < laenge*(abschnitt-1)/ende)
            or (rentner[i].pos+zeltbreite/2 > laenge*abschnitt/ende)  ) then
                                                                        begin

     if pos = 1+round(79*abschnitt/ende) then          {rechte Grenze}
     begin
      gotoxy(pos+1,y); write('|');
     end
     else
     begin
      gotoxy(pos-1,y); write('|');
     end;

    end;
   end
  else
   textcolor(lightgray);

  gotoxy(pos,y);
  write(copy(rentner[i].name,1,1));    {Anfangsbuchstabe des Namens}
 end;
 textcolor(lightgray);
end;

procedure zaehlen(nr,einteilung: integer; r: alleRentner; var anzahlen: Tanzahl);
{Bestimmt, wie viele Renter in welchem Abschnitt wohnen}
var i: integer;
begin
 for i := 1 to einteilung do anzahlen[i] := 0;
 for i := 1 to nr do
  if r[i].pos <> -1 then inc(anzahlen[abschnittnr(einteilung,r[i].pos)]);
end;


procedure raeumen(nr: integer; var r: alleRentner);
{Entfernt alle Rentner, die sich in zwei Abschnitten befinden}
var i: integer;
    pos: real;
    abschnitt: integer;
begin
 for i := 1 to nr-1 do begin                 {Alle Rentner,...}
  pos := rentner[i].pos;
  abschnitt := abschnittnr(nr, pos);         {...deren Zelt in 2 Abschnitten
                                              steht...}
  if    (pos-zeltbreite/2 < laenge*(abschnitt-1)/nr)
     or (pos+zeltbreite/2 > laenge*abschnitt/nr) then
      r[i].pos := -1                         {...mÅssen umziehen.}
  else
      r[i].pos := pos;
 end;
 r[nr].pos := -1;
end;

function einziehen(nr, abschnitte: integer; links, rechts: real; var r: alleRentner):integer;
{Weist dem ersten umherirrendem Rentner einen "optimalen" Platz zu}
const stufen = 8;
var anzahlen: Tanzahl;
    i: integer;
    rent: integer;
    abschlinks,abschrechts: integer;
    neupos: real;

begin
 i := 0;
 repeat i := i+1; until (r[i].pos = -1);    {Der erste Rentner ohne Platz}
 rent := i;

 if rechts-links < zeltbreite then begin    {Ist der freie Abschnitt zu
                                             schmal fÅr ein Zelt, zieht er in
                                             die Mitte.}
  r[rent].pos := (rechts+links)/2;
  einziehen := 0;
  exit;
 end;

 zaehlen(nr,abschnitte,r,anzahlen);

 abschlinks := abschnittnr(abschnitte,links-zeltbreite/2);
 abschrechts := abschnittnr(abschnitte,rechts+zeltbreite/2);

 if anzahlen[abschlinks] > 0 then links := laenge*abschlinks/abschnitte;
 if anzahlen[abschrechts] > 0 then rechts := laenge*(abschrechts-1)/abschnitte;

 abschlinks := abschnittnr(abschnitte,links-zeltbreite/2);
 abschrechts := abschnittnr(abschnitte,rechts+zeltbreite/2);
 if abschlinks <> abschrechts then begin
  neupos := laenge*abschlinks/abschnitte;
  if neupos < (links+rechts)/2 then links := neupos else rechts := neupos;
 end;

 if (abschnitte-nr<stufen) and (abschnitte<maxgaeste) then
 einziehen := 1+einziehen(nr,abschnitte+1,links,rechts,r)
 else
     begin einziehen := 2+stufen-(abschnitte-nr);
     r[rent].pos := (links+rechts)/2; end;

end;

function umziehen(nr: integer; var r: alleRentner): integer;
{Weist allen Rentnern, die einen
 neuen Platz suchen einen zu, gibt Bewertung aus}
var anzahlen: Tanzahl;
    i,j: integer;
    suchende: integer;
    abschnitt: integer;
    links, rechts: real;
    erg,min: integer;
begin

 min := 1000;
 suchende := 0;
 for i := 1 to nr do if r[i].pos = -1 then inc(suchende);
 {Anzahl der Rentner, die einen Platz suchen}

 for i := 1 to suchende do begin

  zaehlen(nr,nr,r,anzahlen);

  j := 0;
  repeat j := j+1; until anzahlen[j] = 0;
  abschnitt := j;
  links := laenge*(abschnitt-1)/nr;
  rechts := laenge*abschnitt/nr;
  {leerer Abschnitt}

  erg := einziehen(nr,nr+1,links,rechts,r);
  if erg < min then min := erg;
 end;
 umziehen := min;
end;

function leere(nr: integer; var r: alleRentner): integer;
{Leert alle Abschnitte bis auf einen Rentner, gibt Bewertung zurÅck}
var anzahlen: Tanzahl;
    altpos: array[1 .. maxgaeste] of real;
    i: integer;
    pos: real;
    abschnittvoll: integer;
    bewert, opt, max: integer;

begin
 zaehlen(nr,nr,r,anzahlen);

 i := 0;
 repeat i := i+1 until (i>nr) or (anzahlen[i] > 1);
                              {Aus dem ersten ÅberfÅlltem Abschnitt...}
 if i > nr then {kein ÅberfÅllter Abschnitt} begin
  leere := umziehen(nr,r); exit;
 end;
 abschnittvoll := i;

 for i := 1 to nr do altpos[i] := -1;

 for i := 1 to nr do begin
  pos := r[i].pos;
  if pos <> -1 then begin
    if abschnittvoll = abschnittnr(nr,pos) then begin
     altpos[i] := pos;
     r[i].pos := -1;       {... mÅssen alle ausziehen,...}
    end;
  end;
 end;

 max := 0;
 for i := 1 to nr do begin
  if altpos[i] >= 0 then begin
   r[i].pos := altpos[i];     {... nur einer darf probeweise bleiben.}
   bewert := leere(nr,r);
   if bewert > max then begin opt := i; max := bewert; end;
   altpos[i] := r[i].pos;
   r[i].pos := -1;
  end;
 end;
 r[opt].pos := altpos[opt];
 leere := max;

end;

procedure ermittlepos(nr: integer; var r: alleRentner);
{Ermittelt eine Position fÅr Rentner nr, dessen Zelt die angebene Breite hat}
var i: integer;
begin
 raeumen(nr,r);
 i := leere(nr,r);
 i := umziehen(nr,r);
end;

procedure eingabe(nr: integer);

var name: zeichenkette;
    rentnerneu: alleRentner;
    pos,links,rechts: real;
    i,j: integer;

 function eing_name: zeichenkette;
 var name: zeichenkette;
 begin
 case modus of
 0:         readln(name);
 1,2,3:     begin name := chr(64+nr); writeln(name); end;
 end;
  eing_name := name;
 end;

 function position: real;
 var stelle: string;
     fehler: integer;
     pos: real;
 begin
 case modus of
 0:
  repeat
   readln(stelle);
   fehler := 0;
   if stelle = '' then pos := rentnerneu[nr].pos else val(stelle,pos,fehler);
  until fehler = 0;
 1: pos := rentnerneu[nr].pos;
 2: if odd(nr) then pos := links-zeltbreite/2+7 else pos := rentnerneu[nr].pos;
 3: if random<p then pos := links+random*(rechts-links) else pos := rentnerneu[nr].pos;
 end;
 if modus <> 0 then writeln(pos:0:2);
  position := pos;
 end;


begin
 clrscr;
 textcolor(lightblue);
 writeln('            |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|');
 writeln('            |                                            |');
 writeln('            |              Strandverwaltung              |');
 writeln('            |                NORDERFRIERUM               |');
 writeln('            |                                            |');
 writeln('            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
 writeln;
 textcolor(lightgray);
 writeln(' Bisher:');
 strand(nr-1,true);
 writeln;
 writeln;
   write('   Bitte geben sie ihren Namen ein: ');
 name := eing_name;
 writeln;
 rentner[nr].name := name; rentner[nr].pos := -1;
 ermittlepos(nr,rentnerneu);
 writeln;

 for i := 1 to nr-1 do begin
  if rentnerneu[i].pos <> rentner[i].pos then begin
   umzuege := umzuege+1;
   if erster_umzug = 0 then erster_umzug := nr;
   rentner[i].pos := rentnerneu[i].pos;
   writeln('   ',rentner[i].name,', leider mÅssen Sie umziehen.');
   writeln('     Ihre neue Position liegt ',rentner[i].pos:0:2,' m îstlich vom Westende.');
  end;
 end;

 pos := rentnerneu[nr].pos;
 links := laenge*(abschnittnr(nr,pos)-1)/nr+ zeltbreite/2;
 rechts := laenge*abschnittnr(nr,pos)/nr-zeltbreite/2;

 writeln('   ',name,', fÅr Sie ist der Ort ',pos:0:2,' m îstlich vom Westende vorgesehen.');
 repeat
  writeln('   Bitte geben Sie die Position ein, an der Sie ihr Zelt aufstellen');
  writeln('   wollen (oder <ENTER> um den Vorschlag zu akzeptieren).');
    write('   Die Position muss zwischen ',links:0:2,' und ',rechts:0:2,' liegen: ');
  pos := position;
 until (links<=pos) and (pos<= rechts);
 rentner[nr].pos := pos;

 writeln;
 writeln(' Jetzt:');
 strand(nr,false);
 writeln;
 for i := 1 to nr do begin
     for j := 1 to nr do
         if abschnittnr(nr, rentner[j].pos)=i then write(rentner[j].name);
     write('; ');
     end;
 readln;
end;

begin
clrscr;
writeln('Mîgliche Modi');
writeln;
writeln('0: Eingabe durch Benutzer');
writeln('1: 20 GÑste, die alle dem Programm folgen');
writeln('2: 20 GÑste, von denen jeder zweite dem Programm folgt');
writeln('3: 20 ZufallsgÑste');
writeln;
repeat write('GewÅnschter Modus: '); readln(modus); until modus in [0,1,2,3];
if modus = 0 then begin
 write('Anzahl der GÑste (hîchstens ',maxgaeste,'): ');
 readln(gaeste);
end
else
 gaeste := 20;

if gaeste > maxgaeste then gaeste := maxgaeste;
if modus = 3 then begin
   write('Wahrscheinlichkeit, dass sich der Rentner nicht ans Progamm hÑlt: ');
   readln(p);
   randomize;
   end;
erster_umzug := 0; umzuege := 0;
for i := 1 to gaeste do eingabe(i);
clrscr;
if umzuege > 0 then
 if umzuege = 1 then
  writeln('Es fand ein Umzug bei Ankunft der ', erster_umzug, '. Person statt.')
 else
  writeln('Es fanden ',umzuege,' UmzÅge statt, der erste bei der Ankunft der ',erster_umzug,'. Person.')
else
 writeln('Es fanden keine UmzÅge statt.');
readln;
end.