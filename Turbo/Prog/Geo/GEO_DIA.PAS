unit geo_dia;

interface
uses geo_def;
var name_neu_pgk: namenstr;

type option=(opt_e, opt_z, opt_m, opt_p, opt_g, opt_k, opt_ae);
           {Ende, Zeichnen, MenÅ, Punkt, Gerade, Kreis, Ñndern}
procedure neup;                          {Neuer Punkt        Eingabe   }
procedure neug;                          {      Gerade         im      }
procedure neuk;                          {      Kreis       Textmodus  }

function istneup(name:namenstr):boolean; {Neuer Name fÅr Punkt }
function istneug(name:namenstr):boolean; {               Gerade}
function istneuk(name:namenstr):boolean; {               Kreis }

procedure aendernT;                      {Ñndern eines Punkts im Textmodus}
procedure ausgabe;                       {Ausgabe der Wert    im Textmodus}
procedure einstellung;

procedure graphikmodus;                  {Graphikmodus                    }

procedure statuszeile(status:string);    {Statuszeilen-Text}
function lesestatus(meldung:string):string;
                                   {Wert in Statuszeile von Tastatur lesen}
procedure loeschestatus;                 {Statuszeilen-Text lîschen}

implementation
uses crt,graph,graph2,maus;

var punktezeiger, letztp: ppliste;
    geradenzeiger, letztg: pgliste;
    kreisezeiger, letztk: pkliste;

    statustext: string;


procedure grafikname;
begin
 name_neu_pgk:=lesestatus('Name: ');
 loeschestatus;
end;

function suchep(name: namenstr): ppunkt;
var z: ppliste;
begin
 z:=punktezeiger;
 while z<>nil do begin
  if z^.p^.name = name then break;
  z:=z^.naechster;
 end;
 if z<> nil then suchep:=z^.p else suchep:=nil;
end;

function sucheg(name: namenstr): pgerade;
var z: pgliste;
begin
 z:=geradenzeiger;
 while z<>nil do begin
  if z^.g^.name = name then break;
  z:=z^.naechster;
 end;
 if z<> nil then sucheg:=z^.g else sucheg:=nil;
end;

function suchek(name: namenstr): pkreis;
var z: pkliste;
begin
 z:=kreisezeiger;
 while z<>nil do begin
  if z^.k^.name = name then break;
  z:=z^.naechster;
 end;
 if z<> nil then suchek:=z^.k else suchek:=nil;
end;


function istneup;
begin
 istneup:=(suchep(name)=nil);
end;

function istneug;
begin
 istneug:=(sucheg(name)=nil);
end;

function istneuk;
begin
 istneuk:=(suchek(name)=nil);
end;


function findep(x,y:integer): ppunkt;
var z: ppliste;
begin
 z:=punktezeiger;
 while z<>nil do begin
  if z^.p^.koordin(x,y,0.1) then break;
  z:=z^.naechster;
 end;
 if z<> nil then findep:=z^.p else findep:=nil;
end;

function findeg(x,y:integer): pgerade;
var z: pgliste;
begin
 z:=geradenzeiger;
 while z<>nil do begin
  if z^.g^.koordin(x,y,0.1) then break;
  z:=z^.naechster;
 end;
 if z<> nil then findeg:=z^.g else findeg:=nil;
end;

function findek(x,y:integer): pkreis;
var z: pkliste;
begin
 z:=kreisezeiger;
 while z<>nil do begin
  if z^.k^.koordin(x,y,0.1) then break;
  z:=z^.naechster;
 end;
 if z<> nil then findek:=z^.k else findek:=nil;
end;


function neuerp:ppunkt;
var pp: ppunkt;
    pl: ppliste;
begin
 new(pp, init);
 new(pl);
 pl^.p:=pp;
 pl^.naechster:=nil;
 if punktezeiger=nil then
    punktezeiger:=pl
 else
    letztp^.naechster:=pl;
 letztp:=pl;
 neuerp:=pp;
