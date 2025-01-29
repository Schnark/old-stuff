program formulierer;
uses crt;

const VersucheMax=100;          {maximale Anzahl der Messwerte}

type TOperator=(plus, minus);   {Operator vor 2. Faktor}
type TFormel=record             {Formel: 3 Faktoren + Operator}
             faktor1, faktor2, faktor3: word;
             op: TOperator;
             end;
type TMesswert=record           {Messwert: 3 ganze Zahlen}
               H_Wert, A_Wert, M_Wert: word;
               end;
type TTabelle=array[1..VersucheMax] of TMesswert; {Tabelle mit Messwerten}

type TOptimum = record                {mîgliche optimale Formel:}
                formel: TFormel;      {Formel}
                abw: real;            {Gesamtabweichung}
                fehler: byte;         {Anzahl der falschen Versuche}
                f1,f2,f3: byte;       {Nummern der falschen Versuche o. 0}
                summe: integer;       {Summe der Faktoren}
                end;
type TOptima = array[1..3] of TOptimum;   {die 3 schînsten Formeln}

function lese_datei(name: string; var tabelle: TTabelle): byte;
{liest Tabelle mit Messwerten aus Datei -> Anzahl der Versuche}
var datei: file of char;
    zeichen: char;
    zahl: string;
    wert, nr: word;
    ham: byte;
    fehler: integer;
