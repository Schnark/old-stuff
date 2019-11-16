program diskinfo;
uses dos,crt;
type Pdpb=^Tdpb;
     Tdpb=record
          lnr,pnr:byte;
          byte_sek:word;
          interleave,sek_cluster:byte;
          res_sek:word;
          fat_anz:byte;
          root_anz,sek1,letzt_cluster:word;
          sek_fat:word;
          dsek1:word;
          treiber:pointer;
          medium,benutzt:byte;
          naechster:Pdpb;
          end;
type vier=string[4];

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

var reg:registers;
    dib:^pointer;
    dpb:Pdpb;
    dpb_nr:byte;
    ende:boolean;


begin
 reg.ah:=$52; msdos(reg);
 dib:=ptr(reg.es,reg.bx);
 dpb:=dib^;
 ende:=false;
 repeat
  clrscr;
  with dpb^ do begin
   writeln('Logisches Laufwerk:                     ',char(65+lnr));
   writeln('Physikalisches Laufwerk:                ',char(65+pnr));
   writeln('Bytes / Sektor:                         ',byte_sek);
   writeln('Interleave-Faktor:                      ',interleave);
   writeln('Sektoren / Cluster:                     ',sek_cluster);
   writeln('Anzahl d. reservierten Sektoren:        ',res_sek);
   writeln('Anzahl d. FATs:                         ',fat_anz);
   writeln('Anzahl d. Eintr„ge im Stammverzeichnis: ',root_anz);
   writeln('1. belegter Sektor:                     ',sek1);
   writeln('1. Datensektor:                         ',dsek1);
   writeln('Letzter belegter Cluster:               ',letzt_cluster);
   writeln('Sektoren / FAT:                         ',sek_fat);
   writeln('Adresse d. Ger„tetreibers:              ',
            hex(seg(treiber^)),':',hex(ofs(treiber^)));
   if ofs(naechster^)=$FFFF then ende:=true;
   dpb:=naechster;
   readln;
  end;
 until ende;
end.