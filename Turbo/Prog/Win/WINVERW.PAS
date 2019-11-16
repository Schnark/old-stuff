unit winverw;
interface
 uses win;
 type typen = (app, doc, dlg);          {Anwendung, Dokument, Dialogfeld}
 type PHintergrund = ^THintergrund;
 type pdiaver = ^diaver;
      diaver = object
             dia: pwindow;              {Zeiger auf graph. Def.}
             ketteweiter: pdiaver;      {Kette mit allen diaver}
             selbst: pdiaver;           {Zeiger auf sich selbst}
             vorfahre: pdiaver;         {Vorfahre des Fensters}
             typ: typen;

             anwendung: pdiaver;  {NÑchstes}
             dokument: pdiaver;   {aktives}
             dialog: pdiaver;     {Fenster}

             alontop: byte;             {Hîhe "always on top"}
             hoeher: pdiaver;           {Fenster direkt darÅber}
             tiefer: pdiaver;           {Fenster direkt darunter}
             offen: boolean;
             constructor init(fenster: pwindow; t:typen);
             procedure wertesetzen(s: pdiaver);
             procedure oeffnen(vorf: pdiaver; aot: byte);
             procedure aktivieren;
             procedure schliessen;
             procedure schliessen_ohne_zeichnen;
             procedure nachoben;
             destructor fertig;
      end;

 function register(f: pwindow; t:typen): pdiaver;
 procedure registerback(h: PHintergrund);
 procedure redraw(ueber: pdiaver);
 procedure echo(anaus: boolean);

 function gethintergrund: PHintergrund;
 function getunten: PDiaver;
 function finden_verw(p: PWindow): PDiaver;
 function findew_m(x,y: integer): PWindow;
 function findew_t_app: PWindow;
 function findew_t_all: PWindow;

implementation
 var kettestart: pdiaver;
     aktiv: pdiaver;
     oben, unten: pdiaver;      {oberstes / unterstes Fenster}

     hintergrund: PHintergrund;


 constructor diaver.init;
 begin
  typ:=t;
  dia:=fenster;
  offen:=false;
 end;

 procedure diaver.wertesetzen;
 begin
     selbst:=s;
     ketteweiter:=kettestart;
     kettestart:=selbst;
 end;

procedure diaver.oeffnen;
var darunter, neuzeichnen: pdiaver;
begin
 if offen then exit;                        {bereits offen?}
 vorfahre:=vorf; alontop:=aot;              {initialisieren}
 if (vorf<>nil) and (vorf^.alontop>aot) then alontop:=vorf^.alontop;
 offen:=true; dia^.sichtbar:=true;
 dokument:=nil; dialog:=nil;
 neuzeichnen:=selbst;

 if typ=app then begin                      {Anwendung}
    anwendung:=aktiv;
    aktiv:=selbst;

    darunter:=oben;                                       {oben einordnen}
    while (darunter<>nil) and (darunter^.alontop>aot) do  {tiefer, bis kein}
          darunter:=darunter^.tiefer;                     {alontop darÅber}
    if darunter=nil then begin
       hoeher:=unten; if hoeher<>nil then hoeher^.tiefer:=selbst else oben:=selbst;
       unten:=selbst; tiefer:=nil;
    end else begin
       hoeher:=darunter^.hoeher; darunter^.hoeher:=selbst;
       tiefer:=darunter; if hoeher<>nil then hoeher^.tiefer:=selbst else oben:=selbst;
    end;

    if anwendung<>nil then begin {deaktivieren}
       anwendung^.dia^.OnLoseFocus; if anwendung^.alontop<=aot then neuzeichnen:=anwendung;
       if anwendung^.dokument<>nil then anwendung^.dokument^.dia^.OnLoseFocus;
       if anwendung^.dialog<>nil then anwendung^.dialog^.dia^.OnLoseFocus;
    end;
    dia^.OnGetFocus;
 end

 else begin
    if typ=doc then begin {Dokument}
       dokument:=vorfahre^.dokument; vorfahre^.dokument:=selbst; end
    else begin {Dialogfeld}
       dialog:=vorfahre^.dialog; vorfahre^.dialog:=selbst; end;
    if dokument<>nil then dokument^.dia^.OnLoseFocus;
    if dialog<>nil then dialog^.dia^.OnLoseFocus;
    dia^.aktiv:=false;
    if vorfahre^.dia^.aktiv then dia^.OnGetFocus;

    darunter:=vorfahre;
    if dokument<>nil then darunter:=dokument; if dialog<>nil then darunter:=dialog;
    while (darunter^.hoeher<>nil) and (darunter^.hoeher^.alontop<=aot)
          and not ((typ=doc) and (darunter^.hoeher^.typ=dlg) and (darunter^.hoeher^.vorfahre=vorfahre)) do
          darunter:=darunter^.hoeher;
    hoeher:=darunter^.hoeher; darunter^.hoeher:=selbst;
    tiefer:=darunter; if hoeher<>nil then hoeher^.tiefer:=selbst else oben:=selbst;
    if dia^.aktiv then neuzeichnen:=vorfahre^.hoeher;
 end;
 redraw(neuzeichnen);
