/*global mediaWiki, ve, OO*/
(function ($, mw, libs) {
"use strict";
mw.loader.using('ext.visualEditor.desktopArticleTarget.init').done(function () {
//virtual indent
mw.libs.ve.addPlugin(function () {
//virtual indent

function TextInputWithSuggestionsAndStatus (config) {
	this.pdParser = config.pdParser;
	this.pdField = config.pdField;
	var value = this.pdParser.getCurrentContent(this.pdField);
	TextInputWithSuggestionsAndStatus.parent.call(this, $.extend({input: {value: value}}, config));
	this.updateStatus();
	this.updateSuggestions();
	this.getInput().connect(this, {change: 'updatePDParser'});
	if (config.onChange) {
		this.getInput().connect(config, {change: 'onChange'});
	}
	this.pdParser.on('statusChanged', this.updateStatus.bind(this));
	this.pdParser.on('suggestionsChanged', this.updateSuggestions.bind(this));
}
OO.inheritClass(TextInputWithSuggestionsAndStatus, OO.ui.ComboBoxWidget);

TextInputWithSuggestionsAndStatus.prototype.updateStatus = function () {
	this.setStatus(this.pdParser.getStatus(this.pdField));
};
TextInputWithSuggestionsAndStatus.prototype.updateSuggestions = function () {
	this.setSuggestions(this.pdParser.getSuggestions(this.pdField));
};
TextInputWithSuggestionsAndStatus.prototype.updatePDParser = function () {
	var oldValue = this.getInput().getValue(), newValue = this.pdParser.setCurrentContent(this.pdField, oldValue);
	if (newValue !== oldValue) {
		this.getInput().setValue(newValue);
	}
};
TextInputWithSuggestionsAndStatus.prototype.setStatus = function (status) {
	this.getInput().setLabel(status).setIcon(status ? 'info' : null); //FIXME
};
TextInputWithSuggestionsAndStatus.prototype.setSuggestions = function (suggestions) {
	var current = this.getInput().getValue();
	this.getMenu().clearItems().addItems($.map(suggestions, function (suggestion) {
		return current !== suggestion ? new OO.ui.MenuOptionWidget({data: suggestion, label: suggestion}) : undefined;
	}));
	this.getInput().setIndicator(this.getMenu().isEmpty() ? null : 'down');
};

function makeInput (pdParser, pdField, config) {
	config = config || {};
	return new OO.ui.FieldLayout(
		new TextInputWithSuggestionsAndStatus(
			$.extend({pdParser: pdParser, pdField: pdField}, config)
		),
		{label: config.fieldLabel || pdField}
	);
}

function makePDFieldset (pdParser) {
	return new OO.ui.FieldsetLayout({items: [
		makeInput(pdParser, 'NAME', {onChange: pdParser.updateSuggestions.bind(pdParser)}),
		makeInput(pdParser, 'ALTERNATIVNAMEN'),
		makeInput(pdParser, 'KURZBESCHREIBUNG', {onChange: pdParser.updateSuggestions.bind(pdParser)}),
		makeInput(pdParser, 'GEBURTSDATUM', {onChange: pdParser.updateSuggestions.bind(pdParser)}),
		makeInput(pdParser, 'GEBURTSORT'),
		makeInput(pdParser, 'STERBEDATUM', {onChange: pdParser.updateSuggestions.bind(pdParser)}),
		makeInput(pdParser, 'STERBEORT')
	]});
}
function makeCategoryFieldset (pdParser) {
	return new OO.ui.FieldsetLayout({items: [
		makeInput(pdParser, 'SORTIERUNG', {fieldLabel: $('<code>{{SORTIERUNG}}</code>')}),
		makeInput(pdParser, 'Staatsangehörigkeit'),
		makeInput(pdParser, 'Geboren', {fieldLabel: 'Kategorie:Geboren'}),
		makeInput(pdParser, 'Gestorben', {fieldLabel: 'Kategorie:Gestorben'}),
		makeInput(pdParser, 'Geschlecht', {fieldLabel: 'Geschlecht: Kategorie:'})
	]});
}

function getPersonendatenDialog (pdParser) {
	return $('<div>').append(
		makePDFieldset(pdParser).$element,
		makeCategoryFieldset(pdParser).$element
	);
}

function getPersonendatenScriptPromise () {
	var deferred = $.Deferred();
	if (libs.personendaten) {
		deferred.resolve(libs.personendaten.PersonendatenParser);
	} else {
		$.ajax({
			url: 'https://de.wikipedia.org/w/index.php?title=' +
				'Benutzer:Schnark/js/personendaten.js' + //</nowiki>[[Benutzer:Schnark/js/personendaten.js]]<nowiki>
				'&action=raw&ctype=text/javascript',
			dataType: 'script',
			crossDomain: true,
			cache: true
		}).done(function () {
			deferred.resolve(libs.personendaten.PersonendatenParser);
		}).fail(deferred.reject);
	}
	return deferred.promise();
}

function getWikitextPromise () {
	var deferred = $.Deferred();
	ve.init.target.serialize(ve.init.target.getSurface().getDom(), function (wikitext) {
		deferred.resolve(wikitext);
	});
	return deferred.promise();
}

function getPersonendatenPromise () {
	return $.when(
		getPersonendatenScriptPromise(),
		getWikitextPromise()
	).then(function (PersonendatenParser, wikitext) {
		var pdParser = new PersonendatenParser(mw.config.get('wgRelevantPageName'), wikitext, true);
		return {
			$body: getPersonendatenDialog(pdParser),
			onApply: function () {
				return updateFromPDParser(pdParser);
			}
		};
	});
}

function updateFromPDParser (pdParser) {
	var data = pdParser.getDataForVE();
	updateCategories(data.defaultsort, data.categories.remove, data.categories.add);
	//FIXME getEditsummary, getMinorflag
	return getPersonendatenTemplate(data.pd);
}

function getPersonendatenTemplate (params) {
	return {
		target: {
			href: 'Vorlage:Personendaten', wt: 'Personendaten'
		},
		params: {
			NAME: {wt: params[0]},
			ALTERNATIVNAMEN: {wt: params[1]},
			KURZBESCHREIBUNG: {wt: params[2]},
			GEBURTSDATUM: {wt: params[3]},
			GEBURTSORT: {wt: params[4]},
			STERBEDATUM: {wt: params[5]},
			STERBEORT: {wt: params[6]}
		}
	};
}

function updateCategories (sort, remove, add) {
	var metaList = ve.init.target.getSurface().getModel().metaList, i;

	function setDefaultsort (sort) {
		var defaultsortItem = metaList.getItemsInGroup('mwDefaultSort')[0] || null,
			newDefaultsortItem = {
				type: 'mwDefaultSort',
				attributes: {content: sort}
			};
		if (!defaultsortItem) {
			if (sort) {
				metaList.insertMeta(newDefaultsortItem);
			}
		} else {
			if (!sort) {
				defaultsortItem.remove();
			} else if (defaultsortItem.getAttribute('content') !== sort) {
				defaultsortItem.replaceWith(
					ve.extendObject(true, {}, defaultsortItem.getElement(), newDefaultsortItem)
				);
			}
		}
	}

	function removeCategory (category) {
		var categoryItems = metaList.getItemsInGroup('mwCategory'), i;
		for (i = 0; i < categoryItems.length; i++) {
			if (categoryItems[i].element.attributes.category === category) {
				categoryItems[i].remove();
				return true;
			}
		}
		return false;
	}

	function addCategory (category) {
		metaList.insertMeta({
			attributes: {category: category, sortkey: ''},
			type: 'mwCategory'
		});
	}

	setDefaultsort(sort);
	for (i = 0; i < remove.length; i++) {
		removeCategory('Kategorie:' + remove[i]);
	}
	for (i = 0; i < add.length; i++) {
		addCategory('Kategorie:' + add[i]);
	}
}

function SpecialTransclusionDialog () {
	SpecialTransclusionDialog.parent.apply(this, arguments);
}
OO.inheritClass(SpecialTransclusionDialog, ve.ui.MWTransclusionDialog);

SpecialTransclusionDialog.prototype.getPromiseForTemplate = function (templateName) {
	if (templateName === 'Personendaten') {
		return getPersonendatenPromise();
	}
	return $.Deferred().reject().promise();
};
SpecialTransclusionDialog.prototype.getActionProcess = function (action) {
	if (this.specialTransclusion && (action === 'apply' || action === 'insert')) {
		return new OO.ui.Process(function () {
			var newTransclusion = {parts: [{template: this.specialTransclusion.onApply()}]};

			if (this.selectedNode instanceof ve.dm.MWTransclusionNode) {
				this.getFragment().getSurface()
					.getLinearFragment(this.selectedNode.getOuterRange(), true)
					.changeAttributes({mw: newTransclusion});
			} else {
				this.fragment = this.getFragment().collapseToEnd();
				this.getFragment().insertContent([
					{type: 'mwTransclusionInline', attributes: {mw: newTransclusion}},
					{type: '/mwTransclusionInline'}
				]);
			}

			this.close({action: action});
		}, this);
	} else {
		return SpecialTransclusionDialog.parent.prototype.getActionProcess.apply(this, arguments);
	}
};
SpecialTransclusionDialog.prototype.getSetupProcess = function (data) {
	data = data || {};
	return SpecialTransclusionDialog.parent.prototype.getSetupProcess.apply(this, arguments).next(function () {
		var that = this, deferred = $.Deferred(), templateName;
		if (!this.selectedNode) {
			templateName = data.template;
		} else {
			templateName = (OO.getProp(this.selectedNode.getAttribute('mw'), 'parts', 0, 'template', 'target', 'wt') || '').trim();
		}
		this.getPromiseForTemplate(templateName).done(function (specialTransclusion) {
			that.specialTransclusion = specialTransclusion;
			that.$body.replaceWith(specialTransclusion.$body);
			that.actions.setAbilities({apply: true, insert: true});
		}).always(function () {
			deferred.resolve();
		});
		return deferred.promise();
	}, this);
};
ve.ui.windowFactory.register(SpecialTransclusionDialog);
//virtual outdent
});
//virtual outdent
});
})(jQuery, mediaWiki, mediaWiki.libs);