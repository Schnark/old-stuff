unit keyb;
interface
const {#0 + #Nr: F1 bis F10, allein / mit Shift / mit Strg / mit Alt}
      K_F1  = 59; K_ShiftF1  = 84; K_StrgF1  =  94; K_AltF1  = 104;
      K_F2  = 60; K_ShiftF2  = 85; K_StrgF2  =  95; K_AltF2  = 105;
      K_F3  = 61; K_ShiftF3  = 86; K_StrgF3  =  96; K_AltF3  = 106;
      K_F4  = 62; K_ShiftF4  = 87; K_StrgF4  =  97; K_AltF4  = 107;
      K_F5  = 63; K_ShiftF5  = 88; K_StrgF5  =  98; K_AltF5  = 108;
      K_F6  = 64; K_ShiftF6  = 89; K_StrgF6  =  99; K_AltF6  = 109;
      K_F7  = 65; K_ShiftF7  = 90; K_StrgF7  = 100; K_AltF7  = 110;
      K_F8  = 66; K_ShiftF8  = 91; K_StrgF8  = 101; K_AltF8  = 111;
      K_F9  = 67; K_ShiftF9  = 92; K_StrgF9  = 102; K_AltF9  = 112;
      K_F10 = 68; K_ShiftF10 = 93; K_StrgF10 = 103; K_AltF10 = 113;

      {#0 + #Nr: F11 und F12 (falls Åberhaupt)}
      K_F11 = 133; K_ShiftF11 = 135; K_StrgF11 = 137; K_AltF11 = 139;
      K_F12 = 134; K_ShiftF12 = 136; K_StrgF12 = 138; K_AltF12 = 140;

      {Cursor Zehnertastatur allein #0 + #Nr / mit Shift #Nr / mit Strg #0 + #Nr}
      K_POS1_ZT  = 71; K_ShiftPOS1_ZT  = 55; K_StrgPOS1_ZT  = 119;
      K_UP_ZT    = 72; K_ShiftUP_ZT    = 56; K_StrgUP_ZT    = 141;{?}
      K_PUP_ZT   = 73; K_ShiftPUP_ZT   = 57; K_StrgPUP_ZT   = 132;
      K_LEFT_ZT  = 75; K_ShiftLEFT_ZT  = 52; K_StrgLEFT_ZT  = 115;
      K_RIGHT_ZT = 77; K_ShiftRIGHT_ZT = 54; K_StrgRIGHT_ZT = 116;
      K_ENDE_ZT  = 79; K_ShiftENDE_ZT  = 49; K_StrgENDE_ZT  = 117;
      K_DOWN_ZT  = 80; K_ShiftDOWN_ZT  = 50; K_StrgDOWN_ZT  = 145;{?}
      K_PDOWN_ZT = 81; K_ShiftPDOWN_ZT = 51; K_StrgPDOWN_ZT = 118;
      K_EINFG_ZT = 82; K_ShiftEINFG_ZT = 48; K_StrgEINFG_ZT = 146;{?}
      K_ENTF_ZT  = 83; K_ShiftENTF_ZT  = 46; K_StrgENTF_ZT  = 147;{?}

      {Richtungstasten #224 + #Nr Shift = allein   ?   }
      K_POS1  = 71; K_StrgPOS1  = 119; K_AltPOS1  = 151;
      K_UP    = 72; K_StrgUP    = 141; K_AltUP    = 152;
      K_PUP   = 73; K_StrgPUP   = 132; K_AltPUP   = 153;
      K_LEFT  = 75; K_StrgLEFT  = 115; K_AltLEFT  = 155;
      K_RIGHT = 77; K_StrgRIGHT = 116; K_AltRIGHT = 157;
      K_ENDE  = 79; K_StrgENDE  = 117; K_AltENDE  = 159;
      K_DOWN  = 80; K_StrgDOWN  = 145; K_AltDOWN  = 154;
      K_PDOWN = 81; K_StrgPDOWN = 118; K_AltPDOWN = 161;
      K_EINFG = 82; K_StrgEINFG = 146; K_AltEINFG = 162;
      K_ENTF  = 83; K_StrgENTF  = 147; K_AltENTF  = 163;

      {#0 + #Nr }
      K_StrgDRUCK = 114; K_StrgPAUSE = 0;
      K_RUECK = 8; {auch Shift} K_StrgRUECK = 127;
      K_ENTER = 13; K_StrgENTER = 10;
      K_TAB = 9; K_ShiftTAB = {#0 + }15; K_StrgTAB = {#0 + }148; {?} K_AltTAB = {#0 + }165; {?}


      {Strg + Buchstabe: #Nr}
      K_StrgA =  1; K_StrgB =  2; K_StrgC =  3; K_StrgD =  4; K_StrgE =  5;
      K_StrgF =  6; K_StrgG =  7; K_StrgH =  8; K_StrgI =  9; K_StrgJ = 10;
      K_StrgK = 11; K_StrgL = 12; K_StrgM = 13; K_StrgN = 14; K_StrgO = 15;
      K_StrgP = 16; K_StrgQ = 17; K_StrgR = 18; K_StrgS = 19; K_StrgT = 20;
      K_StrgU = 21; K_StrgV = 22; K_StrgW = 23; K_StrgX = 24; K_StrgY = 25;
      K_StrgZ = 26;

      K_Strg2 = {#0+}3; K_Strg6 = 30;


procedure tasten(var taste, sonder: byte);
procedure hidecursor;
procedure showcursor;
procedure savecursor;
implementation
uses crt, dos;
var speicher: word;
procedure tasten;
begin
taste := ord(readkey);
if (taste = 0) and keypressed then sonder := ord(readkey) else sonder := 0;
end;
procedure hidecursor;
var regs: registers;
begin
 regs.ah:=1; regs.cx:=$2000;
 intr($10, regs);
end;
procedure showcursor;
var regs: registers;
begin
 regs.ah:=1; regs.cx:=speicher;
 intr($10, regs);
end;
procedure savecursor;
var regs: registers;
begin
 regs.ah:=3; regs.bh:=0;
 intr($10, regs);
 speicher:=regs.cx;
end;
end.