end;

function neueg:pgerade;
var pg: pgerade;
    gl: pgliste;
begin
 new(pg, init);
 new(gl);
 gl^.g:=pg;
 gl^.naechster:=nil;
 if geradenzeiger=nil then
    geradenzeiger:=gl
 else
    letztg^.naechster:=gl;
 letztg:=gl;
 neueg:=pg;
end;

function neuerk:pkreis;
var pk: pkreis;
    kl: pkliste;
begin
 new(pk, init);
 new(kl);
 kl^.k:=pk;
 kl^.naechster:=nil;
 if kreisezeiger=nil then
    kreisezeiger:=kl
 else
    letztk^.naechster:=kl;
 letztk:=kl;
 neuerk:=pk;
end;


procedure neup;
var n,n1,n2: namenstr;
    ant: byte;
    pp: ppunkt;
    pl: ppliste;
begin
  pp:=neuerp;
  writeln('Konstruktion Punkt');
  repeat write('Name: '); readln(n); until istneup(n);
  pp^.name:=n;
  writeln;
  writeln('1. Koordinaten');
  writeln('2. Schnittpunkt von Gerade-Gerade');
  writeln('3.  "            "  Gerade-Kreis');
  writeln('4.  "            "  Kreis-Kreis');
  writeln('5. Mittelpunkt einer Strecke');
  writeln('6.  "       "  eines Kreises');
  write('--> '); readln(ant);
  case ant of
  1: begin
      pp^.konstr.konstruktion:=ko;
      write('x-Koordinate: '); readln(pp^.konstr.xk);
      write('y-Koordinate: '); readln(pp^.konstr.yk);
     end;
  2: begin
      pp^.konstr.konstruktion:=gg;
      repeat write('1. Gerade: '); readln(n1); until sucheg(n1)<>nil;
      repeat write('2. Gerade: '); readln(n2); until sucheg(n2)<>nil;
      pp^.konstr.g1:=sucheg(n1);
      pp^.konstr.g2:=sucheg(n2);
     end;
  3: begin
      pp^.konstr.konstruktion:=gk;
      repeat write('Gerade: '); readln(n1); until sucheg(n1)<>nil;
      repeat write('Kreis: '); readln(n2); until suchek(n2)<>nil;
      write('Schnittpunktnr.: '); readln(pp^.konstr.nrgk);
      pp^.konstr.g:=sucheg(n1);
      pp^.konstr.k:=suchek(n2);
     end;
  4: begin
      pp^.konstr.konstruktion:=kk;
      repeat write('1. Kreis: '); readln(n1); until suchek(n1)<>nil;
      repeat write('2. Kreis: '); readln(n2); until suchek(n2)<>nil;
      write('Schnittpunktnr.: '); readln(pp^.konstr.nrkk);
      pp^.konstr.k1:=suchek(n1);
      pp^.konstr.k2:=suchek(n2);
     end;
  5: begin
      pp^.konstr.konstruktion:=ms;
      repeat write('1. Punkt: '); readln(n1); until suchep(n1)<>nil;
      repeat write('2. Punkt: '); readln(n2); until suchep(n2)<>nil;
      pp^.konstr.p1:=suchep(n1);
      pp^.konstr.p2:=suchep(n2);
     end;
  6: begin
      pp^.konstr.konstruktion:=mk;
      repeat write('Kreis: '); readln(n1); until suchek(n1)<>nil;
      pp^.konstr.kk:=suchek(n1);
     end;
  end;
end;

procedure neug;
var n,n1,n2: namenstr;
    ant: byte;
    pg: pgerade;
    gl: pgliste;
