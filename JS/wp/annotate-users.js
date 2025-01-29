//Dokumentation unter [[Benutzer:Schnark/js/annotate-users]] <nowiki>
/*global mediaWiki*/
(function ($, mw) {
"use strict";

var timestampRe = /CES?T/, specialContribution = ['Contirubions', 'Beiträge']; //FIXME

function getBlocks ($content) {
	return $content.children().add($content.find('dd'));
}

function getContent ($block) {
	return $block.clone().find('dd').remove().end();
}

function getTitleParts (href) {
	var path = mw.config.get('wgArticlePath').replace('$1', ''),
		title = mw.util.getParamValue('title', href), parts;
	if (!title && href.indexOf(path) === 0) {
		title = href.slice(path.length);
		try {
			title = decodeURIComponent(title);
		} catch (e) {
		}
	}
	try {
		title = new mw.Title(title);
	} catch (e) {
		return;
	}
	parts = title.getMainText().split('/');
	parts.unshift(title.getNamespaceId());
	return parts;
}

function userFromHref (href) {
	var result = getTitleParts(href);
	if (result) {
		if (result[0] === -1 && $.inArray(result[1], specialContribution) > -1) {
			return result[2];
		}
		if (result[0] === 2 || result[0] === 3) {
			return result[1];
		}
	}
}

function getUser ($content) {
	var user;
	$content.find('a').each(function () { //FIXME ignore links without timestamp near them
		user = userFromHref($(this).attr('href')) || user;
	});
	return user;
}

function isHeadline ($block) {
	return !!$block.find('.mw-headline').length;
}

function isPS ($block) {
	return false; //FIXME
}

function annotateContent ($content) {
	var $prev = $([]), user;
	if (!timestampRe.test($content.html())) {
		return;
	}
	getBlocks($content).each(function () {
		var $this = $(this);
		if (isHeadline($this)) {
			$prev = $([]);
		}
		$prev = $prev.add($this);
		if (!user || !isPS($this)) {
			user = getUser(getContent($this));
		}
		if (user) {
			$prev.each(function () {
				$(this).attr('data-user', user);
			});
			$prev = $([]);
		}
	});
}

mw.loader.using(['mediawiki.util', 'mediawiki.Title'], function () {
	mw.hook('wikipage.content').add(annotateContent);
	//mw.util.addCSS('[data-user]::before{content:attr(data-user);background:yellow}')
	mw.util.addCSS('[data-user]{color: black} [data-user="Hans Haase"],[data-user="Hans Haase"] > :not([data-user]),[data-user="Hans Haase"] > :not([data-user])> :not([data-user]) {color:gray!important}')
	mw.util.addCSS('[data-user]{background-color: white} [data-user="Eike sauer"],[data-user="Eike sauer"] > :not([data-user]),[data-user="Eike sauer"] > :not([data-user])> :not([data-user]) {background-color:yellow!important}')
});
})(jQuery, mediaWiki);
