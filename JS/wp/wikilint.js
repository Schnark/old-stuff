var registeredCallbacks = [], registeredCallbacksSeverity = [];
function register (f, severity) {
	registeredCallbacks.push(f);
	registeredCallbacksSeverity.push(severity || 2);
}
function executeCallbacks (type, text, html) {
	var ret = [], words = {}, r, i, j;
	for (i = 0; i < registeredCallbacks.length; i++) {
		r = registeredCallbacks[i](type, text, html);
		if (r) {
			if (typeof r === 'string') {
				r = {html: r};
			}
			if (r.words) {
				for (j = 0; j < r.words.length; j++) {
					words[r.words[j]] = Math.min(registeredCallbacksSeverity[i], words[r.words[j]] || 10);
				}
			}
			if (r.html) {
				ret.push('<p class="wikihint-severity-' + registeredCallbacksSeverity[i] + '">' + r.html + '</p>');
			}
		}
	}
	return [ret.join(''), words];
}

function addRow ($table, data) {
	var ret, $tr;
	ret = executeCallbacks(data.type, data.text, data.html);
	$tr = $('<tr><td>' + data.html + '</td><td>' + ret[0] + '</td></tr>');
	highlight($tr.find('td:first'), ret[1]);
	$table.append($tr);
}

function highlight ($el, words) {
	//TODO
}

function getText (html, tags) {
	var text = [], nottags = [], i, j;
	for (i = 0; i < tags.length; i++) {
		for (j = 0; j < tags.length; j++) {
			nottags.push(tags[i] + ' ' + tags[j]);
		}
	}
	$(html).find(tags.join(',')).not(nottags.join(',')).each(function () {
		text.push($(this).text().replace(/\r?\n/g, ' '));
	});
	return text.join('\n');
}

function findAll (text, re) {
	var found = [], match;
	while (match = re.exec(text)) {
		found.push(match[0]);
	}
	return found;
}

function splitHTML (root) {
	var children = root.childNodes, ret = [], type, text, html, i, level;
	for (i = 0; i < children.length; i++) {
		html = children[i].outerHTML || '';
		if (html === '') {
			continue;
		} else if (/^<h\d\b/.test(html)) {
			level = html.charAt(2);
			html = '<h' + level + '>' + $(html).find('.mw-headline').html() + '</h' + level + '>';
			type = 'headline';
		} else if (/^<table\b/.test(html)) {
			type = 'table';
		} else if (/^(?:<div\b[^>]*>\s*)*<pre\b/.test(html)) {
			type = 'pre';
		} else if (/^(?:<p\b[^>]*>)?(?:<div\b[^>]*>\s*)*(?:<a\b[^>]*>\s*)?<img\b/.test(html)) {
			type = 'image';
		} else if (/^<(?:ul|ol|dl)\b/.test(html)) {
			type = 'list';
		} else if (/^<p\b/.test(html)) {
			type = 'text';
		} else if (/^</.test(html)) {
			type = 'other';
		} else {
			html = '<p>' + html + '</p>';
			type = 'text';
		}

		switch (type) {
		case 'headline':
			text = $(html).text();
			break;
		case 'table':
			text = getText(html, ['caption', 'th', 'td']);
			break;
		case 'pre':
			text = children[i].textContent;
			break;
		case 'list':
			text = getText(html, ['li', 'dt', 'dd']);
			break;
		default:
			text = children[i].textContent.replace(/\r?\n/g, ' ');
		}
		if (type === 'text' && ret.length && ret[ret.length - 1].type === 'text') {
			ret[ret.length - 1].text += '\n' + text;
			ret[ret.length - 1].html += html;
		} else {
			ret.push({type: type, text: text, html: html});
		}
	}
	return ret;
}

function analyse () {
	var $content, elements, $table, i, $title, ret;
	$content = $('#mw-content-text');
	$content.remove('#toc');
	elements = splitHTML($content[0]);
	$table = $content.html('<table></table>').find('table');
	for (i = 0; i < elements.length; i++) {
		addRow($table, elements[i]);
	}
	$title = $('#firstHeading > span');
	ret = executeCallbacks('', $title.text(), $title.html());
	$content.prepend(ret[0]);
	highlight($title, ret[1]);
}

