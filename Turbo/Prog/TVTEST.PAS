program tv;
uses app, drivers, crt;
var anwendung: TApplication;
    event: TEvent;
begin
anwendung.init;
initevents;
showmouse;
repeat
getmouseevent(event);
if event.what <> evnothing then
begin
 gotoxy(35,1);
 write(event.where.x:4,event.where.y:4);
 case event.buttons of
 1: write('  links');
 2: write(' rechts');
 4: begin write('  mitte'); if event.where.y < 5 then hidemouse else showmouse; end;
 end;
end
until keypressed;
anwendung.run;
anwendung.done;
end.