/*global mediaWiki*/
(function ($, mw) {
"use strict";

function runSequence (list, callback) {
	var d = $.Deferred().resolve([]);
	$.each(list, function (i, item) {
		d = d.then(function (all) {
			return callback(item).then(function (data) {
				all.push(data);
				return all;
			});
		});
	});
	return d;
}

function getAllRevisions (title, timestamp, revs, cont) {
	var query = {
		action: 'query',
		prop: 'revisions',
		titles: title,
		rvstart: timestamp,
		rvdir: 'newer',
		rvlimit: 'max',
		format: 'json',
		formatversion: 2
	};
	if (!revs) {
		revs = [];
	}
	if (cont) {
		query = $.extend(query, cont);
	}
	return $.getJSON(mw.util.wikiScript('api'), query).then(function (data) {
		revs = revs.concat(data.pages[0].revisions);
		if (data['continue']) {
			return getAllRevisions(title, timestamp, revs, data['continue']);
		} else {
			return {title: title, revisions: revs};
		}
	});
}

function getChangedTitles (all, cont) {
	var query = {
		action: 'query',
		list: 'watchlistraw',
		wrlimit: 'max',
		wrprop: 'changed',
		wrshow: 'changed',
		format: 'json',
		formatversion: 2
	};
	if (!all) {
		all = [];
	}
	if (cont) {
		query = $.extend(query, cont);
	}
	return $.getJSON(mw.util.wikiScript('api'), query).then(function (data) {
		all = all.concat(data.watchlistraw);
		if (data['continue']) {
			return getChangedTitles(all, data['continue']);
		} else {
			return all;
		}
	});
}

function getAllChanges () {
	return getChangedTitles().then(function (list) {
		return runSequence(list, function (entry) {
			return getAllRevisions(entry.title, entry.changed);
		});
	});
}

function formatList (list) {
	return '<ul>' + list.map(function (entry) {
		return '<li>' + formatPage(entry.title, entry.revisions) + '</li>';
	}).join('') + '</ul>';
}

function formatPage (title, revisions) {
	return mw.html.element('a', {href: mw.util.getUrl(title), target: '_blank', rel: 'noopener'}, title) +
		'<ul>' + revisions.map(function (entry) {
		return '<li>' +
			mw.html.element('a', {
				href: mw.util.wikiScript() + '?' + (
					entry.parentid > 0 ? 'diff=' + entry.revid + '&oldid=' + entry.parentid :
					'diff=prev&oldid=' + entry.revid
				),
				target: '_blank', rel: 'noopener'
			}, 'Änderung') +
			' von ' +
			mw.html.element('a', {
				href: mw.util.getUrl('Special:Contributions/' + entry.user), target: '_blank', rel: 'noopener'
			}, entry.user) +
			': ' +
			mw.html.element('code', {}, entry.comment) +
			'</li>';
	}).join('') + '</ul>';
}

function run () {
	getAllChanges().then(function (list) {
		$('#mw-content-text').html(formatList(list));
	});
}

$(run);

})(jQuery, mediaWiki);