program faxe_entschluesseln;
uses graph,crt;

const faxbreite=152 div 2; faxhoehe=112 div 2; {Grî·e des Faxes}
const Typ_A = 0; Typ_B = 1;                    {Typ A, Typ B auf Fax und Folie}

type muster=Typ_A .. Typ_B;
type TFax=array[1..faxbreite, 1..faxhoehe] of muster;  {Faxe}
type TMaske=TFax;                                      {Folie}
type TVersuchsMaske=array[1..faxbreite, 1..faxhoehe] of array[muster] of byte;


procedure lese_datei(name: string; var fax: TFax);
{Liest Datei mit Fax ein}
var datei: file of char;
    zeichen: char;
    kette: string;
    i: byte;
    zahl, dummy: integer;
    zeile, spalte: integer;
    nr: integer;
    korrekt: boolean;
begin
 {ôffnen}
 assign(datei, name);
 reset(datei);

 {öberprÅfung des Formats}
 kette:='';
 for i:=1 to 2 do begin read(datei, zeichen); kette:=kette+zeichen; end;
 if kette<>'P1' then begin write('Falsches Format!'); halt; end;

 {öberprÅfung der Breite}
 repeat read(datei, zeichen); until zeichen in ['0'..'9'];
 kette:='';
 repeat kette:=kette+zeichen; read(datei, zeichen); until not (zeichen in ['0'..'9']);
 val(kette, zahl, dummy);
 if zahl<>faxbreite*2 then begin write('False Breite!'); halt; end;

 {öberprÅfung der Hîhe}
 repeat read(datei, zeichen); until zeichen in ['0'..'9'];
 kette:='';
 repeat kette:=kette+zeichen; read(datei, zeichen); until not (zeichen in ['0'..'9']);
 val(kette, zahl, dummy);
 if zahl<>faxhoehe*2 then begin write('False Hîhe!'); halt; end;

 for zeile:=1 to faxhoehe*2 do begin
     for spalte:=1 to faxbreite*2 do begin
         repeat read(datei, zeichen); until zeichen in ['0','1'];
                if odd(zeile) and odd(spalte) then begin
                   {Typ feststellen}
                   if zeichen='1' then
                      fax[(spalte-1) div 2 + 1, (zeile-1) div 2 + 1]:=Typ_A
                   else
                      fax[(spalte-1) div 2 + 1, (zeile-1) div 2 + 1]:=Typ_B;
                end else begin
                   {öberprÅfen des Typs}
                   korrekt:=fax[(spalte-1) div 2 + 1, (zeile-1) div 2 +1]=Typ_A;
                   if zeichen='1' then begin
                      korrekt:=(korrekt and not odd(zeile) and not odd(spalte))
                                or (not korrekt and (odd(zeile) or odd(spalte)));
                   end else begin
                      korrekt:=(korrekt and (odd(zeile) or odd(spalte))) or
                               (not korrekt and not odd(zeile) and not odd(spalte));
                   end;
                   if not korrekt then begin write('Falsche Form!'); halt; end;
                end;
     end;
 end;

 {Schlie·en}
 close(datei);
end;

procedure verknuepfe(fax1, fax2: TFax; var VMaske: TVersuchsMaske);
{XOR-VerknÅpfung von 2 Faxen -> Informationen Åber Maske}
var i,j: integer;
begin
 for i:=1 to faxbreite do
     for j:=1 to faxhoehe do
         if fax1[i,j] xor fax2[i,j] = 0 then inc(VMaske[i,j][fax1[i,j]]);
end;

procedure erzeugeMaske(VMaske: TVersuchsMaske; var Maske: TMaske);
{Maske aus diesen Informationen erzeugen}
var i,j: integer;
begin
 randomize;
 for i:=1 to faxbreite do
     for j:=1 to faxhoehe do begin
         {ein Typ (A o. B) Åberwiegt}
         if VMaske[i,j][Typ_A]>VMaske[i,j][Typ_B] then Maske[i,j]:=Typ_A;
         if VMaske[i,j][Typ_A]<VMaske[i,j][Typ_B] then Maske[i,j]:=Typ_B;
         {kein Typ Åberwiegt -> Zufall}
         if VMaske[i,j][Typ_A]=VMaske[i,j][Typ_B] then Maske[i,j]:=random(2);
     end;
end;

procedure entschluesseln(cryptFax: TFax; maske: TMaske; var fax: TFax);
{EntschlÅsseln des Faxes}
var i,j: integer;
begin
 for i:=1 to faxbreite do
     for j:=1 to faxhoehe do
         fax[i,j]:=cryptFax[i,j] xor maske[i,j];
end;

procedure zeichne(fax: TFax);
{Zeichnen des Faxes}
const b=4; {Breite der Quadrate}
var i,j: integer;
begin
 for i:=1 to faxbreite do
     for j:=1 to faxhoehe do begin
         setfillstyle(solidfill, 15-15*fax[i,j]);
         setcolor(15-15*fax[i,j]);
         bar(b*(i-1),b*(j-1),b*i,b*j);
     end;
 readln;
end;

const maxfaxe=10;                      {maximale Faxanzahl}
var anzahl: byte;                      {tatsÑchliche Faxanzahl}
    name: string;                      {Dateiname}
    faxe: array[1..maxfaxe] of TFax;   {verschlÅsselte Faxe (A, B: Typen)}
    entschluesselt: TFax;              {entschlÅsseltes Fax (0, 1: Farben)}
    maske: TMaske;                     {Ver-/EntschlÅsselungsfolie}
    VMaske: TVersuchsMaske;            {Informationsspeicher fÅr Maske}
    i,j: integer;
    treiber,modus: integer;            {fÅr Grafikmodus}

begin
{Einlesen der Faxe}
clrscr;
writeln('Fax-EntschlÅsselung');
write('Anzahl der Faxe (max. ',maxfaxe,'): '); readln(anzahl);
for i:=1 to anzahl do begin
    write('Datei mit Fax Nr. ',i,': '); readln(name);
    lese_datei(name, faxe[i]);
end;

{Initialisieren der Versuchsmaske}
for i:=1 to faxbreite do
    for j:=1 to faxhoehe do begin
        VMaske[i,j][Typ_A]:=0;
        VMaske[i,j][Typ_B]:=0;
    end;

{Informationsgewinnung aus Faxen}
for i:=1 to anzahl do
    for j:=i+1 to anzahl do
        verknuepfe(faxe[i],faxe[j],VMaske);

{Ermittlung der Maske}
erzeugeMaske(VMaske,maske);

{Initialisierung des Grafikmodus}
treiber := detect;
initgraph(treiber, modus, '');

{EntschlÅsseln und Anzeigen der Faxe}
for i:=1 to anzahl do begin
    entschluesseln(faxe[i],maske,entschluesselt);
    zeichne(entschluesselt);
end;

closegraph;
end.