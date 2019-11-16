program TurboVision;
uses objects, drivers, views, menus, app, dialogs, crt;
const befehl1 =101;
      befehl2 =102;
      fenster1=103;
      fenster2=104;

type TAnwendung = object(TApplication)
     procedure initmenubar; virtual;
     procedure initstatusline; virtual;
     procedure newwindow;
     procedure newdialog;
     procedure handleevent(var event: TEvent); virtual;
     end;

type PFenster = ^TFenster;
     TFenster = object(TWindow)
     constructor init(Bounds: TRect; WinTitle: string; WindowNo: byte);
     procedure handleevent(var event: TEvent); virtual;
     end;

type PInterior = ^TInterior;
     TInterior = object(TView)
     constructor init(var bounds: TRect);
     procedure draw; virtual;
     end;

type PDialog1 = ^TDialog1;
     TDialog1 = object(TDialog)
     Button1, Button2, Button3: PButton;
     constructor init;
     procedure handleevent(var event: TEvent); virtual;
     end;

procedure TAnwendung.initmenubar;
var r: TRect;
begin
 getextent(r); r.b.y:=r.a.y+1;
 MenuBar:=new(pmenubar, init(r,
 newmenu(newsubmenu('~D~atei' ,hcnocontext,
    newmenu(newitem('Nr. ~1~' ,'F1'   ,kbF1  ,befehl1 ,hcnocontext,
            newitem('~E~nde'  ,'Alt-X',kbAltX,cmQuit  ,hcnocontext,nil))),
         newsubmenu('~M~enu 2',hcnocontext,
    newmenu(newitem('Nr. ~2~' ,''     ,0     ,befehl2 ,hcnocontext,nil)),
         newsubmenu('~F~enster',hcnocontext,
    newmenu(newitem('™~f~fnen',''     ,0     ,fenster1,hcnocontext,
            newitem('~D~ialog',''     ,0     ,fenster2,hcnocontext,nil))),nil))))));
end;

procedure TAnwendung.initstatusline;
var r: TRect;
begin
 getextent(r); r.a.y:=r.b.y-1;
 statusline:=new(pstatusline, init(r, newstatusdef(0,$FFFF,
 newstatuskey('~Alt-X~ Ende',kbAltX,cmQuit ,
 newstatuskey('~F1 Nr. 1~'  ,kbF1  ,befehl1,
 newstatuskey(' Nr. ~2~'    ,0     ,befehl2,nil))),nil)));
end;

procedure TAnwendung.newwindow;
var f: PFenster;
    r: TRect;
begin
 r.assign(5,5,50,20);
 f:=new(PFenster, init(r, 'Mein Fenster', 1));
 DeskTop^.insert(f);
end;

procedure TAnwendung.newdialog;
var d: PDialog1;
    x: word;
begin
 d:=new(PDialog1,init);
 x:=DeskTop^.execview(d);
end;

procedure TAnwendung.handleevent;
begin
 inherited handleevent(event);
 if event.what=evcommand then case event.command of
    befehl1:  write(#7);
    befehl2:  begin write(#7); delay(100); write(#7); end;
    fenster1: newwindow;
    fenster2: newdialog;
    end;
end;

constructor TFenster.init;
var nr: string[3];
    int: PInterior;
begin
 str(windowno, nr);
 inherited init(Bounds, WinTitle+' '+nr,wnNoNumber);
 getcliprect(bounds);
 bounds.grow(-1,-1);
 int:=new(PInterior,init(Bounds));
 insert(int);
end;

procedure TFenster.HandleEvent;
begin
 inherited HandleEvent(event);
 case event.what of
 evKeyDown: begin
   writeChar(self.cursor.x+1,self.cursor.y+1,event.charCode,1,1);
   if self.cursor.x>self.size.x-self.origin.x then setcursor(0,self.cursor.y+1)
      else setcursor(self.cursor.x+1,self.cursor.y);
 end;
 end;
end;

constructor TInterior.init;
begin
 inherited init(bounds);
 GrowMode:=gfGrowHiX+gfGrowHiY;
 Options:=Options or ofFramed;
end;

procedure TInterior.draw;
begin
 inherited draw;
end;

constructor TDialog1.init;
var r:TRect;
begin
 r.assign(20,5,60,15);
 inherited init(r, 'T”ne');
 r.assign(10,2,30,4);
 Button1:=new(PButton,init(r,'Ein Piepser', befehl1,bfNormal));
 insert(button1);
 r.assign(10,4,30,6);
 Button2:=new(PButton,init(r,'Zwei Piepser', befehl2,bfNormal));
 insert(button2);
 r.assign(10,6,30,8);
 Button3:=new(PButton,init(r,'Ende', cmOK,bfNormal));
 insert(button3);
end;

procedure TDialog1.HandleEvent;
begin
 inherited HandleEvent(event);
 if event.what=evcommand then case event.command of
    befehl1:  write(#7);
    befehl2:  begin write(#7); delay(100); write(#7); end;
    end;
end;

var anwendung: TAnwendung;
begin
 anwendung.init;
 anwendung.run;
 anwendung.done;
end.