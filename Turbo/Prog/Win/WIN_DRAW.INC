procedure kasten(x,y,b,h: integer; ein: boolean);
begin
if ein then begin
 setcolor(black);
 setlinestyle(centerLN,0,normwidth);
end
else
 setcolor(_HGRND);
rectangle(x,y,x+b,y+h);
setlinestyle(solidLN,0,normwidth);
end;


procedure zeichne3D(x,y,b,h: integer; farbe: byte; tief: boolean);
var ol, ur, iur: byte;
begin
 if tief then
  begin
  ol := _OLI; ur := _URI; iur := _IURI;
  end
 else
  begin
  ol := _OLA; ur := _URA; iur := _IURA;
  end;
 setcolor(ol);
 line(x, y, x + b - 1, y);
 line(x, y + 1, x, y + h - 1);
 setcolor(ur);
 line(x + b, y, x + b, y + h);
 line(x, y + h, x + b - 1, y + h);
 setcolor(iur);
 line(x + 1, y + h - 1, x + b - 1, y + h - 1);
 line(x + b - 1, y + 1, x + b - 1, y + h - 1);
 setfillstyle(solidfill, farbe);
 bar(x + 1, y + 1, x + b - 2, y + h - 2);
end;

procedure THintergrund.zeichne_;
begin
 mausoff;
 setfillstyle(solidfill, farbe);
 bar(xx, yy, xx + breite, yy + hoehe);
 mauson;
end;

procedure TButton.zeichne_;
var b, h: integer;
    i: string;
begin
 b := breite; h := hoehe;
 i:=strpas(inhalt);
 {if gewaehlt then
  begin
  setfillstyle(solidfill, black);
  bar(xx, yy, xx + b, yy + h);
  xx := xx + 1; yy := yy + 1;
  b := b - 2; h := h - 2;
  end;}
 zeichne3D(xx,yy,b,h,_BUTTON,gedrueckt);
 if aktiv then setcolor(_AKTIV) else setcolor(_INAKTIV);
 outtextxy(xx + 5, yy + 3, i);
 {if inhalt<>'' then}
    kasten(xx+4,yy+2,textwidth(i)+3,textheight(i)+3,gewaehlt);
end;

procedure TSymButton.zeichne_;
var i,j,f: byte;
    b, h: integer;
begin
 b := breite; h := hoehe;
 {if gewaehlt then
  begin
  setfillstyle(solidfill, black);
  bar(xx, yy, xx + b, yy + h);
  xx := xx + 1; yy := yy + 1;
  b := b - 2; h := h - 2;
  end;}
 zeichne3D(xx,yy,b,h,_BUTTON,gedrueckt);
 if aktiv then f:=_AKTIV else f:=_INAKTIV;
 for i:=1 to 8 do for j:=1 to 8 do
     if (symbol[i] and (1 SHL (8-j))) <> 0 then putpixel(j+xx+2,i+yy+2,f);
end;

var altexpos: integer;
    c_onoff: boolean;
procedure TEdit.zeichnecursor(onoff: boolean);
var xpos: integer;
    xx, yy, b, h: integer;
    i: char;
    d: PDiaver;
    vp: ViewPortType;
begin
 if onoff=c_onoff then exit;
 c_onoff:=onoff;

 schranke(true);
 getviewsettings(vp);
 xx:=abs_x-vp.x1; yy:=abs_y-vp.y1; b := breite; h := hoehe;
 mausoff;
 if onoff then begin
    i:=(inhalt+cursorpos)[0]; (inhalt+cursorpos)[0]:=#0;
    xpos:=textwidth(strpas(inhalt+start))+xx+4;
    (inhalt+cursorpos)[0]:=i;
 end else
    xpos:=altexpos;
 (*setwritemode(XORput);*)
 if onoff then setcolor(black) else setcolor(_EDIT);
 line(xpos,yy+1,xpos,yy+h-1);
 (*setwritemode(NORMALput);*)
 altexpos:=xpos;
 schranke(false);
 d:=finden_verw(fenster);
 if (d<>nil) and (d^.hoeher<>nil) then d^.hoeher^.dia^.zeichne;
 mauson;
end;

