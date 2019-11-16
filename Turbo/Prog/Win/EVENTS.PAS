unit events;
   {(*$DEFINE events_test*){}
{  ^ diese Klammer ({) zum Testen entfernen}
interface
const _STAYTIME=200;
      _DBCLICKTIME=40;
      _DBDIFF=5;
type mouseaktion = (nothing,    {kein Event}
                    mousestay,  {lÑnger als _STAYTIME hsek auf (x,y)}
                    stayend,    {Maus nach mousestay wieder bewegt}
                    moveto,     {zu (x,y) bewegt}
{von Event-Ver-   } mouseenter, {Maus tritt in neues Objekt ein}
{ teiler eingefÅgt} mouseleave, {Maus verlÑsst Objekt}
                    mousedown,  {Taste gedrÅckt (x,y,taste,shift)}
                    mouseup,    {Taste losgelassen (x,y) (an down-Objekt)}

{von Event-Ver-   } mouseclick, {geklickt (x,y,taste,shift)
                                (up und down auf selben Objekt)}
{ teiler eingefÅgt} dbclick,    { 2ter click innerhalb von _DBCLICKTIME hsek
                                auf fast (_DBDIFF) gleicher Stelle
                                (x,y,taste,shift)}

{Draginfo  erst   } dragstart,  {beginnt zu ziehen
 nachtrÑglich                   (x,y,taste,shift) -> draginfo}
                    dragto,     {ziehen (x,y,taste,draginfo)}
{annehmen in      } dragdrop,   {loslassen (x,y,taste,shift,draginfo)
 Draginfo schreiben             -> annehmen?
                                (an Objekt, auf dem ziehen endet)}
                    dragstop);  {losgelassen
                                (x,y,taste,shift,draginfo,angenommen?)
                                an Objekt, auf dem ziehen begonnen}

type draginfo= record
     art: (none, window, dragfile, other, mark, down);
          {nichts,       Datei,    anderes (Symbol, Zeichnung, Text, ...)
                 Fenster,                 Markieren
                                                beim Verlassen erhÑlt altes
                 Objekt mouseup (ohne mouseclick) und neues Objekt mousedown}
     objekt: pointer;
     accept: boolean;
     end;

type PDraginfo=^draginfo;

type mouseevent= record
     x,y: integer;
     taste: byte;
     shift: word;
     aktion: mouseaktion;
     drag: Pdraginfo;
     end;
type Pmouseevent= ^mouseevent;


procedure m_events;

var tatsaechliches_element: pointer{PElement}; {Element, das Event empfangen hat}

implementation
uses maus, zeit, kevents,{$IFDEF events_test}graph,{$ELSE} crt, win, winverw{$ENDIF};
var altx, alty: integer;
    alttaste: byte;
    altdraginfo: Pdraginfo;
    altaktion, aktionvorstay: mouseaktion;
    (*altzeit_stay, in KEVENTS*)
    altzeit_dbclick: longint;
    altlastclickx, lastclickx, altlastclicky, lastclicky: integer;
    lastobject, dragobject: {$IFDEF events_test}pointer{$ELSE}PElement{$ENDIF};
                             {fÅr mousedown, ...; drag}
    start: boolean;
    event_status: byte;

type Prawevent= ^rawevent;
     rawevent= record
     x,y: integer;
     taste: byte;
     shift: word;
     zeit: longint;
     next: Prawevent;
     end;

type PQEvent= ^QEvent;
     QEvent= record
     e: mouseevent;
     next: PQEvent;
     end;

var rawevents, lastrawevent: Prawevent;
    allevents, lastevent: PQEvent;

procedure getrawevent;
var x,y,t: integer;
    s: word;
    z: longint;
    p: Prawevent;
begin
 t:=mausget(x,y);     {Daten holen}
 z:=timer;
 s:=getshift;

 if start then begin
    altx:=x; alty:=y; alttaste:=t; altzeit_stay:=z; altzeit_dbclick:=z;
    altaktion:=moveto;
{$IFDEF events_test}graph.moveto(x,y);{$ENDIF}
    start:=false;
 end;
 new(p);
 p^.x:=x; p^.y:=y; p^.taste:=t; p^.shift:=s; p^.zeit:=z; p^.next:=nil;
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
var x,y: integer;
    t: byte;
    s: word;
    z: longint;
    alt: Prawevent;
    e: PQEvent;
begin
 if rawevents=nil then exit;
 x:= rawevents^.x;
 y:= rawevents^.y;
 t:= rawevents^.taste;
 s:= rawevents^.shift;
 z:= rawevents^.zeit;
 alt:= rawevents;
 rawevents:=rawevents^.next;
 if rawevents = nil then lastrawevent:=nil;
 dispose(alt);                              {Daten holen}

 if (x=altx) and (y=alty) and (t=alttaste) then          {keine VerÑnderung}
    if (z-altzeit_stay >= _STAYTIME) and (altaktion<>mousestay) then begin
       new(e);                                           {mousestay}
       e^.e.x:=x; e^.e.y:=y; e^.e.taste:=t; e^.e.aktion:=mousestay;
       aktionvorstay:=altaktion;
       altaktion:=mousestay;
       einreihen(e);
       stay_ist_an:=true;                    {fÅr Tastatur signalisieren}
       exit;
    end else begin
       exit;
    end;

 altzeit_stay:=z;                            {neue Zeit der letzten énderung}
 if altaktion=mousestay then begin
    new(e);
    e^.e.x:=altx; e^.e.y:=alty; e^.e.taste:=alttaste; e^.e.shift:=s; e^.e.aktion:=stayend;
    einreihen(e);
    stay_ist_an:=false;           {fÅr Tastatur}
    altaktion:=aktionvorstay;
 end;
 altx:=x; alty:=y;

 if t=alttaste then begin                {keine VerÑnderung der Taste}
  case altaktion of
   moveto, mouseup, dragstop:
              begin
                new(e);
                e^.e.x:=x; e^.e.y:=y; e^.e.taste:=t{=0}; e^.e.shift:=s;
                e^.e.aktion:=moveto; altaktion:=moveto;
                einreihen(e);
              end;                             {bewegen der Maus}
   mousedown: begin
                new(e);
                e^.e.x:=x; e^.e.y:=y; e^.e.taste:=t; e^.e.shift:=s;
                e^.e.drag:=altdraginfo;
                e^.e.aktion:=dragstart;
                einreihen(e);
                new(e);
                e^.e.x:=x; e^.e.y:=y; e^.e.taste:=t; e^.e.shift:=s;
                e^.e.drag:=altdraginfo;
                e^.e.aktion:=dragto; altaktion:=dragto;
                einreihen(e);
              end;                             {Beginn des Ziehens}
   dragto: begin
             new(e);
             e^.e.x:=x; e^.e.y:=y; e^.e.taste:=t; e^.e.shift:=s;
             e^.e.drag:=altdraginfo;
             e^.e.aktion:=dragto; altaktion:=dragto;
             einreihen(e);
           end;                                {ziehen}
  end;
  alttaste:=t;
  exit;
 end;
 {Taste wurde verÑndert}
 if alttaste=0 then begin {Taste wurde gedrÅckt}
    new(e);
    e^.e.x:=x; e^.e.y:=y; e^.e.taste:=t; e^.e.shift:=s;
    e^.e.aktion:=mousedown; altaktion:=mousedown;
    einreihen(e);
    alttaste:=t;
    exit;
 end;

 if t=0 then begin {Taste wurde losgelassen}
    case altaktion of
    dragto: begin {Ziehen beendet}
             new(e);
             e^.e.x:=x; e^.e.y:=y; e^.e.taste:=alttaste; e^.e.shift:=s;
             e^.e.drag:=altdraginfo;
             e^.e.aktion:=dragdrop;
             einreihen(e);
             new(e);
             e^.e.x:=x; e^.e.y:=y; e^.e.taste:=alttaste; e^.e.shift:=s;
             e^.e.drag:=altdraginfo;
             e^.e.aktion:=dragstop; altaktion:=dragstop;
             einreihen(e);
            end;
    mousedown: begin  {Taste losgelassen}
                new(e);
                e^.e.x:=x; e^.e.y:=y; e^.e.taste:=alttaste; e^.e.shift:=s;
                e^.e.aktion:=mouseup; altaktion:=mouseup;
                einreihen(e);
                if z-altzeit_dbclick<=_DBCLICKTIME then begin
                   new(e);
                   e^.e.x:=x; e^.e.y:=y; e^.e.taste:=alttaste; e^.e.shift:=s;
                   e^.e.aktion:=dbclick;
                   einreihen(e);
                end; {mîglicherwei·e ein Doppelklick}
                altzeit_dbclick:=z;
               end;
    end;
    alttaste:=t;
    exit;
 end;
end;

function getobject(x,y: integer): {$IFDEF events_test}pointer{$ELSE}PElement{$ENDIF};
{$IFNDEF events_test}
var fenster: PWindow;
    objekt: PElement;
{$ENDIF}
begin
{$IFDEF events_test}
if (x>100) or (y>100) then getobject:=nil else getobject:=altdraginfo;
{$ELSE}
 fenster:=findew_m(x,y);
 if fenster=nil then
    objekt:=gethintergrund
 else
    objekt:=fenster^.finden_m(x,y);
 if objekt=nil then objekt:=fenster;
 getobject:=objekt;
{$ENDIF}
end;

{$IFDEF events_test}
procedure handle1(e: mouseevent);
var x,y: integer;
begin
 x:=e.x; y:=e.y;
 if e.aktion=dragstart then e.drag^.art:=other;
 if not(e.aktion in [stayend, mousedown, mouseup, dragstart, dragdrop, dragstop]) then
  mausoff;
 case e.aktion of
 mousestay: begin setcolor(red); circle(x,y,2); end;
 stayend: begin sound(55); delay(100); nosound; end;
 moveto: begin setcolor(white); lineto(x,y); end;
 mouseleave: begin setcolor(black); circle(getmaxx-5,5,2); graph.moveto(x,y); end;
 mouseenter: begin setcolor(blue); circle(getmaxx-5,5,2); graph.moveto(x,y); end;
 mousedown: begin sound(440); delay(100); nosound; end;
 mouseup: begin sound(880); delay(100); nosound; end;
 mouseclick: begin setcolor(blue); circle(x,y,3); end;
 dbclick: begin setcolor(green); circle(x,y,4); end;
 dragstart: begin sound(220); delay(100); nosound; end;
 dragto: begin setcolor(red); lineto(x,y); end;
 dragdrop: begin sound(110); delay(100); nosound; end;
 dragstop: begin sound(1760); delay(100); nosound; end;
 end;
 if not(e.aktion in [stayend, mousedown, mouseup, dragstart, dragdrop, dragstop]) then
  mauson;
end;

procedure handle2(e: mouseevent);
var x,y: integer;
begin
 x:=e.x; y:=e.y;
 if e.aktion=dragstart then e.drag^.art:=down;
 if not(e.aktion in [stayend, mousedown, mouseup, dragstart, dragdrop, dragstop]) then
  mausoff;
 case e.aktion of
 mousestay: begin setcolor(blue); circle(x,y,2); end;
 stayend: begin sound(55); delay(100); nosound; end;
 moveto: begin graph.moveto(x,y); end;
 mouseleave: begin setcolor(black); circle(5,5,2); graph.moveto(x,y); end;
 mouseenter: begin setcolor(blue); circle(5,5,2); graph.moveto(x,y); end;
 mousedown: begin sound(440); delay(100); nosound; end;
 mouseup: begin sound(880); delay(100); nosound; end;
 mouseclick: begin setcolor(blue); circle(x,y,3); end;
 dbclick: begin clearviewport; setcolor(lightgray); rectangle(0,0,100,100); end;
 dragstart: begin sound(220); delay(100); nosound; end;
 dragto: begin setcolor(red); lineto(x,y); end;
 dragdrop: begin sound(110); delay(100); nosound; end;
 dragstop: begin sound(1760); delay(100); nosound; end;
 end;
 if not(e.aktion in [stayend, mousedown, mouseup, dragstart, dragdrop, dragstop]) then
  mauson;
end;
{$ENDIF}


procedure send(e: mouseevent; var o: {$IFDEF events_test}pointer{$ELSE}PElement{$ENDIF});
begin
{$IFDEF events_test}
 if o=nil then handle1(e) else handle2(e);
{$ELSE}
 if o=nil then exit;
 tatsaechliches_element:=o;
 case e.aktion of
  mousestay:  o^.OnMouseStay(e);
  stayend:    o^.OnMouseStayEnd(e);
  moveto:     o^.OnMouseMoveTo(e);
  mouseleave: o^.OnMouseLeave(e);
  mouseenter: o^.OnMouseEnter(e);
  mousedown:  o^.OnMouseDown(e);
  mouseup:    o^.OnMouseUp(e);
  mouseclick: o^.OnMouseClick(e);
  dbclick:    o^.OnMouseDBClick(e);
  dragstart:  o^.OnMouseDragStart(e);
  dragto:     o^.OnMouseDragTo(e);
  dragdrop:   o^.OnMouseDragDrop(e);
  dragstop:   o^.OnMouseDragStop(e);
 end;
 {evt. irgendwie o auf tatsÑchlichen Wert setzen}
 o:=tatsaechliches_element;
{$ENDIF}
end;

procedure makemouseevent;
var e: mouseevent;
    alt: PQEvent;
    neuo: {$IFDEF events_test}pointer{$ELSE}PElement{$ENDIF};
begin
 if allevents=nil then exit;
 e:= allevents^.e;
 alt:= allevents;
 allevents:=allevents^.next;
 if allevents = nil then lastevent:=nil;
 dispose(alt);                              {Daten holen}

 neuo:=getobject(e.x,e.y);                  {Objekt, Åber dem die Maus steht}

 case e.aktion of
 mousestay: begin
              send(e, neuo); lastobject:=neuo; {neues O. erhÑlt Nachricht,
                                                wird gespeichert}
            end;
 stayend:   begin
              send(e, lastobject);             {altes O. erhÑlt Nachricht}
            end;
 moveto:    begin
              if lastobject<>neuo then begin   {bei Wechsel leave und enter}
                 e.aktion:=mouseleave;
                 send(e, lastobject);
                 e.aktion:=mouseenter;
                 send(e, neuo);
                 e.aktion:=moveto;
                 lastobject:=neuo;
              end;
              send(e, neuo);                   {neues O. erhÑlt Nachricht}
            end;
 mousedown: begin
              send(e, neuo); lastobject:=neuo; {neues O. erhÑlt Nachricht,
                                                wird gespeichert}
            end;
 mouseup:   begin
              send(e, lastobject);             {altes O. erhÑlt Nachricht}
              if neuo=lastobject then begin    {wenn Down und Up auf selben O.}
                 e.aktion:=mouseclick;         {MouseClick}
                 send(e, lastobject);          {an altes O. senden}
                 altlastclickx:=lastclickx; altlastclicky:=lastclicky;
                 lastclickx:=e.x; lastclicky:=e.y;  {Klick-Koordinaten fÅr
                                                  Doppelklick aktualisieren}
              end else                         {kein Klick =>}
                  if (allevents<>nil) and (allevents^.e.aktion=dbclick) then begin
                     alt:=allevents; allevents:=allevents^.next;
                     if allevents = nil then lastevent:=nil;
                     dispose(alt);              {evt. DBClick lîschen}
                  end;
            end;
 dbclick:   begin
              if (abs(altlastclickx-e.x)<=_DBDIFF) and (abs(altlastclicky-e.y)<=_DBDIFF) and (neuo=lastobject) then
                  send(e, lastobject);          {wenn Maus nur wenig bewegt
                                                 an altes O. senden}
            end;
 dragstart: begin
              send(e, neuo); dragobject:=neuo;  {neues O. erhÑlt Nachricht,
                                                 wird gespeichert}
              lastobject:=neuo;
            end;
 dragto: begin
         if (lastobject<>neuo) and (e.drag^.art<>down) then begin
                               {bei Wechsel leave und enter (down machtÔs selber)}
            if (e.drag^.art=none) and (lastobject=dragobject) then begin
               e.aktion:=mouseup; send(e, dragobject);
            end;
            e.aktion:=mouseleave;
            send(e, lastobject);
            e.aktion:=mouseenter;
            send(e, neuo);
            if (e.drag^.art=none) and (neuo=dragobject) then begin
               e.aktion:=mousedown; send(e, dragobject);
            end;
            lastobject:=neuo;
            e.aktion:=dragto;
         end;
           case e.drag^.art of
           none: begin
                   e.aktion:=moveto;            {als Bewegen an neues O.}
                   send(e, neuo);
                 end;
           window, dragfile, other: begin send(e, neuo); end;
                                                {an neues O.}
           mark: begin send(e, dragobject); end;{an altes O.}
           down: begin
                   if neuo<>lastobject then begin  {bei O.-Wechsel}
                      e.aktion:=mouseup;        {Up an altes, Down an neues O.}
                      send(e,lastobject);
                      e.aktion:=mouseleave;
                      send(e,lastobject);
                      e.aktion:=mouseenter;
                      send(e,neuo);
                      e.aktion:=mousedown;
                      send(e,neuo);
                      lastobject:=neuo;         {neues O. speichern}
                   end else begin               {selbes O.}
                      e.aktion:=moveto;         {Ziehen senden}
                      send(e, neuo);
                   end;
                 end;
           end;
         end;
 dragdrop: begin
             case e.drag^.art of
             none: begin
                     if neuo=dragobject then begin
                        e.aktion:=mouseup;        {evt. Up senden (wenn nicht
                                                   schon bei dragto)}
                        send(e, dragobject);
                        e.aktion:=mouseclick;  {evt. Click senden}
                        send(e, dragobject);
                     end;
                     if (allevents<>nil) and (allevents^.e.aktion=dragstop) then begin
                        alt:=allevents; allevents:=allevents^.next;
                        if allevents = nil then lastevent:=nil;
                        dispose(alt);          {evt. DragStop lîschen}
                     end;
                   end;
             window, dragfile, other: begin send(e, neuo); end; {senden}
             mark: begin
                     send(e, dragobject);   {senden u. evt. DragStop lîschen}
                     if (allevents<>nil) and (allevents^.e.aktion=dragstop) then begin
                        alt:=allevents; allevents:=allevents^.next;
                        if allevents = nil then lastevent:=nil;
                        dispose(alt);
                     end;
                   end;
             down: begin
                     e.aktion:=mouseup;     {Up und Click an altes O.}
                     send(e, lastobject);
                     e.aktion:=mouseclick;
                     send(e, lastobject);
                     if (allevents<>nil) and (allevents^.e.aktion=dragstop) then begin
                        alt:=allevents; allevents:=allevents^.next;
                        if allevents = nil then lastevent:=nil;
                        dispose(alt);      {evt. DragStop lîschen}
                     end;
                   end;
             end;
           end;
 dragstop: begin
             send(e, dragobject);          {an altes O. senden}
           end;
 end;
end;

procedure m_events;
var e: PQEvent;
begin
  if stay_soll_aus then begin
    new(e);
    e^.e.x:=altx; e^.e.y:=alty; e^.e.taste:=alttaste; e^.e.shift:=getshift; e^.e.aktion:=stayend;
    einreihen(e);
    stay_soll_aus:=false;
    stay_ist_an:=false;           {fÅr Tastatur}
    altaktion:=aktionvorstay;
    makemouseevent; exit;
  end;
  case event_status of
  0: getrawevent;
  1: getevent;
  2: getrawevent;
  3: makemouseevent;
  4: getevent;
  5: getrawevent;
  6: makemouseevent;
  7: getevent;
  end;
  event_status:=(event_status+1) mod 8;
end;

begin
 rawevents:=nil; lastrawevent:=nil;
 allevents:=nil; lastevent:=nil;
 lastobject:=nil; dragobject:=nil;
 new(altdraginfo);
 start:=true;
 event_status:=0;
end.