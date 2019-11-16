unit graphneu;
interface
const karten: array[0..3] of string=('?','EGA','MCGA','VGA');
const VGA320x200=$13;
      VGA320x400=$14;
      VGA360x480=$15;

function karte:byte;                                {Stellt Grafikkarte fest}

procedure modustext;                                              {Textmodus}


procedure modus320x200;                 {Modus 320 * 200 Pixel in 256 Farben}
procedure modus320x400;                 {Modus 320 * 400 Pixel in 256 Farben}
procedure modus360x480;                 {Modus 360 * 480 Pixel in 256 Farben}

procedure setP320x200(x,y: integer; farbe: byte);              {Pixel setzen}
function  getP320x200(x,y: integer): byte;                      {Pixel lesen}
procedure setP320x400(x,y: integer; farbe: byte);
function  getP320x400(x,y: integer): byte;
procedure setP360x480(x,y: integer; farbe: byte);
function  getP360x480(x,y: integer): byte;

procedure activ320x400(seite:byte);                  {aktive BS-Seite setzen}
procedure visual320x400(seite:byte);              {sichtbare BS-Seite setzen}

procedure initgraph(modus:byte);
function getgraphmode: byte;
procedure closegraph;
function getmaxcolor:word;
function getmaxx:integer;
function getmaxy:integer;
procedure putpixel(x,y: integer; farbe: word);
function getpixel(x,y:integer): word;
procedure setactivepage(seite: word);
procedure setvisualpage(seite: word);

implementation
uses dos;

var reg: registers;
    altermodus: byte;
    benutzt: boolean;
    aktmodus: byte;
    ramseg:word;

function karte:byte;
var wert:byte;
begin
 reg.ah:=$1A; reg.al:=$0;
 intr($10,reg);
 if reg.al=$1A then begin
    wert:=0;
    case reg.bl of
    $4,$5: wert:=1;
    $7,$8: wert:=3;
    $A,$B,$C: wert:=2;
    end;
 end
 else begin
    reg.bl:=$10; reg.ah:=$12;
    intr($10,reg);
    if reg.bl=$10 then wert:= 0 else wert:=1;
 end;
 karte:=wert;
end;

procedure modus320x200;
begin
 if not benutzt then begin
  reg.ah:=$F;
  intr($10,reg);
  altermodus:=reg.al;
  benutzt:=true;
 end;
 reg.ah:=0; reg.al:=$13;
 intr($10,reg);
end;

procedure modus320x400;
var lese:byte;
    i:word;
begin
 modus320x200;
       port[$3C4]:=4;
 lese:=port[$3C5];
       port[$3C5]:=(lese and (255-8)) or 4;
       port[$3CE]:=5;
 lese:=port[$3CF];
       port[$3CF]:=lese and (255-$10);
       port[$3CE]:=6;
 lese:=port[$3CF];
       port[$3CF]:=lese and (255-2);
       port[$3C4]:=2;
       port[$3C5]:=$F;
 for i:= 0 to $FFFF do mem[sega000:i]:=0;
       port[$3D4]:=9;
 lese:=port[$3D5];
       port[$3D5]:=lese and (255-$1F);
       port[$3D4]:=$14;
 lese:=port[$3D5];
       port[$3D5]:=lese and (255-$40);
       port[$3D4]:=$17;
 lese:=port[$3D5];
       port[$3D5]:=lese or $40;
 activ320x400(0);
 visual320x400(0);
end;

procedure modus360x480;
const CRTC: array[0..$17] of byte =
      ($6B,$59,$5A,$8E,$5E,$8A,$0D,$3E,$FF,$40,$FF,$FF,
       $FF,$FF,$FF,$FF,$EA,$AC,$DF,$2D,$00,$E7,$06,$E3);
var lese,i: byte;
begin
 if not benutzt then begin
  reg.ah:=$F;
  intr($10,reg);
  altermodus:=reg.al;
  benutzt:=true;
 end;
 reg.ah:=0; reg.al:=$12;
 intr($10,reg);
 reg.ah:=0; reg.al:=$13;
 intr($10,reg);
       port[$3C4]:=4;
       port[$3C5]:=6;
       port[$3C4]:=0;
       port[$3C5]:=1;
       port[$3C2]:=$E7;
       port[$3C4]:=0;
       port[$3C5]:=3;
       port[$3D4]:=$11;
 lese:=port[$3D5];
       port[$3D5]:=lese and $7F;
 for i:=0 to $17 do if CRTC[i]<>$FF then begin
       port[$3D4]:=i;
       port[$3D5]:=CRTC[i];
       end;
