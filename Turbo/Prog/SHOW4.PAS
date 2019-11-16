program show;
{Programm zum Darstellen von BMP's mit max. 256 Farben}
uses crt, graphneu, dac;

CONST Headerlaenge=54;          {L„nge Header}
      MaxFarben=256;


type Header=RECORD
         TypB, TypM: char; {In BMP's muss hier BM stehen}
         Size1:longint;    {ohne Vorzeichen!}
         Res1:word;
         Res2:word;
         OffBits:longint;  {ohne Vorzeichen!,
                      bei Adr. hier f„ngt das Bild an (normal: 1078) Off: 10}
         Size2:longint;    {ohne Vorzeichen!}
         Breite,Breite2:word;      {Breite des Bildes in Pixel  jeweils}
         Hoehe,Hoehe2:word;        {H”he des Bildes in Pixel   aufgeteilt}
         Planes:word;
         BiBitCount:word;                    {Farbtiefe 8 bit=256}
	 Compression:longint;                {ohne Vorzeichen!}
         SizeImage:longint;                  {ohne Vorzeichen! Off: 34}
         XPelsPerMtr:longint;                {ohne Vorzeichen!}
         YPelsPerMtr:longint;                {ohne Vorzeichen!}
         ColorsUsed:longint;                 {ohne Vorzeichen!}
         CImportant:longint;                 {ohne Vorzeichen!}
end;
type Palette= array[0..MaxFarben-1] of record
                                 b,g,r,dummy: byte;  {Farbpalette}
                                 end;


var Head:Header;
    Pal:Palette;
    dateiname:string;
    datei:file;

    Farben: word;
    PalLen: word;	        {L„nge Palette}

    bild: array[0..$FFFE-3539] of byte;
    nr,x,y,korrektur: integer;
    position:longint;
    dacreg: dac_reg;
    i:byte;

begin
 write('Datei: ');
 readln(dateiname);{ dateiname:='c:\dos\prog\asm\bmp\ship.bmp';}
 assign(datei,dateiname);
 reset(datei,1);
 blockread(datei,head,Headerlaenge); {Header einlesen}

 if (Head.TypM<>'M') or (Head.TypB<>'B') then
    begin write('Fehler'); exit; end;        {kein Bitmap}
 farben:=round(exp(ln(2)*Head.BiBitCount));
 if farben>MaxFarben then
    begin write('Fehler'); exit; end;
 PalLen:=farben*4;
 blockread(datei,pal,PalLen);                {Palette einlesen}
 blockread(datei,bild,Head.SizeImage);       {Bild einlesen}
 close(datei);

 initgraph(VGA320x200);
 for nr:=0 to farben-1 do begin
      with dacreg do begin
      R:=Pal[nr].r div 4;
      G:=Pal[nr].g div 4;
      B:=Pal[nr].b div 4;
      end;
      setdacreg(nr,dacreg);
      end;

 if Head.Breite mod 4 <> 0 then      {Breite nicht durch 4 teilbar?}
    korrektur:=4-(Head.Breite mod 4);          {4 minus Rest=Nullbyte(s)}

(* for i:=0 to 1 do begin
  activ320x400(i);*)
  position:=0;
  for y:= Head.Hoehe-1 downto 0 do begin
      for x:= 0 to Head.Breite-1 do begin
          putpixel(x+10*i,y+10*i,bild[position]);
          inc(position);
          end;
      position:=position+korrektur;
  end;
(* end;
 for i:=0 to 255 do begin
  visual320x400(i mod 2);
  delay(20);
 end;*)
 repeat until keypressed;
 closegraph;
 readln;
end.
