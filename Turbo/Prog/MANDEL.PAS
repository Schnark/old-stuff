program mandelbrot;
{$G+}{$N+}
uses graph, graph2, crt, maus;
const farbe: array[0..3,0..15] of byte = ((black, white, yellow, lightmagenta, red,
             lightblue, cyan, blue, darkgray, lightgray, brown, magenta,
             lightred, lightgreen, green, lightcyan),
             (0,1,9,10,4,12,6,14,0,1,9,10,4,12,6,14),
             (black,white,lightgray,darkgray,black,white,lightgray,darkgray,
             black,white,lightgray,darkgray,black,white,lightgray,darkgray),
             (0,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15));

type Tausschnitt = record
     start_re, start_im, ende_re, ende_im: extended;
     max_it: word;
     end;

var maxX, maxY, x_pixel, y_pixel: word;
    farbwahl: byte;
    x_maus, y_maus, x2_maus, dummy: integer;
    i, max_it: word;
    a, b, x, y, x_2, y_2,
    start_re, start_im, ende_re, ende_im, dx, dy,
    d_re, d_im: extended;
    x_suche, y_suche: extended;
    neu_eingabe: boolean;
    taste: char;
    vergr_it: boolean;
    eingabe: string;
    fehler: integer;

    ausschnitt: TAusschnitt;
    datei: file of TAusschnitt;

function ende_im_(start_re, start_im, ende_re: extended): extended;
{Berechnet ende_im, sodass Bildschirmverh„ltnis stimmt}
begin
 ende_im_:=start_im-(ende_re-start_re)*maxY/maxX;
end;

