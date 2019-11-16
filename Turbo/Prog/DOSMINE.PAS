program dosmine;
{Version 1 18. 7. 2005}
uses graph,graph2,maus,zeit,crt,keyb;

const _BREITE=16;    {Breite der Felder}
const _X=50; _Y=50;  {Startpos. des Spielfelds}


type TSpiel = record
     frageerlaubt: boolean;  {Fragezeichen als Markierung}
     start: longint;         {Startzeit}
     status: (bereit, begonnen, verloren, gewonnen, neuerrekord);  {Status des Spiels}
     minenges: integer;                               {Anzahl der Minen}
     minen: integer;                                  {verbleibende Minen}
     breite, hoehe: integer;                          {Maแe des Spielfelds}
     end;
const Spiel: TSpiel = (frageerlaubt: true; start: 0);

type TRekord = record
     name: string;
     zeit: integer;
     end;
     TRekorde = array[1..3,1..3] of TRekord;


type feld = object
     x, y: integer; {Position}
     nummer: integer; {Zahl der Minen, -1 bei Mine}
     offen: boolean; {ge”ffnet?}
     markierung: (ohne, mine, frage); {Markierung}
     procedure oeffne;                {”ffnen}
     procedure markiere;              {markieren}
     procedure zaehle;               {alle ”ffnen, wenn alle Minen gefunden}
     procedure zeichne;               {zeichnen}
     end;
var spielfeld : array[1 .. 30, 1 .. 25] of feld;  {Spielfeld}
    altezeit: longint;
    antwort: boolean;
    wahl: byte;
    rekorde: TRekorde;

procedure ausgabe(x,y,zahl:integer; negativ:boolean);
const anzeige: array[-1..9,0..6] of byte =((0,1,0,0,0,0,0),
                                           (1,0,1,1,1,1,1),
                                           (0,0,0,0,1,0,1),
                                           (1,1,1,0,1,1,0),
                                           (1,1,1,0,1,0,1),
                                           (0,1,0,1,1,0,1),
                                           (1,1,1,1,0,0,1),
                                           (1,1,1,1,0,1,1),
                                           (1,0,0,0,1,0,1),
                                           (1,1,1,1,1,1,1),
                                           (1,1,1,1,1,0,1));
const l=10;
      b=2;
var s:string;
    i,wert,dummy:integer;
begin
 if negativ then begin
    str(abs(zahl):2,s);
    if zahl<0 then s:='-'+s else s:='0'+s;
 end
 else str(zahl:3,s);
 if s[1]=' ' then s[1]:='0'; if s[2]=' ' then s[2]:='0';

 setcolor(red); setfillstyle(solidfill, red);
 for i:=1 to 3 do begin
     if s[i]='-' then wert:=-1 else val(s[i],wert,dummy);
     if anzeige[wert,0]=1 then bar(x+b,y,        x+b+l,y+b        );
     if anzeige[wert,1]=1 then bar(x+b,y+   b+l, x+b+l,y+b+   b+l );
     if anzeige[wert,2]=1 then bar(x+b,y+2*(b+l),x+b+l,y+b+2*(b+l));

     if anzeige[wert,3]=1 then bar(x    ,y+b,    x+b,    y+   b+l );
     if anzeige[wert,4]=1 then bar(x+b+l,y+b,    x+b+b+l,y+   b+l );
     if anzeige[wert,5]=1 then bar(x    ,y+b+b+l,x+b,    y+2*(b+l));
     if anzeige[wert,6]=1 then bar(x+b+l,y+b+b+l,x+b+b+l,y+2*(b+l));
     x:=x+2*b+l+4;
 end;


end;


