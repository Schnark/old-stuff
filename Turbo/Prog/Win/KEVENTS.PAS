unit kevents;
{{$DEFINE test}
interface
const _WARTEZEIT=50;
      _WIEDERHOLZEIT=30;

      _CURSORBLINK=30;
var altzeit_stay: longint; {fÅr EVENTS}
    stay_ist_an, stay_soll_aus: boolean;

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
      VK_Strg_l = 22;
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
      VK_ESC = 39;
      VK_MalNum = 40;
      VK_ENTER_NUM = 41;
      VK_Strg_r = 42;
      VK_DurchNum = 43;
      VK_AltGr = 44;



type keyaktion = (keydown,  {Taste gedrÅckt (Scan [in nr], shift)}
                  keyup,    {Taste losgelassen (Scan [in nr], shift)}
                  keyascii, {Tastendruck mit lesbarer Taste (ascii [in nr])}
                  keyspec); {Sondertaste (nr, shift)}

type keyevent= record
     nr: byte;
     shift: word;
     aktion: keyaktion;
     end;
type Pkeyevent= ^keyevent;

procedure k_events;

procedure edit_cursor(e: pointer);

function getshift: word;
function gross(s: word): byte;  {CAPS Shift_r Shift_l}
const Shift=3; Shift_l=1; Shift_r=2; CAPS=4;
function num(s: word): boolean;
function strgalt(s: word): byte; {AltGr Alt Strg_r Strg_l}
const Strg=3; Strg_l=1; Strg_r=2;
      Alt=12; Alt_l=4; AltGr=8;

implementation
uses zeit, crt{$IFNDEF test}, win, winverw {$ENDIF};
type PEdit = ^TEdit;

var altport62: byte;
    erweitert, erweitertpause: boolean;
    event_status: byte;

    edit: PEdit;
    cursorzeit: longint;
    cursoronoff: boolean;

type Prawevent= ^rawevent;
     rawevent= record
     p62: byte;
     zeit: longint;
     next: Prawevent;
     end;

type PQEvent= ^QEvent;
     QEvent= record
     e: keyevent;
     next: PQEvent;
     end;

const _SHIFT_l =  42;   BitNrShL =  1;
      _SHIFT_r =  54;   BitNrShR =  2;
      _STRG_l  =  29;   BitNrStL =  4;
      _STRG_r  = 157;   BitNrStR =  8;
      _ALT     =  56;   BitNrAlt = 16;
      _ALTGR   = 184;   BitNrAG  = 32;

      _CAPS    =  58;   BitNrCAPS =  256;
      _NUM     =  69;   BitNrNUM  =  512;
      _ROLLEN  =  70;   BitNrRoll = 1024;
      _EINFG   = 200;   BitNrEinf = 2048;
      ShiftTasten1: set of byte = [_SHIFT_l, _SHIFT_r, _STRG_l, _STRG_r, _ALT, _ALTGR];
      ShiftTasten2: set of byte = [_CAPS, _NUM, _ROLLEN, _EINFG];

      akzente: set of char = ['^','Ô', '`'];
type  akzent_typen = (dach,auf,ab);
const akz_buch: array [akzent_typen] of record
                      von, zu: string[11]; end =
                      ((von:' aeiouAEIOU'; zu:'^Éàåìñ∂“◊‚Í'),
                       (von:' aeiouAEIOU'; zu:'Ô†Ç°¢£µê÷‡È'),
                       (von:' aeiouAEIOU'; zu:'`Öäçïó∑‘ﬁ„Î'));

      ascii_d: array [1..128+83,1..3] of char =
                     ((#0,chr(VK_ESC),#0),
                      ('1','!',#0),
                      ('2','"','˝'),
                      ('3','ı','¸'),
                      ('4','$',#0),
                      ('5','%',#0),
                      ('6','&',#0),
                      ('7','/','{'),
                      ('8','(','['),
                      ('9',')',']'),
                      ('0','=','}'),
                      ('·','?','\'),
                      ('Ô','`',#0),
                      (#0,chr(VK_BS),#0),
                      (#0,chr(VK_TAB),#0),
                      ('q','Q','@'),
                      ('w','W',#0),
                      ('e','E',#0),
                      ('r','R',#0),
                      ('t','T',#0),
                      ('z','Z',#0),
                      ('u','U',#0),
                      ('i','I',#0),
                      ('o','O',#0),
                      ('p','P',#0),
                      ('Å','ö',#0),
                      ('+','*','~'),
                      (#0,chr(VK_ENTER),#0),
                      (#0,chr(VK_Strg_l),#0),
                      ('a','A',#0),
                      ('s','S',#0),
                      ('d','D',#0),
                      ('f','F',#0),
                      ('g','G',#0),
                      ('h','H',#0),
                      ('j','J',#0),
                      ('k','K',#0),
                      ('l','L',#0),
                      ('î','ô',#0),
                      ('Ñ','é',#0),
                      ('^','¯',#0),
                      (#0,chr(VK_Shift_l),#0),
                      ('#','''',#0),
                      ('y','Y',#0),
                      ('x','X',#0),
                      ('c','C',#0),
                      ('v','V',#0),
                      ('b','B',#0),
                      ('n','N',#0),
                      ('m','M','Ê'),
                      (',',';',#0),
                      ('.',':',#0),
                      ('-','_',#0),
                      (#0,chr(VK_Shift_r),#0),
                      (#255,'*',chr(VK_MalNUM)),
                      (#0,chr(VK_Alt),#0),
                      (' ',' ',#0),
                      (#0,chr(VK_CAPS),#0),
                      (#0,chr(VK_F1),#0),
                      (#0,chr(VK_F2),#0),
                      (#0,chr(VK_F3),#0),
                      (#0,chr(VK_F4),#0),
                      (#0,chr(VK_F5),#0),
                      (#0,chr(VK_F6),#0),
                      (#0,chr(VK_F7),#0),
                      (#0,chr(VK_F8),#0),
                      (#0,chr(VK_F9),#0),
                      (#0,chr(VK_F10),#0),
                      (#0,chr(VK_Num),#0),
                      (#0,chr(VK_Rollen),#0),
                      (#255,'7',chr(VK_Pos1)),
                      (#255,'8',chr(VK_Up)),
                      (#255,'9',chr(VK_Bild_up)),
                      (#255,'-',chr(VK_MinusNum)),
                      (#255,'4',chr(VK_Left)),
                      (#255,'5',chr(VK_MitteNum)),
                      (#255,'6',chr(VK_Right)),
                      (#255,'+',chr(VK_PlusNum)),
                      (#255,'1',chr(VK_Ende)),
                      (#255,'2',chr(VK_Down)),
                      (#255,'3',chr(VK_Bild_down)),
                      (#255,'0',chr(VK_Einfg)),
                      (#255,',',chr(VK_Entf)),
                      (#0,chr(VK_SysReq),#0),
                      (#0,#0,#0),
                      ('<','>','|'),
                      (#0,chr(VK_F11),#0),
                      (#0,chr(VK_F12),#0),
{89..127,128..128+27:}(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
           (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
           (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
           (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
           (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
           (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
           (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
                      (#0,chr(VK_ENTER_NUM),#0),
                      (#0,chr(VK_Strg_r),#0),
{128+30..128+52:}     (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
           (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
           (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
                      (#255,'/',chr(VK_DurchNum)),
{128+54..128+55:}     (#0,#0,#0),(#0,#0,#0),
                      (#0,chr(VK_AltGr),#0),
{128+57..128+68:}     (#0,#0,#0),(#0,#0,#0),
           (#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),(#0,#0,#0),
                      (#0,chr(VK_Pause),#0),
{128+70:}             (#0,#0,#0),
                      (#0,chr(VK_Pos1),#0),
                      (#0,chr(VK_Up),#0),
                      (#0,chr(VK_Bild_up),#0),
{128+74:}             (#0,#0,#0),
                      (#0,chr(VK_Left),#0),
{128+76:}             (#0,#0,#0),
                      (#0,chr(VK_Right),#0),
{128+78:}             (#0,#0,#0),
                      (#0,chr(VK_Ende),#0),
                      (#0,chr(VK_Down),#0),
                      (#0,chr(VK_Bild_down),#0),
                      (#0,chr(VK_Einfg),#0),
                      (#0,chr(VK_Entf),#0));


var rawevents, lastrawevent: Prawevent;
    allevents, lastevent: PQEvent;
    alte_taste: keyevent;                  {fÅr wiederholten Tastendruck}
    alte_zeit: longint;
    wiederholung: boolean;

    _SHIFT_: word;
    letzter_akzent: char;

function getshift: word;
begin getshift:=_SHIFT_; end;

function gross(s: word): byte;  {CAPS Shift_r Shift_l}
begin gross:=byte(s mod 4) or (byte(s div 128) and 1) shl 2; end;

function num(s: word): boolean;
begin num:=(byte(s div 128) and 2)<>0; end;

function strgalt(s: word): byte; {AltGr Alt Strg_r Strg_l}
begin strgalt:=byte(s mod 64) shr 2; end;


procedure aendereShift(taste: byte; ein: boolean);
var bitnr: word;
begin
case taste of
  _SHIFT_l: bitnr:=BitNrShL;
  _SHIFT_r: bitnr:=BitNrShR;
  _STRG_l:  bitnr:=BitNrStL;
  _STRG_r:  bitnr:=BitNrStR;
  _ALT:     bitnr:=BitNrAlt;
  _ALTGR:   bitnr:=BitNrAG;

  _CAPS:    bitnr:=BitNrCAPS;
  _NUM:     bitnr:=BitNrNUM;
  _ROLLEN:  bitnr:=BitNrRoll;
  _EINFG:   bitnr:=BitNrEinf;
end;
if taste in ShiftTasten2 then
   ein:=(_SHIFT_ and bitnr) = 0;
_SHIFT_:= (_SHIFT_ and not bitnr);
if ein then _SHIFT_:=_SHIFT_ or bitnr;
end;

procedure edit_cursor(e: pointer);
begin
 if cursoronoff and (edit<>nil) then edit^.zeichnecursor(false);
 edit:=PEdit(e);
 if e=nil then exit;
 cursoronoff:=true; cursorzeit:=timer;
 edit^.zeichnecursor(true);
end;

procedure blinkcursor;
begin
 if edit=nil then exit;
 if timer-cursorzeit<_CURSORBLINK then exit;
 cursoronoff:=not cursoronoff;
 edit^.zeichnecursor(cursoronoff);
 cursorzeit:=timer;
end;


procedure getrawevent;
var p62: byte;
    s: byte;
    z: longint;
    p: Prawevent;
begin
 p62:=port[$62];     {Daten holen}
 if p62=0 then exit;
 if p62=altport62 then exit;
 altport62:=p62;
 z:=timer;

 altzeit_stay:=z;
 if stay_ist_an then stay_soll_aus:=true; {Taste -> StayEnd}

 new(p);
 p^.p62:=p62; p^.zeit:=z; p^.next:=nil;
 if lastrawevent <> nil then begin
    lastrawevent^.next:=p; lastrawevent:=p;
 end else begin
    rawevents:=p; lastrawevent:=p;       {an Liste anhÑngen}
 end;
end;

procedure einreihen(e: PQEvent);
begin
 e^.next:=nil;
 if lastevent <> nil then begin
    lastevent^.next:=e; lastevent:=e;
 end else begin
    allevents:=e; lastevent:=e;       {an Liste anhÑngen}
 end;
end;

procedure getevent;
var p62: byte;
    z: longint;
    alt: Prawevent;
    e: PQEvent;
    c: char; a_t:akzent_typen; p: byte;
begin
 if rawevents=nil then begin
    if alte_taste.nr<>0 then begin
       z:=timer;
       if (wiederholung and (z-alte_zeit>=_WIEDERHOLZEIT)) or
          (not wiederholung and (z-alte_zeit>=_WARTEZEIT)) then begin
          wiederholung:=true; alte_zeit:=z;
          new(e); e^.e:=alte_taste; einreihen(e);
       end;
    end;
    exit;
 end;
 p62:= rawevents^.p62;
 z:= rawevents^.zeit;
 alt:= rawevents;
 rawevents:=rawevents^.next;
 if rawevents = nil then lastrawevent:=nil;
 dispose(alt);                              {Daten holen}
 if p62=122+128 then begin erweitert:=false; exit; end;       {unnîtig}
 if erweitertpause then if p62 mod 128 <> 69 then exit        {Pause: Strg+NUM}
    else begin erweitertpause:=false; erweitert:=true; end;
 if p62=96+128 then begin erweitert:=true; exit; end;         {nÑchste: erw.}
 if p62=97+128 then begin erweitertpause:=true; exit; end;    {nÑchste: erw.}
 new(e);
 if p62>128 then e^.e.aktion:=keyup else e^.e.aktion:=keydown; {gedrÅckt/losgelassen}
 p62:=p62 mod 128; if erweitert then p62:=p62+128; e^.e.nr:=p62; {Sondertaste?}
 if (p62 in ShiftTasten1)                          {Shifttaste?}
 or ((p62 in ShiftTasten2) and (e^.e.aktion=keydown)) then aendereShift(p62,e^.e.aktion=keydown);
 e^.e.shift:=getshift;
 einreihen(e);

 if e^.e.aktion=keydown then begin
    new(e);
    e^.e.aktion:=keyascii;
    e^.e.shift:=getshift;

    if strgalt(e^.e.shift) mod 8 > 0 then e^.e.aktion:=keyspec; {Strg/Alt}
    if (strgalt(e^.e.shift) div 8 > 0) and (ascii_d[p62,3]=#0) then e^.e.aktion:=keyspec;
       {AltGr mit falscher Taste}
    if ascii_d[p62,1]=#0 then e^.e.aktion:=keyspec;
       {Sondertaste}
    if (ascii_d[p62,1]=#255) and (not num(e^.e.shift)) then e^.e.aktion:=keyspec;
       {NUM aus und NUM-Taste}
    if e^.e.aktion=keyascii then begin

       if num(e^.e.shift) then c:=ascii_d[p62,2]
       else if strgalt(e^.e.shift)>0 then c:=ascii_d[p62,3]
       else if gross(e^.e.shift)>0 then c:=ascii_d[p62,2]
       else c:=ascii_d[p62,1];

       if c in akzente then begin
          letzter_akzent:=c;
          dispose(e); exit; end;
       if letzter_akzent<>#0 then begin
          case letzter_akzent of
           '^': a_t:=dach;
           'Ô': a_t:=auf;
           '`': a_t:=ab;
           end;
           p:=pos(c,akz_buch[a_t].von);
           if p=0 then begin
              e^.e.nr:=ord(letzter_akzent); einreihen(e);
              new(e); e^.e.aktion:=keyascii; e^.e.shift:=getshift;
           end else
              c:=akz_buch[a_t].zu[p];
           letzter_akzent:=#0;
       end;
       e^.e.nr:=ord(c);
    end else begin
       if not(p62 in ShiftTasten1) then letzter_akzent:=#0;
       c:=ascii_d[p62,1];
       if ascii_d[p62,1]=#255 then c:=ascii_d[p62,3];
       if ascii_d[p62,1]=#0 then c:=ascii_d[p62,2];
       e^.e.nr:=ord(c);
    end;
    einreihen(e);
    alte_taste:=e^.e; alte_zeit:=z;
 end else begin
    alte_taste.nr:=0; wiederholung:=false;
 end;
 erweitert:=false;
end;

procedure makekeyevent;
var e: keyevent;
    alt: PQEvent;
    {$IFNDEF test}
    empfaenger_f: PWindow;
    empfaenger_el: PElement;
    {$ENDIF}
begin
 if allevents=nil then exit;
 e:= allevents^.e;
 alt:= allevents;
 allevents:=allevents^.next;
 if allevents = nil then lastevent:=nil;
 dispose(alt);                              {Daten holen}
{$IFDEF test}
 case e.aktion of
      keydown:  write('v: ',e.nr:3,' ',getSHIFT:8,' ');
      keyup:    write('^: ',e.nr:3,' ',getSHIFT:8,' ');
      keyascii: write('   ',chr(e.nr),'   ',getSHIFT:8,' ');
      keyspec:  write('   ',e.nr:3,' ',getSHIFT:8,' ');
 end;
{$ELSE}
 empfaenger_f:=findew_t_all;
 if empfaenger_f<>nil then begin
    empfaenger_el:=empfaenger_f^.finden_t;
    if empfaenger_el=nil then empfaenger_el:=empfaenger_f;
 end else
    empfaenger_el:=gethintergrund;

 case e.aktion of
      keydown:  empfaenger_el^.OnKeydown(e);
      keyup:    empfaenger_el^.OnKeyup(e);
      keyascii: empfaenger_el^.OnKeyascii(e);
      keyspec:  empfaenger_el^.OnKeyspec(e);
 end;
{$ENDIF}
end;

procedure k_events;
var dummy:char;
begin
  while keypressed do dummy:=readkey;
  blinkcursor;
  case event_status of
  0: getrawevent;
  1: getevent;
  2: makekeyevent;
  3: getevent;
  4: getrawevent;
  5: getevent;
  6: makekeyevent;
  7: makekeyevent;
  end;
  event_status:=(event_status+1) mod 8;
end;

begin
 rawevents:=nil; lastrawevent:=nil;
 allevents:=nil; lastevent:=nil;
 event_status:=0; letzter_akzent:=#0; _SHIFT_:=0;
 edit:=nil;
end.