begin
  pg:=neueg;
  writeln('Konstruktion Gerade');
  repeat write('Name: '); readln(n); until istneug(n);
  pg^.name:=n;
  writeln;
  writeln('1. durch 2 Punkte');
  writeln('2. Parallele in Abstand');
  writeln('3.  "     "  durch Punkt');
  writeln('4. Senkrechte durch Punkt');
  writeln('5. Tangente');
  writeln('6. Winkelhalbierende');
  writeln('7. Winkel');
  write('--> '); readln(ant);
  case ant of
  1: begin
      pg^.konstr.konstruktion:=p2;
      repeat write('1. Punkt: '); readln(n1); until suchep(n1)<>nil;
      repeat write('2. Punkt: '); readln(n2); until suchep(n2)<>nil;
      pg^.konstr.p1:=suchep(n1);
      pg^.konstr.p2:=suchep(n2);
     end;
  2: begin
      pg^.konstr.konstruktion:=pa;
      repeat write('Gerade: '); readln(n1); until sucheg(n1)<>nil;
      write('Abstand: '); readln(pg^.konstr.d);
      pg^.konstr.g:=sucheg(n1);
     end;
  3: begin
      pg^.konstr.konstruktion:=pp;
      repeat write('Gerade: '); readln(n1); until sucheg(n1)<>nil;
      repeat write('Punkt: '); readln(n2); until suchep(n2)<>nil;
      pg^.konstr.g:=sucheg(n1);
      pg^.konstr.p:=suchep(n2);
     end;
  4: begin
      pg^.konstr.konstruktion:=sp;
      repeat write('Gerade: '); readln(n1); until sucheg(n1)<>nil;
      repeat write('Punkt: '); readln(n2); until suchep(n2)<>nil;
      pg^.konstr.g:=sucheg(n1);
      pg^.konstr.p:=suchep(n2);
     end;
  5: begin
      pg^.konstr.konstruktion:=tp;
      repeat write('Kreis: '); readln(n1); until suchek(n1)<>nil;
      repeat write('Punkt: '); readln(n2); until suchep(n2)<>nil;
      write('Nr.: '); readln(pg^.konstr.nr);
      pg^.konstr.k:=suchek(n1);
      pg^.konstr.pt:=suchep(n2);
     end;
  6: begin
      pg^.konstr.konstruktion:=wh;
      repeat write('1. Gerade: '); readln(n1); until sucheg(n1)<>nil;
      repeat write('2. Gerade: '); readln(n2); until sucheg(n2)<>nil;
      pg^.konstr.g1:=sucheg(n1);
      pg^.konstr.g2:=sucheg(n2);
     end;
  7: begin
      pg^.konstr.konstruktion:=ww;
      repeat write('Gerade: '); readln(n1); until sucheg(n1)<>nil;
      repeat write('Punkt: '); readln(n2); until suchep(n2)<>nil;
      write('Winkel (Bogenma·): '); readln(pg^.konstr.winkel);
      pg^.konstr.gw:=sucheg(n1);
      pg^.konstr.pw:=suchep(n2);
     end;
  end;
end;

procedure neuk;
var n,n1,n2: namenstr;
    ant: byte;
    pk: pkreis;
    kl: pkliste;
begin
  pk:=neuerk;
  writeln('Konstruktion Kreis');
  repeat write('Name: '); readln(n); until istneuk(n);
  pk^.name:=n;
  writeln;
  writeln('1. Radius');
  writeln('2. durch Punkt');
  write('--> '); readln(ant);
  case ant of
  1: begin
      pk^.konstr.konstruktion:=mr;
      repeat write('Mittelpunkt: '); readln(n1); until suchep(n1)<>nil;
      write('Radius: '); readln(pk^.konstr.r);
      pk^.konstr.p:=suchep(n1);
     end;
  2: begin
      pk^.konstr.konstruktion:=mp;
      repeat write('Mittelpunkt: '); readln(n1); until suchep(n1)<>nil;
      repeat write('2. Punkt: '); readln(n2); until suchep(n2)<>nil;
      pk^.konstr.p1:=suchep(n1);
      pk^.konstr.p2:=suchep(n2);
     end;
  end;
end;

procedure ausgabe;
var p:ppliste;
    g:pgliste;
    k:pkliste;