procedure TEdit.zeichne_;
var b, h: integer;
    markstart, markende: word;
    c: char;
    teil1,teil2,teil3: string;
    vp: ViewPortType;
begin
 b := breite; h := hoehe;
 {if gewaehlt then
  begin
  setfillstyle(solidfill, black);
  bar(xx, yy, xx + b, yy + h);
  xx := xx + 1; yy := yy + 1;
  b := b - 2; h := h - 2;
  end;}
 zeichne3D(xx,yy,b,h,_EDIT,true);

 if cursorpos<markend then begin
    markstart:=cursorpos; markende:=markend;
 end else begin
    markstart:=markend; markende:=cursorpos;
 end;
 if start>markstart then markstart:=start;

 if not aktiv then begin
    setcolor(_INAKTIV);
    outtextxy(xx + 5, yy, strpas(inhalt+start));
 end else begin
    c:=(inhalt+markstart)[0]; (inhalt+markstart)[0]:=#0;
    teil1:=strpas(inhalt+start);
    (inhalt+markstart)[0]:=c; c:=(inhalt+markende)[0]; (inhalt+markende)[0]:=#0;
    teil2:=strpas(inhalt+markstart);
    (inhalt+markende)[0]:=c;
    teil3:=strpas(inhalt+markende);

    einschraenken(abs_x+5,abs_y,abs_x+b-5,abs_y+h-3);
    getviewsettings(vp);
    xx:=abs_x+5-vp.x1; yy:=abs_y-vp.y1;
    if teil2<>'' then begin
    setfillstyle(solidfill, _MARK);
    bar(textwidth(teil1) (*- 1*), 2, textwidth(teil1+teil2) - 1, h - 3);
    end;

    setcolor(_AKTIV);
    outtextxy(xx,yy,teil1);
    setcolor(_MARKEDTEXT);
    outtextxy(xx+textwidth(teil1)+1,yy,teil2);
    setcolor(_AKTIV);
    outtextxy(xx+textwidth(teil1+teil2),yy,teil3);
    entschraenken;
 end;
 {kasten(xx+4,yy+1,textwidth(inhalt)+3,textheight(inhalt)+2,gewaehlt);}
end;

procedure TLabel.zeichne_;
var b, h: integer;
begin
 b := breite; h := hoehe;
 setfillstyle(solidfill, _LABEL);
 bar(xx, yy, xx + b, yy + h);
 if aktiv then setcolor(_AKTIV) else setcolor(_INAKTIV);
 outtextxy(xx + 5, yy-2, strpas(inhalt));
 {kasten(xx+3,yy,textwidth(inhalt)+2,textheight(inhalt)+3,gewaehlt);}
end;

procedure TCheck.zeichne_;
const d = 12;
var b, h: integer;
    i: string;
begin
 b := d; h := d;
 i:=strpas(inhalt);
 {if gewaehlt then
  begin
  setfillstyle(solidfill, black);
  bar(xx, yy, xx + b, yy + h);
  xx := xx + 1; yy := yy + 1;
  b := b - 2; h := h - 2;
  end;}
 zeichne3D(xx,yy,b,h,_CHECK,true);
 if aktiv then setcolor(_AKTIV) else setcolor(_INAKTIV);
 outtextxy(xx + d+5, yy-2, i);
 if checked then
 begin
 {line (xx + 3, yy + 3, xx + 9, yy + 9);  (*Kreuz*)
 line (xx + 4, yy + 3, xx + 9, yy + 8);
 line (xx + 3, yy + 4, xx + 8, yy + 9);
 line (xx + 9, yy + 3, xx + 3, yy + 9);
 line (xx + 8, yy + 3, xx + 3, yy + 8);
 line (xx + 9, yy + 4, xx + 4, yy + 9);}

 line (xx + 3, yy + 5, xx + 3, yy + 7);       (*Haken*)
 line (xx + 4, yy + 6, xx + 4, yy + 8);
 line (xx + 5, yy + 7, xx + 5, yy + 9);
 line (xx + 6, yy + 6, xx + 6, yy + 8);
 line (xx + 7, yy + 5, xx + 7, yy + 7);
 line (xx + 8, yy + 4, xx + 8, yy + 6);
 line (xx + 9, yy + 3, xx + 9, yy + 5);
 end;
 kasten(xx+d+3,yy,textwidth(i),textheight(i)+1,gewaehlt);
