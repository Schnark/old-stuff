uses key_evnt, crt;

function sonder(nr: byte): string;
begin
case nr of
 T_ESC:sonder:='ESC'; T_1:sonder:='1'; T_2:sonder:='2'; T_3:sonder:='3';
 T_4:sonder:='4'; T_5:sonder:='5'; T_6:sonder:='6'; T_7:sonder:='7'; T_8:sonder:='8';
 T_9:sonder:='9'; T_0:sonder:='0'; T_SS:sonder:='·'; T_APO:sonder:='Ô'; T_BS:sonder:='BS';
 T_TAB:sonder:='TAB'; T_q:sonder:='q'; T_w:sonder:='w'; T_e:sonder:='e'; T_r:sonder:='r';
 T_t:sonder:='t'; T_z:sonder:='z'; T_u:sonder:='u'; T_i:sonder:='i'; T_o:sonder:='o';
 T_p:sonder:='p'; T_ue:sonder:='Å'; T_PLUS:sonder:='+'; T_ENTER:sonder:='ENTER'; T_STRG:sonder:='STRG';
 T_a:sonder:='a'; T_s:sonder:='s'; T_d:sonder:='d'; T_f:sonder:='f'; T_g:sonder:='g';
 T_h:sonder:='h'; T_j:sonder:='j'; T_k:sonder:='k'; T_l:sonder:='l'; T_oe:sonder:='î';
 T_ae:sonder:='Ñ'; T_DACH:sonder:='^'; T_SHIFT_L:sonder:='SHIFT L'; T_RAUTE:sonder:='#'; T_y:sonder:='y';
 T_x:sonder:='x'; T_c:sonder:='c'; T_v:sonder:='v'; T_b:sonder:='b'; T_n:sonder:='n';
 T_m:sonder:='m'; T_KOMMA:sonder:=','; T_PUNKT:sonder:='.'; T_MINUS:sonder:='- /NUM'; T_SHIFT_R:sonder:='SHIFT R';
 T_MAL_NUM:sonder:='*NUM'; T_ALT:sonder:='ALT'; T_SP:sonder:='SP'; T_CAPS:sonder:='CAPS'; T_F1:sonder:='F1';
 T_F2:sonder:='F2'; T_F3:sonder:='F3'; T_F4:sonder:='F4'; T_F5:sonder:='F5'; T_F6:sonder:='F6';
 T_F7:sonder:='F7'; T_F8:sonder:='F8'; T_F9:sonder:='F9'; T_F10:sonder:='F10'; T_NUM:sonder:='NUM';
 T_ROLLEN:sonder:='ROLLEN'; T_POS1:sonder:='POS 1'; T_UP:sonder:='UP'; T_PUP:sonder:='BILD AUF'; T_MINUS_NUM:sonder:='-NUM';
 T_LEFT:sonder:='LEFT'; T_5NUM:sonder:='5NUM'; T_RIGHT:sonder:='RIGHT'; T_PLUS_NUM:sonder:='+NUM'; T_ENDE:sonder:='ENDE';
 T_DOWN:sonder:='DOWN'; T_PDOWN:sonder:='BILD AB'; T_EINF:sonder:='EINF'; T_ENTF:sonder:='ENTF';
 T_KLEINER:sonder:='<'; T_F11:sonder:='F11'; T_F12:sonder:='F12';
 T_PAUSE:sonder:='PAUSE'; T_SONDER:sonder:='SONDER';

 else sonder:='??';
end;
end;

var k: taste;
    ende: boolean;
begin
clrscr;
ende:=false;
repeat
 get_key(k);
 case k.art of
  NONE: ;
  C_NORM: begin writeln(chr(k.nr)); if k.nr=27 then ende:=true; end;
  C_SONDER: writeln(sonder(k.nr));
  K_DOWN: writeln('v ',sonder(k.nr));
  K_UP: writeln('^ ',sonder(k.nr));
 end;
until ende;
readln;
end.