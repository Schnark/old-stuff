var hintspeicher: pointer;

procedure TElement.OnMouseStay(e: mouseevent);      {Event-Handler}
var groesse: word;
    h: string;
begin
 if not showhint then exit;
 mausoff;
 h:=strpas(hint);
 groesse:=imagesize(e.x, e.y-textheight(h)-5, e.x+textwidth(h), e.y);
 getmem(hintspeicher, groesse);
 getimage(e.x, e.y-textheight(h)-5, e.x+textwidth(h), e.y, hintspeicher^);
 setfillstyle(solidfill, _HINT);
 bar(e.x, e.y-textheight(h)-5, e.x+textwidth(h), e.y);
 setcolor(black);
 outtextxy(e.x, e.y-textheight(h)-5, h);
 mauson;
 {zeichne ggf. Hint}
end;

procedure TElement.OnMouseStayEnd(e: mouseevent);   {Event-Handler}
var groesse: word;
    h: string;
begin
 if not showhint then exit;
 h:=strpas(hint);
 mausoff;
 putimage(e.x, e.y-textheight(h)-5, hintspeicher^, normalput);
 groesse:=imagesize(e.x, e.y-textheight(h)-5, e.x+textwidth(h), e.y);
 freemem(hintspeicher, groesse);
 mauson;
 {lîsche ggf. Hint}
end;

procedure TElement.OnMouseMoveTo(e: mouseevent);    {Event-Handler}
begin
 {}
end;

procedure TElement.OnMouseLeave(e: mouseevent);
begin
 {evt. Statuszeile zurÅcksetzen}
end;

procedure TElement.OnMouseEnter(e: mouseevent);
begin
 {evt. Statuszeile verÑndern}
end;

procedure TElement.OnMouseDown(e: mouseevent);      {Event-Handler}
var alt: PObjektschlange;
begin
 if not aktiv then exit;
 if e.taste<>1 then exit;
 if not fenster^.aktiv then begin fenster^.OnMouseDown(e); exit; end;
 gedrueckt:=true;
 if fenster^.acceptkey<>nil then begin
    alt:=fenster^.acceptkey;
    repeat
       fenster^.acceptkey:=fenster^.acceptkey^.next;
    until (fenster^.acceptkey^.el=selbst) or (fenster^.acceptkey=alt);
    if fenster^.acceptkey<>alt then begin
       alt^.el^.gewaehlt:=false; alt^.el^.zeichne;
       alt^.el^.OnLoseFocus;
       gewaehlt:=true;
       zeichne;
       OnGetFocus;
       exit;
    end;
 end;
 zeichne;
 {zeichne gedrÅckt, aktiviere}
end;

procedure TWindow.OnMouseDown(e: mouseevent);
begin
 finden_verw(fenster)^.aktivieren;
 tatsaechliches_element:=selbst; {da evt. von anderem Element Åbernommen}
 {aktivieren}
end;

procedure THintergrund.OnMouseDown(e: mouseevent);
begin
end;

procedure TEdit.OnMouseDown(e: mouseevent);
var c: char;
    gefunden: boolean;
begin
 if not aktiv then exit;
 if e.taste<>1 then begin TElement.OnMouseDown(e); exit; end;
 if not fenster^.aktiv then begin fenster^.OnMouseDown(e); exit; end;
 if fenster^.acceptkey^.el=selbst then begin
 zeichnecursor(false);
 gefunden:=false;
 cursorpos:=start;
 repeat
   c:=(inhalt+cursorpos)[0]; (inhalt+cursorpos)[0]:=#0;
   gefunden:=(textwidth(strpas(inhalt+start))+abs_x+5>=e.x);
   (inhalt+cursorpos)[0]:=c;
   if not gefunden then inc(cursorpos);
   if cursorpos=strlen(inhalt) then gefunden:=true;
 until gefunden;
 markend:=cursorpos; zeichne;
 zeichnecursor(true);
 {Markierung aufheben und Cursor setzen}
 end
 else TElement.OnMouseDown(e);
end;

procedure TElement.OnMouseUp(e: mouseevent);        {Event-Handler}
begin
 if not aktiv then exit;
 gedrueckt:=false;
 zeichne;
 {zeichne normal}
