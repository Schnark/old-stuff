// --------------------------------------------------------------------
// VZ ist eine kleine Welt -- Suche nach Verbindungen über mehr als einen Freund hinweg
// Copyright (C) 2009 Michael Müller
// Email: <Vorname><Unterstrich><Nachname mit aufglöstem Umlaut><Pi mit 4 Nachkommastellen und Unterstrich statt Komma><bei>gmx<Punkt>de
// Profil: http://
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//  or read it online: <http://www.gnu.org/licenses/gpl-2.0.html>
//
//  Eine inoffizielle deutsche Übersetzung findet sich unter
//  <http://www.gnu.de/documents/gpl-2.0.de.html>
//
//  Das Programm basiert zu Teilen auf den VZ-Tools (<http://userscripts.org/scripts/show/38483>)
//  von Henning Schaefer (<http://userscripts.org/users/74882>).
//
// --------------------------------------------------------------------
//  Für die Zukunft geplant
//  - Bilder anzeigen
//  - korrigierter Algorithmus, falls Treffen nicht in Mitte
//  - Algorithmus nur abbrechen, wenn beide Seiten in Sackgasse (erfordert Einbindung auch dort, wo der Kasten "Verbindung" fehlt)
//  - Konfigurationsdialog
//  - Heuristiken um die Abfragen zu minimieren, aber immer noch vernünftige Ergebnisse zu erzielen
//  - bereits implementierten Abbruch bei nicht mehr voller Seite aktivieren
//  - Abbruch bei Captcha, erst wird sowieso nichts mehr
//
//  Versionsgeschichte
//  1.1.x: rudimentärer Konfigurationsdialog
//  1.0.x: Funktion nett einbinden (nein, bei jedem Seitenaufruf eine Input-Box ist nicht nett)
//  0.4.x: die Anbindung an studiVZ funktioniert!
//  0.3.x: verbesserter Algorithmus, Laufzeit auf Wurzel heruntergebracht
//  0.2.x: erster Versuch, das Ganze an studiVZ anzubinden, es blieb beim Versuch
//  0.1.x: ursprünglicher Algorithmus
//
// --------------------------------------------------------------------
// ==UserScript==
// @name           VZ: Kleine Welt
// @namespace      vzisteinekleinewelt
// @description    sucht nach Verbindungen aus einer Kette von Freunden
// @version        1.1.42
// @include        http://*.meinvz.tld/*
// @include        http://*.studivz.tld/*
// @include        http://*.schuelervz.tld/*
// ==/UserScript==

//============================== Globale Variablen ====================
// Informationen über aktuell aufgerufene Seite: (aus VZ-Tools)
var host = window.location.host;
var url = window.location.protocol + "//" + host + "/";

// Eigene Profil-ID feststellen (aus VZ-Tools)
var profId = document.evaluate('//ul[@id="Grid-Navigation-Main"]/li[2]/a', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).wrappedJSObject;
    profId = profId.singleNodeValue.href
    profId = profId.substring(profId.indexOf("Profile/") + 8, profId.length - 8);

var idlaenge = profId.length;                                          //Länge einer ID

var Namen = new Object();                                              //Namen[Id] liefert Name zu einer Id
Namen[profId] = "ich";                                                 //sollte eigentlich überschrieben werden
var Bilder = new Object();                                             //Bilder[Id] liefert Bild-URL zu einer Id

var maximum = 3;                                                       //Maximale Suchtiefe (Personen dazwischen)

//============================== Hilfsfunktion ========================
var Freunde = new Array();

holeFreunde = function(vonwem) {
//speichert alle Freunde im Array Freunde[], gibt deren Anzahl zurück
var freundeproseite = 1;                                               //Anzahl der Freunde pro Seite, zum schnelleren Abbruch
var index = 0;
var seite = 1;
while (1) {                                                            //in einer hoffentlich irgendwann endenden Endlosschleife die Seiten durchgehen
      var req = new XMLHttpRequest();
      req.open("GET", url + "Friends/Friends/" + vonwem + "/p/" + seite, false);
                                                                       //hole Seite mit Freunden und warte
      req.send(null);                                                  //was auch immer das tut, es stand so im Beispiel
      if(req.status !== 200) {
         debug_message += "\nFehler beim Aufruf von " + url + "Friends/Friends/" + vonwem + "/p/" + seite;
         return index;}                                                //kein Erfolg -> Ende
      var friends = document.createElement("div");
      friends.innerHTML = req.responseText;
      friends = friends.getElementsByTagName("tbody")[0];
      if (friends) {
         var tags = friends.getElementsByTagName("tr");
         var nodes = [];
         for (var n = 0; n < tags.length; n++)
             nodes[nodes.length] = tags[n].wrappedJSObject;}
      if ((!friends) || (nodes.length == 0)) return index;             //keine Freunde mehr da -> Ende
      for (var i = 0 ; i < nodes.length; i++) {                        //sonst alle auslesen
          var urlf = nodes[i].childNodes[1].childNodes[1].href;
          var name = nodes[i].childNodes[1].childNodes[1].childNodes[1].alt;
          var id = urlf.substring(urlf.length - idlaenge, urlf.length);
          Freunde[index] = id; Namen[id] = name;
          Bilder[index] = "wasweissich";
          index++;}
      if (index % freundeproseite != 0) {
          debug_message += "\nSeite " + seite + " von " + vonwem + "war nicht mehr voll. Insgesamt " + index + " Freunde."
          return index;}                                               //Seite war nicht mehr voll -> Ende
      seite++;}                                                        //nächste Seite
}

