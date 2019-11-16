unit astr;
interface
uses koordinaten, astronomie;

var daten: record
           zeit: real;
           ekl_w: real;
           sternzeit: real;
           erde: helio_ekl;
           ort: geo_aequ;
           end;

var h_e: helio_ekl;
    g_e: geo_ekl;
    g_ae: geo_aequ;
    t_ae: topo_aequ;
    hor: horizontal;

procedure zeit_setzen(t: real);
procedure berechne_himmelskoerper(k: himmelskoerper);

implementation

procedure zeit_setzen(t: real);
begin
 with daten do begin
  zeit:=t;
  ekl_w:=ekliptikwinkel_t(t);
  sternzeit:=lokale_Sternzeit(t, geogr_laenge);
  ort.d:=0.000042635;
  ort.delta:=geogr_breite;
  ort.alpha:=sternzeit;
  erde.r:=1;
  erde.b:=0;
  erde.l:=M_t(astronomie.erde, t);
 end;
end;

procedure berechne_himmelskoerper(k: himmelskoerper);
var p:bahnebene;
begin
 if k=sonne then begin
    g_e.d:=daten.erde.r; g_e.beta:=daten.erde.b; g_e.lambda:=daten.erde.l;
 end;
 if k=erde then begin
    h_e.r:=daten.erde.r; h_e.b:=daten.erde.b; h_e.l:=daten.erde.l;
 end;
 if k=mond then begin
    mond_geoekl(daten.zeit, g_e);
    geoekl_helioekl(g_e, daten.erde, h_e);
 end;
 if k in [merkur, venus, mars .. pluto] then begin
    p.r:=grosse_halbachse[k]; p.u:=M_t(k,daten.zeit)+W_t(k,daten.zeit); {?}
    bahn_helioekl(p, Omega_t(k, daten.zeit), neigung_t(k, daten.zeit), h_e);
    helioekl_geoekl(h_e, daten.erde, g_e);
 end;
 if k <> erde then begin
    geoekl_geoaequ(g_e, daten.ekl_w, g_ae);
    geoaequ_topoaequ(g_ae, daten.ort, t_ae);
    topoaequ_horiz(t_ae, daten.sternzeit, daten.ort.delta, hor);
 end;

end;

end.