end;

procedure TWindow.OnMouseUp(e: mouseevent);
begin
end;

procedure THintergrund.OnMouseUp(e: mouseevent);
begin
end;

procedure TElement.OnMouseClick(e: mouseevent);     {Event-Handler}
begin
 if @MouseClickHand<>nil then MouseClickHand(selbst, e);
 if e.aktion=nothing then exit;
 {if e.taste=2 then if kontextmenu<>nil then kontextmenu^.open;}
end;

procedure TWindow.OnMouseClick(e: mouseevent);
begin
 if e.taste<>1 then begin TElement.OnMouseClick(e); exit; end;
 if (x+breite-e.x <=20) and (e.y-y <=20) then finden_verw(fenster)^.schliessen;
end;

procedure TCheck.OnMouseClick(e: mouseevent);
begin
 if not aktiv then exit;
 if e.taste<>1 then begin TElement.OnMouseClick(e); exit; end;
 aendernc(not checked);
end;

procedure TRadio.OnMouseClick(e: mouseevent);
var r,s: PRadio;
begin
 if not aktiv then exit;
 if e.taste<>1 then begin TElement.OnMouseClick(e); exit; end;
 if checked then exit;
 aendernc(true);
 s:=naechster; r:=s;
 while not r^.checked do r:=r^.naechster;
 if not (r^.naechster=s) then r^.aendernc(false);
end;

procedure TScrollButton.OnMouseClick(e: mouseevent);
var p: TPos;
    pos: integer;
begin
 if not aktiv then exit;
 if e.taste<>1 then begin TElement.OnMouseClick(e); exit; end;
 p:=sb^.p; pos:=p.position;
 if groesser then pos:=pos+p.d_klein else pos:=pos-p.d_klein;
 if pos>p.max then pos:=p.max; if pos<p.min then pos:=p.min;
 p.position:=pos;
 sb^.aendernp(p);
end;

procedure TScrollLeiste.OnMouseClick(e: mouseevent);
var p: TPos;
    pos: integer;
begin
 if not aktiv then exit;
 if e.taste<>1 then begin TElement.OnMouseClick(e); exit; end;
 p:=sb^.p; pos:=p.position;
 if groesser then pos:=pos+p.d_gross else pos:=pos-p.d_gross;
 if pos>p.max then pos:=p.max; if pos<p.min then pos:=p.min;
 p.position:=pos;
 sb^.aendernp(p);
end;

procedure TElement.OnMouseDBClick(e: mouseevent);   {Event-Handler}
begin
 {}
end;

procedure TEdit.OnMouseDBClick(e: mouseevent);
begin
 if not aktiv then exit;
 if e.taste<>1 then exit;
 zeichnecursor(false);
 cursorpos:=0; start:=0; markend:=strlen(inhalt);
 zeichne; zeichnecursor(true);
end;

procedure TElement.OnMouseDragStart(e: mouseevent); {Event-Handler}
begin
 e.drag^.art:=none;
 {fÅlle DragInfo aus}
end;

var scrollstartmaus: word;
procedure TScrollSchieber.OnMouseDragStart(e: mouseevent);
begin
 e.drag^.art:=mark;
 if sb^.ausrichtung then scrollstartmaus:=e.x else scrollstartmaus:=e.y;
 e.drag^.objekt:=@scrollstartmaus;
end;
type win_drag_art = (schieb, rechts, unten, links, linksunten, rechtsunten);
type win_drag_inf = record
     breite, hoehe: integer;
     minb, minh: integer;
     case art: win_drag_art of
     schieb: (dx, dy: integer);
     unten,rechts,rechtsunten: (x,y: integer);
     links,linksunten: (xr,yr: integer);
     end;
     PWDI= ^win_drag_inf;

var altrahmen: record
    x1,x2,y1,y2: integer;
    start: boolean;
    end;

procedure TWindow.OnMouseDragStart(e: mouseevent);
var p: PWDI;
    art: win_drag_art;
