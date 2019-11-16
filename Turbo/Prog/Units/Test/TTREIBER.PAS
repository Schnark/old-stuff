program tastaturtreiber;
uses crt;

const VK_F1 = 1;
      VK_F2 = 2;
      VK_F3 = 3;
      VK_F4 = 4;
      VK_F5 = 5;
      VK_F6 = 6;
      VK_F7 = 7;
      VK_F8 = 8;
      VK_F9 = 9;
      VK_F10 = 10;
      VK_F11 = 11;
      VK_F12 = 12;
      VK_Druck = 13;
      VK_Rollen = 14;
      VK_Pause = 15;
      VK_BS = 16;
      VK_TAB = 17;
      VK_ENTER = 18;
      VK_CAPS = 19;
      VK_Shift_l = 20;
      VK_Shift_r = 21;
      VK_Strg = 22;
      VK_Alt = 23;
      VK_Einfg = 24;
      VK_Entf = 25;
      VK_Pos1 = 26;
      VK_Ende = 27;
      VK_Bild_up = 28;
      VK_Bild_down = 29;
      VK_left = 30;
      VK_up = 31;
      VK_down = 32;
      VK_right = 33;
      VK_NUM = 34;
      VK_MinusNum = 35;
      VK_PlusNum = 36;
      VK_MitteNum = 37;
      VK_SysReq = 38;
type tastentyp = (leer, normal, special, akzent, num);
type taste = record
             case art: tastentyp of
                  leer:();
                  normal: (klein, gross: char);
               {z. B.: Taste <a>: 'a', 'A'; <2>: '2', '"'}
                  special: (nr: byte);
               {z. B.: F1}
                  akzent: (von_k, zu_k, von_g, zu_g: string[15]);
               {z. B.: Taste <^>: ' aeiouAEIOU', '^Éàåìñ∂“◊‚Í'
                    => 'e' -> 'à'; ' ' -> '^'; 'w' -> '^w'}
                  num: (c: char; num_nr: byte);
             end;
type tastatur = array[1..127] of taste;
var alttaste: taste; {zum Speichern von Akzenten}

