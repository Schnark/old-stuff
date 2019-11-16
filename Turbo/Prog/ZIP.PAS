program zip;
{$D-}
{$D Komprimierungsprogramm}
{$G+}
{$L-}
{$N+}
{$Q-}
{$R-}
{$S-}
{$Y-}
uses crt, dos;
const MAXWOERTER = 7000;
      LAENGE = 8;
      _EXT = 'ZIP';
type stri = string[LAENGE];
     datei = file of char;
     zahlen = file of byte;
var woerterbuch : array[256 .. MAXWOERTER] of stri;
    laengenliste: array[2 .. LAENGE] of 255 .. MAXWOERTER;
    anzahlw: integer;
    speicher: longint;
    bits: byte;
    ln2: real;

procedure prozent(neu: boolean; p: integer);
var i, laenge: integer;
    ausgabe: string[78];
    zahl: string[5];
begin
if neu then begin
 gotoxy(1,20); write('⁄'); gotoxy(80,20); write('ø');
 gotoxy(1,21); write('≥'); gotoxy(80,21); write('≥');
 gotoxy(1,22); write('¿'); gotoxy(80,22); write('Ÿ');
 for i := 2 to 79 do begin
     gotoxy(i,20); write('ƒ');
     gotoxy(i,22); write('ƒ');
 end;
end;
 laenge:=round(p/100*78);
 ausgabe[0]:=#78;
 for i:= 1 to 78 do ausgabe[i] := ' ';
 str(p:3, zahl); zahl :=  zahl + ' %';
 for i:= 37 to 41 do ausgabe[i] := zahl[i-36];
 textcolor(lightgray); textbackground(black); gotoxy(2,21);
 write(copy(ausgabe,1,laenge));
 textcolor(black); textbackground(lightgray);
 write(copy(ausgabe,laenge+1,78-laenge));
end;


procedure ausgabe(var nach: zahlen; wert: integer);
var i: word;
    sbits: byte;