begin
 e.drag^.art:=none;
 if (e.taste=1) and (e.y-y <= 20) and (x+breite-e.x > 20) then begin
    e.drag^.art:=window;
    art:=schieb;
 end;
 if (e.taste=1) and (abs(e.y-(y+hoehe)) <= 2) then begin
    e.drag^.art:=window;
    art:=unten;
 end;
 if (e.taste=1) and (abs(e.x-x)<=2) then begin
    e.drag^.art:=window;
    if art=unten then art:=linksunten else art:=links;
 end;
 if (e.taste=1) and (abs(e.x-(x+breite))<=2) then begin
    e.drag^.art:=window;
    if art=unten then art:=rechtsunten else art:=rechts;
 end;
 if e.drag^.art<>none then begin
    new(p);
    if art=schieb then begin p^.dx:=e.x-x; p^.dy:=e.y-y; end;
    if (art=unten) or (art=rechts) or (art=rechtsunten) then begin p^.x:=x; p^.y:=y; end;
    if (art=links) or (art=linksunten) then begin p^.xr:=x+breite; p^.yr:=y; end;
    p^.breite:=breite; p^.hoehe:=hoehe;
    p^.minb:=min_b; p^.minh:=min_h;
    p^.art:=art;
    e.drag^.objekt:=p;
    altrahmen.start:=true;
 end;
end;

procedure THintergrund.OnMouseDragStart(e: mouseevent);
begin
 e.drag^.art:=none;
end;

procedure TEdit.OnMouseDragStart(e: mouseevent);
begin
 e.drag^.art:=mark;
 mausmark:=true;
end;

procedure TElement.OnMouseDragTo(e: mouseevent);    {Event-Handler}
begin
 if e.drag^.art=window then begin gethintergrund^.OnMouseDragTo(e); exit; end;
 {reagiere evt. mit Maus (Verbots-Cursor)}
end;

procedure THintergrund.OnMouseDragTo(e: mouseevent);
var p: PWDI;
    xx1,xx2,yy1,yy2: integer;
begin
 if e.drag^.art=window then begin
    setwritemode(XORput);
    setcolor(white);
    mausoff;
    with altrahmen do if not start then rectangle(x1,y1,x2,y2);

    p:=PWDI(e.drag^.objekt);
    case p^.art of
    schieb: begin
      xx1:=e.x-p^.dx; yy1:=e.y-p^.dy;
      xx2:=xx1+p^.breite; yy2:=yy1+p^.hoehe; end;
    unten: begin
      p^.hoehe:=e.y-p^.y; if p^.hoehe<p^.minh then p^.hoehe:=p^.minh;
      xx1:=p^.x; yy1:=p^.y;
      xx2:=xx1+p^.breite; yy2:=yy1+p^.hoehe; end;
    rechts: begin
      p^.breite:=e.x-p^.x; if p^.breite<p^.minb then p^.breite:=p^.minb;
      xx1:=p^.x; yy1:=p^.y;
      xx2:=xx1+p^.breite; yy2:=yy1+p^.hoehe; end;
    links: begin
      p^.breite:=p^.xr-e.x; if p^.breite<p^.minb then p^.breite:=p^.minb;
      xx1:=p^.xr-p^.breite; yy1:=p^.yr;
      xx2:=p^.xr; yy2:=yy1+p^.hoehe; end;
    rechtsunten: begin
      p^.breite:=e.x-p^.x; if p^.breite<p^.minb then p^.breite:=p^.minb;
      p^.hoehe:=e.y-p^.y; if p^.hoehe<p^.minh then p^.hoehe:=p^.minh;
      xx1:=p^.x; yy1:=p^.y;
      xx2:=xx1+p^.breite; yy2:=yy1+p^.hoehe; end;
    linksunten: begin
      p^.hoehe:=e.y-p^.yr; if p^.hoehe<p^.minh then p^.hoehe:=p^.minh;
      p^.breite:=p^.xr-e.x; if p^.breite<p^.minb then p^.breite:=p^.minb;
      xx1:=p^.xr-p^.breite; yy1:=p^.yr;
      xx2:=p^.xr; yy2:=yy1+p^.hoehe; end;
    end;

    rectangle(xx1,yy1,xx2,yy2);
    with altrahmen do begin
     x1:=xx1; y1:=yy1; x2:=xx2; y2:=yy2;
     start:=false;
    end;
    mauson;
    setwritemode(NORMALput);
    exit;
 end;
