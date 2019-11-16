program dateisuche;
uses dos, crt, dyna;
type TSuche= record
             name: string[8];
             ext:  string[3];
             attr: byte;
             groessemin: longint;
             groessemax: longint;
             datummin: longint;
             datummax: longint;
             end;
type treffer= record
              verzeichnis: string[100];
              name:        string[8];
              ext:         string[3];
              attr:        byte;
              groesse:     longint;
              datum:       longint;
              end;

var s: TSuche;
    trefferliste: liste;
    datum: DateTime;

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
 findfirst(verzeichnis+suche.name+'.'+suche.ext, ANYFILE, reg);
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
       if (attr and a = attr) and
          (groessemin <= groesse) and (groesse <= groessemax) and
          frueher(datummin, datum) and frueher(datum, datummax) then begin
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
var erg, fertig: boolean;
    t1, t2: treffer;
begin
 t1:=treffer(x1^); t2:=treffer(x2^);

 erg:=(t1.verzeichnis<t2.verzeichnis);
 if t1.verzeichnis<>t2.verzeichnis then goto ende;

 erg:=(((t1.attr and VolumeID = VolumeID)) and (t2.attr and VolumeID <> VolumeID));
 if erg then goto ende;
 erg:=not (((t2.attr and VolumeID = VolumeID)) and (t1.attr and VolumeID <> VolumeID));
 if not erg then goto ende;

 erg:=(((t1.attr and directory = directory)) and (t2.attr and directory <> directory));
 if erg then goto ende;
 erg:=not (((t2.attr and directory = directory)) and (t1.attr and directory <> directory));
 if not erg then goto ende;

 erg:=(t1.name<t2.name);
 if not (t1.name=t2.name) then goto ende;

 erg:=(t1.ext<t2.ext);

 ende:
 sortieren:=erg;
end;
{$F-}

procedure ausgabe(trefferliste: liste);
var dat: DateTime;
    i, l: integer;
    t: ^treffer;
    altv: string;
    zeile: integer;
    groesseges: longint;
    anzahl: word;
begin
 clrscr; zeile:=0;
 altv:='';
 stecksort(trefferliste, sortieren);

 l:=len(trefferliste);
 groesseges:=0; anzahl:=l;

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
 with s do begin
      name:='*'; ext:='*'; attr:=0;
      groessemin:=1000000; groessemax:=maxlongint;
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
 trefferliste:=nil;
 suchen('C:\',s,true);
 ausgabe(trefferliste);
end.