begin
 p:=punktezeiger;
 g:=geradenzeiger;
 k:=kreisezeiger;
 while p<>nil do begin
  p^.p^.ausgabe;
  p:=p^.naechster;
 end;
 while g<>nil do begin
  g^.g^.ausgabe;
  g:=g^.naechster;
 end;
 while k<>nil do begin
  k^.k^.ausgabe;
  k:=k^.naechster;
 end;
 readln;
 clrscr;
end;

procedure einstellung;
var nr,i: integer;
    ant: string;
begin
 clrscr;
 writeln('Einstellungen'); writeln;
 writeln('1. Farben');
 writeln('2. Achsen');
 writeln('3. Begrenzung');
 writeln('4. verzerrungsfreie Darstellung');
 writeln('5. Standard'); writeln;
 write(' --> '); readln(nr);
 case nr of
 1: begin
     for i:= 0 to 15 do begin textcolor(i); write('-',i:2,'-'); end;
     textcolor(lightgray); textbackground(black); writeln;
     write('Hintergrundfarbe:  '); readln(koordsys.hgrund);
     write('Achsenfarbe:       '); readln(koordsys.afarbe);
     write('Farbe fÅr Punkte:  '); readln(koordsys.pfarbe);
     write('Farbe fÅr Geraden: '); readln(koordsys.gfarbe);
     write('Farbe fÅr Kreise:  '); readln(koordsys.kfarbe);
     write('Farbe fÅr Text:    '); readln(koordsys.statfarbe);
    end;
 2: begin
     write('Achsen sichtbar? <j,n>'); readln(ant);
     koordsys.achsen:=(ant='j') or (ant='J');
    end;
 3: begin
     write('kleinster x-Wert: '); readln(koordsys.xmin);
     write('grî·ter x-Wert:   '); readln(koordsys.xmax);
     write('kleinster y-Wert: '); readln(koordsys.ymin);
     write('grî·ter y-Wert:   '); readln(koordsys.ymax);
    end;
 4: begin
     koordsys.xmax:=koordsys.xmin + (koordsys.ymax-koordsys.ymin)/480*640;
    end;
 5: begin
     with koordsys do begin
      xmin:=-16; xmax:=16;
      ymin:=-12; ymax:=12;
      achsen:=true;
      hgrund:=white;
      afarbe:=darkgray;
      pfarbe:=red;
      gfarbe:=black;
      kfarbe:=black;
      statfarbe:=black;
     end;
    end;
 end;
end;


function mauspunkt(anweisung:string):ppunkt;
var x,y,taste:integer;
begin
 statuszeile(anweisung);
 mauson;
 repeat
  taste:=mausget(x,y);
 until (taste=1) and (findep(x,y)<>nil);
 mausoff;
 loeschestatus;
 repeat
  taste:=mausget(x,y);
 until taste=0;
 mauspunkt:=findep(x,y);
end;

function mausgerade(anweisung:string):pgerade;
var x,y,taste:integer;
begin
 statuszeile(anweisung);
 mauson;
 repeat
  taste:=mausget(x,y);
 until (taste=1) and (findeg(x,y)<>nil);
 mausoff;
 loeschestatus;
 repeat
  taste:=mausget(x,y);
 until taste=0;
 mausgerade:=findeg(x,y);
end;

function mauskreis(anweisung:string):pkreis;
var x,y,taste:integer;
begin
 statuszeile(anweisung);
 mauson;
 repeat
  taste:=mausget(x,y);
 until (taste=1) and (findek(x,y)<>nil);
 mausoff;
 loeschestatus;
 repeat
  taste:=mausget(x,y);
 until taste=0;
 mauskreis:=findek(x,y);
end;


procedure zeichne;
var p:ppliste;
    g:pgliste;
    k:pkliste;
    x,y:integer;
