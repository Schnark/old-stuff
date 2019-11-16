unit dac;
interface

type dac_reg= record R,G,B: byte end;
     dac_feld= record regs: array[0..255] of dac_reg; anzahl, start: byte; end;

procedure setdacreg(nr: byte; dac: dac_reg);
procedure setdacregs(dac: dac_feld);
procedure getdacreg(nr: byte; var dac: dac_reg);
procedure getdacregs(var dac: dac_feld);

procedure setdacmask(mask:byte);
function  getdacmask: byte;

implementation
uses dos;
var reg:registers;

procedure setdacreg;
begin
 reg.ah:=$10; reg.al:=$10;
 reg.bx:=nr; reg.cl:=dac.B; reg.ch:=dac.G; reg.dh:=dac.R;
 intr($10,reg);
end;

procedure setdacregs;
begin
 reg.ah:=$10; reg.al:=$12; reg.bx:=dac.start; reg.cx:=dac.anzahl;
 reg.es:=seg(dac.regs[dac.start]); reg.dx:=ofs(dac.regs[dac.start]);
 intr($10,reg);
end;

procedure getdacreg;
begin
 reg.ah:=$10; reg.al:=$15; reg.bx:=nr;
 intr($10,reg);
 dac.R:=reg.dh; dac.G:=reg.cl; dac.B:=reg.ch;
end;

procedure getdacregs;
begin
 reg.ah:=$10; reg.al:=$17; reg.bx:=dac.start; reg.cx:=dac.anzahl;
 reg.es:=seg(dac.regs[dac.start]); reg.dx:=ofs(dac.regs[dac.start]);
 intr($10,reg);
end;

procedure setdacmask;
begin
 reg.ah:=$10; reg.al:=$18; reg.bl:=mask;
 intr($10,reg);
end;

function getdacmask;
begin
 reg.ah:=$10; reg.al:=$19;
 intr($10,reg);
 getdacmask:=reg.bl;
end;
end.