procedure panel(neu,minen:boolean);                 {zeichnet Anzeigetafel}
var x1,x2,y1,y2,xm,ym,t: integer;
begin
 x1:=_X; y1:=_Y-45; x2:=_X+_BREITE*(Spiel.breite+2); y2:=_Y;
 xm:=(x1+x2) div 2; ym:=(y1+y2) div 2;
 if neu then begin
 setfillstyle(solidfill, lightgray);
 bar(x1+1,y1+1,x2,y2);
 bar(x1+1,y2,x1+_BREITE,y2+_BREITE*Spiel.hoehe);
 bar(x2-_BREITE+1,y2,x2,y2+_BREITE*Spiel.hoehe);
 bar(x1+1,y2+_BREITE*Spiel.hoehe+1,x2,y2+_BREITE*(Spiel.hoehe+1));

 setcolor(white);
 line(x1+1,y1+1,x2,y1+1); line(x1+1,y1+1,x1+1,y2+_BREITE*(Spiel.hoehe+1));
 line(x1+5,_Y-7,x1+5+3*18-4+4,_Y-7); line(x1+5+3*18+1,_Y-39,x1+6+3*18,_Y-8);
 line(x2-5-3*18,_Y-7,x2-5,_Y-7); line(x2-5+1,_Y-39,x2-4,_Y-8);
 line(xm-16,ym-16,xm-16,ym+16); line(xm-16,ym-16,xm+16,ym-16);

 setcolor(darkgray);
 {line(x1+1,y2,x2,y2);} line(x2,y1+1,x2,y2+_BREITE*(Spiel.hoehe+1));
 line(x1+1,y2+_BREITE*(Spiel.hoehe+1),x2,y2+_BREITE*(Spiel.hoehe+1));
 line(x1+_BREITE+1,y2+_BREITE*Spiel.hoehe+1,x2-_BREITE+1,y2+_BREITE*Spiel.hoehe+1);
 line(x2-_BREITE+1,y2+1,x2-_BREITE+1,y2+_BREITE*Spiel.hoehe);
 line(x1+5,_Y-40,x1+5+3*18-4+4,_Y-40); line(x1+5-1,_Y-39,x1+4,_Y-8);
 line(x2-5-3*18,_Y-40,x2-5,_Y-40); line(x2-5-3*18-1,_Y-39,x2-6-3*18,_Y-8);
 line(xm-16,ym+16,xm+16,ym+16); line(xm+16,ym-16,xm+16,ym+16);

 setcolor(yellow); setfillstyle(solidfill, yellow);
 pieslice(xm,ym,0,360,10);
 setcolor(darkgray); circle(xm,ym,10);
 setcolor(blue);
 circle(xm-5,ym-3,1); circle(xm+5,ym-3,1);
 setcolor(red);
 line(xm-4,ym+5,xm+4,ym+5); putpixel(xm-5,ym+4,red); putpixel(xm+5,ym+4,red);

 end;

 if (Spiel.status=gewonnen) or (Spiel.status=neuerrekord) then begin
 setcolor(yellow); setfillstyle(solidfill, yellow);
 pieslice(xm,ym,0,360,10);
 setcolor(darkgray); circle(xm,ym,10);
 setcolor(blue);
 circle(xm-5,ym-3,1); circle(xm+5,ym-3,1);
 setcolor(red);
 arc(xm,ym+2,210,330,5);
 end;

 if Spiel.status=neuerrekord then
    line(xm-4,ym+5,xm+4,ym+5);



 if Spiel.status=verloren then begin
 setcolor(yellow); setfillstyle(solidfill, yellow);
 pieslice(xm,ym,0,360,10);
 setcolor(darkgray); circle(xm,ym,10);
 setcolor(blue);
 circle(xm-5,ym-3,1); circle(xm+5,ym-3,1);
 setcolor(red);
 arc(xm,ym+8,30,130,5);
 end;


 setcolor(black); setfillstyle(solidfill, black);
 if minen then bar(x1+5,_Y-39, x1+5+3*18-4+4, _Y-8);
 if (Spiel.status=begonnen) or (Spiel.status=bereit) then
    bar(x2-5-(3*18-4)-4,_Y-39, x2-5,_Y-8);

 if minen then ausgabe(x1+7, _Y-36, Spiel.minen, true);
                                  {Anzahl der verbleibenden Minen}

 if Spiel.start<>0 then t:=(timer-Spiel.start+99) div 100 else t:=0;
 if (Spiel.status=begonnen) or (Spiel.status=bereit) then
                  ausgabe(x2-5-(3*18-4)-2,_Y-36, t, false); {vergangene Zeit}
 altezeit:=timer;
