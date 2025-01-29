program TrimmDichPfade;
{uses strings;}
const Pfad:string='RTBRSTBTRBTRRTSSSSSRRTTSTRTTSBBRTBRSBRRBBBSRBRBB'{}
{'RTRBRTBTTRRBTR'{}
{'RTRT'{};
const datei_string:boolean=true;
var datei: file of char;
{var langPfad1, langPfad2: pchar;}

type buchstaben=char;
const zeichen:set of char = ['A'..'Z',#196,#214,#220,#223];
const anzahl_zeichen=30;
var nummer_d_Buchstabens: array[char] of byte;
var pos_mit_n_zeichen: array[0..anzahl_zeichen] of longint;
const speicher=10;
var erste_stelle: array[1..anzahl_zeichen, 1..speicher] of longint;

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

procedure init;
var feld: array[buchstaben] of byte;
    c: char;
    anzahl,j: integer;
    i: longint;
    l: longint;
begin
 for i:=1 to anzahl_zeichen do for j:=1 to speicher do erste_stelle[i,j]:=0;
 for i:=0 to anzahl_zeichen do pos_mit_n_zeichen[i]:=-1;
 if datei_string then l:=filesize(datei) else l:=length(pfad);
 pos_mit_n_zeichen[0]:=l; anzahl:=0;
 for c:=chr(0) to chr(255) do
     if c in zeichen then begin
        nummer_d_Buchstabens[c]:=0; feld[c]:=0;
     end;

 for i:=l downto 1 do
     if datei_string then begin
        seek(datei, i-1);
        read(datei, c);
        if feld[c]=0 then begin feld[c]:=1; inc(anzahl);
           pos_mit_n_zeichen[anzahl]:=i-1; nummer_d_Buchstabens[c]:=anzahl; end;
     end else
        if feld[pfad[i]]=0 then begin feld[pfad[i]]:=1; inc(anzahl);
        pos_mit_n_zeichen[anzahl]:=i-1; nummer_d_Buchstabens[pfad[i]]:=anzahl; end;

end;

function Anzahl_Buchstaben(ab: longint): integer;
var i: integer;
begin
 for i:=anzahl_zeichen downto 0 do if pos_mit_n_zeichen[i]>=ab then break;
 Anzahl_Buchstaben:=i;
end;

function position_Buchstabe(nr: integer; ab: longint): longint;
var c: char;
    i: longint;
    j: integer;
begin
 for j:= 1 to speicher do begin
     if ab<erste_Stelle[nr,j] then begin
        position_Buchstabe:=erste_Stelle[nr,j];
        exit; end;
 end;
 i:=ab;
 if datei_string then seek(datei, i);
 repeat
   i:=i+1;
   if datei_string then begin
      {seek(datei, i-1);}
      read(datei, c);
   end else
       {if i<=65535 then c:=langpfad1[i-1] else c:=langpfad2[i-65536];}
       c:=pfad[i];

 until nummer_d_Buchstabens[c]=nr;
 for j:= 1 to speicher do
     if erste_Stelle[nr,j]=0 then begin erste_Stelle[nr, j]:=i; break; end;
 position_Buchstabe:=i;
end;

procedure loesche_pos_ab(ab: longint);
var i,j: integer;
begin
 for i:=1 to anzahl_zeichen do
     for j:=1 to speicher do
         if erste_Stelle[i,j]>=ab then erste_Stelle[i,j]:=0;
end;

type z = ^element;
     element = record
               a: longint;
               haeufigkeit: langeZahl;
               naechster: z;
               end;



procedure einfuegen_in_Liste(var listeneu: z; zeiger: z; a:longint);
var suche1, suche2, zneu: z;
begin
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
            if suche1=listeneu then listeneu:=zneu else suche2^.naechster:=zneu;
         end else begin
            addiere(suche1^.haeufigkeit,zeiger^.haeufigkeit);
         end;
end;




var s: langeZahl;
    liste, zneu, zeiger, listeneu: z;
    j, i, n: integer;
    a: longint;
    neu: boolean;
    datnam: string;
    {l: longint;
    datei_: file;}

begin
if datei_string then begin
   write('Dateiname: '); readln(datnam);
   assign(datei, datnam); reset(datei);
   {assign(datei_, datnam); reset(datei_, 1);
   l:=filesize(datei);}
end;
init;

{datei_string:=false;}

{if l>65534 then begin
   getmem(langpfad1, 65535);
   blockread(datei_, langpfad1^, 65534); langpfad1[65534]:=#0;
   getmem(langpfad2, l-65534+1);
   blockread(datei_, langpfad2^, l-65534); langpfad2[l-65534]:=#0;
end else begin
   getmem(langpfad1, l+1);
   blockread(datei_, langpfad1^, l); langpfad1[l]:=#0;
   langpfad2:=nil;
end;

close(datei_);}

initLZ(s, 1);                         {Pfad ohne šbungen}
new(zneu); zneu^.a:=0;                {letzte šbung an Position 0}
initLZ(zneu^.haeufigkeit, 1);         {H„ufigkeit: 1}
zneu^.naechster:=nil; liste:=zneu;

repeat
 listeneu:=nil; neu:=true;            {neue Liste}
 zeiger:=liste;                       {erstes Element}
 while zeiger<>nil do begin
  n:=Anzahl_Buchstaben(zeiger^.a);    {Wie viele m”gliche šbungen?}
  if neu then begin
     loesche_Pos_ab(zeiger^.a); neu:=false;
  end;
  if n>0 then begin
     for j:=1 to n do addiere(s, zeiger^.haeufigkeit); {s:= s + n * H„ufigkeit}
     for i:=1 to n do begin
         a:=position_Buchstabe(i, zeiger^.a); {erste Postion d. n„chsten š.}
         einfuegen_in_Liste(listeneu, zeiger, a);
     end;
  end;
  zeiger:=zeiger^.naechster;
 end;

 {l”schen}
 zeiger:=liste;
 while zeiger<>nil do begin
  liste:=zeiger; zeiger:=zeiger^.naechster;
  loesche(liste^.haeufigkeit); dispose(liste);
 end;
 liste:=listeneu;
until liste=nil;
ausgabe(s); readln;
{freemem(langpfad1, length(pfad)+1);}
end.