end;

procedure modustext;
begin
 if not benutzt then exit;
 reg.ah:=0; reg.al:=altermodus;
 intr($10,reg);
end;

procedure setP320x200;
var offset: word;
begin
 if x<0 then exit; if x>319 then exit; if y<0 then exit; if y>199 then exit;
 offset:=320*word(y)+word(x);
 mem[sega000:offset]:=farbe;
end;

function getP320x200;
var offset: word;
begin
 if x<0 then exit; if x>319 then exit; if y<0 then exit; if y>199 then exit;
 offset:=320*y+x;
 getP320x200:=mem[sega000:offset];
end;

procedure setP320x400;
var offset: word;
    plane: byte;
begin
 if x<0 then exit; if x>319 then exit; if y<0 then exit; if y>399 then exit;
 offset:=word(y)*80+(word(x) div 4);
 plane:= 1 shl (word(x) mod 4);
 port[$3C4]:=2;
 port[$3C5]:=plane;
 mem[ramseg:offset]:=farbe;
end;

function getP320x400;
var offset: word;
    plane: byte;
begin
 if x<0 then exit; if x>319 then exit; if y<0 then exit; if y>399 then exit;
 offset:=word(y)*80+(word(x) div 4);
 plane:= 1 shl (word(x) mod 4);
 port[$3C4]:=2;
 port[$3C5]:=plane;
 getP320x400:=mem[ramseg:offset];
end;

procedure setP360x480;
var offset: word;
    plane: byte;
begin
 if x<0 then exit; if x>359 then exit; if y<0 then exit; if y>479 then exit;
 offset:=word(y)*90+(word(x) div 4);
 plane:= 1 shl (word(x) mod 4);
 port[$3C4]:=2;
 port[$3C5]:=plane;
 mem[segA000:offset]:=farbe;
end;

function getP360x480;
var offset: word;
    plane: byte;
begin
 if x<0 then exit; if x>359 then exit; if y<0 then exit; if y>479 then exit;
 offset:=word(y)*90+(word(x) div 4);
 plane:= 1 shl (word(x) mod 4);
 port[$3C4]:=2;
 port[$3C5]:=plane;
 getP360x480:=mem[segA000:offset];
end;

procedure activ320x400;
begin
 if seite=0 then ramseg:=sega000 else ramseg:=sega000+$800;
end;

procedure visual320x400;
begin
 port[$3D4]:=$C;
 if seite=0 then port[$3D5]:=0 else port[$3D5]:=$80;
end;


procedure initgraph(modus:byte);
begin
 case modus of
 VGA320x200: modus320x200;
 VGA320x400: modus320x400;
 VGA360x480: modus360x480;
 end;
 aktmodus:=modus;
end;

function getgraphmode: byte;
begin
 getgraphmode:=aktmodus;
end;

procedure closegraph;
begin
 modustext;
 aktmodus:=0;
end;

function getmaxcolor;
begin
 getmaxcolor:=256;
end;

function getmaxx;
begin
 if aktmodus=VGA360x480 then getmaxx:=360 else getmaxx:=320;
end;

function getmaxy;
begin
 case aktmodus of
 VGA320x200: getmaxy:=200;
 VGA320x400: getmaxy:=400;
 VGA360x480: getmaxy:=480;
 end;
end;

procedure putpixel(x,y: integer; farbe: word);
begin
 case aktmodus of
 VGA320x200: setP320x200(x,y,farbe);
 VGA320x400: setP320x400(x,y,farbe);
 VGA360x480: setP360x480(x,y,farbe);
 end;
end;

function getpixel(x,y:integer): word;
begin
 case aktmodus of
 VGA320x200: getpixel:=getP320x200(x,y);
 VGA320x400: getpixel:=getP320x400(x,y);
 VGA360x480: getpixel:=getP360x480(x,y);
 end;
end;

procedure setactivepage(seite: word);
begin
 if aktmodus <> VGA320x400 then exit;
 if seite>1 then exit;
 activ320x400(seite);
end;

procedure setvisualpage(seite: word);
begin
 if aktmodus <> VGA320x400 then exit;
 if seite>1 then exit;
 visual320x400(seite);
end;



begin
benutzt:=false;
aktmodus:=0;
end.