end;

procedure TEdit.OnMouseDragTo(e: mouseevent);
var c: char;
    gefunden: boolean;
begin
 if e.drag^.art<>mark then begin inherited OnMouseDragTo(e); exit; end;
 zeichnecursor(false);
 if abs_x+5>=e.x then begin if start>0 then dec(start); end
 else if abs_x+breite-2<=e.x then begin
      if textwidth(strpas(inhalt+start)) > breite-7 then inc(start); end
 else begin
 gefunden:=false;
 cursorpos:=start;
 repeat
   c:=(inhalt+cursorpos)[0]; (inhalt+cursorpos)[0]:=#0;
   gefunden:=(textwidth(strpas(inhalt+start))+abs_x+5>=e.x);
   (inhalt+cursorpos)[0]:=c;
   if not gefunden then inc(cursorpos);
   if cursorpos=strlen(inhalt) then gefunden:=true;
 until gefunden;
 end;
 zeichne;
 zeichnecursor(true);
end;

procedure TScrollSchieber.OnMouseDragTo(e: mouseevent);
var lges, l, d: integer;
    pp: TPos;
begin
 if e.drag^.art = mark then begin
{    d:=word(e.drag^.objekt^); if sb^.ausrichtung then d:=e.x-d else d:=e.y-d;
    if sb^.ausrichtung then word(e.drag^.objekt^):=e.x else word(e.drag^.objekt^):=e.y;
    if sb^.ausrichtung then lges:=sb^.breite-sb^.sb1^.breite-sb^.sb2^.breite
                       else lges:=sb^.hoehe-sb^.sb1^.hoehe+sb^.sb2^.hoehe;
    l:= round(lges * (sb^.p.d_gross/(sb^.p.max-p.min)));
    if l<4 then l:=4; if l>lges then l:=lges;

    pp:=sb^.p;
    pp.position:=pp.position+round((pp.max-pp.min)/(lges-l)*d);
    if pp.position<pp.min then pp.position:=pp.min; if pp.position>pp.max then pp.position:=pp.max;
    sb^.ochandle:=false;
    sb^.aendernp(pp);
    sb^.ochandle:=true;
} end
 else
  TElement.OnMouseDragTo(e);
end;

procedure TElement.OnMouseDragDrop(e: mouseevent);  {Event-Handler}
begin
 if e.drag^.art in [window] then
    e.drag^.accept:=true
 else
    e.drag^.accept:=false;
 {akzeptieren?, Datenempfang}
end;

procedure TEdit.OnMouseDragDrop(e: mouseevent);
begin
 if e.drag^.art = mark then begin
    mausmark:=false;
 end
 else
  TElement.OnMouseDragDrop(e);
end;

procedure TScrollSchieber.OnMouseDragDrop(e: mouseevent);
var lges, l, d: integer;
    pp: TPos;
begin
 if e.drag^.art = mark then begin
    pp:=sb^.p;
    d:=word(e.drag^.objekt^); if sb^.ausrichtung then d:=e.x-d else d:=e.y-d;
    if sb^.ausrichtung then lges:=sb^.breite-sb^.sb1^.breite-sb^.sb2^.breite
                       else lges:=sb^.hoehe-sb^.sb1^.hoehe+sb^.sb2^.hoehe;
    l:= round(lges * (pp.d_gross/(pp.max-pp.min+pp.d_gross)));
    if l<4 then l:=4; if l>lges then l:=lges;

    pp.position:=pp.position+round((pp.max-pp.min)/(lges-l)*d);
    if pp.position<pp.min then pp.position:=pp.min; if pp.position>pp.max then pp.position:=pp.max;
    sb^.aendernp(pp);
 end
 else
  TElement.OnMouseDragDrop(e);
end;

procedure TElement.OnMouseDragStop(e: mouseevent);  {Event-Handler}
begin
 {falls akzeptiert, schicke Daten}
end;

