function WikitextContent ($textbox) {
	this.$textbox = $textbox;
}
WikitextContent.prototype.getSelection = function () {
	var range = this.$texbox.textSelection('getCaretPosition', {startAndEnd: true});
	return (range[0] === range[1]) ? false : range;
};
WikitextContent.prototype.setSelection = function (range) {
	this.$textbox.textSelection('setSelection', {start: range[0], end: range[1]});
};
WikitextContent.prototype.unselect = function () {
	this.setSelection([0, 0]);
};
WikitextContent.prototype.getContent = function (selection) {
	var text = this.$textbox.textSelection('getContents');
	return selection ? text.slice(selection[0], selection[1]) : text;
};
WikitextContent.prototype.changeContent = function (changer, selection) {
	var result = changer(this.getContent(selection)), text;
	if (result === undefined || result === false) {
		return;
	}
	if (selection) {
		text = this.getContent();
		result = text.slice(0, selection[0]) + result + text.slice(selection[1]);
		this.$textbox.textSelection('setContents', result);
		this.setSelection([selection[0], selection[1] + result.length - text.length]);
	} else {
		this.$textbox.textSelection('setContents', result);
	}
};

function Problem (content, description) {
	this.content = content;
	this.description = description;
}
Problem.prototype.init = function (selection) {
	this.selection = selection && this.content.getSelection();
	this.hasBeenFound = false;
	this.getResult();
}
Problem.prototype.check = function () {
	throw 'abstract';
};
Problem.prototype.fix = function () {
	throw 'abstract';
};
Problem.prototype.getResult = function () {
	this.lastResult = this.check(this.content.getContent(this.selection));
	if ($.isArray(this.lastResult) && this.lastResult.length === 0) {
		this.lastResult = false;
	}
	if (this.lastResult) {
		this.hasBeenFound = true;
	}
};
Problem.prototype.runFix = function (all) {
	this.content.changeContent(this.fix, all ? this.selection : this.content.getSelection());
};
Problem.prototype.getCount = function () {
	return this.lastResult ? (this.lastResult.length || Infinity) : 0;
};
Problem.prototype.highlight = function (d) {
	var curLen;
	d = d || 0;
	this.getResult();
	curLen = this.getCount();
	if (curLen === 0) {
		this.currentIndex = undefined;
		this.content.unselect();
		return;
	}
	if (this.currentIndex === undefined) {
		this.currentIndex = d >= 0 ? 0 : curLen - 1;
	} else {
		this.currentIndex = (((this.currentIndex + d) % curLen) + curLen) % curLen;
	}
	this.content.setSelection(this.lastResult[this.currentIndex]);
};
Problem.prototype.getNavigation = function () {
	var prev = mw.html.element('span', {'class': 'schnark-lint-prev'}, mw.msg('schnark-lint-prev')),
		next = mw.html.element('span', {'class': 'schnark-lint-next'}, mw.msg('schnark-lint-next'));
	if (this.currentIndex !== undefined) {
		return mw.msg('schnark-lint-navigation2', prev, next, this.currentIndex + 1, this.getCount());
	}
	return mw.msg('schnark-lint-navigation1', prev, next, this.getCount());
};
Problem.prototype.getStatus = function () {
	var hasSelection = !!this.selection, count = this.getCount();
	if (count === 0) {
		if (hasSelection) {
			return mw.msg('schnark-lint-not-in-selection', this.description);
		}
		return mw.msg('schnark-lint-no-longer-found', this.description);
	}
	if (count === Infinity) {
		return mw.msg('schnark-lint-found', this.description);
	}
	if (hasSelection) {
		return mw.msg('schnark-lint-found-n-in-selection', this.description, count, this.getNavigation());
	}
	return mw.msg('schnark-lint-found-n', this.description, count, this.getNavigation());
};
Problem.prototype.updateLi = function () {
	if (!this.hasBeenFound) {
		return;
	}
	var html = this.getStatus(), created = false, that = this;
	if (this.$li && this.$li.html() === html) {
		return;
	}
	if (!this.$li) {
		this.$li = $('<li>');
		created = true;
	}
	this.$li.html(html);
	this.$li.find('.schnark-lint-prev').click(function () {
		that.highlight(-1);
	});
	this.$li.find('.schnark-lint-next').click(function () {
		that.highlight(1);
	});
	if (created) {
		return this.$li;
	}
};




function WikitextProblem (config) {
	this.config = config;
}

WikitextProblem.prototype.getText = function (selected) {
	var content;
	if (selected) {
		content = this.config.$textarea.textSelection('getSelection');
		if (content) {
			return content;
		}
	}
	return this.config.$textarea.textSelection('getContents');
};
WikitextProblem.prototype.highlightRange = function (range) {
	this.config.$textarea.textSelection('setSelection', {start: range[0], end: range[1]});
};
WikitextProblem.prototype.detect = function (/*wikitext*/) {
	throw 'abstract';
};
WikitextProblem.prototype.getInfo = function (selected) {
	
};












function Problem (config) {
	this.config = config;
}

Problem.prototype.detect = function (type, data) {
	var f;
	switch (type) {
	case 'html': f = this.detectInHtml; break;
	case 'wikitext': f = this.detectInWikitext; break;
	case 've': f = this.detectInVE; break;
	default: throw new Error('Unsupported type: ' + type);
	}
	if ($.isFunction(f)) {
		return f.call(this, data);
	} else {
		return false;
	}
};

Problem.prototype.canFix = function (type) {
	switch (type) {
	case 'html': return false;
	case 'wikitext': return $.isFunction(this.fixWikitext);
	case 've': return $.isFunction(this.fixVE);
	default: throw new Error('Unsupported type: ' + type);
	}
};

Problem.prototype.execute = function (type, data) {
	var result = this.detect(type, data);
	if (!result || ($.isArray(result) && result.length === 0)) {
		return;
	}
	if (!$.isArray(result)) {
		return this.reportSingle();
	}
	return this.reportMultiple(result);
};