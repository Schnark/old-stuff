program mp3;

uses crt;

const MaxLiednummer = 250;                   {maximale Anzahl der Lieder}
type TLiednummer = 0..MaxLiednummer;         {Liednummern + 0 (= kein Lied)}
type TMenge = set of TLiednummer;            {Menge von Liedern}
type TReihenfolge = array[TLiednummer] of TLiednummer;  {Reihenfolge
                                                      ([1]: erstes Lied,...)}
type TTop_Ten = array[TLiednummer] of record          {Lieder + HÑufigkeit}
                                      nr: TLiednummer;
                                      haeufigkeit: word;
                                      end;

var haeufigkeiten: array[TLiednummer] of word;      {HÑufigkeiten
                                                     d. einzelnen Lieder}

procedure ordne_zufaellig(lieder: TMenge; var reihenfolge: TReihenfolge);
{bringt angebebene Lieder in zufÑllige Reihenfolge}
var lied, nr: TLiednummer;
begin
 for nr:=1 to MaxLiednummer do reihenfolge[nr]:=0;

 nr:=1;
 while lieder<>[] do begin               {Solange es noch Lieder gibt, ...}
       lied:=random(MaxLiednummer)+1;    {wird eines zufÑllig ausgewÑhlt ...}
       if lied in lieder then begin
          lieder:=lieder-[lied];
          reihenfolge[nr]:=lied;         {und in die Reihenfolge eingefÅgt.}
          inc(nr);
       end;
 end;
end;

procedure sortiere(var feld: TTop_Ten; anzahl: TLiednummer);
{sortiert die Lieder nach der HÑufigkeit (Stecksort)}
var i,j:TLiednummer;
    v: word;
    nr: TLiednummer;
begin
 for i := 2 to anzahl do begin
  v := feld[i].haeufigkeit; nr:=feld[i].nr; j := i;
  while (j>1) and (feld[j-1].haeufigkeit<v) do begin
   feld[j] := feld[j-1];
   j := j-1;
  end;
  feld[j].haeufigkeit := v; feld[j].nr:=nr;
 end;

end;

procedure favorites_first(zahl_lieder: TLiednummer; var reihenfolge: TReihenfolge);
{setzt "Favorites First" um}
var top_ten: TTop_Ten;
    i, nr: TLiednummer;
    haeufig: word;
    zahl_der_haeufigen: TLiednummer;
    menge_5, menge_20, menge_rest: TMenge;
    r2: TReihenfolge;
begin
{bei weniger als 20 Liedern werden diese nur zufÑllig sortiert}
if zahl_lieder<20 then begin ordne_zufaellig([1..zahl_lieder], reihenfolge); exit; end;

{HÑufigkeiten werden ermittelt}
for i:=1 to zahl_lieder do begin
    top_ten[i].nr:=i; top_ten[i].haeufigkeit:=haeufigkeiten[i];
end;

{Lieder werden nach HÑufigkeit sortiert}
sortiere(top_ten, zahl_lieder);

{alle Lieder, die so hÑufig sind wie das 10t-hÑufigste,
 gehîren zu den "10" HÑufigsten}
haeufig:=top_ten[10].haeufigkeit;
if haeufig=top_ten[zahl_lieder].haeufigkeit then
   zahl_der_haeufigen:=zahl_lieder
else begin
   zahl_der_haeufigen:=10;
   while top_ten[zahl_der_haeufigen+1].haeufigkeit=haeufig do inc(zahl_der_haeufigen);
end;

{aus den 10 HÑufigsten werden zufÑllig 5 ausgewÑhlt}
menge_5:=[];
for i:=1 to 5 do begin
    repeat
       nr:=random(zahl_der_haeufigen)+1;
    until not (top_ten[nr].nr in menge_5);
    menge_5:=menge_5+[top_ten[nr].nr];
end;

{es werden 15 Lieder zufÑllig hinzugefÅgt}
menge_20:=menge_5;
for i:=1 to 15 do begin
    repeat
       nr:=random(zahl_lieder)+1;
    until not (nr in menge_20);
    menge_20:=menge_20+[nr];
end;

menge_rest:=[1..zahl_lieder]-menge_20;

{die ersten 20 und der Rest wird getrennt in zufÑllige Reihenfolge gebracht}
ordne_zufaellig(menge_20, reihenfolge);
ordne_zufaellig(menge_rest, r2);
{Rest wird an Reihenfolge angehÑngt}
for i:=21 to zahl_lieder do reihenfolge[i]:=r2[i-20];

end;


function spiele(nr: TLiednummer): boolean;
{spielt ein Lied}
var taste: char;
begin
 write('Lied Nr. ',nr:3,': Anspielen  <weiter: Enter; Ende: Esc>');
 taste:=readkey;
 if taste=#13 then begin
    inc(haeufigkeiten[nr]);         {Lied wurde ein (weiteres) Mal gespielt}
    writeln('  wird gespielt  <Ende: Esc>');
    taste:=readkey;
 end else writeln;
 if taste=#27 then spiele:=false else spiele:=true;
end;

procedure reihe_spielen(r: TReihenfolge);
{spielt Lieder in einer Reihe ab}
var i: TLiednummer;
begin
i:=1;
while (spiele(r[i])) and (i<MaxLiedNummer) do inc(i);
end;

var i,nr:TLiednummer;
    r:TReihenfolge;
    wahl: byte;
    L,L_4: integer;
    lieder: TMenge;
    j: integer;
begin

randomize;
for i:=1 to MaxLiedNummer do haeufigkeiten[i]:=0;

repeat
 clrscr;
 writeln('1. ZufÑllige Reihenfolge');
 writeln('2. Favorites First');
 writeln('3. Aufgabe 3');
 writeln('4. Ende');
 writeln;
 write(' -> '); readln(wahl);
 clrscr;

 case wahl of
 1: begin
    ordne_zufaellig([1..MaxLiednummer],r);
    reihe_spielen(r);
    end;
 2: begin
    favorites_first(MaxLiednummer,r);
    reihe_spielen(r);
    end;
 3: begin
    for j:=1 to 200 do begin
     favorites_first(MaxLiednummer,r);
     L:=random(11)+10;                    {Anzahl der angespielten Lieder}
     L_4:=L div 4;                        {Anzahl der Åbersprungenen Lieder}
     lieder:=[];
     for i:=1 to L do lieder:=lieder+[r[i]];  {Menge d. ersten L Lieder}
     for i:=1 to L_4 do begin                 {ohne Åbersprungene Lieder}
        repeat nr:=random(MaxLiednummer)+1; until nr in lieder;
        lieder:=lieder-[nr];
     end;
     write(j,': ');
     for i:=1 to MaxLiednummer do if i in lieder then begin
             write(i,' ');
             inc(haeufigkeiten[i]); end;
     writeln;
     if j mod 20 = 0 then readln;
    end;
    writeln('HÑufigkeiten d. einzelnen Lieder:');
    for i:=1 to MaxLiednummer do begin
        write(i:3,': ',haeufigkeiten[i]:3,'; ');
        if i mod 100 = 0 then readln;
    end;
    readln;
    end;
 4: ;
 end;
until wahl=4;

end.