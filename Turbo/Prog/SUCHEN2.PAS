program dateisuche;
uses dos, crt, dyna;
type TSuche= record
             name: string[12];
             attron: byte;    {1: muss gesetzt sein, 0: egal}
             attroff: byte;   {0: darf nicht gesetzt sein, 1: egal}
             groessemin: longint;
             groessemax: longint;
             datummin: longint;
             datummax: longint;
             trivial: boolean {Anzeige von . und .. ?}
             end;
type treffer= record
              verzeichnis: string[100];
              name:        string[8];
              ext:         string[3];
              attr:        byte;
              groesse:     longint;
              datum:       longint;
              end;

type sortierkrit = (naz, nza      , eaz, eza   , d09, d90       , g09, g90);
                   {Name (auf, ab), Erweiterung, Datum (auf, ab), Gr”แe}
var sortierung : record
                 verzgrup: boolean; {nach Verz. gruppiert}
                 vol: boolean;  {Volume ID zuerst}
                 verz: boolean; {Verzeichnisse zuerst}
                 krit: array[1..4] of sortierkrit; {Kriterien}
                 end;

var s: TSuche;
    trefferliste: liste;
    datum: DateTime;
    verzeichnis: string;
    alle: boolean;
    eingabe,ausgabe: string;
    zahl: longint;
    fehler: integer;
    i: byte;

function attribut(a: byte): string;
var attr: string;
begin
 attr:='';
 if a and VolumeID <> 0 then attr:=attr+'V' else attr:=attr+' ';
 if a and Directory <> 0 then attr:=attr+'D' else attr:=attr+' ';
 if a and Archive <> 0 then attr:=attr+'A' else attr:=attr+' ';
 if a and SysFile <> 0 then attr:=attr+'S' else attr:=attr+' ';
 if a and Hidden <> 0 then attr:=attr+'H' else attr:=attr+' ';
 if a and ReadOnly <> 0 then attr:=attr+'R' else attr:=attr+' ';
 attribut:=attr;
end;

function fuehrendenull(n: integer): string;
var s: string;
begin
 str(n,s);
 if n<10 then fuehrendenull:='0'+s else fuehrendenull:=s;
end;

function frueher(dat1, dat2: longint): boolean;
begin
if (dat1<0) and (dat2>=0) then
   frueher:=false
else begin
   if (dat1>=0) and (dat2<0) then
      frueher:=true
   else begin
      if dat1<0 then
         frueher:=(dat1>dat2)
      else
         frueher:=(dat1<dat2);
   end;
end;
end;

procedure suchen(verzeichnis: string; suche: TSuche; weiter: boolean);
var reg: SearchRec;
    n: string[8];
    e: string[3];
    a: byte;
    groesse: longint;
    datum: longint;
    punktpos: integer;
    t: ^treffer;