begin
  setcolor(koordsys.hgrund);
  setfillstyle(solidfill,koordsys.hgrund);
  bar(0,0,getmaxx,getmaxy);

  if koordsys.achsen then begin
   setcolor(koordsys.afarbe);
   koordinaten(0,0,x,y);
   line(0,y,getmaxx,y);
   line(x,0,x,getmaxy);
  end;

  p:=punktezeiger;
  g:=geradenzeiger;
  k:=kreisezeiger;
  while p<>nil do begin
   p^.p^.zeichne;
   p:=p^.naechster;
  end;
  while g<>nil do begin
   g^.g^.zeichne;
   g:=g^.naechster;
  end;
  while k<>nil do begin
   k^.k^.zeichne;
   k:=k^.naechster;
  end;
end;




procedure mausaendern;
var x,y,taste:integer;
    p:ppunkt;
begin
 repeat
  statuszeile('links: Punkte verschieben   rechts: Ende');
  mauson;
  taste:=mausget(x,y);
  if taste=1 then begin
   p:=findep(x,y);
   if (p<>nil) and (p^.konstr.konstruktion=ko) then begin
      repeat
        taste:=mausget(x,y);
      until taste=0;
      mausoff;
      koordzurueck(x,y, p^.konstr.xk,p^.konstr.yk);
      incaenderung;
      zeichne;
   end;
  end;
 until taste=2;
 mausoff;
 loeschestatus;
end;

procedure mausdefp;
var x,y,taste,dummy:integer;
    xx,yy:real;
    pp1,pp2:ppunkt;
    pg1,pg2:pgerade;
    pk1,pk2:pkreis;
    pp: ppunkt;
    pl: ppliste;
    k,k2,nr: string;

begin
 repeat grafikname; until istneup(name_neu_pgk);
 k2:=lesestatus('1. Koordinaten  2. Schnittpunkt  3. Mittelpunkt  --> ');
 loeschestatus;
 if k2='2' then
    k:=lesestatus('1. Gerade-Gerade  2. Gerade-Kreis  3. Kreis-Kreis --> ');
 if k2='3' then
    k:=lesestatus('1. Strecke  2. Kreis  --> ');
 loeschestatus;
 if k2='1' then k:='1'; if k2='2' then k:= chr(ord(k[1])+1);
 if k2='3' then k:= chr(ord(k[1])+4);
 case k[1] of
 '1': begin
      statuszeile('Punkt markieren');
      mauson;
      repeat
       taste:=mausget(x,y);
      until taste=1;
      mausoff;
      loeschestatus;
      koordzurueck(x,y,xx,yy);
      pp:=neuerp;
      pp^.name:=name_neu_pgk;
      pp^.konstr.konstruktion:=ko;
      pp^.konstr.xk:=xx;
      pp^.konstr.yk:=yy;
      end;
 '2': begin
      pg1:=mausgerade('1. Gerade markieren');
      pg2:=mausgerade('2. Gerade markieren');
      pp:=neuerp;
      pp^.name:=name_neu_pgk;
      pp^.konstr.konstruktion:=gg;
      pp^.konstr.g1:=pg1;
      pp^.konstr.g2:=pg2;
      end;
 '3': begin
      pg1:=mausgerade('Gerade markieren');
      pk1:=mauskreis('Kreis markieren');
      nr:=lesestatus('Schnittpunktnr.: ');
      loeschestatus;
      pp:=neuerp;
      pp^.name:=name_neu_pgk;
      pp^.konstr.konstruktion:=gk;
      pp^.konstr.g:=pg1;
      pp^.konstr.k:=pk1;
      val(nr,pp^.konstr.nrgk,dummy);
      end;
 '4': begin
      pk1:=mauskreis('1. Kreis markieren');
      pk2:=mauskreis('2. Kreis markieren');
      nr:=lesestatus('Schnittpunktnr.: ');
      loeschestatus;
      pp:=neuerp;
      pp^.name:=name_neu_pgk;
      pp^.konstr.konstruktion:=kk;
      pp^.konstr.k1:=pk1;
      pp^.konstr.k2:=pk2;
      val(nr,pp^.konstr.nrkk,dummy);
      end;
 '5': begin
      pp1:=mauspunkt('1. Punkt markieren');
      pp2:=mauspunkt('2. Punkt markieren');
      pp:=neuerp;
      pp^.name:=name_neu_pgk;
      pp^.konstr.konstruktion:=ms;
      pp^.konstr.p1:=pp1;
      pp^.konstr.p2:=pp2;
      end;
 '6': begin
      pk1:=mauskreis('Kreis markieren');
      pp:=neuerp;
      pp^.name:=name_neu_pgk;
      pp^.konstr.konstruktion:=mk;
      pp^.konstr.kk:=pk1;
      end;
 end;