end;


procedure neu(b, h, m: integer);           {neues Spiel}
var xx,yy,i,j,s: integer;
begin
 if b>30 then b:=30; if h>25 then h:=25; if m>99 then m:=99;
 if b<5 then b:=5; if h<5 then h:=5; if m<5 then m:=5;
 if m>(b-1)*(h-1) then m:=(b-1)*(h-1);
 with Spiel do begin
   breite:=b; hoehe:=h; minenges:=m; minen:=m;
   start:= 0; status:=bereit; {Daten speichern}
 end;
 for xx:=1 to b do
     for yy:=1 to h do
         with spielfeld[xx,yy] do begin
              x:=xx; y:=yy; nummer:=0; offen:=false; markierung:=ohne;
              zeichne;                         {Felder initialisieren}
         end;

 randomize;
 for i:=1 to m do begin
     repeat
         xx:=1+random(b); yy:=1+random(h);
     until spielfeld[xx,yy].nummer<>-1;
     spielfeld[xx,yy].nummer:=-1               {Minen verteilen}
 end;

 for xx:= 1 to b do
     for yy:=1 to h do
         if spielfeld[xx,yy].nummer<>-1 then begin
            s:=0;
            for i:= -1 to 1 do
                for j:= -1 to 1 do
                    if not ( (i=0) and (j=0) ) then
                       if (xx+i>0) and (xx+i<=b) and
                          (yy+j>0) and (yy+j<=h) then
                                  if spielfeld[xx+i,yy+j].nummer=-1 then inc(s);
            spielfeld[xx,yy].nummer:=s;         {Minen um Feld zhlen}
         end;
end;

procedure gewinnen;  {Spiel gewonnen}
var zeit: integer;
begin
 if (Spiel.status=verloren) or (Spiel.status=gewonnen) then exit;
 zeit:= (timer-Spiel.start+99) div 100;
 Spiel.minen:=0;
 Spiel.status:=gewonnen;
 if (wahl<4) and (zeit<rekorde[1,wahl].zeit) then begin
    rekorde[1,wahl].zeit:=zeit;
    Spiel.status:=neuerrekord;
 end;
 panel(false,true);
end;

procedure verlieren(xx,yy:integer);   {Spiel auf Feld (xx,yy) verloren}
var i,j,x1,x2,y1,y2: integer;
begin
 if (Spiel.status=verloren) or (Spiel.status=gewonnen) then exit;
 Spiel.status:=verloren;
 for i:=1 to Spiel.breite do
     for j:=1 to Spiel.hoehe do
         with spielfeld[i,j] do begin  {jedes Feld}

              x1:=_X+x*_BREITE+1; y1:=_Y+(y-1)*_BREITE+1;
              x2:=_X+(x+1)*_BREITE; y2:=_Y+y*_BREITE;

              if nummer=-1 then begin             {mit Mine}
                 if markierung<>mine then begin   {aber ohne Markierung}
                    offen:=true; zeichne;
                    if (i=xx) and (j=yy) then begin
                       setcolor(red); setfillstyle(solidfill, red);
                       bar(x1+1,y1+1,x2,y2);
                    end;
                    setcolor(black); setfillstyle(solidfill, black);
                    pieslice(x1+_BREITE div 2, y1 + _BREITE div 2, 0,360, _BREITE div 2 - 4);
                    line(x1+_BREITE div 2, y1+2, x1+_BREITE div 2, y2-1);
                    line(x1+2, y1+_BREITE div 2, x2-1, y1+_BREITE div 2);
                    putpixel(x1+4,y1+4,black); putpixel(x1+4,y2-3,black);
                    putpixel(x2-3,y1+4,black); putpixel(x2-3,y2-3,black);
                    setcolor(white); setfillstyle(solidfill, white);
                    bar(x1+6,y1+6,x1+7,y1+7);     {wird ge”ffnet und mit Mine versehen}
                 end
              end
              else                                {ohne Mine}
                   if markierung=mine then begin  {aber mit Markierung}
                      nummer:=-1; offen:=true; zeichne;
                      setcolor(black); setfillstyle(solidfill, black);
                      pieslice(x1+_BREITE div 2, y1 + _BREITE div 2, 0,360, _BREITE div 2 - 4);
                      line(x1+_BREITE div 2, y1+2, x1+_BREITE div 2, y2-1);
                      line(x1+2, y1+_BREITE div 2, x2-1, y1+_BREITE div 2);
                      putpixel(x1+4,y1+4,black); putpixel(x1+4,y2-3,black);
                      putpixel(x2-3,y1+4,black); putpixel(x2-3,y2-3,black);
                      setcolor(white); setfillstyle(solidfill, white);
                      bar(x1+6,y1+6,x1+7,y1+7);
                      setcolor(red);
                      line(x1+2,y1+2, x2-2,y2-2); line(x2-2,y1+2, x1+2,y2-2);
                       {wird ge”fnet und mit durchgestrichener Mine versehen}
                   end;
         end;
 panel(false,true);