begin
 findfirst(verzeichnis+suche.name, ANYFILE, reg);
 while doserror=0 do begin
       punktpos:=pos('.',reg.name);
       if (punktpos=0) or (reg.name='.') or (reg.name='..') then begin
          n:=copy(reg.name,1,8); e:='';
       end
       else begin
          n:=copy(reg.name,1,punktpos-1);
          e:=copy(reg.name,punktpos+1,3);
       end;
       a:=reg.attr;
       groesse:=reg.size;
       datum:=reg.time;
       with suche do
       if (attron and a = attron) and
          (attroff or a = attroff) and
          (groessemin <= groesse) and (groesse <= groessemax) and
          frueher(datummin, datum) and frueher(datum, datummax) and
          ( ((n<>'.')and(n<>'..')) or trivial ) then begin
            new(t);
            t^.verzeichnis:=verzeichnis;
            t^.name:=n; t^.ext:=e;
            t^.attr:=a;
            t^.groesse:=groesse; t^.datum:=datum;
            add(trefferliste,t);
       end;
       findnext(reg);
 end;
 if weiter then begin
    findfirst(verzeichnis+'*.*',Directory,reg);
    while doserror=0 do begin
          if (reg.name<>'.') and (reg.name<>'..') and (reg.attr and Directory <> 0) then
             suchen(verzeichnis+reg.name+'\',suche,true);
          findnext(reg);
    end;
 end;
end;

{$F+}
function sortieren(x1, x2: pointer): boolean;
label ende;
var erg, gleich: boolean;
    t1, t2: treffer;
    i: byte;
begin
 t1:=treffer(x1^); t2:=treffer(x2^);
 gleich:=true;

 if sortierung.verzgrup and (t1.verzeichnis<>t2.verzeichnis) then gleich:=false;
 if not gleich then begin
    erg:=(t1.verzeichnis<t2.verzeichnis);
    goto ende;
 end;

 if sortierung.vol then begin
 erg:=(((t1.attr and VolumeID = VolumeID)) and (t2.attr and VolumeID <> VolumeID));
 if erg then goto ende;
 erg:=not (((t2.attr and VolumeID = VolumeID)) and (t1.attr and VolumeID <> VolumeID));
 if not erg then goto ende;
 end;

 if sortierung.verz then begin
 erg:=(((t1.attr and directory = directory)) and (t2.attr and directory <> directory));
 if erg then goto ende;
 erg:=not (((t2.attr and directory = directory)) and (t1.attr and directory <> directory));
 if not erg then goto ende;
 end;

 i:=1;
 while gleich and (i<5) do begin
    case sortierung.krit[i] of
    naz,nza: gleich:=(t1.name=t2.name);
    eaz,eza: gleich:=(t1.ext=t2.ext);
    d09,d90: gleich:=(t1.datum=t2.datum);
    g09,g90: gleich:=(t1.groesse=t2.groesse);
    end;
    if not gleich then begin
       case sortierung.krit[i] of
       naz: erg:=(t1.name<t2.name);
       nza: erg:=(t1.name>t2.name);
       eaz: erg:=(t1.ext<t2.ext);
       eza: erg:=(t1.ext>t2.ext);
       d09: erg:=frueher(t1.datum,t2.datum);
       d90: erg:=not frueher(t1.datum,t2.datum);
       g09: erg:=(t1.groesse<t2.groesse);
       g90: erg:=(t1.groesse>t2.groesse);
    end;
    end;
    inc(i);
 end;
 if gleich then erg:=(t1.verzeichnis<t2.verzeichnis);

 ende:
 sortieren:=erg;
end;
{$F-}

procedure ausgeben(trefferliste: liste);
var dat: DateTime;
    i, l: integer;
    t: ^treffer;
    altv: string;
    zeile: integer;
    groesseges: longint;
    anzahl: word;
begin
 altv:='';
 stecksort(trefferliste, sortieren);

 l:=len(trefferliste);
 groesseges:=0; anzahl:=l;
 clrscr; zeile:=0;

 for i:=1 to l do begin
     t:= get(trefferliste, i);
     with t^ do begin
          if altv<>verzeichnis then begin
             writeln;
             writeln(verzeichnis);
             inc(zeile,2);
             altv:=verzeichnis;
          end;
          unpacktime(datum,dat);
          if attr and VolumeID <> VolumeID then begin
             write(name:8);
             if ext <> '' then write('.') else write(' ');
             write(ext:3);
          end
          else
             write(name+ext:12);
          write('  ',attribut(attr):6,'  ',groesse:7,'   ');
          with dat do
               writeln(day:2,'. ',month:2,'. ',year:4,'  ',
                       fuehrendenull(hour):2,':',fuehrendenull(min):2,
                       ':',fuehrendenull(sec):2);
          inc(zeile);
          groesseges:=groesseges+groesse;
          if zeile>=22 then begin
             writeln('     --- Enter ---'); readln;
             clrscr; zeile:=0;
          end;
     end;
 end;
 writeln;
 writeln('Gesamt:            ',groesseges:10,' Bytes in ',anzahl,' Dateien');
 write('     --- Ende - Enter ---'); readln;
end;

begin
 clrscr;
 write('ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
 write('บ                               Dateisuche                                     บ');
 write('ฬอออออออออออออออหออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน');
 write('บ Verzeichnis   บ C:\                                                          บ');
 write('บ Name          บ *.*                                                          บ');
 write('ฬอออออออออออออออฮอออออออออออออออหอออออหออออออออออออออออออออออออออออออออออออออออน');
 write('บ Gr”แe     von บ 0             บ bis บ 2147483647                             บ');
 write('บ Datum     von บ  1.  1. 1980  บ bis บ 31. 12. 2099                           บ');
 write('บ Attribute     บ VDASHR        บ     บ                                        บ');
 write('บ +, -, leer:   บ               บ     บ                                        บ');
 write('ฬอออออออออออออออสอออออออออออออออสอออออฮอออหออออออออออออออออออออออออออออออออออออน');
 write('บ Unterverzeichnisse durchsuchen      บ X บ                                    บ');
 write('บ auch triviale Verzeichnisse angeben บ   บ                                    บ');
 write('ฬอออออออออออออออออออออออออออออออออออออสอออสออออออออออออออออออออออออออออออออออออน');
 write('บ                             Sortierung                                       บ');
 write('ฬอออออออออออออออออออออออออออออออออหอออหออออออออออออออออออออออหอออหอออออออออออออน');
 write('บ nach Verzeichnissen gruppieren  บ X บ                      บ   บ             บ');
 write('บ VolumeID zuerst                 บ X บ Verzeichnisse zuerst บ X บ             บ');
 write('ฬอออออออออออออออหอออออออออออออออออสอออฮออออออออออออออหอออออออสอออสอออออออออออออน');
 write('บ 1. Kriterium  บ Name aufsteigend    บ 2. Kriterium บ Erw. aufsteigend        บ');
 write('บ 3. Kriterium  บ Datum aufsteigend   บ 4. Kriterium บ Gr”แe aufsteigend       บ');
 write('ฬอออออออออออออออสอออออออออออออออออออออสออออออออออออออสอออออออออออออออออออออออออน');
 write('บ                                                                              บ');
 write('ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');

 verzeichnis:='C:\';
 alle:=true;
 with s do begin
      name:='*.*'; attron:=0; attroff:=$FF;
      trivial:=false;
      groessemin:=0; groessemax:=maxlongint;
      with datum do begin
           day:=1; month:=1; year:=1980;
           hour:=0; min:=0; sec:=0;
      end;
      packtime(datum, datummin);
      with datum do begin
           day:=31; month:=12; year:=2099;
           hour:=23; min:=59; sec:=59;
      end;
      packtime(datum, datummax);
 end;
 with sortierung do begin
      verzgrup:=false;
      vol:=true;
      verz:=true;
      krit[1]:=naz;
      krit[2]:=eaz;
      krit[3]:=d09;
      krit[4]:=g09;
 end;

 repeat
  gotoxy(3,23); write('neuer Suchpfad oder <ENTER>                                 ');
  gotoxy(19,4); readln(eingabe); if eingabe<>'' then begin
                verzeichnis:=eingabe;
                gotoxy(19,4); write('                                                             ');
                gotoxy(19,4); write(verzeichnis); end;

  gotoxy(3,23); write('Dateiname (mit *, ?) oder <ENTER>                           ');
  gotoxy(19,5); readln(eingabe); if eingabe<>'' then begin
                s.name:=eingabe;
                gotoxy(19,5); write('                                                             ');
                gotoxy(19,5); write(s.name); end;

  gotoxy(3,23); write('Minimale Dateigr”แe oder <ENTER>                            ');
  gotoxy(19,7); readln(eingabe); if eingabe<>'' then begin
                val(eingabe,zahl,fehler); if zahl<0 then zahl:=0;
                if fehler=0 then s.groessemin:=zahl;
                gotoxy(19,7); write('              ');
                gotoxy(19,7); write(s.groessemin); end;

  gotoxy(3,23); write('Maximale Dateigr”แe (bis 2147483647) oder <ENTER>           ');
  gotoxy(41,7); readln(eingabe); if eingabe<>'' then begin
                val(eingabe,zahl,fehler); if zahl<0 then zahl:=0;
                if fehler=0 then s.groessemax:=zahl;
                gotoxy(41,7); write('              ');
                gotoxy(41,7); write(s.groessemax); end;

  unpacktime(s.datummin,datum);
  gotoxy(3,23); write('Tag des frhesten Datums oder <ENTER>                       ');
  gotoxy(19,8); readln(eingabe); if eingabe<>'' then begin
                val(eingabe,zahl,fehler);
                if (fehler=0) and (zahl>=1) and (zahl<=31)
                then datum.day:=zahl;
                gotoxy(19,8); write('  ');
                gotoxy(19,8); write(datum.day:2); end;
  gotoxy(3,23); write('Monat des frhesten Datums oder <ENTER>                     ');
  gotoxy(23,8); readln(eingabe); if eingabe<>'' then begin
                val(eingabe,zahl,fehler);
                if (fehler=0) and (zahl>=1) and (zahl<=12)
                then datum.month:=zahl;
                gotoxy(23,8); write('  ');
                gotoxy(23,8); write(datum.month:2); end;
  gotoxy(3,23); write('Jahr des frhesten Datums (ab 1980) oder <ENTER>            ');
  gotoxy(27,8); readln(eingabe); if eingabe<>'' then begin
                val(eingabe,zahl,fehler);
                if (fehler=0) and (zahl>=1980) and (zahl<=2099)
                then datum.year:=zahl;
                gotoxy(27,8); write('    ');
                gotoxy(27,8); write(datum.year:4); end;
  packtime(datum,s.datummin);

  unpacktime(s.datummax,datum);
  gotoxy(3,23); write('Tag des sptesten Datums oder <ENTER>                       ');
  gotoxy(41,8); readln(eingabe); if eingabe<>'' then begin
                val(eingabe,zahl,fehler);
                if (fehler=0) and (zahl>=1) and (zahl<=31)
                then datum.day:=zahl;
                gotoxy(41,8); write('  ');
                gotoxy(41,8); write(datum.day:2); end;
  gotoxy(3,23); write('Monat des sptesten Datums oder <ENTER>                     ');
  gotoxy(45,8); readln(eingabe); if eingabe<>'' then begin
                val(eingabe,zahl,fehler);
                if (fehler=0) and (zahl>=1) and (zahl<=12)
                then datum.month:=zahl;
                gotoxy(45,8); write('  ');
                gotoxy(45,8); write(datum.month:2); end;
  gotoxy(3,23); write('Jahr des sptesten Datums (bis 2099) oder <ENTER>           ');
  gotoxy(49,8); readln(eingabe); if eingabe<>'' then begin
                val(eingabe,zahl,fehler);
                if (fehler=0) and (zahl>=1980) and (zahl<=2099)
                then datum.year:=zahl;
                gotoxy(49,8); write('    ');
                gotoxy(49,8); write(datum.year:4); end;
  packtime(datum,s.datummax);

  ausgabe:='';
  if s.attron and VolumeID = VolumeID then ausgabe:=ausgabe+'+'
     else if s.attroff or not VolumeID = not VolumeID then ausgabe:=ausgabe+'-'
          else ausgabe:=ausgabe+' ';
  if s.attron and Directory = Directory then ausgabe:=ausgabe+'+'
     else if s.attroff or not Directory = not Directory then ausgabe:=ausgabe+'-'
          else ausgabe:=ausgabe+' ';
  if s.attron and Archive = Archive then ausgabe:=ausgabe+'+'
     else if s.attroff or not Archive = not Archive then ausgabe:=ausgabe+'-'
          else ausgabe:=ausgabe+' ';
  if s.attron and SysFile = SysFile then ausgabe:=ausgabe+'+'
     else if s.attroff or not SysFile = not SysFile then ausgabe:=ausgabe+'-'
          else ausgabe:=ausgabe+' ';
  if s.attron and Hidden = Hidden then ausgabe:=ausgabe+'+'
     else if s.attroff or not Hidden = not Hidden then ausgabe:=ausgabe+'-'
          else ausgabe:=ausgabe+' ';
  if s.attron and ReadOnly = ReadOnly then ausgabe:=ausgabe+'+'
     else if s.attroff or not ReadOnly = not ReadOnly then ausgabe:=ausgabe+'-'
          else ausgabe:=ausgabe+' ';

  gotoxy(3,23); write('+: muss gesetzt sein, -: darf nicht gesetzt sein, leer: egal');
  gotoxy(19,10); write(ausgabe);
  gotoxy(19,10); readln(eingabe);
  if length(eingabe)<6 then eingabe:=eingabe+copy(ausgabe,length(eingabe)+1,6-length(eingabe));
  s.attron:=0; s.attroff:=$FF;
  if eingabe[1]='+' then s.attron:=s.attron or VolumeID
     else if eingabe[1]='-' then s.attroff:=s.attroff and not VolumeID;
  if eingabe[2]='+' then s.attron:=s.attron or Directory
     else if eingabe[2]='-' then s.attroff:=s.attroff and not Directory;
  if eingabe[3]='+' then s.attron:=s.attron or Archive
     else if eingabe[3]='-' then s.attroff:=s.attroff and not Archive;
  if eingabe[4]='+' then s.attron:=s.attron or SysFile
     else if eingabe[4]='-' then s.attroff:=s.attroff and not SysFile;
  if eingabe[5]='+' then s.attron:=s.attron or Hidden
     else if eingabe[5]='-' then s.attroff:=s.attroff and not Hidden;
  if eingabe[6]='+' then s.attron:=s.attron or ReadOnly
     else if eingabe[6]='-' then s.attroff:=s.attroff and not ReadOnly;
  for i:= 1 to 6 do if not (eingabe[i] in ['+','-',' ']) then eingabe[i]:=' ';
  gotoxy(19,10); write(eingabe);

  gotoxy(3,23); write('beliebige Eingabe fr ja, Leereingabe fr nein              ');
  gotoxy(41,12); readln(eingabe);
  alle:=eingabe<>'';
  gotoxy(41,12); if alle then write('X ') else write('  ');
  gotoxy(41,13); readln(eingabe);
  s.trivial:=eingabe<>'';
  gotoxy(41,13); if s.trivial then write('X ') else write('  ');
  gotoxy(37,17); readln(eingabe);
  sortierung.verzgrup:=eingabe<>'';
  gotoxy(37,17); if sortierung.verzgrup then write('X ') else write('  ');
  gotoxy(37,18); readln(eingabe);
  sortierung.vol:=eingabe<>'';
  gotoxy(37,18); if sortierung.vol then write('X ') else write('  ');
  gotoxy(64,18); readln(eingabe);
  sortierung.verz:=eingabe<>'';
  gotoxy(64,18); if sortierung.verz then write('X ') else write('  ');

  gotoxy(3,23); write('n: Name, e: Erw, d: Datum, g: Gr”แe; +: auf-, -: absteigend ');
  for i:=1 to 4 do begin
  gotoxy(19 + 37 * ((i-1) mod 2),20 + (i-1) div 2); readln(eingabe);
  if (length(eingabe)=2) and (eingabe[1] in ['n','e','d','g']) and (eingabe[2] in ['+', '-']) then begin
     if eingabe[2]='+' then eingabe[1]:=upcase(eingabe[1]);
     case eingabe[1] of
     'N': sortierung.krit[i]:=naz;
     'n': sortierung.krit[i]:=nza;
     'E': sortierung.krit[i]:=eaz;
     'e': sortierung.krit[i]:=eza;
     'D': sortierung.krit[i]:=d09;
     'd': sortierung.krit[i]:=d90;
     'G': sortierung.krit[i]:=g09;
     'g': sortierung.krit[i]:=g90;
     end;
  end;
  gotoxy(19 + 37 * ((i-1) mod 2),20 + (i-1) div 2);
  case sortierung.krit[i] of
  naz: write('Name aufsteigend ');
  nza: write('Name absteigend  ');
  eaz: write('Erw. aufsteigend ');
  eza: write('Erw. absteigend  ');
  d09: write('Datum aufsteigend');
  d90: write('Datum absteigend ');
  g09: write('Gr”แe aufsteigend');
  g90: write('Gr”แe absteigend ');
  end;
  end;

  gotoxy(3,23); write('<ENTER> um Suche zu starten, sonst beliebige Taste          ');
  gotoxy(3,23); readln(eingabe);

 until eingabe='';

 trefferliste:=nil;
 suchen(verzeichnis,s,alle);
 ausgeben(trefferliste);
end.