begin
 sbits := 1+trunc(ln(anzahlw+1)/ln2);   {#+1 wegen Rundungsfehlern}

 speicher := speicher SHL sbits OR wert;  {+ wert}
 inc(bits,sbits);

 while bits>=8 do begin
      dec(bits,8);
      i := word(speicher SHR bits) ;
      write(nach, byte(i));
      dec(speicher, i SHL bits); {speicher mod _2hoch;}
 end;
end;

function lese(var von: zahlen): integer;
var wert: integer;
    wert2: word;
    sbits, byte1: byte;
begin
 sbits := 1+trunc(ln(anzahlw+1)/ln2); {#+1 wegen Rundungsfehlern}
 while (bits<sbits) and not eof(von) do begin
  read(von, byte1);
  speicher := speicher SHL 8 OR byte1; {+ byte1}
  inc(bits,8);
 end;
 if bits<sbits then
    wert := -1
 else begin
    dec(bits,sbits);
    wert2 := word(speicher SHR bits);
    dec(speicher, wert2 SHL bits); {speicher mod _2hoch;}
    wert := wert2;
 end;
 lese := wert;
end;

procedure speichern(wort: string; erstliste: boolean);
{Speichert ein Wort im Wîrterbuch,
 falls es noch Platz hat und nicht zu lang ist}
var l:integer;
begin
 if anzahlw >= MAXWOERTER then exit;
 l:= length(wort);
 if (l > LAENGE) or (l = 1) then exit;
 inc(anzahlw);
 woerterbuch[anzahlw] := wort;
 if erstliste and (laengenliste[l]=255) then laengenliste[l]:=anzahlw;
end;

function nummer(wort: string; ab: integer): integer;
{Ermittelt die Nummer des Worts im Wîrterbuch}
var i, ausgabe, l: integer;
begin
 ausgabe := -1;
 l:=length(wort);
 if l = 1 then ausgabe := ord(wort[1])
                     else begin
                          if l>LAENGE then l:=255 else l:=laengenliste[l];
                          if l=255 then ab:=anzahlw+1 else if ab<l then ab:=l;
                          if ab<256 then ab:=256;
                          for i := ab to anzahlw do
                              if woerterbuch[i] = wort then begin
                                 ausgabe := i;
                                 break;
                              end;
                     end;
 nummer := ausgabe;
end;

procedure kompr(var von: datei; var nach: zahlen);
var kette, alt: string[LAENGE+1];
    zeichen: char;
    nr: integer;
    p: integer;
    gelesen, laenge: longint;
begin
 prozent(true,0);
 gelesen := 0; laenge := filesize(von);
 kette := ''; alt := ''; nr := 256;
 repeat
  read(von, zeichen);                            {1 Zeichen lesen}

  inc(gelesen);
  if gelesen mod 20 = 0 then begin
     p:=round(100*gelesen/laenge);
     prozent(false, p);
  end;

  kette := kette + zeichen;                      {an Kette anhÑngen}
  nr := nummer(kette,nr);                        {nachschlagen}
  if (nr = -1) or eof(von) then begin            {nich gefunden o. Ende}
   ausgabe(nach, nummer(copy(kette,1,length(kette)-1),nr));
                                                 {alte Kette in Datei}
   if alt <> '' then speichern(alt,true);
   alt := kette;                                 {neue Kette in W.-buch}
   kette := kette[length(kette)];                {weiter}
  end;
 until eof(von);
 ausgabe(nach, nummer(kette,nr));
 anzahlw := 255;
 ausgabe(nach, 0);
end;

procedure dekompr(var von: zahlen; var nach: datei);
var nr, i, p: integer;
    groesse, position: longint;
    zeichen, zeichenalt: string[LAENGE+1];
begin
 groesse := filesize(von);
 zeichenalt := '';
 prozent(true, 0);
 repeat

  position:=filepos(von);
  if position mod 20 = 0 then begin
     p:=round(100*position/groesse);
     prozent(false, p);
  end;

  nr := lese(von);
  if nr >= 0 then begin
     if nr < 256 then zeichen := chr(nr) else zeichen := woerterbuch[nr];
      {nachschlagen}
     if (zeichenalt <> '') then
                           speichern(zeichenalt + zeichen[1],false); {hinzufÅgen}
     for i := 1 to length(zeichen) do write(nach, zeichen[i]);
     zeichenalt := zeichen;
  end;
 until nr=-1;
end;

procedure komprimiere(von, nach: string);
var ein: datei;
    aus: zahlen;
    i: integer;
begin
 anzahlw := 255; speicher := 0; bits := 0;
 for i:= 2 to LAENGE do laengenliste[i]:=255;
 assign(ein, von);
 assign(aus, nach);
 reset(ein); rewrite(aus);
 kompr(ein, aus);
 gotoxy(2,18);
 write('KomprimierungsverhÑltnis: ',filesize(ein)/filesize(aus):0:1,' : 1.0');
 close(ein); close(aus);
 readln;
end;

procedure dekomprimiere(von, nach: string);
var ein: zahlen;
    aus: datei;
begin
 anzahlw := 255; speicher := 0; bits := 0;
 assign(ein, von);
 assign(aus, nach);
 reset(ein); rewrite(aus);
 dekompr(ein, aus);
 close(ein); close(aus);
end;

function dateiname(ex, ext: boolean): string;
var eingabe: string;
    f: file;
    ok: boolean;
    antwort: char;
    fehler: integer;
begin
repeat
 ok := true;
 readln(eingabe);
 if ext and (pos('.',eingabe) = 0) then eingabe := eingabe+'.'+_EXT;
 if ex then begin
    {$I-}
    assign(f, eingabe);
    reset(f);
    if IOResult<>0 then begin
       write(' Datei existiert nicht!');
       ok := false;
    end
    else close(f);
    {$I+}
 end;
 if not ex then begin
    {$I-}
    assign(f, eingabe);
    reset(f);
    fehler:=IOResult;
    if fehler=0 then begin
       write(' Datei existiert bereits! öberschreiben? <j,n> ');
       readln(antwort);
       ok := (upcase(antwort)='J');
       close(f);
    end
    else if fehler<>2 then begin
            write(' Pfad/Laufwerk/... existiert nicht!');
            ok := false;
         end;
    {$I+}
 end;
 if not ok then write(' Neuer Versuch: ');
until ok;
dateiname := eingabe;
end;

procedure verzeichnis;
var v: string;
begin
 getdir(0,v);
 writeln(' Aktuelles Verzeichnis: ',v);
 write(' Neues Verzeichnis: ');
 readln(v);
 {$I-}
 chdir(v);
 if IOResult<>0 then begin write(' Verzeichnis existiert nicht!'); readln; end;
 {$I+}
end;

procedure liste;
var DirInfo: SearchRec;
    suche: string;
    nr: integer;
begin
 nr := 0;
 getdir(0,suche);
 writeln(' Aktuelles Verzeichnis: ', suche);
 write(' Zu suchende Datei(en): ');
 readln(suche);
 FindFirst(suche, anyfile, DirInfo);
 while DosError = 0 do begin
       inc(nr);
       write(' ',DirInfo.Name:12);
       if (dirinfo.attr and directory)<>0 then write(' <DIR>');
       writeln;
       if nr mod 23 = 0 then readln;
       FindNext(DirInfo);
 end;
 if nr = 0 then begin writeln(' Keine Datei gefunden!'); readln; end;
 if nr mod 23 <> 0 then readln;
end;

procedure menu;
var ende: boolean;
    eingabe: char;
    ein, aus: string;
begin
 textcolor(black); textbackground(lightgray);
 ende := false;
 repeat
  clrscr;
  writeln('                             Komprimierungsprogramm');
  writeln;
  writeln;
  textcolor(red);
  write('  1. K');
  textcolor(black);
  writeln('omprimieren');
  textcolor(red);
  write('  2. D');
  textcolor(black);
  writeln('ekomprimieren');
  textcolor(red);
  write('  3. V');
  textcolor(black);
  writeln('erzeichnis wechseln');
  textcolor(red);
  write('  4. ');
  textcolor(black);
  write('Datei');
  textcolor(red);
  write('l');
  textcolor(black);
  writeln('iste');
  writeln;
  textcolor(red);
  write('  5. E');
  textcolor(black);
  writeln('nde');
  writeln;
  write(' --> ');
  readln(eingabe);
  case eingabe of
  '1','k','K': begin
        write(' Zu komprimierende Datei: ');
        ein := dateiname(true, false);
        write(' Komprimierte Datei: ');
        aus := dateiname(false, true);
        komprimiere(ein, aus);
       end;
  '2','d','D': begin
        write(' Komprimierte Datei: ');
        ein := dateiname(true, true);
        write(' Entkomprimierte Datei: ');
        aus := dateiname(false, false);
        dekomprimiere(ein, aus);
       end;
  '3','v','V': verzeichnis;
  '4','l','L': liste;
  '5','e','E': ende := true;
  end;
 until ende;
 textcolor(lightgray); textbackground(black); clrscr;
end;

begin
 ln2:=ln(2);
 menu;
end.