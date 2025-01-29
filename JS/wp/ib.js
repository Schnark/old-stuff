mw.libs.JSBotFn.defaultConfig.max = 500;
(new JSBot('Vorlage:Infobox Krankenhaus')).embeddedin().not(new JSBot('Vorlage:Infobox Krankenhaus'))
.edit(function (t, p) {
	var	text = p.text,
		infobox = mw.libs.Template('Infobox Krankenhaus', text);
	if (infobox === null) {
		return {reason: mw.libs.templateGetLastError()};
	}

	//Staat + Bundesland/Kanton -> Region-ISO
	var	iso_alt = (infobox.getVal('Region-ISO') || '').replace(/<!--.*?-->/g, '').replace(/^\s+|\s+$/g, ''),
		iso_neu = getISO(
			(infobox.getVal('Staat') || '') + (infobox.getVal('Land') || ''),
			(infobox.getVal('Bundesland') || '') + (infobox.getVal('Kanton') || '') + (infobox.getVal('Bundeslang') || '')
		);
	if (iso_alt === iso_neu) {
		p.isook = '';
	} else {
		if (iso_alt.indexOf('-') === -1 && iso_neu !== '') { //neue ist besser als alte
			infobox.change('Region-ISO', iso_neu) || infobox.insert('Region-ISO', iso_neu, 'Staat');
		}
	}
	infobox.remove('Staat');
	infobox.remove('Land');
	infobox.remove('Bundesland');
	infobox.remove('Kanton');
	infobox.remove('Bundeslang');

	//Leitung + Leitungstitel -> Kaufmännische Leitung + Kaufmännischer Leitungstitel & Ärztliche Leitung + Ärztlicher Leitungstitel FIXME
	var	leiter = infobox.getVal('Leitung') || '',
		titel = infobox.getVal('Leitungstitel') || '',
		k_leiter = '', k_titel = '',
		a_leiter = '', a_titel = '';
	if (titel) {
		k_leiter = leiter;
		k_titel = titel;
	} else {
		a_leiter = leiter;
		a_titel = titel;
	}
	infobox.insert('Kaufmännische Leitung', k_leiter, 'Leitung');
	infobox.insert('Kaufmännischer Leitungstitel', k_titel, 'Kaufmännische Leitung');
	infobox.insert('Ärztliche Leitung', a_leiter, 'Kaufmännischer Leitungstitel');
	infobox.insert('Ärztlicher Leitungstitel', a_titel, 'Ärztliche Leitung');
	infobox.remove('Leitung');
	infobox.remove('Leitungstitel');
	infobox.remove('Geschäftsführer');

	//Nebenbox entfernen, falls ohne Wert
	if ((infobox.getVal('Nebenbox') || '').replace(/<!--.*?-->/g, '').replace(/\s/g, '') === '') {
		infobox.remove('Nebenbox');
	}

	//FIXME -> FIXME
	infobox.rename('', '');

	//FIXME
	infobox.insert('')

	//Website formatieren
	var website = infobox.getVal('Website') || '[';
	if (website.indexOf('[') === -1) {
		if (website.indexOf('www.') === 0) {
			website = 'http://' + website;
		}
		website = '[' + website + ' ' + website.replace(/^https?:(www\.)?/, '').replace(/\/.*$/, '') + ']';
		infobox.change('Website', website);
	}

	//Falschschreibungen
	infobox.rename('Jahresbilanz', 'Jahresetat');
	infobox.rename('Mitarbeiter', 'Mitarbeiterzahl'); //FIXME
	infobox.rename('[[Versorgungsstufe]]', 'Versorgungsstufe');
	infobox.rename('Träger', 'Trägerschaft');
	infobox.rename('Stadt', 'Ort');

	//unbekannte Parameter
	infobox.remove('Studenten');
	infobox.remove('Institutskennzeichen');
	infobox.remove('Anzahl Kliniken');
	infobox.remove('Anzahl Kompetenzzentren');
	infobox.remove('davon Pfleger');
	infobox.remove('davon Professoren');
	infobox.remove('Studentenzahl');
	infobox.remove('Fachabteilungen');

	if (infobox.validate({
		'Name': {optional: true},
		'Logo': {optional: true},
		'Logogrösse': {optional: true, re: /^(?:|<!-- Nur in Ausnahmefällen, zum Beispiel 81px -->|\d+px)\s*$/},
		'Zugehörigkeit': {},
		'Trägerschaft': {},
		'Versorgungsstufe': {},
		'Bettenzahl': {},
		'Ort': {},
		'Breitengrad': {re: /^(?:\d\d?\/\d\d?\/\d\d?(?:\.\d+)\/[NS]|-?\d+(?:\.\d+)?)$/},
		'Längengrad': {re: /^(?:\d\d?\/\d\d?\/\d\d?(?:\.\d+)\/[WEO]|-?\d+(?:\.\d+)?)$/},
		'Region-ISO': {re: /^[A-Z]+(?:-[A-Z0-9]+)?$/},
		'Nebenbox': {optional: true, re: /\S/},
		'Kaufmännische Leitung': {},
		'Kaufmännischer Leitungstitel': {},
		'Ärztliche Leitung': {},
		'Ärztlicher Leitungstitel': {},
		//FIXME
		'Fachgebiete': {optional: true},
		'Jahresetat': {optional: true},
		'Gründungsdatum': {optional: true},
		'Website': {re: /http/}
	})) {
		p.valid = '';
	} else {
		p.valid = mw.libs.templateGetLastError();
	}

	return {text: infobox.toString(), summary: 'Bot: Stelle [[Vorlage:Infobox Krankenhaus]] um'};
}, 'simulate')
.alert(['#', 'title', 'editOK', 'editStatus', 'isook', 'valid'], botlog);




