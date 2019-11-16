unit bereiche;
interface

procedure einschraenken(x1,y1,x2,y2:integer);
procedure entschraenken;

implementation
uses graph;
type PView = ^ViewPortType;
     PKette = ^TKette;
     TKette = record
              v: PView;
              n: PKette;
              end;
var kette: PKette;

procedure speichern;
var k: PKette;
    v:ViewPortType;
begin
 new(k);
 k^.n:=kette; kette:=k;
 new(k^.v); getViewSettings(k^.v^);
end;

procedure einschraenken(x1,y1,x2,y2:integer);
var x1_,y1_,x2_,y2_:integer;
begin
 speichern;
 x1_:=x1; if kette^.v^.x1>x1_ then x1_:=kette^.v^.x1;
 y1_:=y1; if kette^.v^.y1>y1_ then y1_:=kette^.v^.y1;
 x2_:=x2; if kette^.v^.x2<x2_ then x2_:=kette^.v^.x2;
 y2_:=y2; if kette^.v^.y2<y2_ then y2_:=kette^.v^.y2;
 setViewPort(x1_,y1_,x2_,y2_,true);
end;

procedure entschraenken;
var alt: PKette;
begin
 with kette^.v^ do setViewPort(x1,y1,x2,y2,clip);
 dispose(kette^.v);
 alt:=kette; kette:=kette^.n;
 dispose(alt);
end;

begin
kette:=nil;
end.