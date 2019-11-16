program pinball; {$N+}
uses flipper_;
var links,rechts,oben,unten0,unten1,unten2,deckel: PWand;
procedure taskmanager(task: longint; k: PKugel); far;
begin
 case task of
 -5..-2:if k^.nr=1 then write(#7);
 -1: begin write(#7#7#7); schleifenende:=true; end;
 1: if k^.nr=1 then warte(18,2,k) else
       if deckel^.flaeche^.aktiv then begin
          deckel^.flaeche^.aktiv:=false; deckel^.zeichne; end;
 2: kugeleinwurf(15,15, -5,0);
 end;
end;

begin
taskmng:=taskmanager;
init(300,300,''); zeichnewand:=true;
links:=neuwand(eckig,0,300,0,0,0, 2,-0.8,0.999);
rechts:=neuwand(eckig,300,0,300,300,0, 0,-0.8,0.999);
oben:=neuwand(eckig,0,0,300,0,0, 0,-0.8,0.999);
unten0:=neuwand(eckig,300,300,280,300,0, 0,-0.25,0.999);
unten1:=neuwand(eckig,280,300,200,300,0, 1,-0.8,0.999);
unten2:=neuwand(eckig,100,300,0,300,0, 1,-0.8,0.999); {Rand}
wandtask(1,oben);

vollwand(100,200,200,100,4, 0,-0.4,0.999);
waende[2]^.ny:=-0.8;
vollbahn(100,100,50,1.5*pi+0.2,pi+0.5,4, 0,-0.4,0.999);
vollwand(280,300,280,250,4, 0,-0.8,0.999);
killwand(waende[1]);
vollwand(280,250,250,220,4, 0,-0.8,0.999);
killwand(waende[1]);
deckel:=neuwand(eckig,300,170,250,220,0, 0,-0.8,0.999);
deckel^.flaeche^.aktiv:=false; deckel^.zeichne;
kicker(unten0,36,10, deckel, 18);

neuflipper(15,245,50, -pi/4,pi/4,0.5, true, -0.8,0.999);
neuflipper(245,245,50, 0.75*pi,1.25*pi,0.5, false, -0.8,0.999);
                                                      {Flipper}
(*kugeleinwurf(150,125, 0,0);*)
(*kugeleinwurf(15,15, -5,0);
kugeleinwurf(285,15, -5,0);
kugeleinwurf(15,285, -5,0);
kugeleinwurf(285,285, -5,0);*)
einschuss(4,295,0.5,20,0);
schleife;
ende;
end.