begin
 farbwahl:=0;
 vergr_it:=false; {Anzahl der Iterationen wird nicht vergr”áert}
 assign(datei, 'P:\TURBO\PROG\PROG\MANDEL.DAT'); {Datei fr Ausschnitte}
 x_suche:=0; y_suche:=0; {es wird nach dem 0-Punkt gesucht}
 start_re:=-2.55; start_im:=2; {Startausschnitt}
 ende_re:=2.8;
 max_it:=16;

 init;                         {Grafikmodus}
 maxX:=getmaxX; maxY:=getmaxY;
 ende_im:=ende_im_(start_re, start_im, ende_re);
{$R-}{$S-}
 repeat
    dx:=(ende_re-start_re)/maxX;
    dy:=(start_im-ende_im)/maxY; {dy:=dx;}

    a:=start_re;
    for x_pixel:=0 to maxX do begin
        b:=start_im;
        for y_pixel:=0 to maxY do begin
            if not( vergr_it and (getpixel(x_pixel,y_pixel)<>farbe[farbwahl,max_it mod 16])) then begin
               x:=0; y:=0; x_2:=0; y_2:=0; i:=0;
               repeat
                   y:=2*x*y+b;
                   x:=x_2-y_2+a;
                   inc(i);
                   x_2:=sqr(x); y_2:=sqr(y);
               until (i>=max_it) or (x_2+y_2>4);
               putpixel(x_pixel, y_pixel, farbe[farbwahl,i mod 16]);
            end;
            b:=b-dy;
        end;
        a:=a+dx;
    end;
{$R+}{$S+}
    vergr_it:=false;

    repeat
      neu_eingabe:=false;
      taste:=readkey;
      if keypressed then begin
        taste:=readkey;
        case taste of
        #27: begin taste:=#0; neu_eingabe:=true; end;
        #59: {F1} begin
                      closegraph;
                      writeln('Aktuelle Werte');
                      writeln;
                      writeln('Links oben,   x-Wert: ',start_re:20:16);
                      writeln('Links oben,   y-Wert: ',start_im:20:16);
                      writeln('Rechts unten, x-Wert: ',ende_re:20:16);
                      writeln('Rechts unten, y-Wert: ',ende_im:20:16);
                      writeln;
                      writeln('Anzahl Iterationen:   ',max_it);
                      writeln; writeln;
                      writeln('Neue Werte, zum šbernehmen <ENTER>');
                      writeln;
                      write('Links oben,   x-Wert: '); readln(eingabe);
                      if eingabe<>'' then val(eingabe, start_re, fehler);
                      write('Links oben,   y-Wert: '); readln(eingabe);
                      if eingabe<>'' then val(eingabe, start_im, fehler);
                      write('Rechts unten, x-Wert: '); readln(eingabe);
                      if eingabe<>'' then val(eingabe, ende_re, fehler);
                      writeln('Rechts unten, y-Wert: (wird automatisch berechnet)');
                      ende_im:=ende_im_(start_re,start_im,ende_re);
                      writeln;
                      write('Anzahl Iterationen:   '); readln(eingabe);
                      if eingabe<>'' then val(eingabe, max_it, fehler);
                      init;
            end;
        #60: {F2} begin
                       ausschnitt.start_re:=start_re;
                       ausschnitt.start_im:=start_im;
                       ausschnitt.ende_re:=ende_re;
                       ausschnitt.ende_im:=ende_im;
                       ausschnitt.max_it:=max_it;
                       reset(datei); seek(datei, filesize(datei));
                       write(datei, ausschnitt);
                       close(datei);
                       neu_eingabe:=true;
            end;
        #61: {F3} begin
                       closegraph;
                       reset(datei);
                       write('Bildnr. (0 - ',filesize(datei)-1,'): ');
                       readln(dummy);
                       seek(datei, dummy);
                       read(datei, ausschnitt);
                       start_re:=ausschnitt.start_re;
                       start_im:=ausschnitt.start_im;
                       ende_re:=ausschnitt.ende_re;
                       ende_im:=ausschnitt.ende_im;
                       max_it:=ausschnitt.max_it;
                       init;
            end;
        #62: {F4} begin
                      mauson;
                      repeat until mausget(x_maus, y_maus)<>0;
                      repeat until mausget(x2_maus, dummy)=0;
                      repeat until mausget(x2_maus, dummy)<>0;
                      mausoff;
                      start_re:=start_re+x_maus*dx;
                      start_im:=start_im-y_maus*dy;
                      ende_re:={altstart_re+x2_maus*dx;
                                start_re-x_maus*dx+...;}
                                start_re+dx*(x2_maus-x_maus);
                                ende_im:=ende_im_(start_re, start_im, ende_re);
            end;
        #63: {F5}begin
                      mauson;
                      repeat until mausget(x_maus, y_maus)<>0;
                      mausoff;
                      x_suche:=start_re+x_maus*dx;
                      y_suche:=start_im-y_maus*dy;
                      neu_eingabe:=true;
            end;
        #64: {F6}begin
                      setcolor(white); setlinestyle(0,0,3); setwritemode(1);
                      rectangle( trunc((x_suche-start_re)/(ende_re-start_re)*maxX)-maxX div 20,
                                 trunc((start_im-y_suche)/(start_im-ende_im)*maxY)+maxY div 20,
                                 trunc((x_suche-start_re)/(ende_re-start_re)*maxX)+maxX div 20,
                                 trunc((start_im-y_suche)/(start_im-ende_im)*maxY)-maxY div 20);
                      neu_eingabe:=true;
            end;
        #71: {Pos1}begin
                       start_re:=-2.55; start_im:=2;
                       ende_re:=2.8; ende_im:=ende_im_(start_re, start_im, ende_re);
            end;
        #72: {^}begin
                    d_im:=start_im-ende_im;
                    start_im:=start_im+d_im/2;
                    ende_im:=ende_im+d_im/2;
            end;
        #73: {P^}begin
                      d_re:=ende_re-start_re;
                      d_im:=start_im-ende_im;
                      start_re:=start_re-d_re/2;
                      start_im:=start_im+d_im/2;
                      ende_re:=ende_re+d_re/2;
                      ende_im:=ende_im-d_im/2;
            end;
        #75: {<}begin
                    d_re:=ende_re-start_re;
                    start_re:=start_re-d_re/2;
                    ende_re:=ende_re-d_re/2;
            end;
        #77: {>}begin
                    d_re:=ende_re-start_re;
                    start_re:=start_re+d_re/2;
                    ende_re:=ende_re+d_re/2;
            end;
        #80: {v}begin
                    d_im:=start_im-ende_im;
                    start_im:=start_im-d_im/2;
                    ende_im:=ende_im-d_im/2;
            end;
        #81: {Pv}begin
                      d_re:=ende_re-start_re;
                      d_im:=start_im-ende_im;
                      start_re:=start_re+d_re/4;
                      start_im:=start_im-d_im/4;
                      ende_re:=ende_re-d_re/4;
                      ende_im:=ende_im+d_im/4;
            end;
        else neu_eingabe:=true;
        end;
     end else
        case taste of
        #13: begin
                  start_re:=x_suche-(maxX div 20)*dx;
                  start_im:=y_suche+(maxY div 20)*dy;
                  ende_re:=x_suche+(maxX div 20)*dx;
                  ende_im:=y_suche-(maxY div 20)*dy;
             end;
        '+': begin max_it:=max_it+16; vergr_it:=true; end;
        '-': if max_it>16 then max_it:=max_it-16 else max_it:=16;
        '*': begin max_it:=max_it+160; vergr_it:=true; end;
        '/': if max_it>160 then max_it:=max_it-160 else max_it:=16;
        #27:;
        else neu_eingabe:=true;
        end;
    until not neu_eingabe;
 until taste=#27;
 closegraph;
end.