//============================== DER Hauptbestandteil =================
var Kette = new Array();
findeVerbindung = function(von, nach) {
//sucht Verbindung, gibt Länge der Kette zurück, Kette[0]=nach, Kette[return]=von
debug_message += "\nStarte Suche von " + von + " zu " + nach + " bis Tiefe " + maximum;
var erfolg = 0;

if (von == nach) {Kette[0] = von; return 0;}                           //von und nach identisch

var a = new Array(2);                                                  //a[x] (x=0, 1): von vorne und hinten
a[0] = new Array();                                                    //a[x][k][0]: möglicher Freund, a[x][k][1]: dessen Vorgänger in der Kette
a[0][0] = new Array(2);
a[0][0][0] = von; a[0][0][1] = "";                                     //erster Freund, kein Vorgänger
a[1] = new Array();
a[1][0] = new Array(2);
a[1][0][0] = nach; a[1][0][1] = "";                                    //letzter Freund, kein Vorgänger

var treffen;                                                           //wo die Ketten aufeinandertreffen

var s = 0; p = 0;                                                      //Stufe, Richtung
var k_min = new Array(2); var k_max = new Array(2);                    //k_min: bis zu diesem Index untersucht, k_max: größter Index
k_min[0] = -1; k_min[1] = -1; k_max[0] = 0; k_max[1] = 0;
var k_min_ = new Array(2); var k_max_ = new Array(2);                  //jeweils alte Werte

repeat: do {
    k_min_[p] = k_max[p]; k_max_[p] = k_max[p];                        //alte Werte speichern
    for (var k = k_min[p] + 1; k <= k_max[p]; k++) {                   //von der kleinsten bis zur größten noch nicht untersuchten Person
        var anzahl = holeFreunde(a[p][k][0]);                          //Freunde holen
        forR: for (var i = 0; i < anzahl; i++) {                       //jeden Freund untersuchen
            var R = Freunde[i];
            for (var l = 0; l <= k_max_[p]; l++)
                if (a[p][l][0] == R) continue forR;                    //ob er schon vorkommt
            k_max_[p]++;                                               //ansonsten hinten anhängen
            a[p][k_max_[p]] = new Array(2);
            a[p][k_max_[p]][0] = R; a[p][k_max_[p]][1] = a[p][k][0];   //Vorgänger ist aktuell untersuchter Freund
            for (var n = 0; n <= k_max[1 - p]; n++)
                 if (R == a[1 - p][n][0]) {                            //am Ziel angekommen?
                    erfolg = 1; treffen = R; break repeat;}
        }
    }
    k_min[p] = k_min_[p]; k_max[p] = k_max_[p]; s++; p = 1 - p;
} while ((k_min[1 - p] != k_max[1 - p]) && (s <= maximum));            //weiter bis keine neuen Freunde oder zu viele Iterationen

if (erfolg == 0) return -1;

Kette[Math.ceil(s/2)] = treffen;                                       //in der Mitte
for (var i = Math.ceil(s/2) - 1; i >= 0; i--) {                        //Kette nach vorne ...
    forj1: for (var j = 0; j <= k_max_[1]; j++)
           if (a[1][j][0] == Kette[i + 1]) break forj1;
    Kette[i] = a[1][j][1];}
for (var i = Math.ceil(s/2) + 1; i <= s + 1; i++) {                    //... und hinten fortsetzen
    forj2: for (var j = 0; j <= k_max_[0]; j++)
           if (a[0][j][0] == Kette[i - 1]) break forj2;
    Kette[i] = a[0][j][1];}

return s + 1;
}

