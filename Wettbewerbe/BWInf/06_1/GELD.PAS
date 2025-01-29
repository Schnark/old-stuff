program kleingeld;
uses crt;

type TMuenzen = 1..99;                          {mîgliche Cent-MÅnzen}
const Cent: set of TMuenzen = [1,2,5,10,20,50]; {Cent-MÅnzen}
type TGeld = array[TMuenzen] of byte;           {Sammlung von MÅnzen}

var geldbeutel: TGeld;                          {Claras Geldbeutel}
    i, versuche: word;
    gesamtzahl: longint;                        {fÅr Statistik-    }
    anzahlen: array[TMuenzen] of longint;       {     zwecke       }

procedure ausgabe(position: byte; muenzen: TGeld);
{gibt MÅnzen am Bildschirm aus}
var i: byte;
begin
 gotoxy(position,wherey);
 for i:=1 to 99 do
     if i in Cent then
        if i<10 then write(muenzen[i]:2) else write(muenzen[i]:3);
end;


procedure wechselgeld(betrag: word; var muenzen: TGeld);
{stellt Betrag mit mîglichst wenig MÅnzen dar}
var i: byte;
begin
 betrag:=betrag mod 100;          {ganze Euros spielen keine Rolle}
 for i:=99 downto 1 do            {Jede ...}
     if i in Cent then begin      {... Cent-MÅnze ...}
        muenzen[i]:=0;
        while i<=betrag do begin  {... wird so oft genommen, wie sie passt.}
              betrag:=betrag-i;
              inc(muenzen[i]);
        end;
     end;
end;

procedure bezahlen(betrag: word; var geldbeutel: TGeld);
{ein Einkauf}
var i, anzahl: byte;
    summe: word;
    bezahlung, wechsel: TGeld;
begin
 if wherey=1 then begin   {öberschrift}
    writeln('Betrag    Geldbeutel       Bezahlung      Wechselgeld      Geldbeutel    Anzahl');
    writeln(' EUR    1 2 5 10 20 50  1 2 5 10 20 50  1 2 5 10 20 50   1 2 5 10 20 50  MÅnzen');
    writeln;
 end;

 write(betrag/100:5:2);
 ausgabe(8,geldbeutel);

 betrag:=betrag mod 100;
 {Geldbeutelinhalt}
 summe:=0;
 for i:=1 to 99 do
     if i in Cent then summe:=summe+i*geldbeutel[i];

 {Bestimmung des Wechselgelds}
 wechselgeld(100+summe-betrag, wechsel);

 for i:=1 to 99 do
     if i in Cent then bezahlung[i]:=geldbeutel[i];

 {Vereinfachung, falls eine MÅnze sowohl im Bezahl- als auch im Wechselgeld
  vorkommt.}
 for i:=1 to 99 do
     if i in Cent then
        if (bezahlung[i]>0) and (wechsel[i]>0) then
           if bezahlung[i]>=wechsel[i] then begin
              bezahlung[i]:=bezahlung[i]-wechsel[i];
              wechsel[i]:=0;
           end else begin
              wechsel[i]:=wechsel[i]-bezahlung[i];
              bezahlung[i]:=0;
           end;

 {Neuer Geldbeutelinhalt (und Statistik}
 for i:=1 to 99 do
     if i in Cent then begin
        geldbeutel[i]:=geldbeutel[i]-bezahlung[i]+wechsel[i];
        anzahlen[i]:=anzahlen[i]+bezahlung[i]+wechsel[i];
     end;


 anzahl:=0;
 for i:=1 to 99 do
     if i in Cent then anzahl:=anzahl+geldbeutel[i];

 ausgabe(24,bezahlung);
 ausgabe(40,wechsel);
 ausgabe(57,geldbeutel);
 gotoxy(76,wherey); writeln(anzahl);
 gesamtzahl:=gesamtzahl+anzahl;
 if wherey=25 then begin readln; clrscr; end;
end;

begin
randomize;
gesamtzahl:=0;
write('Anzahl der EinkÑufe: '); readln(versuche);
clrscr;
{leerer Geldbeutel}
for i:=1 to 99 do
    if i in Cent then begin
       geldbeutel[i]:=0;
       anzahlen[i]:=0;
    end;

{ZufÑllige EinkÑufe}
for i:=1 to versuche do bezahlen(1+random(999),geldbeutel);

for i:=1 to 99 do if i in Cent then
    write(i,':',anzahlen[i]/versuche:5:2,'  ');
write('   Durchschnitt: ',gesamtzahl/versuche:4:2);
readln;
end.