end;

procedure feld.oeffne;
var i,j,s:integer;
begin
 if (Spiel.status=verloren) or (Spiel.status=gewonnen) then exit;
 if offen then exit; if markierung = mine then exit;
                                   {offene/markierte Felder nicht ”ffnen}
 if nummer=-1 then begin verlieren(x,y); exit; end;
                                   {bei Mine verloren}
 offen:=true; zeichne;             {”ffnen, zeichnen}
 if nummer = 0 then
    for i:= -1 to 1 do
        for j:= -1 to 1 do
            if not ( (i=0) and (j=0) ) then
               if (x+i>0) and (x+i<=Spiel.breite) and
                  (y+j>0) and (y+j<=Spiel.hoehe) then spielfeld[x+i,y+j].oeffne;
                                   {eventuell Nachbarn ”ffnen}
 s:=0;
 for i:=1 to Spiel.breite do
     for j:=1 to Spiel.hoehe do
         if not spielfeld[i,j].offen then inc(s);
                                     {alle minenlose Felder offen?}
 if s=Spiel.minenges then begin
    for i:=1 to Spiel.breite do
        for j:=1 to Spiel.hoehe do
            with spielfeld[i,j] do
                 if not offen then begin
                    markierung:=mine;
                    zeichne;
                 end;
    gewinnen;
 end;

end;

procedure feld.markiere;
begin
 if (Spiel.status=verloren) or (Spiel.status=gewonnen) then exit;
 if offen then exit;
 if markierung = ohne then begin markierung:=mine; dec(Spiel.minen); end
 else if markierung = mine then begin markierung:=frage; inc(Spiel.minen); end
      else markierung:=ohne;
 if not Spiel.frageerlaubt then if markierung=frage then markierung:=ohne;
 zeichne;
 {neue Markierung, Minenzahl aktualisieren, neu zeichnen}
end;

procedure feld.zaehle;
var i,j,s: integer;
begin
 if (Spiel.status=verloren) or (Spiel.status=gewonnen) then exit;
 if not offen then exit;
 s:=0;
 for i:= -1 to 1 do
     for j:= -1 to 1 do
         if not ( (i=0) and (j=0) ) then
            if (x+i>0) and (x+i<=Spiel.breite) and
               (y+j>0) and (y+j<=Spiel.hoehe) then
                        if spielfeld[x+i,y+j].markierung=mine then inc(s);
                        {Markierungen zhlen}
 if s=nummer then begin {wenn gleich Anzahl der Minen alle Nachbarn ”ffnen}
    for i:= -1 to 1 do
        for j:= -1 to 1 do
            if not ( (i=0) and (j=0) ) then
               if (x+i>0) and (x+i<=Spiel.breite) and
                  (y+j>0) and (y+j<=Spiel.hoehe) then spielfeld[x+i,y+j].oeffne;
 end;
