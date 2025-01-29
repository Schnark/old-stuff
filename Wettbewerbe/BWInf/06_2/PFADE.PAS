program TrimmDichPfade;
uses strings;
const Pfad_:string={'RTBRSTBTRBTRRTSSSSSRRTTSTRTTSBBRTBRSBRRBBBSRBRBB'{}
'RTRBRTBTTRRBTR'{}
{'RTRT'{};
const datei_string=false;
var datei: file of char;
    datei_: file;
var pfad, pfad2: pchar;

type buchstaben=char;
const zeichen:set of char = ['A'..'Z',#196,#214,#220,#223];
const anzahl_zeichen=30;
var pos_mit_n_zeichen: array[0..anzahl_zeichen] of longint;

type langeZahl = ^ziffern;
     ziffern = record
               z: word;
               w: langeZahl;
               end;

procedure initLZ(var lZ: langeZahl; wert: byte);
begin
new(lZ); lZ^.z:=wert; lZ^.w:=nil;
end;

procedure addiere(lZ, summand: langeZahl);
var summe: longint;
    z1,z2,neu: langeZahl;
    ziffern2: word;
    ende: boolean;
begin
 summe:=0; z1:=lZ; z2:=summand; ende:=false;

 repeat
   if z2=nil then ziffern2:=0 else ziffern2:=z2^.z;
   summe:=summe+z1^.z+ziffern2;
   z1^.z:=summe mod 1000;
   summe:=summe div 1000;
   if z1^.w=nil then ende:=true;
   if z2<>nil then z2:=z2^.w;
   if not ende then z1:=z1^.w;
 until ende or ((summe=0) and (z2=nil));

 if (summe<>0) or (z2<>nil) then
    repeat
       new(neu);
       z1^.w:=neu;
       z1:=neu;
       if z2=nil then ziffern2:=0 else ziffern2:=z2^.z;
       summe:=summe+ziffern2;
       z1^.z:=summe mod 1000;
       z1^.w:=nil;
       summe:=summe div 1000;
       if z2<>nil then z2:=z2^.w;
    until (summe=0) and (z2=nil);

end;

procedure kopiere(von: langeZahl; var nach: langeZahl);
var z1,z2,neu: langeZahl;
begin
 z1:=von;
 z2:=nil;
 repeat
   new(neu);
   if z2<>nil then z2^.w:=neu else nach:=neu;
   neu^.z:=z1^.z;
   neu^.w:=nil;
   z1:=z1^.w;
   z2:=neu;
 until z1=nil
end;

procedure loesche(lZ: langeZahl);
var z: langeZahl;
begin
 repeat
   z:=lZ^.w;
   dispose(lZ);
   lZ:=z;
 until lZ=nil;
end;

procedure ausgabe(lZ: langeZahl);
var z1,z2: langeZahl;
    z: string;
    laenge, i: integer;
begin
 z1:=lZ; laenge:=0;
 while z1<>nil do begin inc(laenge); z1:=z1^.w; end;

 z2:=nil; i:=0;
 repeat
  z1:=lZ;
  while z1^.w<>z2 do z1:=z1^.w;
  if (i<=33) or (laenge-i<=33) then begin
     str(z1^.z+1000,z); z:=copy(z,2,3);
     write(z); end;
  if (i=34) and (laenge-i>33) then write(' ..(',3*(laenge-66),' Stellen).. ');
  inc(i);
  z2:=z1;
 until z1=lZ;
end;

function Anzahl_Buchstaben(ab: longint): integer;
var i: integer;
begin
 for i:=anzahl_zeichen downto 0 do if pos_mit_n_zeichen[i]>=ab then break;
 Anzahl_Buchstaben:=i;
end;

procedure init;
var feld: array[buchstaben] of byte;
    c: char;
    anzahl: integer;
    i: longint;
    l: longint;
begin
 for i:=0 to anzahl_zeichen do pos_mit_n_zeichen[i]:=-1;
 if datei_string then l:=filesize(datei) else l:=strlen(pfad);
 pos_mit_n_zeichen[0]:=l; anzahl:=0;
 for c:=chr(0) to chr(255) do if c in zeichen then feld[c]:=0;

 for i:=l downto 1 do
     if datei_string then begin
        seek(datei, i-1);
        read(datei, c);
        if feld[c]=0 then begin feld[c]:=1; inc(anzahl);
           pos_mit_n_zeichen[anzahl]:=i-1; end;
     end else
        if feld[pfad[i-1]]=0 then begin feld[pfad[i-1]]:=1; inc(anzahl);
        pos_mit_n_zeichen[anzahl]:=i-1; end;

end;

function position_Buchstabe(nr: integer; ab: longint): longint;
var feld: array[buchstaben] of byte;
    c: char;
    i: longint;
    l: longint;
begin
 for c:=chr(0) to chr(255) do if c in zeichen then feld[c]:=0;
 i:=ab; l:=0;
 if datei_string then seek(datei, i);
 repeat
   i:=i+1;
   if datei_string then begin
      {seek(datei, i-1);}
      read(datei, c);
      if feld[c]=0 then begin feld[c]:=1; l:=l+1; end;
   end else
       if i>65534 then begin
         if feld[pfad2[i-65534-1]]=0 then begin feld[pfad[i-65534-1]]:=1; l:=l+1; end;
       end else begin
         if feld[pfad[i-1]]=0 then begin feld[pfad[i-1]]:=1; l:=l+1; end;
       end;
 until l=nr;
 position_Buchstabe:=i;
end;

type z = ^element;
     element = record
               a: longint;
               haeufigkeit: langeZahl;
               naechster: z;
               end;
var s: langeZahl;
    liste, zneu, zeiger, listeneu, suche1, suche2: z;
    j, i, n: word;
    groesse: longint;
    a: longint;
    datnam: string;

begin
if datei_string then begin
   write('Dateiname: '); readln(datnam);
   assign(datei, datnam); reset(datei);
end;

datnam:='C:\TURBO\PROGRAMME\BWINF062\KAFKA.TXT';
assign(datei, datnam); reset(datei);
groesse:=filesize(datei);
close(datei);
assign(datei_, datnam); reset(datei_,1);
if groesse<=65534 then n:=groesse else n:=65534;
getmem(pfad, n+1);
blockread(datei_, pfad^, n);
pfad[n]:=#0;
if groesse>65534 then begin
 n:=groesse-65534;
 getmem(pfad2, n+1);
 blockread(datei_, pfad2^, n);
 pfad2[n]:=#0;
end;
close(datei_);

{if not datei_string then begin
getmem(pfad, length(pfad_)+1);
strPcopy(pfad, pfad_);
end;}

init;

initLZ(s, 1);                         {Pfad ohne šbungen}
new(zneu); zneu^.a:=0;                {letzte šbung an Position 0}
initLZ(zneu^.haeufigkeit, 1);         {H„ufigkeit: 1}
zneu^.naechster:=nil; liste:=zneu;

repeat
 listeneu:=nil;                       {neue Liste}
 zeiger:=liste;                       {erstes Element}
 while zeiger<>nil do begin
  n:=Anzahl_Buchstaben(zeiger^.a);    {Wie viele m”gliche šbungen?}
  if n>0 then begin
     for j:=1 to n do addiere(s, zeiger^.haeufigkeit); {s:= s + n * H„ufigkeit}
     for i:=1 to n do begin
         a:=position_Buchstabe(i, zeiger^.a); {erste Postion d. n„chsten š.}

         suche1:=listeneu;
         while (suche1<>nil) and (suche1^.a<a) do begin
               suche2:=suche1;
               suche1:=suche1^.naechster;
         end;
         if (suche1=nil) or (suche1^.a>a) then begin
            new(zneu);
            zneu^.a:=a;
            kopiere(zeiger^.haeufigkeit, zneu^.haeufigkeit);
            zneu^.naechster:=suche1;
            if listeneu=nil then listeneu:=zneu else suche2^.naechster:=zneu;
         end else begin
            addiere(suche1^.haeufigkeit,zeiger^.haeufigkeit);
         end;
     end;
  end;
  zeiger:=zeiger^.naechster;
 end;

 {l”schen}
 zeiger:=liste;
 while zeiger<>nil do begin
  liste:=zeiger; zeiger:=zeiger^.naechster; loesche(liste^.haeufigkeit); dispose(liste);
 end;
 liste:=listeneu;
until liste=nil;
{writeln(pfad);}
ausgabe(s); readln;

freemem(pfad, length(pfad_)+1);
end.