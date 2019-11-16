program wintest;
uses win, win_more, winverw, graph, crt, events, kevents, strings;

{TEST-Fenster}

type TTestFenster = object(TWindow)
     button: TButton;
{     sbutton: TSymbutton;}
     edit: TEdit;
     label1: TLabel;
     check: TCheck;
     radio1,radio2,radio3: TRadio;
     listbox: TListBox;
     constructor init(r: TRechteck; i: pchar);
     procedure OnKeySpec(e: keyevent); virtual;
     destructor fertig;
     end;

{Meldungs-Fenster}

type TMeldung = object(TWindow)
     label1: TLabel;
     button: TButton;
     frame: TFrame;
     constructor init(r: TRechteck; i: pchar);
     destructor fertig;
     end;

{Dokument-Fenster}
type TDokument = object(TForm)
     edit: TEdit;
     scrollbar: TScrollBar;
     constructor init(r: TRechteck; i: pchar);
     destructor fertig;
     end;
     PDokument = ^TDokument;

procedure TTestFensterButton_OnMouseClick(s: PElement; e: mouseevent); far;
begin
 if not s^.aktiv then exit;
 if e.taste<>1 then exit;
 write(#7);
end;

procedure TMeldungButton_OnMouseClick(s: PElement; e: mouseevent); far;
begin
 if not s^.aktiv then exit;
 if e.taste<>1 then exit;
 finden_verw(s^.fenster)^.schliessen;
end;

procedure TDokument_SBOnChange(s: PElement); far;
var i: string;
    i2: array[0..4] of char;
begin
 with PDokument(s^.fenster)^ do begin
 str(scrollbar.p.position,i);
 strpcopy(i2,i);
 edit.aenderni(i2);
 end;
end;


{INIT, FERTIG: TEST-F., Meldungs-F., Dokument-F.}
constructor TTestFenster.init;
const r1:TRechteck=(x: 100; y: 100; b: 0; h: 0);
      r2:TRechteck=(x:10; y:40; b:13; h:13);
      r3:TRechteck=(x:100; y:150; b:0; h:0);
      r4:TRechteck=(x:100; y:190; b:0; h:0);
      r5:TRechteck=(x:10; y:60; b:0; h:0);
      r6:TRechteck=(x:10; y:110; b:0; h:0);
      r7:TRechteck=(x:10; y:150; b:0; h:0);
      r8:TRechteck=(x:10; y:190; b:0; h:0);
      r9:TRechteck=(x:100;y:30; b:100; h:50);
var f: PWindow;
begin
 TWindow.init(r,i,f);

 button.init(r1, '   Hallo!   ', f);
 button.hint:='  Piepston  ';
 button.showhint:=true;
 button.MouseClickHand:=TTestFensterButton_OnMouseClick;

{ sbutton.init(r2, sb_unten, f);}

 r3.b:=textwidth('Text')+30;
 edit.init(r3, 'Text', f);

 label1.init(r4, 'Text', f);

 check.init(r5, 'Check', f);

 radio1.init(r6, 'Radio 1', f);
 radio2.init(r7, 'Radio 2', f);
 radio3.init(r8, 'Radio 3', f);
 radio1.naechster:=@radio2; radio2.naechster:=@radio3; radio3.naechster:=@radio1;

 listbox.init(r9,'Eintrag 1'#0'Nr. 2'#0'Ende'#0#0, f);
 listbox.select(1, true);

 button.einordnen(e_t); edit.einordnen(e_t); check.einordnen(e_t);
    radio1.einordnen(e_t); radio2.einordnen(e_t); radio3.einordnen(e_t);
    listbox.einordnen(e_t);
 listbox.einordnen(e_m);
 radio3.einordnen(e_m); radio2.einordnen(e_m); radio1.einordnen(e_m);
    check.einordnen(e_m); edit.einordnen(e_m); button.einordnen(e_m);
{    sbutton.einordnen(e_m);}
 listbox.einordnen(e_z);
 radio3.einordnen(e_z); radio2.einordnen(e_z); radio1.einordnen(e_z);
    check.einordnen(e_z); label1.einordnen(e_z); edit.einordnen(e_z);
    button.einordnen(e_z); {sbutton.einordnen(e_z);}
end;

constructor TMeldung.init;
const r1:TRechteck=(x:10;y:50;b:0;h:0);
      r2:TRechteck=(x:50;y:100;b:0;h:0);
      r3:TRechteck=(x:5;y:40;b:185;h:100);
var f: PWindow;
begin
 inherited init(r,i,f);

 label1.init(r1, 'Dies ist die Meldung',f);

 button.init(r2, '   OK   ',f);
 button.MouseClickHand:=TMeldungButton_OnMouseClick;

 frame.init(r3, 'Meldung',f); align:=@frame;

 button.einordnen(e_t); button.einordnen(e_m);
 frame.einordnen(e_z); button.einordnen(e_z); label1.einordnen(e_z);
end;

constructor TDokument.init;
const r1:TRechteck=(x:5;y:5;b:500;h:0);
      r2:TRechteck=(x:5;y:45;b:100;h:13);
      p:TPos=(position:3;min:0;max:10;d_klein:1;d_gross:2);
var f: PWindow;
begin
 inherited init(r,520,100,i,f);

 edit.init(r1, '',f); edit.relativ_zu:=@scrollfeld;
 scrollbar.init(r2,true,p,f); scrollbar.OnChangeHand:=TDokument_SBOnChange;
 scrollbar.relativ_zu:=@scrollfeld;

 edit.einordnen(e_t);
 edit.einordnen(e_m); scrollbar.einordnen(e_m);
 edit.einordnen(e_z); scrollbar.einordnen(e_z);
end;

destructor TTestFenster.fertig;
begin
 button.fertig;
{ sbutton.fertig;}
 edit.fertig;
 label1.fertig;
 check.fertig;
 radio1.fertig;
 radio2.fertig;
 radio3.fertig;
 listbox.fertig;

 Twindow.fertig;
end;

destructor TMeldung.fertig;
begin
 label1.fertig;
 button.fertig;
 TWindow.fertig;
end;

destructor TDokument.fertig;
begin
 edit.fertig;
 scrollbar.fertig;
 inherited fertig;
end;

{DESKTOP}
type TDesktop = object(THintergrund)
     procedure zeichne_(xx,yy:integer); virtual;
     procedure OnMouseDBClick(e: mouseevent); virtual;
     procedure OnKeySPEC(e: keyevent); virtual;
end;

procedure TDesktop.zeichne_;
begin
  inherited zeichne_(xx,yy);
  setfillstyle(solidfill, red);
  bar(5,5,25,25);
  setfillstyle(solidfill, green);
  bar(30,5,50,25);
end;

procedure TDesktop.OnKeySPEC(e: keyevent);
begin
   if e.nr=VK_ESC then begin benutzter_ende:=true; exit; end;
inherited OnKeySPEC(e);
end;

var hw1, hw2, hm1, hm2, hm3, hd1, hd2: pdiaver;
    akt: pdiaver;
    hinten: TDesktop;
    window1, window2: TTestFenster;
    meldung1, meldung2, meldung3: TMeldung;
    dokument1, dokument2: TDokument;
    c: char;

procedure TDesktop.OnMouseDBClick(e: mouseevent);
begin
  if e.taste>2 then exit;
  if e.y>30 then exit;
  if e.x>55 then exit;
  if e.x<30 then hw1^.oeffnen(nil,e.taste-1) else hw2^.oeffnen(nil,e.taste-1);
end;

procedure TTestFenster.OnKeySpec(e: keyevent);
begin
  if Strg and StrgAlt(e.shift) > 0 then
  case chr(e.nr) of
         '1': begin hm1^.oeffnen(finden_verw(fenster),0); exit; end;
         '2': begin hm2^.oeffnen(finden_verw(fenster),0); exit; end;
         '3': begin hm3^.oeffnen(finden_verw(fenster),0); exit; end;

         '4': begin hd1^.oeffnen(finden_verw(fenster),0); exit; end;
         '5': begin hd2^.oeffnen(finden_verw(fenster),0); exit; end;
         else;
  end;
 inherited OnKeySpec(e);
end;

const r1:TRechteck=(x:100; y:100; b:250; h:220);
      r2:TRechteck=(x:200; y:200; b:250; h:220);
      r3:TRechteck=(x:110; y:210; b:200; h:150);
      r4:TRechteck=(x:120; y:220; b:200; h:150);
      r5:TRechteck=(x:130; y:230; b:200; h:150);
      r6:TRechteck=(x:210; y:210; b:200; h:200);
      r7:TRechteck=(x:220; y:220; b:200; h:200);

begin
 hinten.init(_DSK);
 registerback(@hinten);

 window1.init(r1, 'TITEL 1');
 window2.init(r2, 'TITEL 2');
 meldung1.init(r3, 'MELDUNG 1');
 meldung2.init(r4, 'MELDUNG 2');
 meldung3.init(r5, 'MELDUNG 3');
 dokument1.init(r6, 'DOKUMENT 1');
 dokument2.init(r7, 'DOKUMENT 2');

 hw1 := register(@window1,app);
 hw2 := register(@window2,app);
 hm1 := register(@meldung1,dlg);
 hm2 := register(@meldung2,dlg);
 hm3 := register(@meldung3,dlg);
 hd1 := register(@dokument1,doc);
 hd2 := register(@dokument2,doc);

 with window1 do begin
  check.checked := true;
  radio1.checked := true;
  radio2.aktiv := false;
  (*button.gewaehlt := true;*)
 end;
 window2.radio2.checked:=true;

repeat k_events; m_events; until hinten.benutzter_ende;

 hw1^.fertig;
 hw2^.fertig;
 hm1^.fertig;
 hm2^.fertig;
 hm3^.fertig;
 hd1^.fertig;
 hd2^.fertig;

 hinten.fertig;
end.