var translationsFromWD = {
	Q215627: 'p',
	Q4167410: 'n',
	Q43229: 'k',
	Q1656682: 'v',
	Q386724: 'w',
	Q1969448: 's',
	Q618123: 'g',
	Q44148: 'Mann',
	Q43445: 'Frau'
}, translationsToWD = {
}, mapFromWD = {
}, mapToWD = {
	title: 'label',
	alternativnamen: 'alias',
	kurzbeschreibung: 'description',
	geburtsort: [true, 'p19'],
	sterbeort: [true, 'p20'],
	typ: [true, 'p107']
};

function ajax (type, data, callback) {
	data.format = 'json';
	//TODO
	callback({});
}

function callTranslationFromWD (item) {
	//TODO
	translationsFromWD[item] = item;
}
function callTranslationToWD (title) {
	//TODO
	translationsToWD[title] = false;
}

function getTranslationFromWD (item) {
	item = item.replace(/^q/, 'Q');
	if (item in translationsFromWD) {
		return translationsFromWD[item];
	}
	callTranslationFromWD(item);
	return item;
}
function getTranslationToWD (text) {
	var title = text.replace(/^\[\[(.+)(?:\||\]\]).*$/, '$1');
	if (title in translationsToWD) {
		return translationsToWD[title];
	}
	callTranslationToWD(title);
	return false;
}

function extractStringProp (json) {
	if (json && json[0] && json[0].mainsnak && json[0].mainsnak.datavalue && json[0].mainsnak.datavalue.value) { //TODO: mehrere Werte
		return json[0].mainsnak.datavalue.value;
	}
	return '';
}
function extractItemProp (json) {
	if (json && json[0] && json[0].mainsnak && json[0].mainsnak.datavalue && json[0].mainsnak.datavalue.value && json[0].mainsnak.datavalue.value['numeric-id']) { //TODO: mehrere Werte
		return getTranslationFromWD('Q' + json[0].mainsnak.datavalue.value['numeric-id']);
	}
	return '';
}
function extractFromWD (data, json) {
	var prop = mapToWD(data);
	if (prop === 'label') {
		if (json && json.labels && json.labels.de && json.labels.de.value) {
			return json.labels.de.value;
		}
		return '';
	}
	if (prop === 'alias') {
		//TODO
		return '';
	}
	if (prop === 'description') {
		if (json && json.descriptions && json.descriptions.de && json.descriptions.de.value) {
			return json.descriptions.de.value;
		}
		return '';
	}
	if (json && json.claims) {
		return prop[0] ? extractItemProp(json.claims[prop[1]]) : extractStringProp(json.claims[prop[1]]);
	}
	return '';
}

function getFromWikiData (title, data, callback) {
	ajax('GET', {
		action: 'wbgetentities',
		sites: 'dewiki',
		titles: title,
		props: 'aliases|labels|descriptions|claims',
		languages: 'de'
	}, function (json) {
		var i, ret = {};
		if (json && json.entities) {
			for (i in json.entities) {
				json = json.entities[i];
				break;
			}
		} else {
			json = false;
		}
		for (i = 0; i < data.length; i++) {
			ret[data[i]] = extractFromWD(data[i], json);
		}
		callback(json.id || '', ret);
	});
}

function setNewItem (id, prop, value, token, callback) {
	ajax('POST', {
		action: 'wbcreateclaim',
		entity: id,
		property: prop,
		snaktype: 'value',
		value: '{"entity-type":"item","numeric-id":' + value.replace(/^q/i, '') + '}',
		token: token
	}, function (json) {
		if (!json) {
			callback('Unknown error');
		} else if (json.error && json.error.info) {
			callback(json.error.info);
		} else {
			callback('');
		}
	});
}
function setNewString (id, prop, value, token, callback) {
	ajax('POST', {
		action: 'wbcreateclaim',
		entity: id,
		property: prop,
		snaktype: 'value',
		value: '"' + value + '"',
		token: token
	}, function (json) {
		if (!json) {
			callback('Unknown error');
		} else if (json.error && json.error.info) {
			callback(json.error.info);
		} else {
			callback('');
		}
	});
}
function setItem (id, prop, value, token, callback) {
	ajax('POST', {
		action: 'wbsetclaimvalue',
		entity: id,
		claim: prop,
		snaktype: 'value',
		value: '{"entity-type":"item","numeric-id":' + value.replace(/^q/i, '') + '}',
		token: token
	}, function (json) {
		if (!json) {
			callback('Unknown error');
		} else if (json.error && json.error.info) {
			callback(json.error.info);
		} else {
			callback('');
		}
	});
}
function setString (id, prop, value, token, callback) {
	ajax('POST', {
		action: 'wbsetclaimvalue',
		entity: id,
		claim: prop,
		snaktype: 'value',
		value: '"' + value + '"',
		token: token
	}, function (json) {
		if (!json) {
			callback('Unknown error');
		} else if (json.error && json.error.info) {
			callback(json.error.info);
		} else {
			callback('');
		}
	});
}

function showDialog (html, callback) {
	//TODO
}
function showDialogMissing () {
	showDialog('Es ist kein Wikidata-Eintrag vorhanden.');
}
function showDialogEqual () {
	showDialog('Deine Daten stimmen mit denen in Wikidata überein.');
}
function showDialogDiff (link, diffTable) {
	showDialog('Folgende Daten im Wikidata-Eintrag ' + link + ' weichen von deinen Eingaben ab:' + diffTable + 'Hinweis: Unaufgelöste Wikidata-IDs werden nach einem erneuten Aufruf dieses Dialogs korrekt angezeigt.', function () {
		//TODO
	});
}

function getLocalData (data) {
	//TODO
	var i, ret = {};
	for (i = 0; i < data.length; i++) {
		ret[data[i]] = '';
	}
	return ret;
}
function getDisplay (type, val) {
	if (val === '') {
		return '<i>fehlt</i>';
	}
	var href;
	if (val.charAt(0) === 'Q') {
		href = '//wikidata.org/wiki/' + val;
	}
	switch (type) {
	case 'gnd': href = 'https://d-nb.de/FIXME';
	}
	if (href) {
		return mw.html.element('a', {href: href, target: '_blank'}, val);
	}
	return mw.html.escape(val);
}
function isEqual (a, b) {
	return a.replace(/^\[\[(.+)(?:\||\]\]).*$/, '$1') === b.replace(/^\[\[(.+)(?:\||\]\]).*$/, '$1');
}
function getDiffTable (local, wd) {
	var type, html = '', h = {
		gnd: 'GND'
	};
	for (type in local) {
		if (isEqual(local[type], wd[type])) {
			continue;
		}
		html += '<tr><th>' + h[type] + '</th><td>' + getDisplay(type, local[type]) + '</td><td>' + getDisplay(type, wd[type]) + '</td></tr>'; //TODO
	}
	if (html) {
		html = '<table><tr><td>&nbsp;</td><th>Dein Wert</th><th>Wikidata</th></tr>' + html + '</table>';
	}
	return html;
}
function getInfoForDialog (data) {
	getFromWikiData(mw.config.get('wgTitle'), data, function (id, vals) {
		var diffTable;
		if (id === '') {
			showDialogMissing();
		} else {
			diffTable = getDiffTable(getLocalData(data), vals);
			if (diffTable) {
				showDialogDiff(getDisplay(id), diffTable);
			} else {
				showDialogEqual();
			}
		}
	});
}