begin
 {îffnen}
 assign(datei, name);
 reset(datei);

 ham:=0; nr:=1;

 while not eof(datei) do begin
       {bis zum nÑchsten Trennzeichen lesen}
       zahl:='';
       repeat
             read(datei, zeichen);
             if not (zeichen in [#10, #13, ' ']) then zahl:=zahl+zeichen;
       until (zeichen in [#10, #13, ' ']) or eof(datei);
       {gelesenen Wert in Zahl umwandeln}
       val(zahl, wert, fehler);
       if fehler=0 then begin            {falls Zahl:
                        an richtiger Stelle (H, A, M) in Tabelle eintragen}
          case ham of
          0: tabelle[nr].H_Wert:=wert;
          1: tabelle[nr].A_Wert:=wert;
          2: tabelle[nr].M_Wert:=wert;
          end;
          ham:=(ham+1) mod 3; if ham=0 then nr:=nr+1;
       end;
 end;

 close(datei);
 lese_datei:=nr-1;
end;

function abweichung(tabelle: TTabelle; anzahl: byte; formel: TFormel; var falsch1,falsch2,falsch3: byte): real;
{bestimmt Abweichung bei einer Formel}
var abweichungen: array[1 .. VersucheMax] of real;
    abw1,abw2,abw3: real;
    abw_t,s: real;
    i,t: byte;
begin
 {Abweichung bei einzelnen Versuchen}
 for i:=1 to anzahl do
     with formel, tabelle[i] do
          if op=plus then
             abweichungen[i]:=abs((faktor1*integer(H_Wert)+faktor2*integer(A_Wert))/faktor3-integer(M_Wert))
          else
             abweichungen[i]:=abs((faktor1*integer(H_Wert)-faktor2*integer(A_Wert))/faktor3-integer(M_Wert));

 {ermitteln der 3 grî·ten Abweichungen}
 abw1:=0; abw2:=0; abw3:=0; falsch1:=0; falsch2:=0; falsch3:=0;
 for i:=1 to anzahl do
     if abweichungen[i]>abw3 then begin
        abw3:=abweichungen[i]; falsch3:=i;
        if abw3>abw2 then begin
           abw_t:=abw2; abw2:=abw3; abw3:=abw_t;
           t:=falsch2; falsch2:=falsch3; falsch3:=t;
        end;
        if abw2>abw1 then begin
           abw_t:=abw1; abw1:=abw2; abw2:=abw_t;
           t:=falsch1; falsch1:=falsch2; falsch2:=t;
        end;
     end;

 {Gesamtabweichung}
 s:=0;
 for i:=1 to anzahl do s:=s+abweichungen[i];
 s:=s-abw1-abw2-abw3;
 abweichung:=s;
end;

function ggT(a, b:integer): integer;
{bestimmt ggT (Euklidischer Algorithmus)}
begin
 repeat
  if a > b then a := a mod b else b := b mod a;
 until a*b = 0;
 ggT := a + b;
end;


procedure suche(t: TTabelle; anzahl: byte; var o: TOptima);
{sucht die 3 schînsten Formeln}
const MaxFaktor:integer=100; {Bereich, in dem gesucht werden soll}
var f1,f2,f3: word;
    op: TOperator;
    formel: TFormel;
    optima: TOptima;
    ggT12: byte;

procedure einordnen(f: TFormel; var opt: TOptima);
{fÅgt neue Formel in Liste der 3 schînsten ein}
var i,j: byte;
    fehler: byte;
    f1,f2,f3: byte;
    abw: real;
    summe: integer;
begin
 abw:=abweichung(t,anzahl,formel,f1,f2,f3);    {bestimmt Abweichung}
 if abw>opt[3].abw then exit;                  {zu gro·e Abweichung}

 {Anzahl der fehlerhaften Versuche}
 if f3<>0 then
    fehler:=3
 else
    if f2<>0 then
       fehler:=2
    else
       if f1<>0 then
          fehler:=1
       else
          fehler:=0;
 {Summe der Faktoren}
 summe:=formel.faktor1+formel.faktor2+formel.faktor3;

 for i:=1 to 3 do         {Stelle fÅr Formel in Liste suchen, sodass ...}
  if (abw<opt[i].abw) or  {a) kleinere Gesamtabweichung oder}
     ((abw=opt[i].abw) and (fehler<opt[i].fehler)) or
      {b) gleiche Abweichung aber kleinere Anzahl fehlerhafter Versuche oder}
     ((abw=opt[i].abw) and (fehler=opt[i].fehler) and (summe<opt[i].summe)) then
      {c) gleiche Abw. u. gleiche Anz. fehlerh. Vers. aber kleiner Faktoren}
  begin
    for j:= 2 downto i do opt[j+1]:=opt[j];
                          {nachfolgende Formeln rÅcken eins nach hinten}
    {Speichern aller Daten}
    opt[i].formel:=formel;
    opt[i].fehler:=fehler;
    opt[i].f1:=f1; opt[i].f2:=f2; opt[i].f3:=f3;
    opt[i].abw:=abw;
    opt[i].summe:=summe;
    break;
  end;
end;


begin
 {Abweichungen noch "unendlich" gro·}
 optima[1].abw:= 1e38; optima[2].abw:= 1e38; optima[3].abw:= 1e38;
 for f1:=1 to MaxFaktor do
     for f2:=1 to MaxFaktor do begin
         ggT12:=ggT(f1,f2);
         for f3:=1 to MaxFaktor do
             if ggT(ggT12,f3)=1 then   {nur teilerfremde Zahlen untersuchen}
                for op:=plus to minus do begin
                    {Formel aus diesen Zahlen und Operator}
                    with formel do begin
                         faktor1:=f1; faktor2:=f2; faktor3:=f3;
                    end;
                    formel.op:=op;
                    {evt. in Optima einordnen}
                    einordnen(formel, optima);
                end;
     end;
 o:=optima;
end;



var tabelle: TTabelle;
    i, anzahl: word;
    opt: TOptima;
    dateiname: string;

begin
 clrscr;
 write('Name der Datei mit Tabelle: '); readln(dateiname);
 anzahl:=lese_datei(dateiname,tabelle);

 {Ausgabe der Tabelle}
 writeln('Tabelle');
 writeln;
 writeln('Nr.     H     A     M');
 for i:=1 to anzahl do
     with tabelle[i] do
          writeln(i:3,H_Wert:6,A_Wert:6,M_Wert:6);

 {Suche nach schînsten Formeln}
 suche(tabelle,anzahl,opt);

 {Ausgabe}
 writeln;
 writeln('Die besten Formeln');
 for i:=1 to 3 do begin
     with opt[i].formel do begin
          writeln;
          write('Die Formel ',faktor1,' * H ');
          if op=plus then write('+ ') else write('- ');
          writeln(faktor2,' * A = ',faktor3,' * M ist schîn,');
     end;
     writeln('weil sie eine kleine Gesamtabweichung von ',opt[i].abw:0:5,' hat,');
     with opt[i] do begin
          write('wenn man die ',fehler,' Messung(en) mit den/der Nummer(n) ');
          if f1<>0 then write(f1);
          if f2<>0 then write(', ',f2);
          if f3<>0 then write(', ',f3);
          writeln(' weglÑsst.');
     end;
 end;
 readln;
end.