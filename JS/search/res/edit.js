/*global dataManager, l10n*/
(function () {
"use strict";

function buildForm (isNew) {
	document.getElementById('form').innerHTML = [
		'<label>' + l10n.get('input-title') + ' <input id="input-title" required></label>',
		'<label>' + l10n.get('input-url') + ' <input id="input-base" type="url"></label>',
		'<label><input id="input-quote" type="checkbox"> ' + l10n.get('input-exact') + '</label>',
		'<label>' + l10n.get('input-encoding') + ' <select id="input-encode">\n' +
		'<option value="">' + l10n.get('input-encoding-none') + '</option>\n' +
		'<option>encodeUri</option>\n' +
		'<option>encodeUriPlus</option>\n' +
		'</select></label>',
		'<label>' + l10n.get('input-options') + ' <textarea id="input-options"></textarea></label>',
		'<button id="button-save">' + l10n.get(isNew ? 'save-new' : 'save-changes') + '</button> ' +
		(isNew ? '' : '<button id="button-delete" class="warning">' + l10n.get('delete') + '</button> ') +
		'<button id="button-cancel">' + l10n.get('cancel') + '</button>'
	].map(function (p) {
		return '<p>' + p + '</p>';
	}).join('\n');
}

function prefillForm (data) {
	document.getElementById('input-title').value = data.title || '';
	document.getElementById('input-base').value = data.base || '';
	document.getElementById('input-quote').checked = data.quote || false;
	document.getElementById('input-encode').value = data.encode || '';
	document.getElementById('input-options').value = data.options ? JSON.stringify(data.options, null, '\t') : '';
}

function readForm () {
	var data = {}, value;
	data.title = document.getElementById('input-title').value;
	data.base = document.getElementById('input-base').value;
	if (document.getElementById('input-quote').checked) {
		data.quote = true;
	}
	value = document.getElementById('input-encode').value;
	if (value) {
		data.encode = value;
	}
	value = document.getElementById('input-options').value;
	if (value) {
		try {
			data.options = JSON.parse(value);
		} catch (e) {
			document.getElementById('input-options').setCustomValidity(e);
			return;
		}
	}
	return data;
}

function update (index, data) {
	var config = dataManager.get();
	if (index === -1) {
		if (data) {
			config.push(data);
		}
	} else if (data) {
		config[index] = data;
	} else {
		config.splice(index, 1);
	}
	dataManager.set(config);
	location.href = 'index.html';
}

function init () {
	var index, result, isNew = false;
	document.title = l10n.get('edit-title');
	document.getElementsByTagName('html')[0].lang = l10n.getLang();
	result = /^\?i=(\d+)$/.exec(location.search);
	if (result) {
		index = result[1];
	} else {
		index = -1;
		isNew = true;
	}
	buildForm(isNew);
	if (index > -1) {
		prefillForm(dataManager.get()[index]);
	}
	if (!isNew) {
		document.getElementById('button-delete').addEventListener('click', function (e) {
			e.preventDefault();
			update(index);
		});
	}
	document.getElementById('button-cancel').addEventListener('click', function (e) {
		e.preventDefault();
		update(-1);
	});
	document.getElementById('form').addEventListener('submit', function (e) {
		var data;
		e.preventDefault();
		data = readForm();
		if (data) {
			update(index, data);
		}
	});
}

init();

})();