unit win_more;
interface
uses win, stringli, events, kevents;
type TForm = object (TWindow)
     scrollfeld: TScrollfeld;
     constructor init(r: TRechteck; eb,eh: integer; i: pchar; var f: PWindow);
     destructor fertig;
     end;

type TListBox = object (TElement)
     list: TStringList;
     selection: TStringList;
     start: word;
     last_index, alter_index: word; {letzter Eintrag, der mit Maus in Berhrung kam}
     constructor init(r: TRechteck; i: string; f: PWindow);
     procedure zeichne_(xx,yy:integer); virtual;
     procedure select(nr: byte; anaus: boolean);
     procedure selectall(anaus: boolean);

     procedure OnMouseDown(e: mouseevent); virtual;
     procedure OnKeySPEC(e: keyevent); virtual;

     destructor fertig;
     end;

implementation
uses graph, strings;

constructor TForm.init;
begin
inherited init(r,i,f);
r.x:=2; r.y:=22; r.b:=r.b-4; r.h:=r.h-24;
scrollfeld.init(r,eb,eh,f);
align:=@scrollfeld;
if breite>20+textwidth(strpas(i)) then min_b:=20+textwidth(strpas(i));
if hoehe>80 then min_h:=80;
scrollfeld.einordnen(e_m); scrollfeld.einordnen(e_z);
end;

destructor TForm.fertig;
begin
scrollfeld.fertig;
inherited fertig;
end;

constructor TListBox.init;
var j: byte;
begin
 inherited init(r,'',f);
 start:=0; last_index:=0; alter_index:=0;
 list.init;
 j:=pos(#0,i);
 while j<>1 do begin
       list.add(copy(i,1,j-1));
       delete(i,1,j);
       j:=pos(#0,i);
 end;
 selection.init;
 for j:=1 to list.anzahl do selection.add('');
end;

procedure TListBox.zeichne_;
var j: byte;
    h: integer;
    text: string;
begin
 zeichne3D(xx,yy,breite,hoehe,white,true);
 h:=yy+1;
 setfillstyle(solidfill,blue);
 for j:=start to list.anzahl-1 do begin
     text:=strpas(list.get(j));
     if selection.get(j)<>nil then begin
        bar(xx+2,h+1,xx+breite-3,h+textheight('|')+3);
        setcolor(white);
     end else
        setcolor(black);
     outtextxy(xx+4,h+1,text);
     h:=h+2+textheight('|');
 end;
end;

procedure TListBox.select;
begin
 if anaus then
    selection.setzen(nr,list.get(nr))
 else
    selection.setzen(nr,nil);
 kleineAenderung;
end;

procedure TListBox.selectall;
var nr: word;
begin
for nr:=0 to list.anzahl-1 do
 if anaus then
    selection.setzen(nr,list.get(nr))
 else
    selection.setzen(nr,nil);
 kleineAenderung;
end;

procedure TListBox.OnMouseDown;
var nr, j: word;
begin
 if not aktiv then exit;
 inherited OnMouseDown(e);
 if e.taste<>1 then exit;
 nr:=start + (e.y-abs_y-2) div (2+textheight('|'));
 if nr>=list.anzahl then exit;
 if strg and strgalt(e.shift) = 0 then begin
    if shift and gross(e.shift) = 0 then begin {ohne -> nur dieses markieren}
       selectall(false); select(nr, true);
       alter_index:=nr;
    end else begin {Shift -> aufeinanderfolgende markieren/demarkieren}
       selectall(false);
       if alter_index<=nr then
          for j:=alter_index to nr do select(j, true)
       else
          for j:=nr to alter_index do select(j, true);
    end;
 end else begin
    if shift and gross(e.shift) = 0 then begin {Strg -> markieren/demarkieren}
       select(nr, selection.get(nr)=nil);
       alter_index:=nr;
    end else begin {Strg + Shift -> aufeinanderfolgende markieren}
       if last_index<=nr then
          for j:=last_index to nr do select(j, true)
       else
          for j:=nr to last_index do select(j, true);
     end;
 end;
 last_index:=nr;
end;

procedure TListBox.OnKeySPEC;
begin
 case e.nr of
 VK_UP: if last_index <> 0 then begin
           if gross(e.shift) and shift = 0 then begin
              selectall(false); dec(last_index); alter_index:=last_index;
              select(last_index, true);
           end else begin
               if alter_index>=last_index then
                  select(last_index-1, true)
               else
                  select(last_index, false);
               dec(last_index);
           end;
        end else begin
           selectall(false); select(last_index, true); alter_index:=last_index;
        end;
 VK_DOWN: if last_index <> list.anzahl-1 then begin
           if gross(e.shift) and shift = 0 then begin
              selectall(false); inc(last_index); alter_index:=last_index;
              select(last_index, true);
           end else begin
               if alter_index<=last_index then
                  select(last_index+1, true)
               else
                  select(last_index, false);
               inc(last_index);
           end;
        end else begin
           selectall(false); select(last_index, true); alter_index:=last_index;
        end;
 else inherited OnKeySPEC(e);
 end;
end;

destructor TListBox.fertig;
begin
 list.fertig;
 selection.fertig;
 inherited fertig;
end;

end.