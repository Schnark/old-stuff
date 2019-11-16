program testkeyb;
uses keyb;
var t,s: byte;
    ausg: string;
begin
repeat
ausg:='';
tasten(t,s);
write(t:5,s:5,' ':3);
if t <> 0 then begin
if t>32 then ausg:=(chr(t));
case t of
  K_RUECK: ausg:='RÅcktaste'; {auch Shift} K_StrgRUECK: ausg:='Strg RÅck';
  K_ENTER: ausg:='Enter'; K_StrgENTER: ausg:='Strg ENTER';
  K_TAB: ausg:='TAB';

{  K_ShiftPOS1_ZT  : ausg:='Shift POS1 (ZT)' ;
  K_ShiftUP_ZT    : ausg:='Shift ^ (ZT)' ;
  K_ShiftPUP_ZT   : ausg:='Shift Bild ^ (ZT)' ;
  K_ShiftLEFT_ZT  : ausg:='Shift < (ZT)' ;
  K_ShiftRIGHT_ZT : ausg:='Shift > (ZT)' ;
  K_ShiftENDE_ZT  : ausg:='Shift ENDE (ZT)' ;
  K_ShiftDOWN_ZT  : ausg:='Shift v (ZT)' ;
  K_ShiftPDOWN_ZT : ausg:='Shift Bild v (ZT)' ;
  K_ShiftEINFG_ZT : ausg:='Shift EINFG (ZT)' ;
  K_ShiftENTF_ZT  : ausg:='Shift ENTF (ZT)' ;}
  K_StrgA: ausg:='Strg A'; K_StrgB: ausg:='Strg B'; K_StrgC: ausg:='Strg C'; K_StrgD: ausg:='Strg D'; K_StrgE: ausg:='Strg E';
  K_StrgF: ausg:='Strg F'; K_StrgG: ausg:='Strg G'; K_StrgH: ausg:='Strg H'; K_StrgI: ausg:='Strg I'; K_StrgJ: ausg:='Strg J';
  K_StrgK: ausg:='Strg K'; K_StrgL: ausg:='Strg L'; K_StrgM: ausg:='Strg M'; K_StrgN: ausg:='Strg N'; K_StrgO: ausg:='Strg O';
  K_StrgP: ausg:='Strg P'; K_StrgQ: ausg:='Strg Q'; K_StrgR: ausg:='Strg B'; K_StrgS: ausg:='Strg S'; K_StrgT: ausg:='Strg T';
  K_StrgU: ausg:='Strg U'; K_StrgV: ausg:='Strg V'; K_StrgW: ausg:='Strg W'; K_StrgX: ausg:='Strg X'; K_StrgY: ausg:='Strg Y';
  K_StrgZ: ausg:='Strg Z'; K_Strg6: ausg:='Strg 6';


end;

end
else begin
case s of
      K_F1  : ausg:='F1' ; K_ShiftF1  : ausg:='Shift F1' ; K_StrgF1  : ausg:='Strg F1'  ; K_AltF1  : ausg:='Alt F1' ;
      K_F2  : ausg:='F2' ; K_ShiftF2  : ausg:='Shift F2' ; K_StrgF2  : ausg:='Strg F2'  ; K_AltF2  : ausg:='Alt F2' ;
      K_F3  : ausg:='F3' ; K_ShiftF3  : ausg:='Shift F3' ; K_StrgF3  : ausg:='Strg F3'  ; K_AltF3  : ausg:='Alt F3' ;
      K_F4  : ausg:='F4' ; K_ShiftF4  : ausg:='Shift F4' ; K_StrgF4  : ausg:='Strg F4'  ; K_AltF4  : ausg:='Alt F4' ;
      K_F5  : ausg:='F5' ; K_ShiftF5  : ausg:='Shift F5' ; K_StrgF5  : ausg:='Strg F5'  ; K_AltF5  : ausg:='Alt F5' ;
      K_F6  : ausg:='F6' ; K_ShiftF6  : ausg:='Shift F6' ; K_StrgF6  : ausg:='Strg F6'  ; K_AltF6  : ausg:='Alt F6' ;
      K_F7  : ausg:='F7' ; K_ShiftF7  : ausg:='Shift F7' ; K_StrgF7  : ausg:='Strg F7' ; K_AltF7  : ausg:='Alt F7' ;
      K_F8  : ausg:='F8' ; K_ShiftF8  : ausg:='Shift F8' ; K_StrgF8  : ausg:='Strg F8' ; K_AltF8  : ausg:='Alt F8' ;
      K_F9  : ausg:='F9' ; K_ShiftF9  : ausg:='Shift F9' ; K_StrgF9  : ausg:='Strg F9' ; K_AltF9  : ausg:='Alt F9' ;
      K_F10 : ausg:='F10' ; K_ShiftF10 : ausg:='Shift F10' ; K_StrgF10 : ausg:='Strg F10' ; K_AltF10 : ausg:='Alt F10' ;

      {#0 + #Nr: F11 und F12 (falls Åberhaupt)}
      K_F11 : ausg:='' ; K_ShiftF11 : ausg:='' ; K_StrgF11 : ausg:='' ; K_AltF11 : ausg:='' ;
      K_F12 : ausg:='' ; K_ShiftF12 : ausg:='' ; K_StrgF12 : ausg:='' ; K_AltF12 : ausg:='' ;

      {Richtungstasten #224 + #Nr Shift = allein   ?   }
      K_POS1  : ausg:='POS1' ; K_StrgPOS1  : ausg:='Strg POS1' ; K_AltPOS1  : ausg:='Alt POS1' ;
      K_UP    : ausg:='^' ; K_StrgUP    : ausg:='Strg ^' ; K_AltUP    : ausg:='Alt ^' ;
      K_PUP   : ausg:='Bild ^' ; K_StrgPUP   : ausg:='Strg Bild ^' ; K_AltPUP   : ausg:='Alt Bild ^' ;
      K_LEFT  : ausg:='<' ; K_StrgLEFT  : ausg:='Strg <' ; K_AltLEFT  : ausg:='Alt <' ;
      K_RIGHT : ausg:='>' ; K_StrgRIGHT : ausg:='Strg >' ; K_AltRIGHT : ausg:='Alt >' ;
      K_ENDE  : ausg:='ENDE' ; K_StrgENDE  : ausg:='Strg ENDE' ; K_AltENDE  : ausg:='Alt ENDE' ;
      K_DOWN  : ausg:='v' ; K_StrgDOWN  : ausg:='Strg v' ; K_AltDOWN  : ausg:='Alt v' ;
      K_PDOWN : ausg:='Bild v' ; K_StrgPDOWN : ausg:='Strg Bild v' ; K_AltPDOWN : ausg:='Alt Bild v' ;
      K_EINFG : ausg:='EINFG' ; K_StrgEINFG : ausg:='Strg EINFG' ; K_AltEINFG : ausg:='Alt EINFG' ;
      K_ENTF  : ausg:='ENTF' ; K_StrgENTF  : ausg:='Strg ENTF' ; K_AltENTF  : ausg:='Alt ENTF' ;

      {#0 + #Nr }
      K_StrgDRUCK : ausg:='Strg DRUCK' ; K_StrgPAUSE : ausg:='Strg PAUSE' ;
      K_ShiftTAB : ausg:='Shift TAB'; K_StrgTAB : ausg:='Strg TAB'; {?} K_AltTAB : ausg:='Alt TAB'; {?}

      K_Strg2: ausg:='Strg 2';
 else;
end;
end;
writeln(ausg);
until t = 27;
end.