end;

procedure mausdefk;
var pp1,pp2:ppunkt;
    pk: pkreis;
    kl: pkliste;
    k: string;
    rs: string;
    r: real;
    dummy:integer;

begin
 repeat grafikname; until istneuk(name_neu_pgk);
 k:=lesestatus('1. Mittelpunkt+Radius  2. Mittelpunkt+Punkt auf Umfang --> ');
 loeschestatus;
 case k[1] of
 '1': begin
      rs:=lesestatus('Radius: ');
      loeschestatus;
      val(rs,r,dummy);
      pp1:=mauspunkt('Mittelpunkt markieren');
      pk:=neuerk;
      pk^.name:=name_neu_pgk;
      pk^.konstr.konstruktion:=mr;
      pk^.konstr.p:=pp1;
      pk^.konstr.r:=r;
      end;
 '2': begin
      pp1:=mauspunkt('Mittelpunkt markieren');
      pp2:=mauspunkt('Punkt auf Umfang markieren');
      pk:=neuerk;
      pk^.name:=name_neu_pgk;
      pk^.konstr.konstruktion:=mp;
      pk^.konstr.p1:=pp1;
      pk^.konstr.p2:=pp2;
      end;
 end;
end;


procedure mausdefg;
var pp1,pp2:ppunkt;
    pg1,pg2:pgerade;
    pk:pkreis;
    pg: pgerade;
    gl: pgliste;
    k,k2: string;
    sx: string;
    x: real;
    dummy: integer;

begin
 repeat grafikname; until istneug(name_neu_pgk);
 k2:=lesestatus('1. zwei Punkte 2. Parallele 3. Senkrechte 4. Tangente 5. Winkel --> ');
 loeschestatus;
 if k2='2' then k:=lesestatus('1. Abstand  2. Punkt --> ');
 if k2='5' then k:=lesestatus('1. Winkelhalbierende  2. Winkel --> ');
 loeschestatus;
 if k2='1' then k:='1'; if k2='2' then k:=chr(ord(k[1])+1);
 if (k2[1]>='3') and (k2<>'5') then k:=chr(ord(k2[1])+1);
 if k2='5' then k:=chr(ord(k[1])+5);
 case k[1] of
 '1': begin
      pp1:=mauspunkt('Ersten Punkt markieren');
      pp2:=mauspunkt('Zweiten Punkt markieren');
      pg:=neueg;
      pg^.name:=name_neu_pgk;
      pg^.konstr.konstruktion:=p2;
      pg^.konstr.p1:=pp1;
      pg^.konstr.p2:=pp2;
      end;
 '2': begin
      pg1:=mausgerade('Gerade markieren');
      sx:=lesestatus('Abstand: ');
      loeschestatus;
      val(sx,x,dummy);
      pg:=neueg;
      pg^.konstr.konstruktion:=pa;
      pg^.konstr.d:=x;
      pg^.konstr.g:=pg1;
      end;
 '3': begin
      pg1:=mausgerade('Gerade markieren');
      pp1:=mauspunkt('Punkt markieren');
      pg:=neueg;
      pg^.konstr.konstruktion:=pp;
      pg^.konstr.g:=pg1;
      pg^.konstr.p:=pp1;
      end;
 '4': begin
      pg1:=mausgerade('Gerade markieren');
      pp1:=mauspunkt('Punkt markieren');
      pg:=neueg;
      pg^.konstr.konstruktion:=sp;
      pg^.konstr.g:=pg1;
      pg^.konstr.p:=pp1;
      end;
 '5': begin
      pk:=mauskreis('Kreis markieren');
      pp1:=mauspunkt('Punkt marieren');
      sx:=lesestatus('Nr.: ');
      loeschestatus;
      pg:=neueg;
      pg^.konstr.konstruktion:=tp;
      val(sx,pg^.konstr.nr,dummy);
      pg^.konstr.k:=pk;
      pg^.konstr.pt:=pp1;
      end;
 '6': begin
      pg1:=mausgerade('Erste Gerade markieren');
      pg2:=mausgerade('Zweite Gerade markieren');
      pg:=neueg;
      pg^.konstr.konstruktion:=wh;
      pg^.konstr.g1:=pg1;
      pg^.konstr.g2:=pg2;
      end;
 '7': begin
      pg1:=mausgerade('Gerade markieren');
      pp1:=mauspunkt('Punkt markieren');
      sx:=lesestatus('Winkelgrî·e (im Bogenma·): ');
      loeschestatus;
      val(sx,x,dummy);
      pg:=neueg;
      pg^.konstr.konstruktion:=ww;
      pg^.konstr.winkel:=x;
      pg^.konstr.gw:=pg1;
      pg^.konstr.pw:=pp1;
      end;
 end;
