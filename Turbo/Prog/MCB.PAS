program mcb_anzeigen;
uses crt,dos;
type pointer=record segment,offset:word; end;
     vier=string[4];
var reg:registers;
    taste,mcb_code:char;
    dib_adresse,mcb:pointer;
    mcb_nr,groesse:word;

function hex(wert:word):vier;
const ziffern: array[0..15] of char =
      ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
var h: vier;
    i: byte;
    teiler:word;
begin
 h:='0000';
 for i:=3 downto 0 do begin
     teiler:=wert shr (i shl 2);
     wert:=wert-(teiler shl (i shl 2));
     h[4-i]:=ziffern[teiler];
 end;
 hex:=h;
end;

begin
 clrscr;
 reg.ah:=$52; msdos(reg);
 dib_adresse.segment:=reg.es-1;
 dib_adresse.offset:=reg.bx+12;
 mcb.offset:=mem[dib_adresse.segment:dib_adresse.offset]+
         256*mem[dib_adresse.segment:dib_adresse.offset+1];
 mcb.segment:=mem[dib_adresse.segment:dib_adresse.offset+2]+
          256*mem[dib_adresse.segment:dib_adresse.offset+3];
 mcb_nr:=1;

 writeln('              Speicherbl”cke');
 writeln;
 writeln('Nummer Code   Adresse    Gr”áe (in Paragraphen / Byte)    PSP');
 repeat
  write(mcb_nr:4);
  mcb_code:=char(mem[mcb.segment:mcb.offset]);
  write(mcb_code:6);
  write(hex(mcb.segment+1):7,':',hex(mcb.offset));
  groesse:=word(mem[mcb.segment:mcb.offset+3])+
       256*word(mem[mcb.segment:mcb.offset+4]);
  write(groesse:21); write((longint(groesse) shl 4):10);
  writeln(hex(mem[mcb.segment:mcb.offset+2]):7,':',hex(mem[mcb.segment:mcb.offset+1]));
  mcb.segment:=mcb.segment+groesse+1;
  mcb_nr:=mcb_nr+1;
 until mcb_code<>'M';
 readln;
end.
