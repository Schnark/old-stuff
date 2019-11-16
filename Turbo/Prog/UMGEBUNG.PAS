program umgebung;
uses crt,strings;
const param=$80;
      umgeb1=$2C;
      umgeb2=$2D;
var laenge:byte;
    umgeb_seg,i:word;
    parameter:string;
begin
 clrscr;
 laenge:=mem[PrefixSeg:param];
 if laenge=0 then writeln(' (keine Parameter)')
             else begin
              parameter:='';
              for i:=1 to laenge do
               parameter:=parameter+char(mem[PrefixSeg:param+i]);
               writeln(parameter);
             end;
 writeln;

 umgeb_seg:=mem[PrefixSeg:umgeb1]+mem[PrefixSeg:umgeb2]*256;
 i:=0;
 repeat
  while mem[umgeb_seg:i]<>0 do begin
   write(char(mem[umgeb_seg:i])); inc(i);
  end;
  writeln; inc(i);
 until mem[umgeb_seg:i]=0;
 readln;
end.