program pinball; {$N+,E-}
uses flipper_;
var w: array[1..3] of PWand;
    punkte,maxpunkte: word;
    lampe,neulampe: TLampe;
    neustart: byte;

procedure taskmanager(task: longint; k: PKugel); far;
begin
 case task of
 -5..-2:;
 -1: schleifenende:=true;
 1: lampe.an:=not lampe.an;
 2: warte(18, 5, nil);
 3: begin inc(punkte); ausgabe(2,tostr(punkte,3)); end;
 4: begin inc(punkte,2); ausgabe(2,tostr(punkte,3)); end;
 5: kugeleinwurf(262.5,310,0,-20);
 6: k^.verstecke(3);
 end;
end;

begin
taskmng:=taskmanager;
init(270,325,'P:\TURBO\PROG\PROG\FLIPPER\flipper2.pcx');
punkte:=0; maxpunkte:=0;

{0: schwarz          1: dunkelrot          2: dunkelgrÅn
 3: hellbraun        4: dunkelblau         5: dunkelviolett
 6: dunkeltÅrkis     7: dunkelgrau         8: hellgrau
 9: rot             10: grÅn              11: gelb
12: blau            13: violett           14: tÅrkis
15: wei·}

wandfarbe:=3; ausgabefarbe:=9;
resetausgabe(6,180);
ausgabe(1,'Punkte'); ausgabe(2,tostr(punkte,3));
ausgabe(3,'max. Punkte'); ausgabe(4,tostr(maxpunkte,3));

{Lampen}
lampe.init(105,15,3,0,0);
lampe.blinkend(9); lampe.an:=false;

neulampe.init(232,313,5,13,8);
neulampe.blinkend(5); neulampe.an:=false;

{WÑnde, Flipper}
if waende_aus_datei('P:\TURBO\PROG\PROG\FLIPPER\FLIPPER2.FLP',w)<>3 then begin write('Fehler'); exit; end;
w[1]^.flaeche^.korrektur:=false;
w[2]^.v:=2; w[3]^.v:=3;

(*inflliste(nil,eckig,0,0,270,0,50)^.task:=6;*)

linkstask:=1;

zeichnewand:=true;
repeat
 punkte:=0; neustart:=0;
 resetKicker(0);
 repeat
   if neustart>0 then ausgabe(6,'Kugel wiederholen ('+tostr(neustart,1)+')')
   else ausgabe(6,'Kugel einschie·en');
   einschuss(262.5,310,1.0,30,8);
   ausgabe(2,tostr(punkte,3)); ausgabe(6,'');
   if neustart<3 then begin
      neueinschuss(@neulampe,180,36);
      inc(neustart);
   end;
 until schleife=normal;
 write(#7);
 if punkte>maxpunkte then begin maxpunkte:=punkte; ausgabe(4,tostr(maxpunkte,3)); end;
until punkte=0;
ausgabe(6,'Spielende');
ende;
end.