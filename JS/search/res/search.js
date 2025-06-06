/*global dataManager, l10n, MozActivity*/
(function () {
"use strict";

function escapeHtml (s) {
	return s.replace(/&/g, '&amp;').replace(/"/g, '&quot;')
		.replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function openTag (tag, attr) {
	return '<' + tag + ' ' + Object.keys(attr).map(function (key) {
		return key + '="' + escapeHtml(attr[key]) + '"';
	}).join(' ') + '>';
}

function applyModify (method, value) {
	switch (method) {
	case 'quote': return '"' + value + '"';
	case 'encodeUri': return encodeURI(value);
	case 'encodeUriPlus': return encodeURI(value).replace(/%20/g, '+');
	default: return value;
	}
}

function baseFormHtml (config) {
	return '<p><label>' + l10n.get('search-provider') + ' ' +
		'<select id="search-provider">' + config.map(function (entry, i) {
			return '<option value="' + i + '">' + escapeHtml(entry.title) + '</option>';
		}).join('') +
		'</select></label></p>' +
		'<p class="link-container">' +
			'<a id="link-edit" href="edit.html?i=0">' + l10n.get('edit') + '</a> ' +
			'<a href="edit.html">' + l10n.get('add') + '</a></p>' +
		'<p><label>' + l10n.get('search-input') + ' <input type="search" data-action="set"></label></p>' +
		'<div id="options-container"></div>' +
		'<p><button>' + l10n.get('search-button') + '</button></p>';
}

function optionsToHtml (data) {
	var inputs = [];
	inputs.push({type: 'hidden', action: 'append', value: data.base});
	if (data.quote) {
		inputs.push({type: 'checkbox', action: 'modify', label: l10n.get('exact'), value: 'quote'});
	}
	if (data.options) {
		inputs = inputs.concat(data.options);
	}
	if (data.encode) {
		inputs.push({type: 'hidden', action: 'modify', value: data.encode});
	}
	return inputs.map(function (option) {
		var input;
		switch (option.type) {
		case 'checkbox':
			input = openTag('input', {type: 'checkbox', 'data-action': option.action, value: option.value});
			return '<p><label>' + input + ' ' + escapeHtml(option.label) + '</label></p>';
		case 'select':
			input = openTag('select', {'data-action': option.action}) + Object.keys(option.value).map(function (entry) {
				return openTag('option', {value: option.value[entry]}) + escapeHtml(entry) + '</option>';
			}).join('') + '</select>';
			return '<p><label>' + escapeHtml(option.label) + ' ' + input + '</label></p>';
		default:
			return openTag('input', {type: 'hidden', 'data-action': option.action, value: option.value});
		}
	}).join('');
}

function urlFromForm (form) {
	var url = '', search = '', elements = form.querySelectorAll('[data-action]'), i, element;
	for (i = 0; i < elements.length; i++) {
		element = elements[i];
		if (element.type === 'checkbox' && !element.checked) {
			continue;
		}
		switch (element.dataset.action) {
		case 'set':
			search = element.value;
			break;
		case 'modify':
			search = applyModify(element.value, search);
			break;
		case 'append':
			url += element.value;
		}
	}
	return url.replace(/%s/g, search);
}

function changeSearchProvider (data) {
	//TODO try to keep other values, too?
	var quoteCheckbox, shouldQuote;
	quoteCheckbox = document.querySelector('input[type="checkbox"][data-action="modify"][value="quote"]');
	shouldQuote = quoteCheckbox && quoteCheckbox.checked;
	document.getElementById('options-container').innerHTML = optionsToHtml(data);
	quoteCheckbox = document.querySelector('input[type="checkbox"][data-action="modify"][value="quote"]');
	if (quoteCheckbox && shouldQuote) {
		quoteCheckbox.checked = true;
	}
}

function openUrl (url) {
	var activity;
	if (typeof MozActivity !== 'undefined') {
		activity = new MozActivity({
			name: 'view',
			data: {
				type: 'url',
				url: url
			}
		});
		activity.onerror = function () {
			window.open(url);
		};
	} else {
		window.open(url);
	}
}

function init (config) {
	var form = document.getElementById('form');
	document.title = l10n.get('title');
	document.getElementsByTagName('html')[0].lang = l10n.getLang();
	form.innerHTML = baseFormHtml(config);
	form.addEventListener('change', function (e) {
		if (e.target.id === 'search-provider') {
			changeSearchProvider(config[e.target.value]);
			document.getElementById('link-edit').href = 'edit.html?i=' + e.target.value;
		}
	});
	form.addEventListener('submit', function (e) {
		e.preventDefault();
		openUrl(urlFromForm(form));
	});
	changeSearchProvider(config[0]);
}

init(dataManager.get());

})();