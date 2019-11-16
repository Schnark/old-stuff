unit graph2;
interface
procedure init;
procedure init2;
function font(name: string): integer;

implementation
uses graph;
const pfad: string = 'P:\TURBO\GRAPH';
procedure init;
var treiber, modus, fehler: integer;
begin
  treiber := Detect;
  InitGraph(treiber, modus, pfad);
  fehler := GraphResult;
  if fehler <> grOk then
  begin
   Writeln('Grafikfehler: ', GraphErrorMsg(fehler), ' (', -fehler, ')');
   readln;
   halt;
  end;
end;

procedure treiberegavga; external;
{$L egavga.obj}

procedure init2;
var treiber, modus, fehler: integer;
begin
  fehler := registerbgidriver(@treiberegavga);
  if fehler >= 0 then
  begin
   treiber := Detect;
   initgraph(treiber, modus, '');
   fehler := graphresult;
  end;
  if fehler <> grOK then
  begin
   writeln('Grafikfehler: ', grapherrormsg(fehler), ' (', -fehler, ')');
   readln;
   halt;
  end;
end;

function font(name: string): integer;
begin
font := installuserfont(name);
end;

end.