end;

procedure feld.zeichne;
const farben: array[1 .. 8] of byte =
      (blue, green, red, cyan, magenta, lightgreen, black, darkgray);
var x1,x2,y1,y2:integer;
    s:string;
begin
 x1:=_X+x*_BREITE+1; y1:=_Y+(y-1)*_BREITE+1;
 x2:=_X+(x+1)*_BREITE; y2:=_Y+y*_BREITE;
 setfillstyle(solidfill,darkgray);
 bar(x1,y1,x2,y2);
 setfillstyle(solidfill, lightgray);
 bar(x1+1,y1+1,x2,y2);
 if not offen then begin
    setcolor(white);
    line(x1+1,y1+1,x2,y1+1); line(x1+1,y1+1,x1+1,y2);
    setcolor(darkgray);
    line(x1+1,y2,x2,y2); line(x2,y1+1,x2,y2);
    if markierung=ohne then exit;
    setcolor(black);
    if markierung=frage then outtextxy(x1+2,y1-2,'?');
    if markierung=mine then begin
       setfillstyle(solidfill,black);
       bar(x1+4,y2-2, x2-3,y2-4);
       bar(x1+_BREITE div 2, y2-4, x1+_BREITE div 2 + 1,y1+7);
       setfillstyle(solidfill,red); setcolor(red);
       bar(x1+5,y1+3, x1+_BREITE div 2 +1,y1+6);
    end;
    exit;         {Feld zeichnen und mit Markierung versehen}
 end;

 if nummer<=0 then exit;

 setcolor(farben[nummer]);
 str(nummer,s);
 outtextxy(x1+2,y1-2,s); {Nummer schreiben}

end;

procedure spielen(b,h,m: integer);
var taste,tasteneu, x,y: integer;
    t: char;
    neuesspiel: boolean;
begin

repeat
 neuesspiel:=false;
 neu(b,h,m);
 panel(true,true);
 mauson;

repeat
 repeat taste:=mausget(x,y); until (taste<>0) or (timer-altezeit>=100) or keypressed;
 if keypressed then begin t:=readkey; if ord(t)=27 then exit; end;
 if (taste=0) and (Spiel.status=begonnen) then begin panel(false,false); continue; end;
 if taste=0 then continue;

 if (abs(x- (_X+_X+_BREITE*(Spiel.breite+2)) div 2)<16) and
    (abs(y- (_Y-45+_Y) div 2)<16) then begin
         repeat taste:=mausget(x,y); until taste=0;
         mausoff;
         neuesspiel:=true;
         break;
 end;

 if x>=_X+_BREITE then x:=((x-_X-_BREITE) div _BREITE)+1 else x:=0;
 if y>=_Y then y:=((y-_Y) div _BREITE)+1 else y:=0;
 if (0<x) and (0<y) and (x<=Spiel.breite) and (y<=Spiel.hoehe) then begin
    if Spiel.status=bereit then begin
       Spiel.status:=begonnen;
       Spiel.start:=timer;
       delay(10);
       end;
    mausoff;
    if taste=1 then spielfeld[x,y].oeffne;
    if taste=2 then spielfeld[x,y].markiere;
    if taste>2 then spielfeld[x,y].zaehle;
    panel(false,true);
    mauson;
 end;
 repeat tasteneu:=mausget(x,y); until tasteneu<>taste;
until neuesspiel{(Spiel.status=verloren) or (Spiel.status=gewonnen)};
until false;
end;

procedure graphik;
begin
init;
setfillstyle(solidfill,blue);
bar(1,1,getmaxx,getmaxy);
setcolor(white);
outtextxy(10, getmaxy-10, 'Ende mit <ESC>');
{settextstyle(font('LCOM'), horizdir, 1);
setusercharsize(4,5, 1,3);}
settextstyle(font('BOLD'), horizdir, 1);
setusercharsize(1,2, 1,4);
end;

procedure bestzeiten;
var i, j, taste, sonder: byte;
    bestzeiten: TRekorde;

