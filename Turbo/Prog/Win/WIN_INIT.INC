constructor THintergrund.init;
begin
 benutzter_ende:=false; sichtbar:=true; aktiv:=true; relativ_zu:=nil;
 farbe := f;
 x := 0; y := 0;
 graph2.init;
 breite := getmaxx; hoehe := getmaxy;
 settextstyle(smallfont, horizdir, 5);
 settextjustify(lefttext, toptext);
 zeichne;
 mauson;
end;

constructor TButton.init;
begin
 if r.b=0 then r.b:=textwidth(strpas(i))+10;
 if r.h=0 then r.h:=textheight(strpas(i))+10;
 TElement.init(r, i, f);
end;

constructor TSymButton.init;
var i: byte;
begin
 if r.b=0 then r.b:=14;
 if r.h=0 then r.h:=14;
 TButton.init(r, '', f);
 for i:=1 to 8 do symbol[i]:=SymButton[art][i];
end;

constructor TEdit.init;
begin
 if r.b=0 then r.b:=textwidth(strpas(i))+10;
 if r.h=0 then r.h:=textheight('|')+5;
 TElement.init(r, i, f);
 cursorpos:=0; markend:=0; start:=0; mausmark:=false;
end;

constructor TLabel.init;
begin
 if r.b=0 then r.b:=textwidth(strpas(i))+5;
 if r.h=0 then r.h:=textheight(strpas(i))+5;
 TElement.init(r, i, f);
end;

constructor TCheck.init;
begin
 if r.b=0 then r.b:=textwidth(strpas(i))+15;
 if r.h=0 then r.h:=textheight(strpas(i))+5;
 TElement.init(r, i, f);
end;

constructor TRadio.init;
begin
 if r.b=0 then r.b:=textwidth(strpas(i))+15;
 if r.h=0 then r.h:=textheight(strpas(i))+5;
 TElement.init(r, i, f);
end;

constructor TFrame.init;
begin
 TElement.init(r, i, f);
end;

constructor T3D.init;
begin
 TElement.init(r, '', f);
 tief:=t;
end;

constructor TScrollBar.init;
(* [<]----[  ]--[>]
   13  l1  l  l2 13
      |   lges  |   *)
var l,l1,l2,lges: integer;
    r_: TRechteck;
    art: SymButtonArt;
begin
 inherited init(r,'',f);

 if a then lges:=r.b-26 else lges:=r.h-26;
 l:= round(lges * (pp.d_gross/(pp.max-pp.min+pp.d_gross)));
 if l<4 then l:=4; if l>lges then l:=lges;
 l1:= round( (pp.position-pp.min)/(pp.max-pp.min) * (lges-l));
 l2:= lges-l-l1;

 with r_ do begin                                   {Schieber}
      if a then x:=13+l1 else x:=0;
      if a then y:=0 else y:=13+l1;
      if a then b:=l else b:=r.b;
      if a then h:=r.h else h:=l; end;
 new(ss,init(r_,false,f)); ss^.sb:=@self; ss^.relativ_zu:=@self;
 ochandle:=true;
 ausrichtung:=a;
 OnChangeHand:=nil;
 with p do begin
      position:=pp.position;
      min:=pp.min; max:=pp.max;
      d_gross:=pp.d_gross; d_klein:=pp.d_klein; end;

 with r_ do begin                                   {oberer/rechter Knopf}
      x:=0; y:=0; b:=13; h:=13;
      if a then h:=r.h else b:=r.b; end;
 if a then art:=sb_links else art:=sb_oben;
 new(sb1,init(r_,art,f)); sb1^.sb:=@self; sb1^.relativ_zu:=@self;
 sb1^.groesser:=false;

 with r_ do begin                                   {unterer/linker Knopf}
      x:=0; y:=0; b:=13; h:=13;
      if a then x:=13+lges else y:=13+lges;
      if a then h:=r.h else b:=r.b; end;
 if a then art:=sb_rechts else art:=sb_unten;
 new(sb2,init(r_,art,f)); sb2^.sb:=@self; sb2^.relativ_zu:=@self;
 sb2^.groesser:=true;

 with r_ do begin                                   {obere/rechte Leiste}
      x:=0; y:=0; b:=r.b; h:=r.h;
      if a then x:=13 else y:=13;
      if a then b:=l1 else h:=l1; end;
 new(sl1,init(r_,true,f)); sl1^.sb:=@self; sl1^.relativ_zu:=@self;
 sl1^.groesser:=false;

 with r_ do begin                                   {untere/linke Leiste}
      x:=0; y:=0; b:=r.b; h:=r.h;
      if a then x:=13+l1+l else y:=13+l1+l;
      if a then b:=l2 else h:=l2; end;
 new(sl2,init(r_,true,f)); sl2^.sb:=@self; sl2^.relativ_zu:=@self;
 sl2^.groesser:=true;

end;

constructor TRelativ.init;
begin
 inherited init(r,'',f);
 x_start:=0; y_start:=0; echte_breite:=breite; echte_hoehe:=hoehe;
end;

constructor TScrollFeld.init;
var r_:TRechteck;
    p: TPos;
begin
 echte_breite:=eb; echte_hoehe:=eh;
 p.min:=0; p.position:=0; p.d_klein:=1; p.max:=1; p.d_gross:=1;

 r_.x:=r.x; r_.y:=r.y+r.h-13; r_.b:=r.b-13; r_.h:=13;
 new(sb1,init(r_,true,p,f));

 r_.x:=r.x+r.b-13; r_.y:=r.y; r_.b:=13; r_.h:=r.h-13;
 new(sb2,init(r_,false,p,f));

 noetig(r.b,r.h);

 sb1^.zeigen(noetig1); sb2^.zeigen(noetig2);
 sb1^.aendernb(r.b); sb2^.aendernh(r.h);
 p:=sb1^.p; p.max:=echte_breite-r.b; p.d_gross:=r.b; sb1^.aendernp(p);
 p:=sb2^.p; p.max:=echte_hoehe-r.h; p.d_gross:=r.h; sb2^.aendernp(p);

 inherited init(r,f);
 echte_breite:=eb; echte_hoehe:=eh;
 sb1^.bezug:=selbst; sb2^.bezug:=selbst;
 sb1^.OnChangeHand:=TScrollFeldChangex;
 sb2^.OnChangeHand:=TScrollFeldChangey;
end;

constructor TWindow.init;
begin
 f:= @self;
 TElement.init(r, i, f);
 min_b:=breite; min_h:=hoehe;
 relativ_zu:=nil;
 acceptmouse:=nil; acceptkey:=nil; zeichneschlange:=nil;
 sichtbar := false; ueberlappend:=false;
end;

