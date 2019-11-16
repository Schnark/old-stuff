constructor TElement.init;
begin
x := r.x; y := r.y;
breite := r.b; hoehe := r.h;
inhalt := strnew(i);
if inhalt=nil then begin getmem(inhalt, 1); inhalt[0]:=#0; end;
showhint:=false;
aktiv := true; sichtbar := true; gewaehlt := false; gedrueckt := false;
selbst:=@self; fenster:=f; relativ_zu:=f; align:=nil;

MouseClickHand:=nil;
end;

function TElement.abs_x;
begin
 if relativ_zu=nil then abs_x:=x else abs_x:=x+relativ_zu^.abs_x;
end;

function TElement.abs_y;
begin
 if relativ_zu=nil then abs_y:=y else abs_y:=y+relativ_zu^.abs_y;
end;

procedure TElement.zeichne;
var vp: ViewPortType;
begin
 if not (sichtbar and (ausgabe>=0)) then exit;
 if (fenster<>nil) and not fenster^.sichtbar then exit;
 mausoff;
 schranke(true);
 getviewsettings(vp);
 zeichne_(abs_x-vp.x1,abs_y-vp.y1);
 schranke(false);
 mauson;
end;

procedure TElement.zeichne_;
begin
end;

function TElement.innen(xx, yy: integer): boolean;
var i: boolean;
begin
 if not sichtbar then i:=false else
 i := (abs_x <= xx) and (xx <= abs_x + breite)
      and (abs_y <= yy) and (yy <= abs_y + hoehe);
 if i then if (relativ_zu<>nil) and (relativ_zu<>PElement(fenster)) then i:=relativ_zu^.innen(xx,yy);
 innen:=i;
end;

procedure TElement.aendernr;
begin
 x:=r.x; y:=r.y; breite:=r.b; hoehe:=r.h;
 grosseAenderung;
end;

procedure TElement.aendernx;
begin
 if x=xx then exit;
 x := xx;
 grosseAenderung;
end;

procedure TElement.aenderny;
begin
 if y=yy then exit;
 y := yy;
 grosseAenderung;
end;

procedure TElement.aendernb;
begin
 if breite=b then exit;
 if align<>nil then align^.aendernb(align^.breite-breite+b);
 breite := b;
 grosseAenderung;
end;

procedure TElement.aendernh;
begin
 if hoehe=h then exit;
 if align<>nil then align^.aendernh(align^.hoehe-hoehe+h);
 hoehe := h;
 grosseAenderung;
end;

procedure TElement.aenderni;
var ineu: pchar;
begin
 ineu := strnew(i);
 strdispose(inhalt);
 inhalt:=ineu;
 if inhalt=nil then begin getmem(inhalt, 1); inhalt[0]:=#0; end;
 kleineAenderung;
end;

procedure TElement.aktivieren;
begin
 if a = aktiv then exit;
 aktiv := a;
 kleineAenderung;
end;

procedure TElement.zeigen;
begin
 if (s = sichtbar) then exit;
 sichtbar := s;
 if s then kleineAenderung else grosseAenderung;
end;

procedure TElement.grosseAenderung;
begin
 fenster^.zeichne;
end;
procedure TElement.kleineAenderung;
var d: PDiaver;
begin
 if fenster^.ueberlappend then
    fenster^.zeichne
 else begin
    zeichne;
    d:=finden_verw(fenster);
    if (d<>nil) and (d^.hoeher<>nil) then d^.hoeher^.dia^.zeichne;
 end;
end;

procedure TElement.schranke;
begin
 if relativ_zu<>nil then relativ_zu^.schranke(ein);
 if ein then einschraenken(abs_x,abs_y,abs_x+breite,abs_y+hoehe) else entschraenken;
end;

procedure TElement.einordnen;
begin
 case art of
 e_z: fenster^.einordnen_z(selbst);
 e_t: fenster^.einordnen_t(selbst);
 e_m: fenster^.einordnen_m(selbst);
 end;
end;

destructor TElement.fertig;
begin
 strdispose(inhalt);
end;