function getISO (adm1, adm2) {
	//DE
	if (adm2.indexOf('Baden-Württemberg') > -1) return 'DE-BW';
	if (adm2.indexOf('Bayern') > -1) return 'DE-BY';
	if (adm2.indexOf('Bremen') > -1) return 'DE-HB';
	if (adm2.indexOf('Hamburg') > -1) return 'DE-HH';
	if (adm2.indexOf('Hessen') > -1) return 'DE-HE';
	if (adm2.indexOf('Niedersachsen') > -1) return 'DE-NI';
	if (adm2.indexOf('Nordrhein-Westfalen') > -1) return 'DE-NW';
	if (adm2.indexOf('Rheinland-Pfalz') > -1) return 'DE-RP';
	if (adm2.indexOf('Saarland') > -1) return 'DE-SL';
	if (adm2.indexOf('Schleswig-Holstein') > -1) return 'DE-SH';
	if (adm2.indexOf('Berlin') > -1) return 'DE-BE';
	if (adm2.indexOf('Brandenburg') > -1) return 'DE-BB';
	if (adm2.indexOf('Mecklenburg-Vorpommern') > -1) return 'DE-MV';
	if (adm2.indexOf('Sachsen') > -1) return 'DE-SN';
	if (adm2.indexOf('Sachsen-Anhalt') > -1) return 'DE-ST';
	if (adm2.indexOf('Thüringen') > -1) return 'DE-TH';
	//AT
	if (adm2.indexOf('Burgenland') > -1) return 'AT-1';
	if (adm2.indexOf('Kärnten') > -1) return 'AT-2';
	if (adm2.indexOf('Niederösterreich') > -1) return 'AT-3';
	if (adm2.indexOf('Oberösterreich') > -1) return 'AT-4';
	if (adm2.indexOf('Salzburg') > -1) return 'AT-5';
	if (adm2.indexOf('Steiermark') > -1) return 'AT-6';
	if (adm2.indexOf('Tirol') > -1) return 'AT-7';
	if (adm2.indexOf('Vorarlberg') > -1) return 'AT-8';
	if (adm2.indexOf('Wien') > -1) return 'AT-9';
	//CH
	if (adm2.indexOf('Aargau') > -1) return 'CH-AG';
	if (adm2.indexOf('Appenzell Innerrhoden') > -1) return 'CH-AI';
	if (adm2.indexOf('Appenzell Ausserrhoden') > -1) return 'CH-AR';
	if (adm2.indexOf('Bern') > -1) return 'CH-BE';
	if (adm2.indexOf('Basel-Landschaft') > -1) return 'CH-BL';
	if (adm2.indexOf('Basel-Stadt') > -1) return 'CH-BS';
	if (adm2.indexOf('Fribourg') > -1) return 'CH-FR';
	if (adm2.indexOf('Genève') > -1) return 'CH-GE';
	if (adm2.indexOf('Glarus') > -1) return 'CH-GL';
	if (adm2.indexOf('Graubünden') > -1) return 'CH-GR';
	if (adm2.indexOf('Jura') > -1) return 'CH-JU';
	if (adm2.indexOf('Luzern') > -1) return 'CH-LU';
	if (adm2.indexOf('Neuchâtel') > -1) return 'CH-NE';
	if (adm2.indexOf('Nidwalden') > -1) return 'CH-NW';
	if (adm2.indexOf('Obwalden') > -1) return 'CH-OW';
	if (adm2.indexOf('Sankt Gallen') > -1) return 'CH-SG';
	if (adm2.indexOf('Schaffhausen') > -1) return 'CH-SH';
	if (adm2.indexOf('Solothurn') > -1) return 'CH-SO';
	if (adm2.indexOf('Schwyz') > -1) return 'CH-SZ';
	if (adm2.indexOf('Thurgau') > -1) return 'CH-TG';
	if (adm2.indexOf('Ticino') > -1) return 'CH-TI';
	if (adm2.indexOf('Uri') > -1) return 'CH-UR';
	if (adm2.indexOf('Vaud') > -1) return 'CH-VD';
	if (adm2.indexOf('Valais') > -1) return 'CH-VS';
	if (adm2.indexOf('Zug') > -1) return 'CH-ZG';
	if (adm2.indexOf('Zürich') > -1) return 'CH-ZH';
	//Default
	if (adm1.indexOf('Deutschland') > -1) return 'DE';
	if (adm1.indexOf('Österreich') > -1) return 'AT';
	if (adm1.indexOf('Schweiz') > -1) return 'CH';
	if (adm1.indexOf('USA') > -1) return 'US';
	if (adm1.indexOf('Vereinigte Staaten') > -1) return 'US';

	return '';
}