end;

function menue: option;
var ant: string;
begin
 ant:=lesestatus('1. Punkt  2. Gerade  3. Kreis  4. Ñndern  5. Ende    --> ');
 case ant[1] of
 '1': menue:=opt_p;
 '2': menue:=opt_g;
 '3': menue:=opt_k;
 '4': menue:=opt_ae;
 '5': menue:=opt_e;
 end;
 loeschestatus;
end;

procedure graphikmodus;
var wahl:option;
begin
 graph2.init;
 repeat
  zeichne;
  wahl:=menue;
  case wahl of
   opt_p: mausdefp;
   opt_g: mausdefg;
   opt_k: mausdefk;
   opt_ae: mausaendern;
  end;
 until wahl = opt_e;
 closegraph;
end;


procedure aendernT;
var name:namenstr;
    p:ppunkt;
begin
repeat write('Name des Punkts: '); readln(name); until suchep(name)<>nil;
p:=suchep(name);
if p^.konstr.konstruktion<>ko then begin
                              writeln('Falsche Definition!');
                              readln;
                              exit;
                              end;
write('Neuer x-Wert: '); readln(p^.konstr.xk);
write('Neuer y-Wert: '); readln(p^.konstr.yk);
incaenderung;
end;

procedure statuszeile;
begin
setcolor(koordsys.statfarbe);
settextjustify(lefttext,bottomtext);
outtextxy(0,getmaxy,status);
statustext:=status;
end;

function lesestatus;
var z:char;
    eing:string;
begin
statuszeile(meldung);
moveto(textwidth(meldung),getmaxy);
eing:='';
repeat
 z:=readkey;
 if z<>#13 then begin outtext(z); eing:=eing+z; end;
until z=#13;
statustext:=meldung+eing;
lesestatus:=eing;
end;

procedure loeschestatus;
begin
setcolor(koordsys.hgrund);
settextjustify(lefttext,bottomtext);
outtextxy(0,getmaxy,statustext);
statustext:='';
end;


begin
punktezeiger:=nil; letztp:=nil;
geradenzeiger:=nil; letztg:=nil;
kreisezeiger:=nil; letztk:=nil;
with koordsys do begin
 xmin:=-16; xmax:=16;
 ymin:=-12; ymax:=12;
 achsen:=true;
 hgrund:=white;
 afarbe:=darkgray;
 pfarbe:=red;
 gfarbe:=black;
 kfarbe:=black;
 statfarbe:=black;
end;
end.