//============================== Ein- und Ausgabe =====================
starteSuche = function() {
var icon = "data:image/gif,GIF89a%10%00%10%00%E3%00%00%00%00%00%24%24%24GGGkkk%8F%8F%8F%B3%B3" +
    "%B3%D6%D6%D6%FA%FA%FA%FF%FF%FF%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00" +
    "%00!%FF%0BNETSCAPE2.0%03%01%00%00%00!%F9%04%05%0A%00%0F%00%2C%00%00%00%00%10%00%10%00%00%04" +
    "%40%F0%C9%89*%9A%98V%00l~%D6%D6%85%18%12%04au%1C%97T%9D)%B2Vnl%83v%8E%08%82%8E%18%86%0A%CF" +
    "%07%F4%DD%8C%1E%DC%60%10%2B%14h%AEe%F3Y%0A%11%08%A9%8F%E5%9A%FC%D4%A0%98%08%00!%F9%04%05%0A" +
    "%00%0F%00%2C%01%00%01%00%0E%00%0E%00%00%04'%F0%C9%19%C2%BC%B8%E2)%C4%06%C0%D5%7D%E1f%9E%E70" +
    "%A0%CFq%A8%AC%CB%CE(Al%86q%D9%B8n%16%05%1Ap%13%01%00!%F9%04%05%0A%00%0F%00%2C%01%00%01%00%0E" +
    "%00%0E%00%00%04'%F0%C9)%C4%BC%B8%E29%C6%0E%C1%D5%7D%E1f%9E'A%A0%0F%00%A8%AC%CB%CEhQl%C7q%D9" +
    "%B8n%1A%06%1Ap%13%01%00!%F9%04%05%0A%00%0F%00%2C%01%00%01%00%0E%00%0E%00%00%04'%F0%C99%C6%BC" +
    "%B8%E2I%C8%16%C2%D5%7D%E1f%9EgQ%A0O%10%A8%AC%CB%CE%A8al%00p%D9%B8n%1E%07%1Ap%13%01%00!%F9%04" +
    "%05%0A%00%0F%00%2C%01%00%01%00%0E%00%0E%00%00%04'%F0%C9I%C8%BC%B8%E2Y%CA%1E%C3%D5%7D%E1f%9E" +
    "%A7a%A0%8F%20%A8%AC%CB%CE%E8qlAp%D9%B8n%02%00%1Ap%13%01%00!%F9%04%05%0A%00%0F%00%2C%01%00%01" +
    "%00%0E%00%0E%00%00%04'%F0%C9Y%CA%BC%B8%E2i%CC%26%C4%D5%7D%E1f%9E%E7q%A0%CF0%A8%AC%CB%CE(%00l" +
    "%82p%D9%B8n%06%01%1Ap%13%01%00!%F9%04%05%0A%00%0F%00%2C%01%00%01%00%0E%00%0E%00%00%04'%F0%C9i" +
    "%CC%BC%B8%E2y%CE.%C5%D5%7D%E1f%9E'%00%A0%0FA%A8%AC%CB%CEh%10l%C3p%D9%B8n%0A%02%1Ap%13%01%00!" +
    "%F9%04%05%0A%00%0F%00%2C%01%00%01%00%0E%00%0E%00%00%04'%F0%C9y%CE%BC%B8%E2%09%C06%C6%D5%7D" +
    "%E1f%9Eg%10%A0OQ%A8%AC%CB%CE%A8%20l%04q%D9%B8n%0E%03%1Ap%13%01%00%3B";
                                                                       //mit GIMP erstelltes und mit
                                                                       //<http://software.hixie.ch/utilities/cgi/data/data>
                                                                       //konvertiertes Icon
var verbindung = document.getElementById("Friends-Connection");        //Der "Verbindung"-Kasten
verbindung.innerHTML = '<h2>Verbindung</h2><p><img src="' + icon + '" alt = "Bitte warten!" /><p>';
var du = document.URL.substr(document.URL.length - idlaenge);          //ID der Person, deren Seite man gerade besucht
var titel = document.title;                                            //Titel des Dokuments enthält Namen
Namen[du] = titel.substr(titel.indexOf("|")+1);                        //Name extrahieren, nur für den Notfall
Bilder[du] = "Wertderhoffentlichueberschriebenwird";

var zahl = findeVerbindung(profId, du);

var ergebnis = "<h2>Verbindung</h2>";
if (zahl == -1)                                                        //keine Verbindung gefunden
   ergebnis += "<p>Auch keine Verbindung über " + maximum + " Zwischenstationen gefunden";
else {                                                                 //Verbindung aufbauen
  ergebnis += '<ul class="obj-thumbnaillist">';
  for (var i = zahl; i >= 0; i--)
      ergebnis +='<li><div class="imageContainer"><a href="http://www.studivz.net/Profile/' +
      Kette[i] + '"><img src="' + Bilder[Kette[i]] + '" alt="' + Namen[Kette[i]] + '"></a></div>' +
      '<div class="caption"><a href="http://www.studivz.net/Profile/' + Kette[i] +'">' +
      Namen[Kette[i]] + '</a></div></li>';
  ergebnis += "</ul>";
}
verbindung.innerHTML = ergebnis;                                       //Ergebnis anzeigen
}

