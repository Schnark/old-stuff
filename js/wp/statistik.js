//Dokumentation unter [[Benutzer:Schnark/js/statistik]] <nowiki>
/*global mw: true */

(function($){

var statistik = {
version: 1.5,

max: 1,
abfragen: 0,
name: '',

zahlen: {
 namensraeume: {},
 stunden: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
 wochentage: [0, 0, 0, 0, 0, 0, 0],
 monate: {},
 titel: {},
 beitraege: 0
},
benutzer: {},

anfrage: function () {
   statistik.name = $('[name=target]').val();
   $.getJSON(mw.util.wikiScript('api'), {action: 'query', list: 'usercontribs|users', meta: 'globaluserinfo', ucuser: statistik.name, uclimit: 'max', ucprop: 'title|timestamp|comment|flags', ususers: statistik.name, usprop: 'groups|implicitgroups|editcount|gender|registration|blockinfo|emailable', guiuser: statistik.name, guiprop: 'groups', format: 'json'}, statistik.auszaehlen);
},

auszaehlen: function (json) {
   if (!json || !json.query) {
      return;
   }

   if (json.query.users) {
      statistik.benutzer = json.query.users[0];
   }
   if (json.query.globaluserinfo) {
      statistik.benutzer.global = json.query.globaluserinfo;
   }

   var beitraege = json.query.usercontribs;
   if (beitraege) {
      statistik.zahlen.beitraege += beitraege.length;
      for (var i = 0; i < beitraege.length; i++) {
          var beitrag = beitraege[i];
          var ns = beitrag.ns;
          statistik.zahlen.namensraeume[ns].anzahl++;
          if (beitrag.minor === '') {
             statistik.zahlen.namensraeume[ns].klein++;
          }
          if (beitrag['new'] === '') {
             statistik.zahlen.namensraeume[ns].neu++;
          }
          if (beitrag.top === '') {
             statistik.zahlen.namensraeume[ns].top++;
          }
          if (!(beitrag.comment || '').match(/^(?:\/\*.*\*\/)?$/)) {
             statistik.zahlen.namensraeume[ns].comment++;
          }
          var zeiten = /^(\d{4})-(\d\d)-(\d\d)T(\d\d)/.exec(beitrag.timestamp);
          statistik.zahlen.stunden[parseInt(zeiten[4], 10)]++;
          var monat = zeiten[1] + '-' + zeiten[2];
          if (!statistik.zahlen.monate[monat]) {
             statistik.zahlen.monate[monat] = 0;
          }
          statistik.zahlen.monate[monat]++;
          var datum = new Date(zeiten[1], zeiten[2] - 1, zeiten[3]);
          statistik.zahlen.wochentage[datum.getDay()]++;
          if (!statistik.zahlen.titel[beitrag.title]) {
             statistik.zahlen.titel[beitrag.title] = 0;
          }
          statistik.zahlen.titel[beitrag.title]++;
      }
   }

   if ((++statistik.abfragen < statistik.max) && json['query-continue']) {
      $.getJSON(mw.util.wikiScript('api'),
               {action: 'query', list: 'usercontribs', ucuser: statistik.name, uclimit: 'max',
                ucprop: 'title|timestamp|comment|flags', ucstart: json['query-continue'].usercontribs.ucstart,
                format: 'json'}, statistik.auszaehlen);
   } else {
      statistik.ausgeben();
   }
},

ausgeben: function() {
   var html = '';
   html += statistik.benutzerinfo(statistik.benutzer, statistik.zahlen.beitraege);
   html += statistik.zeiten(statistik.zahlen.stunden, statistik.zahlen.wochentage, statistik.zahlen.monate, statistik.zahlen.beitraege);
   html += statistik.inhalt(statistik.zahlen.namensraeume, statistik.zahlen.titel, statistik.zahlen.beitraege);
   $('#contentSub').after(html);
},

benutzerinfo: function (benutzer, anzahl) {
   var html = '<h2>Benutzerinfo</h2><dl>', gruppen = [], i;
   if (benutzer.global && benutzer.global.home) {
      html += '<dt>Heimatwiki</dt><dd>' + benutzer.global.home + '</dd>';
   }
   if (benutzer.registration) {
      html += '<dt>Anmeldezeitpunkt</dt><dd>' + benutzer.registration + '</dd>';
   }
   if (benutzer.global && benutzer.global.registration) {
      html += '<dt>Zeitpunkt der Erstellung des globalen Kontos</dt><dd>' + benutzer.global.registration + '</dd>';
   }
   if (benutzer.editcount) {
      html += '<dt>Beiträge</dt><dd>' + benutzer.editcount + ' (davon in die Statistik eingegangen: ' + anzahl + ')</dd>';
   }
   if (benutzer.groups) {
      for (i = 0; i < benutzer.groups.length; i++) {
          if ($.inArray(benutzer.groups[i], benutzer.implicitgroups) !== -1) {
             gruppen.push('(' + benutzer.groups[i] + ')');
          } else {
             gruppen.push(benutzer.groups[i]);
          }
      }
   }
   if (benutzer.global && benutzer.global.groups) {
      for (i = 0; i < benutzer.global.groups.length; i++) {
          gruppen.push(benutzer.global.groups[i] + ' (G)');
      }
   }
   if (gruppen.length) {
      html += '<dt>Benutzergruppen</dt>' + mw.html.element('dd', {}, gruppen.join(', '));
   }
   if (benutzer.gender) {
      html += '<dt>Geschlecht</dt><dd>' + ((benutzer.gender === 'male') ? 'männlich' : ((benutzer.gender === 'female') ? 'weiblich' : 'nicht angegeben')) + '</dd>';
   }
   html += '<dt>Email</dt><dd>' + ((benutzer.emailable === '') ? 'ja' : 'nein') + '</dd>';
   html += '<dt>Gesperrt</dt>' + mw.html.element('dd', {}, benutzer.blockedby ? 'durch ' + benutzer.blockedby + ' wegen ' + benutzer.blockreason : 'nein');
   html += '</dl>';
   return html;
},

zeiten: function (stunden, wochentage, monate, anzahl) {
   if (anzahl === 0) {
      return '';
   }
   var i, html = '<h2>Auswertung der Zeiten</h2>';
   html += '<h3>Beiträge nach Stunden</h3><table><tr><td></td>';
   for (i = 0; i < 24; i++) {
       html += '<td style="vertical-align:bottom;"><div style="background-color:blue;width:10px;height:' + Math.round(300*stunden[i]/anzahl) + 'px;"></div></td>';
   }
   html += '</tr><tr><td>Beiträge</td>';
   for (i = 0; i < 24; i++) {
       html += '<td>' + stunden[i] + '</td>';
   }
   html += '</tr><tr><td>Stunden (UTC)</td>';
   for (i = 0; i < 24; i++) {
       html += '<td>' + i + '</td>';
   }
   html += '</tr></table><h3>Beiträge nach Wochentagen</h3><table><tr><td></td>';
   for (i = 0; i < 7; i++) {
      html += '<td style="vertical-align:bottom;"><div style="background-color:blue;width:10px;height:' + Math.round(300*wochentage[i]/anzahl) + 'px;"></div></td>';
   }
   html += '</tr><tr><td>Beiträge</td>';
   for (i = 0; i < 7; i++) {
       html += '<td>' + wochentage[i] + '</td>';
   }
   html += '</tr><tr><td>Wochentag</td><td>So</td><td>Mo</td><td>Di</td><td>Mi</td><td>Do</td><td>Fr</td><td>Sa</td></tr></table>';
   html += '<h3>Beiträge nach Monaten</h3><table>';
   var m = [];
   for (i in monate) {
       m.push(i);
   }
   m = m.sort();
   for (i = 0; i < m.length; i++) {
       html += '<tr><td>' + m[i] + '</td><td>' + monate[m[i]] + '<div style="background-color:blue;height:10px;width:' + monate[m[i]] + 'px;"></div></td></tr>';
   }
   html += '</table>';
   return html;
},

inhalt: function (nr, titel, anzahl) {
   if (anzahl === 0) {
      return '';
   }
   var html = '<h2>Auswertung nach Namensräumen</h2><table><tr><th></th>' +
              '<th>Beiträge</th><th>%</th>' +
              '<th>neu</th><th>%</th>' +
              '<th>klein</th><th>%</th>' +
              '<th>mit Kommentar</th><th>%</th>' +
              '<th>aktuell</th><th>%</th></tr>',
       neu = 0, klein = 0, comment = 0, top = 0;
   for (var id in nr) {
       html += '<tr>' + mw.html.element('td', {}, mw.config.get('wgFormattedNamespaces')[id]) + '<td>' +
               nr[id].anzahl + '</td><td>' + Math.round(100*nr[id].anzahl/anzahl) + '</td><td>';
       if (nr[id].anzahl === 0) {
          html += '</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>';
       } else {
          html += nr[id].neu + '</td><td>' + Math.round(100*nr[id].neu/nr[id].anzahl) + '</td><td>' +
                  nr[id].klein + '</td><td>' + Math.round(100*nr[id].klein/nr[id].anzahl) + '</td><td>' +
                  nr[id].comment + '</td><td>' + Math.round(100*nr[id].comment/nr[id].anzahl) + '</td><td>' +
                  nr[id].top + '</td><td>' + Math.round(100*nr[id].top/nr[id].anzahl) + '</td></tr>';
       }
       neu += nr[id].neu; klein += nr[id].klein; comment += nr[id].comment; top += nr[id].top;
   }
   html += '<tr><td><b>Gesamt</b></td><td>' + anzahl + '</td><td></td><td>' +
           neu + '</td><td>' + Math.round(100*neu/anzahl) + '</td><td>' +
           klein + '</td><td>' + Math.round(100*klein/anzahl) + '</td><td>' +
           comment + '</td><td>' + Math.round(100*comment/anzahl) + '</td><td>' +
           top + '</td><td>' + Math.round(100*top/anzahl) + '</td></tr></table>';
   html += '<h2>Am häufigsten bearbeitete Seiten</h2><dl>';
   var zahlen = [], i;
   for (i in titel) {
       if (zahlen.indexOf(titel[i]) === -1) {
          zahlen.push(titel[i]);
       }
   }
   zahlen = zahlen.sort(function (a, b) { return a - b; }).reverse();
   for (i = 0; i < Math.round(zahlen.length*2/3); i++) {
       if (zahlen[i] <= 3 && i !== 0) {
          break;
       }
       html += '<dt>' + zahlen[i] + ' Mal</dt><dd>';
       var t = [];
       for (var j in titel) {
           if (titel[j] === zahlen[i]) {
              t.push(mw.html.element('a', {href: mw.util.wikiGetlink(j)}, j));
           }
       }
       html += t.sort().join(', ') + '</dd>';
   }
   html += '</dl>';
   return html;
},

init: function () {
   var max = mw.util.getParamValue('statistik-max');
   if (max !== null && /^\d+$/.test(max)) {
      statistik.max = Number(max);
   }
   for (var ns in mw.config.get('wgFormattedNamespaces')) {
       if (ns !== '-2' && ns !== '-1') {
          statistik.zahlen.namensraeume[ns] = {anzahl: 0, klein: 0, neu: 0, top: 0, comment: 0};
       }
   }
   $('#firstHeading').one('click', statistik.anfrage);
}
};

if (mw.config.get('debug')) {window.statistik = statistik;}
$(document).trigger('loadWikiScript', ['Benutzer:Schnark/js/statistik.js', statistik]);

if (mw.config.get('wgCanonicalSpecialPageName') === 'Contributions') {
   $(statistik.init);
}

})(jQuery);
//</nowiki>