end;

 procedure diaver.aktivieren;
 var i, neu: pdiaver;
 begin
  if not offen then exit;
  if (typ<>app) and dia^.aktiv then exit;
  if typ<>app then begin
     if typ=doc then begin
        vorfahre^.dokument^.dia^.OnLoseFocus;           {altes Dok. deakt.}
        if vorfahre^.dokument<>selbst then begin
           i:=vorfahre^.dokument;                       {in Reihe einordnen}
           while i^.dokument<>selbst do i:=i^.dokument;
           i^.dokument:=dokument;
           dokument:=vorfahre^.dokument;
           vorfahre^.dokument:=selbst;
        end;
     end else {typ = dlg} begin
        vorfahre^.dialog^.dia^.OnLoseFocus;           {altes Dia. deakt.}
        if vorfahre^.dialog<>selbst then begin
           i:=vorfahre^.dialog;                       {in Reihe einordnen}
           while i^.dialog<>selbst do i:=i^.dialog;
           i^.dialog:=dialog;
           dialog:=vorfahre^.dialog;
           vorfahre^.dialog:=selbst;
        end;
     end;
     if vorfahre^.dia^.aktiv then begin
        dia^.OnGetFocus;
        nachoben;
        redraw(vorfahre^.hoeher);
     end else vorfahre^.aktivieren;
  end else {typ = app} begin
     neu:=nil;
     if not dia^.aktiv then begin
        neu:=aktiv; if neu^.alontop>alontop then neu:=selbst;
        aktiv^.dia^.OnLoseFocus;    {deaktivieren}
        if aktiv^.dokument<>nil then aktiv^.dokument^.dia^.OnLoseFocus;
        if aktiv^.dialog<>nil then aktiv^.dialog^.dia^.OnLoseFocus;

        dia^.OnGetFocus;             {aktivieren}
     end;
     if dokument<>nil then dokument^.dia^.OnGetFocus;
     if dialog<>nil then dialog^.dia^.OnGetFocus;

     if neu=nil then exit;

     if aktiv<>selbst then begin  {in Reihe einordnen}
        i:=aktiv;
        while i^.anwendung<>selbst do i:=i^.anwendung;
        i^.anwendung:=anwendung;
        anwendung:=aktiv;
        aktiv:=selbst;
     end;
     nachoben;
     i:=oben;
     while i<>nil do begin
           if i^.vorfahre=selbst then i^.nachoben;
           i:=i^.tiefer;
     end;
     redraw(neu);
  end;
 end;

 procedure diaver.schliessen;
 begin
   if not offen then exit;
   schliessen_ohne_zeichnen;
   if aktiv <> nil then aktiv^.aktivieren;
   redraw(nil);
 end;

 procedure diaver.schliessen_ohne_zeichnen;
 var i: pdiaver;
 begin
  if typ=doc then begin
     i:=vorfahre;
     while i^.dokument<>selbst do i:=i^.dokument;
     i^.dokument:=dokument;
  end
  else if typ=dlg then begin
     i:=vorfahre;
     while i^.dialog<>selbst do i:=i^.dialog;
     i^.dialog:=dialog;
  end
  else begin
     if aktiv=selbst then
        aktiv:=anwendung
     else begin
        i:=aktiv;
        while i^.anwendung<>selbst do i:=i^.anwendung;
        i^.anwendung:=anwendung;
     end;
     while dokument<>nil do dokument^.schliessen_ohne_zeichnen;
     while dialog<>nil do dialog^.schliessen_ohne_zeichnen;
  end;
  dia^.OnLoseFocus;
  offen:=false;
  dia^.sichtbar:=false;
  if (vorfahre<>nil) and vorfahre^.dia^.aktiv then vorfahre^.dia^.OnGetFocus;
  vorfahre:=nil;

  i:=oben;
  while i<>nil do begin
        if i^.tiefer=selbst then i^.tiefer:=tiefer;
        if i^.hoeher=selbst then i^.hoeher:=hoeher;
        i:=i^.tiefer;
  end;
  if oben=selbst then oben:=tiefer;
  if unten=selbst then unten:=hoeher;

 end;

 procedure diaver.nachoben;
 label weiter,drueber;
 var i: pdiaver;
     v1,v2: pdiaver;
     erfolg: boolean;
     schonselbst: boolean;
 begin
  erfolg:=false;
  schonselbst:=false;
  i:=oben;
  while i<>nil do begin
   if i=selbst then begin schonselbst:=true; goto weiter; end;
   if i^.alontop>alontop then goto weiter;
   if ( i^.alontop<alontop ) then goto drueber;
   if vorfahre=nil then v1:=selbst else v1:=vorfahre;
   if i^.vorfahre=nil then v2:=i else v2:=i^.vorfahre;
   if ( v1<>v2 ) then goto drueber;
   if ( i^.typ=app ) then goto drueber;
   if ( (i^.typ=doc) and (typ=dlg) ) then goto drueber;
   if ( (i^.typ=dlg) and (typ=doc) ) then goto weiter;
   if ( dia^.aktiv=true ) then goto drueber;
   if schonselbst then goto drueber;

   goto weiter;
   drueber:

      v1:=i;
      i:=oben;
      while i<>nil do begin
            if i^.tiefer=selbst then i^.tiefer:=tiefer;
            if i^.hoeher=selbst then i^.hoeher:=hoeher;
            i:=i^.tiefer;
      end;
      if oben=selbst then oben:=tiefer;
      if unten=selbst then unten:=hoeher;

      hoeher:=v1^.hoeher; v1^.hoeher:=selbst;
      tiefer:=v1;
      if hoeher<>nil then hoeher^.tiefer:=selbst else oben:=selbst;

      erfolg:=true;
      i:=v1;
      while i^.tiefer<>nil do i:=i^.tiefer;

   weiter:
      i:=i^.tiefer;
  end;
  if (not erfolg) and (unten<>selbst) then begin
     hoeher:=unten; unten:=selbst;
     if hoeher<>nil then hoeher^.tiefer:=selbst else oben:=selbst;
     tiefer:=nil;
  end;
 end;

 destructor diaver.fertig;
 var i:pdiaver;
 begin
  i:=kettestart;
  while i<>nil do begin
   if i^.ketteweiter=selbst then i^.ketteweiter:=ketteweiter;
   i:=i^.ketteweiter;
  end;
 dia^.fertig;
 end;

 function register;
 var p:pdiaver;
 begin
 new(p,init(f,t));
 p^.wertesetzen(p);
 register:=p;
 end;

 procedure registerback;
 begin
  hintergrund:=h;
 end;