//============================== Konfiguration ========================
//Prinzip und Gestaltung von den VZ-Tools übernommen
GM_registerMenuCommand("VZ: Kleine Welt - Einstellungen", konfiguration);
var dialog;
//Farben
var siteName = host.slice(host.indexOf(".")+1, host.length);
var color1 = "#FFFFFF";
var color2 = "#FFFFFF";
if (siteName == "meinvz.net") {
  color1 = "#ff781e";
  color2 = "#ffa05f";
}else{
  color1 = "#ee0000";
  color2 = "#ffa0a0";
}

function swapTabs(evt) {
  var handles = document.getElementsByClassName("tabhandle");
  for (n = 0; n < handles.length; n++) {
    handles[n].wrappedJSObject.style.backgroundColor = "transparent";
  }
  var pages = document.getElementsByClassName("tabpage");
  for (n = 0; n < pages.length; n++) {
    pages[n].wrappedJSObject.style.display = "none";
  }
  evt.target.wrappedJSObject.style.backgroundColor = color2;
  switch(evt.target.wrappedJSObject.id) {
    case "handle1":
        document.getElementById("tab1").style.display = "block";
      break;
    case "handle2":
        document.getElementById("tab2").style.display = "block";
      break;
    case "handle3":
        document.getElementById("tab3").style.display = "block";
      break;
  }
}