procedure TWindow.OnMouseDragStop(e: mouseevent);
var p: PWDI;
begin
 if (e.drag^.art=window) and e.drag^.accept then begin
    p:=PWDI(e.drag^.objekt);
    case p^.art of
    schieb: begin
      aendernx(e.x-p^.dx);
      aenderny(e.y-p^.dy); end;
    unten: begin
      aendernh(p^.hoehe); end;
    rechts: begin
      aendernb(p^.breite); end;
    links: begin
      aendernx(p^.xr-p^.breite);
      aendernb(p^.breite); end;
    rechtsunten: begin
      aendernb(p^.breite);
      aendernh(p^.hoehe); end;
    linksunten: begin
      aendernx(p^.xr-p^.breite);
      aendernb(p^.breite);
      aendernh(p^.hoehe); end;
    end;
    dispose(p);
 end;
end;


{TASTATUR}

procedure TElement.OnKeyASCII(e: keyevent);
begin
 fenster^.OnKeyASCII(e);
end;

procedure TElement.OnKeySPEC(e: keyevent);
begin
 fenster^.OnKeySPEC(e);
end;

procedure TElement.OnKeyDown(e: keyevent);
var e_m: mouseevent;
begin
if e.shift and 255 = 0 then
case e.nr of
 57{' '}: begin
       e_m.x:=x+breite div 2; e_m.y:=y+hoehe div 2;
       e_m.taste:=1;
       e_m.shift:={e.shift}0;
       e_m.aktion:=mousedown;
       e_m.drag:=nil;
       OnMouseDown(e_m);
       exit;
       end;
end;
fenster^.OnKeyDown(e);
end;

procedure TElement.OnKeyUp(e: keyevent);
var e_m: mouseevent;
begin
if e.shift and 255 = 0 then
case e.nr of
 57{' '}: begin
       e_m.x:=x+breite div 2; e_m.y:=y+hoehe div 2;
       e_m.taste:=1;
       e_m.shift:={e.shift}0;
       e_m.aktion:=mouseup;
       e_m.drag:=nil;
       OnMouseUp(e_m);
       e_m.aktion:=mouseclick;
       OnMouseClick(e_m);
       exit;
       end;
end;
fenster^.OnKeyUp(e);
end;

procedure TWindow.OnKeySPEC(e: keyevent);
var naechster: PDiaVer;
begin
   case e.nr of
        VK_TAB: begin if gross(e.shift) and Shift > 0 then begin
                         acceptkey^.el^.OnLoseFocus;
                         weiter_t(false);
                         acceptkey^.el^.OnGetFocus;
                      end else begin
                         acceptkey^.el^.OnLoseFocus;
                         weiter_t(true);
                         acceptkey^.el^.OnGetFocus;
                      end;
                      exit;
                end;
        VK_F4: if strgalt(e.shift) and Alt > 0 then begin
                  finden_verw(fenster)^.schliessen; exit; end;
   end;

naechster:=finden_verw(fenster)^.vorfahre;
if naechster<>nil then naechster^.dia^.OnKeySPEC(e) else gethintergrund^.OnKeySPEC(e);
end;

procedure TWindow.OnKeyASCII(e: keyevent);
var naechster: PDiaVer;
begin
naechster:=finden_verw(fenster)^.vorfahre;
if naechster<>nil then naechster^.dia^.OnKeyASCII(e) else gethintergrund^.OnKeyASCII(e);
end;

procedure TWindow.OnKeyDown(e: keyevent);
var naechster: PDiaVer;
begin
naechster:=finden_verw(fenster)^.vorfahre;
if naechster<>nil then naechster^.dia^.OnKeyDown(e) else gethintergrund^.OnKeyDown(e);
end;

procedure TWindow.OnKeyUp(e: keyevent);
var naechster: PDiaVer;
begin
naechster:=finden_verw(fenster)^.vorfahre;
if naechster<>nil then naechster^.dia^.OnKeyUp(e) else gethintergrund^.OnKeyUp(e);
end;

procedure THintergrund.OnKeySPEC(e: keyevent);
begin
end;

procedure THintergrund.OnKeyASCII(e: keyevent);
begin
end;

procedure THintergrund.OnKeyDown(e: keyevent);
begin
end;

procedure THintergrund.OnKeyUp(e: keyevent);
begin
end;

procedure TEdit.OnKeySpec(e: keyevent);
var p1,p2: word;
    c: char;