{ var redraw_durch_verw: byte;}

 procedure redraw;
 var i:pdiaver;
 begin
{  if redraw_durch_verw<>0 then exit;
  inc(redraw_durch_verw);

{  if ueber=nil then begin hintergrund^.zeichne; ueber:=unten; end;
  i:=ueber;
  while i<>nil do begin
   if i^.offen then i^.dia^.zeichne;
   i:=i^.hoeher;
  end;
} if ueber=nil then hintergrund^.zeichne else ueber^.dia^.zeichne;
{  dec(redraw_durch_verw);}
 end;

 procedure echo;
 begin
  ausg(anaus);
  if anaus then redraw(nil);
 end;

 function finden_verw;
 var d: pdiaver;
 begin
  d:=oben;
  while d<>nil do begin
        if d^.dia=p then begin
           finden_verw:=d;
           exit;
        end;
        d:=d^.tiefer;
  end;
  finden_verw:=nil;
 end;

 function findew_m;
 var p: pdiaver;
 begin
  p:=oben;
  while p<>nil do begin
        if p^.dia^.innen(x,y) then begin
           findew_m:=p^.dia;
           exit;
        end;
        p:=p^.tiefer;
  end;
  findew_m:=nil;
 end;

 function findew_t_all;
 begin
  if aktiv=nil then begin findew_t_all:=nil; exit; end;
  if aktiv^.dialog<>nil then begin findew_t_all:=aktiv^.dialog^.dia; exit; end;
  if aktiv^.dokument<>nil then begin findew_t_all:=aktiv^.dokument^.dia; exit; end;
  findew_t_all:=aktiv^.dia;
 end;

 function findew_t_app;
 begin
  if aktiv<>nil then findew_t_app:=aktiv^.dia else findew_t_app:=nil;
 end;

 function gethintergrund;
 begin
  gethintergrund:=hintergrund;
 end;

  function getunten; begin getunten:=unten; end;

begin
 kettestart:=nil; aktiv:=nil; oben:= nil; unten:=nil;
{ redraw_durch_verw:=0;}
end.