konfiguration = function() {
var icon = "data:image/gif,GIF89a%20%00%20%00%C2%02%00%00%00%FF%FF%00%00%FFw" +
    "%00%00%FF%00%FF%FF%00%FFw%00%FFw%00%FFw%00!%F9%04%01%0A%00%07%00%2C%00%00" +
    "%00%00%20%00%20%00%00%03%AB%18%B7%BC%DA0%C6%F0%1A%95X%5E%B8%97%F8B%C6UL'" + 
    "%10(%11%8A%25i%AA%A0%CA%3A%EEs%AE%9E%3Co%DB%1D%F9%2C%9E%02%F8%D3e%84DIRC" +
    "%09%00%01P%C0%00%CAXN%9C%BA%A8t0%05T%8D%18%60%97K%26%7Fq%C5%157Z%26%7B%0F" +
    "%D6%1C%AE%2B%AD%97%DF%F1%24%5D%BB%E5~%C0g%10%7C%7De(h%0DKZm%7D%1F%19KkPwQ" +
    "%2C%8F%7B%90%93%94F'%96%7C3r%7F!%83%98%9Ep)8%A2%A4%88%8DAM%AD%AD%A9W%AEM%B0" +
    "%3B%1D%B4%18%B3%B7G%B6%BA%23%24%BD%16%BC%C04%BF%C3%07%B2%AF%BD%C8%AE%09%00%3B";
                                                                       //mit GIMP erstelltes und mit
                                                                       //<http://software.hixie.ch/utilities/cgi/data/data>
                                                                       //konvertiertes Icon

var text = "";
text += "<div id='handle1' class='tabhandle' style='background-color: " + color2 +
        "; cursor: pointer; font-weight: bold; border: 1px solid " + color1 +
        "; border-bottom: none; padding: 4px;float: left;'>Konfiguration</div>";
text += "<div id='handle2' class='tabhandle' style='cursor: pointer; font-weight: bold; border: 1px solid "
        + color1 + "; border-bottom: none; border-left: none; padding: 4px;float: left;'>Debug/Hilfe</div>";
text += "<div id='handle3' class='tabhandle' style='cursor: pointer; font-weight: bold; border: 1px solid  "
        + color1 + "; border-bottom: none; border-left: none; padding: 4px;float: left;'>Info</div>";

text += "<div style='position: relative; clear: both; width: 480px; height: 390px; border: 1px solid  "
        + color1 + ";'>";

// Tab 1: Konfiguration
text += "<div id='tab1' class='tabpage' style='width: 460px; padding: 10px; position: absolute; top: 0px; left: 0px;'>";
text += "<h2>Allgemeine Werte</h2>";
text += "Maximale <span title='Anzahl der Personen zwischen dir und dem anderen' style='border-bottom: 1px dotted #808080; cursor: help;'>Suchtiefe</span>: <input type='text' size='2' maxlength='2' id='vkw_varmax' value='" + maximum + "'/><br />";
text += "Bitte beachte, dass derzeit die Werte nicht dauerhaft gespeichert werden!";
text += "</div>";

// Tab 2: Debug/Hilfe
text += "<div id='tab2' class='tabpage' style='display: none; width: 460px; padding: 10px; position: absolute; top: 0px; left: 0px;'>";
text += "<h2>Debug-Funktionen</h2>";
text += "&raquo; <a href='javascript:void(null)' id='vkw_speziellesuche'>Beliebige Suche durchführen</a><br />";
text += "&raquo; <a href='javascript:void(null)' id='vkw_display'>Fehler- und sonstige Meldungen anzeigen</a><br />";
text += "<h2>Hilfe</h2>";
text += "Hier steht ein nicht hilfreicher Hilfetext";
text += "</div>";

// Tab 3: Info
text += "<div id='tab3' class='tabpage' style='display: none; width: 460px; padding: 10px; position: absolute; top: 0px; left: 0px;'>";
text += "<h2>Info</h2>";
text += "<img src='" + icon + "' alt='VZ ist eine kleine Welt' />";
text += "<b>VZ ist eine kleine Welt</b> – Suche nach Verbindungen über mehr als einen Freund hinweg<br />";
text += "© 2009 Michael Müller<br />";
text += "GPL";
text += "<a href='" + url + "OYwasweissich/'>Profil</a>";
text += "</div>";

text += "</div><br />";
text += '<br /><br /><center><a href="javascript:void(null)" id="vkw_speichern" ><b>[Speichern]</b></a> <a href="javascript:void(null)" id="vkw_abbrechen" ><b>[Abbrechen]</b></a></center>';

dialog = unsafeWindow.Phx.UI.Dialog.ButtonDialog(
                        "VZ: Kleine Welt - Einstellungen",
                        { "message" : text,
                          "buttons" : [ ]
                        });
dialog.show();
document.getElementById("vkw_speziellesuche").addEventListener("click", debug, false);
document.getElementById("vkw_display").addEventListener("click", displayDebug, false);

document.getElementById("vkw_abbrechen").addEventListener("click", function (e) {dialog.close();}, false);
document.getElementById("vkw_speichern").addEventListener("click", konfigurationspeichern, false);

document.getElementById("handle1").addEventListener("click", swapTabs, false);
document.getElementById("handle2").addEventListener("click", swapTabs, false);
document.getElementById("handle3").addEventListener("click", swapTabs, false);
}

konfigurationspeichern = function() {
maximum = document.getElementById("vkw_varmax").value;
dialog.close();
window.location.reload();
}

//============================== Debug/Test ===========================
var debug_message = "";
displayDebug = function() {
alert(debug_message);}

debug = function() {
maximum = prompt("Suchtiefe:", maximum);
var p1 = prompt("ID von erster Person:", profId);
var p2 = prompt("ID von zweiter Person:", profId);
var zahl = findeVerbindung(p1, p2);
if (zahl == -1) {alert("Keine Verbindung!"); return;}
Namen[p1] = "der erste"; Namen[p2] = "der zweite";
var antwort = "";
for (var i = 0; i <= zahl; i++) antwort += i + ": " + Namen[Kette[i]] + " (" + Kette[i] + ")\n";
alert(antwort);
}

//============================== Einbindung in Seite ==================
einbinden = function() {
var verbindung = document.getElementById("Friends-Connection");        //Der "Verbindung"-Kasten
if (!verbindung) debug_message += "\nKein Verbindungskasten vorhanden";
if (verbindung && verbindung.innerHTML.indexOf("Keine Verbindung gefunden") > -1) {
   verbindung.innerHTML = '<h2>Verbindung</h2><p>Keine Verbindung gefunden<br\>' +
   '<a href="javascript:void(null)" id="vkw_startesuche">[Längere Verbindung suchen]</a></p>';
                                                                       //falls keine Verbindung, Link einfügen ...
   document.getElementById("vkw_startesuche").addEventListener("click", starteSuche,false); }
                                                                       //... und Event-Listener installieren
}

window.addEventListener("load", function() { 
 debug_message += "Los geht's!";
 einbinden(); },true);