var deutsch: tastatur;
procedure setze_deutsch;
var i: byte;
begin
 for i:=1 to 127 do
  with deutsch[i] do begin
   art:=normal;
   case i of
   1: begin art:=special; nr:=i; {ESC} end;
   2: begin klein:='1'; gross:='!'; end;
   3: begin klein:='2'; gross:='"'; end;
   4: begin klein:='3'; gross:='ı'; end;
   5: begin klein:='4'; gross:='$'; end;
   6: begin klein:='5'; gross:='%'; end;
   7: begin klein:='6'; gross:='&'; end;
   8: begin klein:='7'; gross:='/'; end;
   9: begin klein:='8'; gross:='('; end;
  10: begin klein:='9'; gross:=')'; end;
  11: begin klein:='0'; gross:='='; end;
  12: begin klein:='·'; gross:='?'; end;
  13: begin art:=akzent; von_k:=' aeiouAEIOU'; zu_k:='Ô†Ç°¢£µê÷‡È';
                         von_g:=' aeiouAEIOU'; zu_g:='`Öäçïó∑‘ﬁ„Î'; end;
  14: begin art:=special; nr:=VK_BS; {BS} end;
  15: begin art:=special; nr:=VK_TAB; {TAB} end;
  16: begin klein:='q'; gross:='Q'; end;
  17: begin klein:='w'; gross:='W'; end;
  18: begin klein:='e'; gross:='E'; end;
  19: begin klein:='r'; gross:='R'; end;
  20: begin klein:='t'; gross:='T'; end;
  21: begin klein:='z'; gross:='Z'; end;
  22: begin klein:='u'; gross:='U'; end;
  23: begin klein:='i'; gross:='I'; end;
  24: begin klein:='o'; gross:='O'; end;
  25: begin klein:='p'; gross:='P'; end;
  26: begin klein:='Å'; gross:='ö'; end;
  27: begin klein:='+'; gross:='*'; end;
  28: begin art:=special; nr:=VK_ENTER; {ENTER} end;
  29: begin art:=special; nr:=VK_Strg; {Strg} end;
  30: begin klein:='a'; gross:='A'; end;
  31: begin klein:='s'; gross:='S'; end;
  32: begin klein:='d'; gross:='D'; end;
  33: begin klein:='f'; gross:='F'; end;
  34: begin klein:='g'; gross:='G'; end;
  35: begin klein:='h'; gross:='H'; end;
  36: begin klein:='j'; gross:='J'; end;
  37: begin klein:='k'; gross:='K'; end;
  38: begin klein:='l'; gross:='L'; end;
  39: begin klein:='î'; gross:='ô'; end;
  40: begin klein:='Ñ'; gross:='é'; end;
  41: begin art:=akzent; von_k:=' aeiouAEIOU'; zu_k:='^Éàåìñ∂“◊‚Í';
            von_g:='¯'; zu_g:=''; end;
  42: begin art:=special; nr:=VK_Shift_l; {Shift links / Cursor bei Num} end;
  43: begin klein:='#'; gross:=''''; end;
  44: begin klein:='y'; gross:='Y'; end;
  45: begin klein:='x'; gross:='X'; end;
  46: begin klein:='c'; gross:='C'; end;
  47: begin klein:='v'; gross:='V'; end;
  48: begin klein:='b'; gross:='B'; end;
  49: begin klein:='n'; gross:='N'; end;
  50: begin klein:='m'; gross:='M'; end;
  51: begin klein:=','; gross:=';'; end;
  52: begin klein:='.'; gross:=':'; end;
  53: begin klein:='-'; gross:='_'; end;
  54: begin art:=special; nr:=VK_Shift_r; {Shift rechts} end;
  55: begin art:=num; c:='*'; num_nr:=VK_Druck; {auch Druck ?} end;
  56: begin art:=special; nr:=VK_Alt; {ALT / ALT GR} end;
  57: begin klein:=' '; gross:=' '; end;
  58: begin art:=special; nr:=VK_CAPS; {CAPS} end;
  59: begin art:=special; nr:=VK_F1; {F1} end;
  60: begin art:=special; nr:=VK_F2; {F2} end;
  61: begin art:=special; nr:=VK_F3; {F3} end;
  62: begin art:=special; nr:=VK_F4; {F4} end;
  63: begin art:=special; nr:=VK_F5; {F5} end;
  64: begin art:=special; nr:=VK_F6; {F6} end;
  65: begin art:=special; nr:=VK_F7; {F7} end;
  66: begin art:=special; nr:=VK_F8; {F8} end;
  67: begin art:=special; nr:=VK_F9; {F9} end;
  68: begin art:=special; nr:=VK_F10; {F10} end;
  69: begin art:=special; nr:=VK_Num; {NUM-Lock} end;
  70: begin art:=special; nr:=VK_Rollen; {Rollen} end;
  71: begin art:=num; c:='7'; num_nr:=VK_Pos1; {Pos 1} end;
  72: begin art:=num; c:='8'; num_nr:=VK_Up; {^} end;
  73: begin art:=num; c:='9'; num_nr:=VK_Bild_up; {Bild ^} end;
  74: begin art:=num; c:='-'; num_nr:=VK_MinusNum; end;
  75: begin art:=num; c:='4'; num_nr:=VK_Left; {<} end;
  76: begin art:=num; c:='5'; num_nr:=VK_MitteNum; end;
  77: begin art:=num; c:='6'; num_nr:=VK_Right; {>} end;
  78: begin art:=num; c:='+'; num_nr:=VK_PlusNum; end;
  79: begin art:=num; c:='1'; num_nr:=VK_Ende; {Ende} end;
  80: begin art:=num; c:='2'; num_nr:=VK_Down; {v} end;
  81: begin art:=num; c:='3'; num_nr:=VK_Bild_down; {Bild v} end;
  82: begin art:=num; c:='0'; num_nr:=VK_Einfg; {Einfg} end;
  83: begin art:=num; c:=','; num_nr:=VK_Entf; {Entf} end;
  84: begin art:=special; nr:=VK_SysReq; {SysReq ?} end;
  85: begin art:=leer; end;
  86: begin klein:='<'; gross:='>'; end;
  87: begin art:=special; nr:=VK_F11; {F11} end;
  88: begin art:=special; nr:=VK_F12; {F12} end;
  89..127: begin art:=leer; end;
   end;
  end;
 alttaste.art:=leer;
end;

procedure loesche_eingabe;
begin
 if keypressed then repeat until readkey <> #0;
end;

function sondertaste(id: byte): string;
begin
case id of
      VK_F1: sondertaste:='F1';
      VK_F2: sondertaste:='F2';
      VK_F3: sondertaste:='F3';
      VK_F4: sondertaste:='F4';
      VK_F5: sondertaste:='F5';
      VK_F6: sondertaste:='F6';
      VK_F7: sondertaste:='F7';
      VK_F8: sondertaste:='F8';
      VK_F9: sondertaste:='F9';
      VK_F10: sondertaste:='F10';
      VK_F11: sondertaste:='F11';
      VK_F12: sondertaste:='F12';
      VK_Druck: sondertaste:='Druck';
      VK_Rollen: sondertaste:='Rollen';
      VK_Pause: sondertaste:='Pause';
      VK_BS: sondertaste:='Backspace';
      VK_TAB: sondertaste:='TAB';
      VK_ENTER: sondertaste:='Enter';
      VK_CAPS: sondertaste:='CAPS';
      VK_Shift_l: sondertaste:='Shift l';
      VK_Shift_r: sondertaste:='Shift r';
      VK_Strg: sondertaste:='Strg';
      VK_Alt: sondertaste:='Alt';
      VK_Einfg: sondertaste:='Einfg';
      VK_Entf: sondertaste:='Entf';
      VK_Pos1: sondertaste:='Pos1';
      VK_Ende: sondertaste:='Ende';
      VK_Bild_up: sondertaste:='Bild ^';
      VK_Bild_down: sondertaste:='Bild v';
      VK_left: sondertaste:='<';
      VK_up: sondertaste:='^';
      VK_down: sondertaste:='v';
      VK_right: sondertaste:='>';
      VK_NUM: sondertaste:='NUM';
      VK_MinusNum: sondertaste:='- (Num)';
      VK_PlusNum: sondertaste:='+ (Num)';
      VK_MitteNum: sondertaste:='Mitte';
      VK_SysReq: sondertaste:='SysReq';
  end;
end;

function getshift: byte;
begin
 getshift:=mem[$0040:$0017];
{0: rechte Shift
 1: linke Shift
 2: Strg
 3: Alt
 4: Rollen
 5: Num-Lock
 6: CAPS
 7: Einfg}
end;

function gross(shift: byte): boolean; {eine Shift-Taste gedrÅckt oder CAPS}
begin
 gross:=(shift and (1+2+64))<>0;
end;

function StrgAlt(shift: byte): byte;
begin
 StrgAlt:=shift and (4+8);
end;

function klein(shift: byte): boolean; {weder Shift, Strg, Alt, noch CAPS}
begin
 klein:=(shift and (1+2+4+8+64))=0;
end;


procedure anzeige(nr, shift: byte);
var c: string[2];
    p: byte;
begin
 case deutsch[nr].art of
      normal: begin
               if StrgAlt(shift)<>0 then alttaste.art:=leer;
               if gross(shift) then c:=deutsch[nr].gross else c:=deutsch[nr].klein;
               if alttaste.art<>leer then begin
                  p:=pos(c, alttaste.von_k);
                  if p<>0 then c:=alttaste.zu_k[p] else c:=alttaste.zu_k[1]+c;
                  alttaste.art:=leer;
               end;
               write(StrgAlt(shift),' ',c,'  ');
              end;
      special: begin
                write(StrgAlt(shift),sondertaste(deutsch[nr].nr),'  ');
               end;
      akzent: begin
               alttaste:=deutsch[nr];
               if gross(shift) then begin
                  alttaste.von_k:=alttaste.von_g;
                  alttaste.zu_k:=alttaste.zu_g;
               end;
               if alttaste.zu_k='' then begin
                  write(StrgAlt(shift),' ',alttaste.von_k,'  ');
                  alttaste.art:=leer;
               end;
              end;
      num: begin
            if shift and 32 = 0 then
                write(StrgAlt(shift),sondertaste(deutsch[nr].nr),'  ')
            else
               write(StrgAlt(shift),' ',deutsch[nr].c,'  ');
           end;
 end;
end;

var nr, alt: byte;
begin
 setze_deutsch;
 alt:=127;
 repeat
  nr:=port[$60];
  if nr<>alt then begin
     alt:=nr;
     if (nr >= 128) and (nr <> 128+122) then begin
                        {Sonder gedrÅckt}
                        write('^: '); anzeige(nr mod 128, getshift);
     end else
         if nr <> 128+122 then
               begin write('v: '); anzeige(nr mod 128, getshift); end
         else write('v: Sonder');
     loesche_eingabe;
  end;
 until nr=129;
end.