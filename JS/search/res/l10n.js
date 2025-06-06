/*global l10n: true*/
l10n =
(function () {
"use strict";

var lang, data = {};

data.defaults = {
	edit: '✎',
	add: '+',

	'default-search-engines': ['google', 'duckduckgo'],
	'search-engine-google': {
		title: 'Google',
		base: 'https://www.google.com/search?q=%s',
		quote: true,
		encode: 'encodeUriPlus'
	},
	'search-engine-duckduckgo': {
		title: 'DuckDuckGo',
		base: 'https://duckduckgo.com/?q=%s',
		quote: true,
		encode: 'encodeUri'
	}
};

data.de = {
	title: 'Suche',
	'search-provider': 'Suchanbieter:',
	'search-input': 'Suche:',
	'search-button': 'Suchen',
	exact: 'exakter Ausdruck',

	'edit-title': 'Bearbeiten',
	'input-title': 'Titel:',
	'input-url': 'URL:',
	'input-exact': 'Anführungszeichen für exakte Suche verwenden',
	'input-encoding': 'Kodierung:',
	'input-encoding-none': '(keine)',
	'input-options': 'Zusätzliche Optionen:',
	'save-changes': 'Änderungen speichern',
	'save-new': 'Speichern',
	'delete': 'Löschen',
	cancel: 'Abbrechen',

	'default-search-engines': ['google', 'duckduckgo', 'archive'],
	'search-engine-archive': { //TODO translate
		title: 'Archive.org',
		base: 'https://archive.org/search.php?',
		quote: true,
		encode: 'encodeUri',
		options: [
			{type: 'select', action: 'append', label: 'Suche in:', value: {
				'Metadaten': 'query=%s',
				'Titel': 'query=title:(%s)',
				'Autor': 'query=creator:(%s)',
				'Verlag': 'query=publisher:(%s)',
				'Volltext': 'query=%s&sin=TXT'
			}},
			{type: 'select', action: 'append', label: 'Sortierung:', value: {
				'Standard': '',
				'Titel': '&sort=titleSorter',
				'Autor': '&sort=creatorSorter',
				'Erscheinungsjahr': '&sort=-date',
				'Erscheinungsjahr (älteste zuerst)': '&sort=date',
				'zuletzt hinzugefügt': '&sort=-addeddate'
			}},
			{type: 'checkbox', action: 'append', label: 'nur Bücher', value: '&and[]=mediatype%3A%22texts%22'}
		]
	}
};

data.en = {
	title: 'Search',
	'search-provider': 'Search provider:',
	'search-input': 'Search:',
	'search-button': 'Search',
	exact: 'exact expression',

	'edit-title': 'Edit',
	'input-title': 'Title:',
	'input-url': 'URL:',
	'input-exact': 'Use quotes for exact search',
	'input-encoding': 'Encoding:',
	'input-encoding-none': '(none)',
	'input-options': 'Additional options:',
	'save-changes': 'Save changes',
	'save-new': 'Save',
	'delete': 'Delete',
	cancel: 'Cancel'
}

function init () {
	//TODO
	lang = 'de';
}

function getLang () {
	return lang;
}

function get (msg) {
	return data[lang][msg] || data.defaults[msg];
}

function getDefaultSearchEngines () {
	return get('default-search-engines').map(function (searchEngine) {
		return get('search-engine-' + searchEngine);
	});
}

init();

return {
	getLang: getLang,
	get: get,
	getDefaultSearchEngines: getDefaultSearchEngines
};
})();