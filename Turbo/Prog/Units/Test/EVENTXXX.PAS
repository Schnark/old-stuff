uses graph2,maus,events,graph,crt;
begin
init;
setcolor(lightgray);
rectangle(0,0,100,100);
mauson;
repeat
 m_events;
{  getrawevent;
  getevent;
  getrawevent;
  makemouseevent;
  getevent;
  getrawevent;
  makemouseevent;
  getevent;

 getrawevent;
 getrawevent;
 getevent;
 getevent;
 getrawevent;
 getevent;
 makemouseevent;
 getrawevent;
 makemouseevent;
 getevent;
}
until keypressed;
mausoff;
closegraph;
end.