end;

procedure TRadio.zeichne_;
const d = 12;
var b, h, xm, ym, r: integer;
    farbe: word;
    i: string;
begin
 b := d; h := d;
 i:=strpas(inhalt);
 {if gewaehlt then
  begin
  setfillstyle(solidfill, black);
  pieslice(xx+trunc(b/2), yy+trunc(h/2), 0, 360, trunc(b/2));
  xx := xx + 1; yy := yy + 1;
  b := b - 2; h := h - 2;
  end;}
 xm := xx + trunc(b / 2); ym := yy + trunc(h / 2); r := trunc(b / 2);
 setfillstyle(solidfill, _RADIO); setcolor(_RADIO);
 pieslice(xm, ym, 0, 360, r);
 setcolor(_OLI);
 arc(xm, ym, 35, 215, r);
 setcolor(_URI);
 arc(xm, ym, 215, 35, r);
 setcolor(black);
 arc(xm, ym, 35, 215, r-1);
 setcolor(_IURI);
 arc(xm, ym, 215, 35, r - 1);
 if aktiv then farbe := _AKTIV else farbe := _INAKTIV;
 setcolor(farbe);
 outtextxy(xx + d+5, yy-2, i);
 if checked then
 begin
 setfillstyle(solidfill, farbe);
 bar(xx + 4, yy + 4, xx + 7, yy + 7);
 putpixel (xx + 3, yy + 5, farbe); putpixel (xx + 3, yy + 6, farbe);
 putpixel (xx + 8, yy + 5, farbe); putpixel (xx + 8, yy + 6, farbe);
 putpixel (xx + 5, yy + 3, farbe); putpixel (xx + 6, yy + 3, farbe);
 putpixel (xx + 5, yy + 8, farbe); putpixel (xx + 6, yy + 8, farbe);
 end;
 kasten(xx+d+3,yy,textwidth(i),textheight(i)+1,gewaehlt);
end;

procedure TFrame.zeichne_;
var b, h: integer;
    i: string;
begin
 b:= breite; h:=hoehe;
 i:= strpas(inhalt);

 setcolor(_OLI); line(xx,yy,xx,yy+h); setcolor(_OLA); line(xx+1,yy,xx+1,yy+h);
 setcolor(_OLI); line(xx,yy+h,xx+b,yy+h); setcolor(_OLA); line(xx,yy+h+1,xx+b,yy+h+1);
 setcolor(_OLI); line(xx+b,yy,xx+b,yy+h); setcolor(_OLA); line(xx+b+1,yy,xx+b+1,yy+h);
 setcolor(_OLI); line(xx,yy,xx+b,yy); setcolor(_OLA); line(xx,yy+1,xx+b,yy+1);
 setfillstyle(solidfill, _HGRND);
 bar(xx+5,yy,xx+5+textwidth(i),yy+1);
 setcolor(black);
 outtextxy(xx+6,yy-7,i);
end;

procedure T3D.zeichne_;
var b, h: integer;
begin
 b:= breite; h:=hoehe;
 zeichne3D(xx,yy,b,h,_LABEL,tief);
end;

procedure TWindow.zeichne_;
const titel = 20;
var b, h: integer;
    f: byte;
    i: string;
    os: PObjektschlange;
begin
 {write(#7); (* zum Z„hlen *)}
 b := breite; h := hoehe; i := strpas(inhalt);
 if aktiv then f:=_TITEL else f:=_TITELIN;
 zeichne3D(xx, yy, b, titel, f, false);

 if aktiv then setcolor(_AKTIV) else setcolor(_INAKTIV);
 outtextxy(xx+5, yy+2, i);
 setcolor(black); setlinestyle(solidln,0,thickwidth);
 line(xx+breite-17,yy+3,xx+breite-3,yy+17);
 line(xx+breite-3,yy+3,xx+breite-17,yy+17);
 setlinestyle(solidln,0,normwidth);

 zeichne3D(xx, yy+titel+1, b, h-titel-1, _HGRND, false);

 {Zeichne Elemente}
 os:=zeichneschlange;
 while os<>nil do begin
   os^.el^.zeichne;
   os:=os^.next;
 end;
end;

