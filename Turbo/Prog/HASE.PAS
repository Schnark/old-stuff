program hase;
uses XMovie,graph,xgraph;
var F:TFigur;
begin
initXgraph('P:\TURBO\GRAPH');
skyline(0,getmaxy div 3,-1,-1,-1);
F.create(getmaxx div 2,getmaxy-150,1,'P:\TURBO\EXTRA');
F.setrange(0,getmaxy div 3,getmaxx,getmaxy);
F.show(1);
(*F.setsound(1);*)
F.steerkey(10);
F.free;
closegraph;
end.