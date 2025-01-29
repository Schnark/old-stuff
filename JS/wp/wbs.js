var getCommentConfigCache, mustSignCache, userReCache, autoSignReCache, autoCommentReCache;
/*
 0: kein Kommentar nötig
 1: leereren Kommentar verhindern
 2: zusätzlich Abschnitt-Kommentar verhindern
 3: zusätzlich Standard-Kommentar verhindern
 4: zusätzlich ursprünglichen Kommentar verhindern
 negativ: bei kleiner Änderung kein Kommentar nötig

 abhängig von: Namensraum, Situation (Neuanlage, neuer Abschnitt, Bearbeitung, Verschieben), Ergebnis von mustSign()
*/
function getCommentConfigFromData (ns, situation, sign) {
	//FIXME
}
//abhängig von: Namensraum, Seitentitel
function getMustSignFromData (ns, title) {
	//FIXME
}

function getCommentConfig () {
	if (getCommentConfigCache === undefined) {
		var situation = 'edit';
		if (mw.config.get('wgCanonicalSpecialPageName') === 'Movepage') {
			situation = 'move';
		} else if ($('input[name="wpSection"]').val() === 'new') {
			situation = 'newsection';
		} else if (mw.config.get('wgArticleId') === 0) {
			situation = 'new';
		}
		getCommentConfigCache = getCommentConfigFromData(mw.config.get('wgNamespaceNumber'), situation, mustSign());
	}
	return getCommentConfigCache;
}

function mustSign () {
	if (mustSignCache === undefined) {
		mustSignCache = getMustSignFromData(mw.config.get('wgNamespaceNumber'), mw.config.get('wgTitle'));
	}
	return mustSignCache;
}

function mustComment () {
	return !!getCommentConfig();
}

function canonize (s, onlyFirst) {
	return s.replace(/[\s_]+/g, '[\\s_]+').replace(onlyFirst ? /./ : /./g, function (c) {
		if (c.toUpperCase() !== c.toLowerCase()) {
			return '[' + c.toUpperCase() + c.toLowerCase() + ']';
		}
		return c;
	});
}

function getNamespacesRe (wanted) {
	var ret = [], ns, all = mw.config.get('wgNamespaceIds');
	for (ns in all) {
		if ($.inArray(all[ns], wanted) > -1) {
			ret.push(ns);
		}
	}
	return $.map(ret, function (ns) {
		return canonize(ns);
	}).join('|');
}

function getUserRe () {
	if (userReCache === undefined) {
		userReCache = '\\[\\[\\s*(?:' + getNamespacesRe([2, 3]) + ')\\s*:\\s*' + canonize(mw.config.get('wgUserName'), true) + '\\s*(?:(?:/|\\|)[^\\[\\]]*)?\\]\\])';
		userReCache = new RegExp(userReCache);
	}
	return userReCache;
}

function getSubst () {
	var ret = ['subst', 'ers']; //FIXME
	return $.map(ret, function (s) {
		return canonize(s);
	}).join('|');
}

function getAutosignTemplates () {
	var ret = []; //FIXME
	return $.map(ret, function (t) {
		return canonize(t, true);
	}).join('|');
}

function getAutosignTemplatesRe () {
	if (autoSignReCache === undefined) {
		autoSignReCache = '\\{\\{\\s*(?:' + getSubst() + ')\\s*:\\s*(?:' + getNamespacesRe([10]) + '\\s*:\\s*)?(?:' + getAutosignTemplates() + ')\\s*(?:\\|[\\s\\S]*)\\}\\}';
		autoSignReCache = new RegExp(autoSignReCache);
	}
	return autoSignReCache;
}

function getAutoCommentRe () {
	if (autoCommentReCache === undefined) {
		autoCommentReCache = '^Änderung \\d+ .*(?:FIXME)? zurückgesetzt;\\s*$'; //FIXME
		autoCommentReCache = new RegExp(autoCommentReCache);
	}
	return autoCommentReCache;
}

function isSigned (text) {
	var user = false, time = false, userRe = getUserRe(), autoSignRe = getAutosignTemplatesRe();
	text = text.replace(/<(nowiki|source|syntaxhighlight|pre|gallery|ref|math|hiero|score|timeline|graph|templatedata)[^>]*>.*?<\/\1>|<!--.*?-->/g, ' ');
	if (text.indexOf('~~~~~') > -1) {
		time = true;
		text = text.replace(/~~~~~/g, '');
	}
	if (text.indexOf('~~~~') > -1 || autoSignRe.test(text)) {
		user = true;
		time = true;
	}
	if (!user && (text.indexOf('~~~') > -1 || userRe.test(text))) {
		user = true;
	}
	return user && time;
}

function isCommented (summary, minor, hash) {
	var config = getCommentConfig();
	if (config < 0 && minor) {
		return true;
	}
	if (/^\s*$/.test(summary)) {
		return false;
	}
	if (Math.abs(config) === 1) {
		return true;
	}
	if (/^\s*\/\*.*?\*\/\s*$/.test(summary)) {
		return false;
	}
	if (Math.abs(config) === 2) {
		return true;
	}
	if (getAutoCommentRe().test(summary)) {
		return false;
	}
	if (Math.abs(config) === 3) {
		return true;
	}
	if (libs.md5 && libs.md5(summary) === hash) { //FIXME
		return false;
	}
	return true;
}

function canSave () {
	var text = $('#wpTextbox1').val(),
		summary = $('#wpSummary').val(),
		minor = $('#wpMinoredit').prop('checked'),
		hash = $('#wpAutoSummary').val();
	return $('#warn-before-save').prop('checked') || (
		(!mustSign() || isSigned(text)) && (!mustComment() || isCommented(summary, minor, hash))
	);
}

function canMove () {
	var summary = $('#wpReason').val();
	return $('#warn-before-save').prop('checked') || (
		(!mustComment() || isCommented(summary, false, '')
	);
}

function abortAndWarn (e) {
	e.preventDefault();
	$('#warn-before-save').prop('checked', true);
	$('label[for="warn-before-save"]').css('color', 'red'); //FIXME
}

function onSubmitEdit (e) {
	if ($.inArray(e.originalEvent.explicitOriginalTarget.id, ['wpPreview', 'wpDiff']) === -1 && !canSave()) { //FIXME: explicitOriginalTarget ?
		abortAndWarn(e);
	}
}

function onSubmitMove (e) {
	if (!canMove()) {
		abortAndWarn(e);
	}
}

function initEdit () {
	var sign = mustSign(), comment = mustComment(), msg;
	if (!sign && !comment) {
		return;
	}
	if (sign && comment) {
		msg = 'schnark-warn-before-save-sign-comment';
	} else if (sign) {
		msg = 'schnark-warn-before-save-sign';
	} else {
		msg = 'schnark-warn-before-save-comment';
	}
	$('#editform').submit(onSubmitEdit);
	$('.editCheckboxes').append('\n')
		.append('<input id="warn-before-save" type="checkbox" />').append('\n')
		.append(mw.html.element('label', {'for': 'warn-before-save'}, mw.msg(msg)));
	//FIXME forcesummary deaktivieren?
}

function initMove () {
	var comment = mustComment();
	if (!comment) {
		return;
	}
	$('#movepage').submit(onSubmitMove);
	$('#watch').parent('tr').append('<tr><td></td><td class="mw-input"><input id="warn-before-save" type="checkbox" />&nbsp;' +
		mw.html.element('label', {'for': 'warn-before-save'}, mw.msg('schnark-warn-before-save-comment')) + '</td></tr>');
	//FIXME andere Spezialseiten?
}