begin
 repeat
 textcolor(yellow); textbackground(blue);clrscr;
 writeln;
 writeln('     ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
 writeln('     บ                             Bestzeiten                             บ');
 writeln('     ฬออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน');
 writeln('     บ Anfnger                                                           บ');
 writeln('     บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ');
 writeln('     บ                  ณ                                                 บ');
 writeln('     บ                  ณ                                                 บ');
 writeln('     บ                  ณ                                                 บ');
 writeln('     ฬออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออน');
 writeln('     บ Fortgeschrittene                                                   บ');
 writeln('     บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ');
 writeln('     บ                  ณ                                                 บ');
 writeln('     บ                  ณ                                                 บ');
 writeln('     บ                  ณ                                                 บ');
 writeln('     ฬออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออน');
 writeln('     บ Profis                                                             บ');
 writeln('     บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ');
 writeln('     บ                  ณ                                                 บ');
 writeln('     บ                  ณ                                                 บ');
 writeln('     บ                  ณ                                                 บ');
 writeln('     ฬออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออน');
 writeln('     บ <ENTER> zurck zum Men    <ENTF> eigene Bestzeiten l”schen        บ');
 writeln('     ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');


 for i:=1 to 3 do begin
     bestzeiten[1,i]:=rekorde[1,i];
     if rekorde[2,i].zeit<bestzeiten[1,i].zeit then begin
        bestzeiten[1,i]:=rekorde[2,i];
        bestzeiten[2,i]:=rekorde[1,i];
     end
     else
        bestzeiten[2,i]:=rekorde[2,i];
     if rekorde[3,i].zeit<bestzeiten[1,i].zeit then begin
        bestzeiten[3,i]:=bestzeiten[2,i];
        bestzeiten[2,i]:=bestzeiten[1,i];
        bestzeiten[1,i]:=rekorde[3,i];
     end
     else begin
        if rekorde[3,i].zeit<bestzeiten[2,i].zeit then begin
           bestzeiten[3,i]:=bestzeiten[2,i];
           bestzeiten[2,i]:=rekorde[3,i];
        end
        else
           bestzeiten[3,i]:=rekorde[3,i];
     end;
 end;

 for i:=1 to 3 do
     for j:=1 to 3 do begin
         gotoxy( 8,6*i+j); write(bestzeiten[j,i].zeit:4);
         gotoxy(27,6*i+j);
         if bestzeiten[j,i].name=rekorde[1,1].name then textcolor(white);
         write(bestzeiten[j,i].name);
         if bestzeiten[j,i].name=rekorde[1,1].name then textcolor(yellow);
     end;

   tasten(taste, sonder);
   if sonder=K_ENTF then begin
      for i:=1 to 3 do rekorde[1,i].zeit:=999;
   end;
 until taste=13;
end;

function menue: boolean;
const arten: array[1 .. 4] of string[19]= (' Anfnger          ',
                                           ' Fortgeschrittene  ',
                                           ' Profis            ',
                                           ' Benutzerdefiniert ');
      h: array[1..3] of byte = ( 8, 16, 16);
      b: array[1..3] of byte = ( 8, 16, 30);
      m: array[1..3] of byte = (10, 40, 99);
var i, taste, sonder: byte;
    fehler: integer;
    eingabe: string;
begin
 if wahl<4 then begin
 Spiel.hoehe:=h[wahl];
 Spiel.breite:=b[wahl];
 Spiel.minenges:=m[wahl];
 end;
 repeat
 textcolor(yellow); textbackground(blue);clrscr;
 writeln;
 writeln('     ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป');
 writeln('     บ                            Minesweeper                             บ');
 writeln('     ฬอออออออออออออออออออหออออออออออออออออออออออออออออออออออออออออออออออออน');
 writeln('     บ                   บ H”he:                                          บ');
 writeln('     บ                   บ Breite:                                        บ');
 writeln('     บ                   บ                                                บ');
 writeln('     บฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤบ Minen:                                         บ');
 writeln('     บ                   บ                                                บ');
 writeln('     ฬอออออออออออออออออออฮออออออออออออออออออออออออออออออออออออออออออออออออน');
 writeln('     บ   Merker (<F3>)   บ Minesweeper wird auf einem Minenfeld gespielt. บ');
 writeln('     บ                   บ Ihre Aufgabe besteht darin, alle Minen so      บ');
 writeln('     บ                   บ schnell wie m”glich zu finden. Hierzu decken   บ');
 writeln('     บ                   บ Sie die Quadrate auf, die keine Minen          บ');
 writeln('     บ                   บ enthalten, und markieren die Quadrate, in      บ');
 writeln('     บ                   บ denen welche vorhanden sind. Der Trick besteht บ');
 writeln('     บ                   บ darin, zu bestimmen, welche Quadrate vermint   บ');
 writeln('     บ                   บ sind und welche nicht.                         บ');
 writeln('     บ                   บ Wenn Sie alle Quadrate ohne Minen aufdecken,   บ');
 writeln('     บ                   บ gewinnen Sie. Wenn Sie auf eine Mine stoแen,   บ');
 writeln('     บ                   บ verlieren Sie.                                 บ');
 writeln('     ฬอออออออออออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออน');
 writeln('     บ <^v> Auswahl  <ENTER> Start  <F4> Bestzeiten   <ESC> Ende          บ');
 writeln('     ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');

 gotoxy(36,5); write(Spiel.hoehe);
 gotoxy(36,6); write(Spiel.breite);
 gotoxy(36,8); write(Spiel.minenges);


 repeat
   for i:=1 to 4 do begin
       if i=wahl then begin textcolor(white); textbackground(green); end
       else begin textcolor(yellow); textbackground(blue); end;
       gotoxy(7,4+i+i div 4);
       write(arten[i]);
       end;
   gotoxy(8,11);
   textcolor(yellow); textbackground(blue);
   if Spiel.frageerlaubt then write('') else write(' ');
   tasten(taste, sonder);
   case sonder of
   K_UP: if wahl>1 then dec(wahl);
   K_DOWN: if wahl<4 then inc(wahl);
   K_F3: Spiel.frageerlaubt:=not Spiel.frageerlaubt;
   K_F4: bestzeiten;
   else;
   end;

   if (sonder=K_UP) or (sonder=K_DOWN) then begin
      if wahl=4 then begin
         showcursor;
         gotoxy(1,23);
         writeln('     บ Benutzerdefinierte H”he eingeben                                   บ');
         repeat
          gotoxy(36,5); write('                                       ');
          gotoxy(36,5); readln(eingabe);
          val(eingabe, Spiel.hoehe, fehler);
         until fehler=0;
         gotoxy(1,23);
         writeln('     บ Benutzerdefinierte Breite eingeben                                 บ');
         repeat
          gotoxy(36,6); write('                                      ');
          gotoxy(36,6); readln(eingabe);
          val(eingabe, Spiel.breite, fehler);
         until fehler=0;
         gotoxy(1,23);
         writeln('     บ Benutzerdefinierte Minenanzahl eingeben                            บ');
         repeat
          gotoxy(36,8); write('                                      ');
          gotoxy(36,8); readln(eingabe);
          val(eingabe, Spiel.minenges, fehler);
         until fehler=0;
         gotoxy(1,23);
         writeln('     บ <^v> Auswahl  <ENTER> Start  <F4> Bestzeiten   <ESC> Ende          บ');
         hidecursor;
      end
      else begin
           Spiel.hoehe:=h[wahl];
           Spiel.breite:=b[wahl];
           Spiel.minenges:=m[wahl];
      end;
      gotoxy(36,5); write('                                      ');
      gotoxy(36,5); write(Spiel.hoehe);
      gotoxy(36,6); write('                                      ');
      gotoxy(36,6); write(Spiel.breite);
      gotoxy(36,8); write('                                      ');
      gotoxy(36,8); write(Spiel.minenges);
   end;

 until (taste=27) or (taste=13) or (sonder=K_F4);
 until (taste=27) or (taste=13);
 menue:=(taste=13);
end;

procedure laden;
const NEU=false;
var rekord: TRekord;
    datei: file of TRekord;
    win: text;
    name1, name2, zeile:string;
    i,f:integer;
begin
 assign(datei, 'C:\WINDOWS\DOSMINE.INI');
 assign(win, 'C:\WINDOWS\WINMINE.INI');
 if NEU then begin
  rewrite(datei);
  rekord.zeit:=999; rekord.name:='Michael';
  write(datei, rekord); write(datei, rekord); write(datei, rekord);
  rekord.name:='neuer Benutzer';
  write(datei, rekord); write(datei, rekord); write(datei, rekord);
  close(datei);
 end;

 system.reset(datei);
 read(datei, rekord); rekorde[1,1]:=rekord;
 read(datei, rekord); rekorde[1,2]:=rekord;
 read(datei, rekord); rekorde[1,3]:=rekord;
 read(datei, rekord); rekorde[2,1]:=rekord;
 read(datei, rekord); rekorde[2,2]:=rekord;
 read(datei, rekord); rekorde[2,3]:=rekord;
 close(datei);

 name1:=rekorde[1,1].name; name2:=rekorde[2,1].name;
 textcolor(yellow); textbackground(blue);
 clrscr;
 writeln;
 writeln(' Benutzer');
 writeln;
 writeln(' 1. ',name1);
 writeln(' 2. ',name2);
 writeln;
 repeat
  write(' -> ');
  readln(name1); val(name1,i,f);
 until f=0;
 if i=2 then begin
    rekord:=rekorde[1,1]; rekorde[1,1]:=rekorde[2,1]; rekorde[2,1]:=rekord;
    rekord:=rekorde[1,2]; rekorde[1,2]:=rekorde[2,2]; rekorde[2,2]:=rekord;
    rekord:=rekorde[1,3]; rekorde[1,3]:=rekorde[2,3]; rekorde[2,3]:=rekord;
    if name2='neuer Benutzer' then begin
    writeln;
    write(' Neuen Namen eingeben: '); readln(name2);
    rekorde[1,1].name:=name2;
    rekorde[1,2].name:=name2;
    rekorde[1,3].name:=name2;
    end;
 end;
 system.reset(win);
 repeat
  readln(win, zeile);
  if pos('Time',zeile)=1 then begin
     val(copy(zeile,7,5),i,f);
     rekorde[3,ord(zeile[5])-ord('0')].zeit:=i;
  end;
  if pos('Name',zeile)=1 then begin
     name1:=copy(zeile,7,30)+' (Windows)';
     rekorde[3,ord(zeile[5])-ord('0')].name:=name1;
  end;
 until eof(win);
end;

procedure speichern;
var tauschen:boolean;
    rekord: TRekord;
    datei: file of TRekord;
begin
 assign(datei,'C:\WINDOWS\DOSMINE.INI'); rewrite(datei);
 if rekorde[1,1].name='Michael' then tauschen:=false else tauschen:=true;
 if tauschen then rekord:=rekorde[2,1] else rekord:=rekorde[1,1];
    write(datei, rekord);
 if tauschen then rekord:=rekorde[2,2] else rekord:=rekorde[1,2];
    write(datei, rekord);
 if tauschen then rekord:=rekorde[2,3] else rekord:=rekorde[1,3];
    write(datei, rekord);
 if tauschen then rekord:=rekorde[1,1] else rekord:=rekorde[2,1];
    write(datei, rekord);
 if tauschen then rekord:=rekorde[1,2] else rekord:=rekorde[2,2];
    write(datei, rekord);
 if tauschen then rekord:=rekorde[1,3] else rekord:=rekorde[2,3];
    write(datei, rekord);
 close(datei);
end;


begin
 savecursor;
 laden;
 wahl:=1;
 hidecursor;
 repeat
  antwort := menue;
  if antwort then begin
     graphik;

     spielen(Spiel.breite,Spiel.hoehe,Spiel.minenges);

     closegraph;
  end;
 until not antwort;
 speichern;
 showcursor;
end.