begin
zeichnecursor(false);
case e.nr of
  VK_LEFT: if cursorpos>0 then dec(cursorpos);
  VK_RIGHT: if cursorpos<strlen(inhalt) then inc(cursorpos);
  VK_POS1: cursorpos:=0;
  VK_ENDE: cursorpos:=strlen(inhalt);

  VK_BS: if cursorpos<>markend then begin
            if cursorpos>markend then begin p2:=cursorpos; p1:=markend; end
                                 else begin p1:=cursorpos; p2:=markend; end;
            (inhalt+p1)[0]:=#0;
            cursorpos:=p1; markend:=cursorpos;
            aenderni(strcat(inhalt,inhalt+p2));
         end else
         if cursorpos>0 then begin
            dec(cursorpos);
            (inhalt+cursorpos)[0]:=#0;
            aenderni(strcat(inhalt,inhalt+cursorpos+1));
         end;
  VK_ENTF: if cursorpos<>markend then begin
            if cursorpos>markend then begin p2:=cursorpos; p1:=markend; end
                                 else begin p1:=cursorpos; p2:=markend; end;
            (inhalt+p1)[0]:=#0;
            cursorpos:=p1; markend:=cursorpos;
            aenderni(strcat(inhalt,inhalt+p2));
         end else
         if cursorpos<strlen(inhalt) then begin
            (inhalt+cursorpos)[0]:=#0;
            aenderni(strcat(inhalt,inhalt+cursorpos+1));
         end;

  else zeichnecursor(true); inherited OnKeySpec(e); exit;
end;
if (gross(e.shift) and Shift) = 0 then markend:=cursorpos;

if cursorpos<start then start:=cursorpos;
c:=(inhalt+cursorpos)[0]; (inhalt+cursorpos)[0]:=#0;
if textwidth(strpas(inhalt+start))>=breite-6 then begin
   start:=cursorpos;
   while (start>0) and (textwidth(strpas(inhalt+start))<breite-6) do dec(start);
   if textwidth(strpas(inhalt+start))>=breite-6 then inc(start);
end;
(inhalt+cursorpos)[0]:=c;

zeichne;
zeichnecursor(true);
end;

procedure TEdit.OnKeyASCII(e: keyevent);
var p: pchar;
    p1,p2: word;
    l: word;
    c: char;
begin
zeichnecursor(false);
if cursorpos>markend then begin p2:=cursorpos; p1:=markend; end
                     else begin p1:=cursorpos; p2:=markend; end;
l:=strlen(inhalt)+2;
getmem(p,l);
strpcopy(p,chr(e.nr));
strcat(p,inhalt+p2);
(inhalt+p1)[0]:=#0;
{"p:=inhalt+p"}
strmove(p+strlen(inhalt),p,l-strlen(inhalt));
strmove(p,inhalt,strlen(inhalt));
cursorpos:=p1+1; markend:=cursorpos;
aenderni(p);
freemem(p,l);

if cursorpos<start then start:=cursorpos;
c:=(inhalt+cursorpos)[0]; (inhalt+cursorpos)[0]:=#0;
if textwidth(strpas(inhalt+start))>=breite-6 then begin
   start:=cursorpos;
   while (start>0) and (textwidth(strpas(inhalt+start))<breite-6) do dec(start);
   if textwidth(strpas(inhalt+start))>=breite-6 then inc(start);
end;
(inhalt+cursorpos)[0]:=c;

zeichnecursor(true);
zeichne;
end;

{SONSTIGES}

procedure TElement.OnGetFocus;
begin
 gewaehlt:=true;
end;

procedure TElement.OnLoseFocus;
begin
 gewaehlt:=false;
end;

procedure TWindow.OnGetFocus;
begin
 aktiv:=true;
 if acceptkey<>nil then acceptkey^.el^.OnGetFocus;
end;

procedure TWindow.OnLoseFocus;
begin
 aktiv:=false;
 if acceptkey<>nil then acceptkey^.el^.OnLoseFocus;
end;

procedure TEdit.OnGetFocus;
begin
 inherited OnGetFocus;
 edit_cursor(selbst);
end;

procedure TEdit.OnLoseFocus;
begin
 inherited OnLoseFocus;
 edit_cursor(nil);
end;