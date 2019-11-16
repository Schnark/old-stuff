program hex; {$N+}
uses graph, graph2, xgraph, maus;
const _PHI: extended = 100;
      R0: extended = 1e-200; {0 Ohm}
      R1: extended = 1;      {1 Ohm}
      R00: extended = 1e200; {unendliche Ohm}

const max_feld=17;          {Maximale Feldbreite}
var feld_groesse: integer;  {tatsÑchliche   "   }

type typen = (leer, rot, blau); {Spielsteine}
var feld: array[1..max_feld,1..max_feld] of typen; {ganzes Feld}

var ende: boolean;          {Spiel vorbei ?}

var phi: array[1..max_feld,1..max_feld] of extended; {Potentiale}

procedure init_phi;
var i,j: integer;
begin
 for i:=1 to feld_groesse do for j:=1 to feld_groesse do
     phi[i,j]:=(feld_groesse-j)/(feld_groesse+1)*_PHI;
end;

procedure zeichneFeld(n: integer);    {Zeichnet Spielfeld und leert es}
var i, j: integer;
    par: array[0..3] of PointType;
begin
 for i := 1 to n do for j := 1 to n do
     polygon(10+15*i,10*i+18*j-5,10,6);
 setfillstyle(solidfill,blue);
 bar(2,13,10,13+18*n); bar(24+15*n,6+10*n,32+15*n,6+18*n+10*n);
 setfillstyle(solidfill,red);
 par[0].x:=18; par[0].y:=-6; par[1].x:=18+15*n; par[1].y:=10*n-6;
 par[2].x:=18+15*n; par[2].y:=3+10*n; par[3].x:=18; par[3].y:=3;
 fillpoly(4,par);
 for i := 0 to 3 do par[i].y:=par[i].y+18*n+22;
 fillpoly(4,par);
 for i:= 1 to max_feld do for j:=1 to max_feld do feld[i,j]:=leer;
end;

procedure zeichneStein(x,y: integer; farbe: word);    {zeichnet Stein und}
begin                                                 {setzt ihn aufs Feld}
 mausoff;
 setfillstyle(solidfill,farbe); setcolor(farbe);
 pieslice(10+15*x,10*x+18*y-5,0,360,7);
 feld[x,y]:=leer;
 if farbe = red then feld[x,y]:=rot;
 if farbe = blue then feld[x,y]:=blau;
 mauson;
end;

function nachbar(x,y,nr: integer; var xx,yy: integer): boolean;
begin                                  {Liefert Nachbarn im UZS}
 case nr of
 1: begin xx:=x;   yy:=y-1; end;
 2: begin xx:=x+1; yy:=y-1; end;
 3: begin xx:=x+1; yy:=y;   end;
 4: begin xx:=x;   yy:=y+1; end;
 5: begin xx:=x-1; yy:=y+1; end;
 6: begin xx:=x-1; yy:=y;   end;
 end;
 nachbar:=((xx>0)and(xx<=feld_groesse)and(yy>0)and(yy<=feld_groesse));
end;

procedure potentiale;
var i,j,k: integer;
    x,y: integer;
    r,phi_ges, r_ges: extended;
    diff: extended;
    pot: array[1..max_feld,1..max_feld] of extended;
    nr: integer;
begin
nr:=0;
repeat
 inc(nr);
 for i:=1 to feld_groesse do for j:=1 to feld_groesse do pot[i,j]:=0;
 for i:=1 to feld_groesse do for j:=1 to feld_groesse do begin
     phi_ges:=0; r_ges:=0;
     for k:=1 to 6 do
         if nachbar(i,j,k,x,y) then begin
            case feld[i,j] of
            leer: r:=R1; rot: r:=R0; blau: r:=R00; end;
            case feld[x,y] of
            leer: r:=r+R1; rot: r:=r+R0; blau: r:=r+R00; end;
            phi_ges:=phi_ges+phi[x,y]/r; r_ges:=r_ges+1/r;
         end;
     if j=1 then begin
        case feld[i,j] of
        leer: r:=R1; rot: r:=R0; blau: r:=R00; end;
        phi_ges:=phi_ges+2*_PHI/r; r_ges:=r_ges+2/r; end;
     if j=feld_groesse then begin
        case feld[i,j] of
        leer: r:=R1; rot: r:=R0; blau: r:=R00; end;
        r_ges:=r_ges+2/r; end;
     pot[i,j]:=phi_ges/r_ges;
(*     case feld[i,j] of
     leer: begin
           for k:=1 to 6 do begin
               if nachbar(i,j,k,x,y) and (feld[x,y]<>blau) then begin
                  if feld[x,y]=rot then r:=1 else r:=2;
                  phi_ges:=phi_ges+phi[x,y]/r; r_ges:=r_ges+1/r;
               end;
           end;
           if i=1 then begin phi_ges:=phi_ges+_PHI; r_ges:=r_ges+1; end;
           if i=feld_groesse then r_ges:=r_ges+1;
           if r_ges=0 then pot[i,j]:=0 else pot[i,j]:=phi_ges/r_ges;
           end;
     rot: if pot[i,j]=0 then begin
             if i=1 then pot[i,j]:=_PHI;
             if i=feld_groesse then pot[i,j]:=0;
             if (i<>1) and (i<>feld_groesse) then begin
                for k:=1 to 6 do begin
                    if nachbar(i,j,k,x,y) and (feld[x,y]=leer) then begin
                       phi_ges:=phi_ges+phi[x,y]; r_ges:=r_ges+1;
                    end;
                end;
                if r_ges=0 then pot[i,j]:=0 else pot[i,j]:=phi_ges/r_ges;
                phi_ges:=0; r_ges:=0;
                for k:=1 to 6 do begin
                    if nachbar(i,j,k,x,y) and (feld[x,y]=rot) then begin
                       phi_ges:=phi_ges+phi[x,y]; r_ges:=r_ges+1;
                    end;
                end;
                pot[i,j]:=(pot[i,j]+phi_ges)/(1+r_ges);
             end;
          end;
     blau: pot[i,j]:=0;
     end; *)
 end;
 diff:=0;
 for i:=1 to feld_groesse do for j:=1 to feld_groesse do begin
     diff:=diff+sqr(phi[i,j]-pot[i,j]);
     phi[i,j]:=pot[i,j];
 end;
until (diff<=0.00000001*_PHI*sqr(feld_groesse)) or (nr > 50);
end;

procedure getMove(var x,y: integer);     {Computer wÑhlt Feld}
var u,p,pmax: extended;
    i,j,k,a,b: integer;
begin
 potentiale;
 pmax:=-1;
 for i:=1 to feld_groesse do for j:=1 to feld_groesse do
     if feld[i,j]=leer then begin
        p:=0;
        for k:=1 to 6 do
        if nachbar(i,j,k,a,b) then begin
           u:=sqr(phi[i,j]-phi[a,b]);
           if feld[a,b]=leer then p:=p+u/2;
           if feld[a,b]=rot then p:=p+u;
        end;
        if j=1 then p:=p+2*sqr(phi[i,j]-_PHI);
        if j=feld_groesse then p:=p+2*sqr(phi[i,j]);
        if p>pmax then begin pmax:=p; x:=i; y:=j; end;
     end;
end;

procedure getKoord(var x,y: integer);           {liest gÅltigen Mausklick}
var xx,yy: integer;
begin
 repeat
   repeat until mausget(xx,yy)=0;
   repeat until mausget(xx,yy)<>0;
   x:=trunc((xx-10)/15+0.5); y:=trunc((yy+5-10*x)/18+0.5);
   if y<=0 then getMove(x,y);
 until (x>0) and (y>0) and (x<=feld_groesse) and (y<=feld_groesse)
       and (feld[x,y]=leer);
end;


function gewinn(farbe: typen):boolean;   {ermittelt, ob man gewonnen hat}
                                         {"lÑsst Wasser flie·en"}
var feld2: array[1..max_feld,1..max_feld] of boolean;
    fertig: boolean;
    i,j,k: integer;
    x,y: integer;
begin
 for i:=1 to feld_groesse do for j:=1 to feld_groesse do feld2[i,j]:=false;
 if farbe = rot then
    for i:=1 to feld_groesse do feld2[i,1]:= (feld[i,1]=rot);
 if farbe = blau then
    for j:=1 to feld_groesse do feld2[1,j]:= (feld[1,j]=blau);
 repeat
   fertig:=true;
   for i:=1 to feld_groesse do for j:=1 to feld_groesse do begin
       if feld2[i,j] then begin
          for k:=1 to 6 do
              if nachbar(i,j,k,x,y) then
                 if (not feld2[x,y]) and (feld[x,y]=farbe) then begin
                    fertig:=false; feld2[x,y]:=true;
                 end;
       end;
   end;
 until fertig;
 fertig:=false;
 if farbe = rot then
    for i:=1 to feld_groesse do if feld2[i,feld_groesse] then fertig:=true;
 if farbe = blau then
    for j:=1 to feld_groesse do if feld2[feld_groesse,j] then fertig:=true;
 gewinn:=fertig;
end;

function zug(farbe:typen; comp: boolean): boolean; {fÅhrt einen Zug durch}
var x,y: integer;
var i,j: integer; f: byte;
begin
 potentiale;
(* for i:=1 to feld_groesse do for j:=1 to feld_groesse do
     if feld[i,j]=leer then begin
        case trunc(4*(phi[i,j]/_PHI)) of
        0: f:=black;
        1: f:=darkgray;
        2: f:=lightgray;
        3,4: f:=white;
        end;
        zeichneStein(i,j,f);
     end;  *)
 mausoff;
 if farbe=rot then f:=red else f:=blue;
 setfillstyle(solidfill,f); setcolor(f);
 pieslice(28+15*feld_groesse,10,0,360,7);
 mauson;
 if comp then getMove(x,y) else getKoord(x,y);
 if farbe=rot then zeichneStein(x,y,red) else zeichneStein(x,y,blue);
 zug:=gewinn(farbe);
end;

begin
 feld_groesse:=5; if feld_groesse>max_feld then feld_groesse:=max_feld;
 init;
 setfillstyle(solidfill,white);
 bar(0,0,getmaxx,getmaxy);
 setcolor(black);

 zeichneFeld(feld_groesse);
 init_phi;

 mauson;

 ende:=false;
 repeat
 ende:=zug(rot,false);
 if not ende then ende:=zug(blau,false);
 until ende;

 mausoff;
 closegraph;
 if gewinn(rot) then writeln('rot') else writeln('blau');
 readln;
end.