//Überschriftenhierarchie
register((function () {
	var prev = false, content = false;
	return function (type, text, html) {
		if (type === '' && !content) {
			return 'Der letzte Abschnitt hat keinen Inhalt!';
		}
		if (type !== 'headline') {
			content = true;
			return;
		}
		var level = html.charAt(2), out = [];
		if (level === '1') {
			out.push('Überschriften der Stufe 1 sollten nicht verwendet werden!');
		}
		if (!prev && !content) {
			out.push('Die Einleitung fehlt!');
		}
		if (prev === level && !content) {
			out.push('Der vorherige Abschnitt hat keinen Inhalt!');
		}
		if (prev && 1 + Number(prev) < Number(level)) {
			out.push('Es wurde eine Stufe in der Überschriftenhierarchie übersprungen!');
		}
		prev = level;
		content = false;
		return out.join('<br />');
	};
})());
/*
register((function () {
	var ;
	return function (type, text, html) {
	};
})());
register(function (type, text, html) {
});
*/
//Typografie, Plenk, Klemp
register(function (type, text, html) {
	text = $(html).remove('code, pre').text();
	var out = [], words = [];
	if (text.indexOf('"') > -1) {
		out.push('Verwende „typografische Anführungszeichen“!');
		words.push('"');
	}
	if (/['´`]/.test(text)) {
		out.push('Verwende den typografischen Apostroph (’) bzw. ‚typografische einfache Anführungszeichen‘!');
		words.push("'", '´', '`');
	}
	if (text.indexOf('...') > -1) {
		out.push('Verwende das typografische Auslassungszeichen (…)!');
		words.push('...');
	}
	if (/[.,:;!?)\]}%]\S/.test(text)) { //FIXME
		out.push('Nach Satzzeichen sollte ein Leerzeichen folgen!');
	}
	if (/\s[.,:;!?(\[\{\/]|\/\s/.test(text)) { //FIXME
		out.push('Vor Satzzeichen und um Schrägstriche sollte kein Leerzeichen stehen!');
	}
	//TODO
	if (out.length) {
		return {html: out.join(' '), words: words};
	}
});

//mehrfache Links
register((function () {
	var links = {};
	return function (type, text, html) {
		var doppel = [];
		$(html).find('a[href]:not(.magnify a)').each(function () {
			var href = $(this).attr('href');
			if (links[href]) {
				doppel.push($(this).text());
			}
			links[href] = true;
		});
		if (doppel.length) {
			return {html: 'Es kommen mehrfache Links vor!', words: doppel};
		}
	};
})());

//Worte, die man vermeiden sollte
register(function (type, text, html) {
	var i, words = [], test = ['wir', 'man', 'aktuell', 'uns', 'aber', 'auch']; //TODO, Zitate entfernen
	for (i = 0; i < test.length; i++) {
		if (text.indexOf(test[i]) !== -1) {
			words.push(test[i]);
		}
	}
	if (words.length) {
		return {html: 'Es kommen problematische Wörter vor: ' + words.join(', '), words: words};
	}
});

//Unicode-Sonderzeichen
register((function () {
	var	charCGJ = '\u034F', //CGJ
		charNBSP = '\u00A0', //NBSP
		charSHY = '\u00AD', //SHY
		charTHINSPACE = '\u2009', //THIN SPACE
		charHORIZONT = '\u2500',
		gcM = '\u0300-\u034E\u0350-\u036F\u1DC0-\u1DFF\u20D0-\u20F0 TODO \u20F1-\u20FF\uFE20-\uFE2F', //gc = M ohne U+034F (CGJ), unvollständig, zusätzlich einige nicht zugewiesene Zeichen in entsprechenden Blöcken
		gcZ = '\u1680\u180E\u2000-\u2008\u200A\u2028\u2029\u202F\u205F\u3000', //gc = Z ohne U+0020 (SPACE), U+00A0 (NBSP), U+2009 (THIN SPACE)
		gcCn = '', //gc = Cn TODO
		gcCc = '\u0000-\u0008\u000B\u000C-\u001F\u007F-\u009F', //gc = Cc ohne U+0009 (TAB), U+000A (LF)
		gcCf = '\u0600-\u0603\u06DD\u070F\u17B4\u17B5\u200B-\u200F\u202A-\u202E\u2060-\u2064\u206A-\u206F\uFEFF\uFFF9-\uFFFB', //gc = Cf ohne SHY, ZWNJ, ZWJ, LRM, RLM und Zeichen außerhalb Plane 0 TODO
		gcCo = '\uE000-\uF8FF', //gc = Co ohne Zeichen außerhalb Plane 0
		gcPd = 'TODO 058A, 05BE, 1400, 1806, 2010..2015, 2E17, 2E1A, 301C, 3030, 30A0, FE31, FE32, FE58, FE63, FF0D', //gc = Pd ohne HYPHEN-MINUS, EM, EN, MINUS
		gcSkLm = '\u005E\u0060\u00A8\u00AF\u00B4\u00B8\u02B0-\u02FF', //gc = Sk und gc = Lm, unvollständig
		compat = '\uF900-\uFE1F\uFE30-\uFEFE\uFF00-\uFFFF', //Zeichen aus den letzten Blöcken
		unerwuenscht = '\u2155-\u218F\u2625-\u2629\u2670\u2671\u2716-\u27BF', //unerwünschte Zahlzeichen, Dingbats, etc.;

		re = [
			[new RegExp('([^' + gcM + ']?[' + gcM + ']*' + charCGJ + '[' + gcM + ']*.?)' , 'g'), 'CGJ'],
			[new RegExp('(.?' + charSHY + '.?)' , 'g'), 'SHY'],
			[new RegExp('(.?[' + gcZ + ']+.?)' , 'g'), 'Leerzeichen'],
			[new RegExp('(.?[' + gcCn + ']+.?)' , 'g'), 'nicht zugewiesen'],
			[new RegExp('(.?[' + gcCc + ']+.?)' , 'g'), 'allg. Steuerzeichen'],
			[new RegExp('(.?[' + gcCf + ']+.?)' , 'g'), 'Steuerzeichen zur Formatierung'],
			[new RegExp('([' + gcCo + ']+)' , 'g'), 'Zeichen zum privatem Gebrauch'],
			[new RegExp('([' + gcSkLm + ']+)' , 'g'), 'Modifizierer'],
			[new RegExp('([' + compat + ']+)' , 'g'), 'Kompatibilitätszeichen'],
			[new RegExp('([' + unerwuenscht + ']+)' , 'g'), 'unerwünschtes Zeichen'],
			[new RegExp('' , 'g'), ''],
			[new RegExp('' , 'g'), ''],
			[new RegExp('' , 'g'), ''],
			[new RegExp('' , 'g'), ''],
			[new RegExp('' , 'g'), ''],
			[new RegExp('' , 'g'), ''],
			[new RegExp('' , 'g'), ''],
			[new RegExp('' , 'g'), ''],
			[new RegExp('' , 'g'), ''],
			[new RegExp('' , 'g'), ''],
		];
	return function (type, text) {
		var problems = [], words = [], i, found;
		for (i = 0; i < re.length; i++) {
			found = findAll(text, re[i][0]);
			if (found.length) {
				problems.push(re[i][1]);
				words.concat(found); //FIXME
			}
		}
		if (problems.length) {
			return {html: problems.join(' '), words: words};
		}
	};
})());

//Wortdopplungen
register(function (type, text) {
	var doppel = findAll(text, (/(\b\S+\b)\W+\1\b/g));
	if (doppel.length) {
		return {html: 'Es kommen Wortdopplungen vor: ' + mw.html.escape(doppel.join(', ')), words: doppel};
	}
});

//gleiche Satzanfänge
register(function (type, text) {
	var doppel = findAll(text, (/(?:^|\.\s+)(\S+)\b[^.]+\.\s+\1/g));
	if (doppel.length) {
		return {html: 'Es gibt aufeinander folgende Sätze mit gleichem Anfang: ' + mw.html.escape(doppel.join(', ')), words: doppel};
	}
});

//identische Überschriften
register((function () {
	var h = {};
	return function (type, text) {
		if (type === 'headline') {
			if (h[text]) {
				return 'Es gibt bereits eine gleichlautende Überschrift!';
			}
			h[text] = true;
		}
	};
})());

//Klappboxen
register(function (type, text, html) {
	if ($(html).find('.mw-collapsible').length) {
		return 'Muss die Klappbox wirklich sein?';
	}
});

//Zahlenformat, geschützte Leerzeichen

//missbilligtes HTML
register(function (type, text, html) {
	if ($(html).find('font, center, strike, [align], [clear], [type]').length) { //TODO
		return 'Missbilligtes HTML'; //TODO
	}
});

//Abkürzungen
register(function (type, text) {
	var abk = findAll(text, (/((?:\b\S{0,2}[^.IVXL0-9]\.\s*)+)/g)); //FIXME
	if (abk.length) {
		return {html: 'Es kommen Abkürzungen vor: ' + mw.html.escape(abk.join(', ')), words: abk};
	}
});

//kurze und lange Absätze

//Datenlinks
register((function () {
	var einleitung = true;
	return function (type, text, html) {
		if (einleitung) {
			if (type === 'headline') {
				einleitung = false;
			}
			return;
		}
		var links = [];
		$(html).find('a:not(.external)').each(function () {
			var text = $(this).attr('title');
			if (/^\d+(?:\. (?:Januar|Jänner|Februar|März|April|Mai|Juni|Juli|August|September|Oktober|November|Dezember))?$/.test(text)) {
				links.push(text);
			}
		});
		if (links.length) {
			return {html: 'Es wurden Links auf Daten gefunden: ' + links.join(', '), words: links};
		}
};
})());

//Quellen

//keine Bilder
register((function () {
	var bild = false;
	return function (type) {
		if (type === 'image') {
			bild = true;
		} else if (type === '' && !bild) {
			return 'Ein Bild wäre nett. Vielleicht findet sich ja was auf Commons.';
		}
	};
})());

//Bilder ohne Unterschrift
register(function (type, text) {
	if (type === 'image' && $.trim(text) === '') {
		return 'Es fehlt eine Bildunterschrift!';
	}
});

//Weblinks und Langlinks im Text
register((function () { //FIXME
	var weblinks = false;
	return function (type, text, html) {
		if (type === 'headline' && (text.indexOf('Weblink') === 0 || text === 'Einzelnachweise' || text === 'Literatur') {
			weblinks = true;
		} else if (!weblinks) {
			if ($(html).find('.external, .extiw').length) {
				return 'Weblinks sollten nur in einem eigenen Abschnitt am Ende vorkommen!';
			}
		}
	};
})());

//fehlerhafte ISBN
register(function (type, text, html) {
	var list = [];
	$(html).find('.mw-magiclink-isbn').each(function () {
		var isbn = $(this).text().toUpperCase().replace(/[ISBN\s\-]+/g, ''), check = 0, i;
		if (isbn.length === 10) {
			for (i = 0; i < 10; i++) {
				check += (i - 1) * Number(isbn.charAt(i));
			}
			check = check % 11;
			if (check !== Number(isbn.charAt(10)) && (check !== 10 || isbn.charAt(10) !== 'X')) {
				list.push($(this).text());
			}
		} else {
			for (i = 0; i <= 13; i++) {
				if (i % 2) {
					check += 3 * Number(isbn.charAt(i));
				} else {
					check += Number(isbn.charAt(i));
				}
			}
			if (check % 10) {
				list.push($(this).text());
			}
		}
	});
	if (list.length) {
		return {html: 'Falsche ISBN: ' + list.join(', '), words: list};
	}
});

//falsch formatierte ISBN

//Listen mit nur einem Punkt
register(function (type, text) {
	if (type === 'list' && text.indexOf('\n') === -1) {
		return 'Listen mit nur einem Eintrag sind selten sinnvoll!';
	}
});

//keine Links zu Schwesterprojekten

//keine Weblinks
register((function () {
	var weblinks = false;
	return function (type, text) {
		if (type === 'headline' && text.indexOf('Weblink') === 0) {
			weblinks = true;
		} else if (type === '' && !weblinks) {
			return 'Es gibt keinen Abschnitt mit Weblinks. Findet sich denn mit Google nichts Geeignetes?';
		}
	};
})());

//viele Weblinks
register((function () {
	var weblinks = false;
	return function (type, text) {
		if (type === 'headline' && text.indexOf('Weblink') === 0) {
			weblinks = true;
		} else if (type === 'list' && weblinks) {
			weblinks = false;
			if (text.test(/(?:\n.*){5}/)) {
				return 'So viele Weblinks? Sind die alle „vom Feinsten“?';
			}
		}
	};
})());

//lange Sätze

//Weblinks ohne Text
register(function (type, text, html) {
	var found = 0;
	$(html).find('a.external').each(function () {
		if ($(this).text().test(/^\d+$|^https?:\/\//)) {
			found++;
		}
	});
	if (found) {
		return 'Es wurden ' + found + 'Weblinks ohne vernünftige Beschriftung gefunden!';
	}
});

//Weblinks in Einzelnachweisen ohne Datum

//Hervorhebungen

//Links ohne Zwischenraum
register(function (type, text, html) {
	if (/<\/a>\s*<a\b/.test(html)) {
		return 'Hier stoßen zwei Links direkt aufeinander. Formuliere den Satz so um, dass ein unverlinktes Wort dazwischen steht!';
	}
});

//viele oder wenig Links

//CSS
register(function (type, text, html) {
	if (type === 'text' && $(html).find('[style]').length) {
		return 'Prüfe bitte, ob die Verwendung von Inline-CSS hier wirklich nötig ist.';
	}
});
//HTML
register(function (type, text, html) {
	if (type === 'text' && $(html).find('em, strong, u').length) {
		return 'Prüfe bitte, ob die Verwendung von HTML-Code hier wirklich nötig ist.';
	}
});

//Links in Überschriften
register(function (type, text, html) {
	if (type === 'headline' && html.indexOf('<a') !== -1) {
		return 'Links in Überschriften sind selten eine gute Idee!';
	}
});

//Hinweise auf BKL-Check und Rechtschreibprüfung
register(function (type) {
	if (type === '') {
		return 'Denke auch daran, nach BKL-Links und Rechtschreibfehlern zu suchen!';
	}
});

//Bilder in festen Größen

//Debug
/*register(function (type, text) {
	return type + ': ' + text;
});
*/

analyse();