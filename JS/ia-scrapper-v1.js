(function () {
"use strict";

function getStyle () {
	return [
		'<style>',
		'#wrap {',
			'height: auto;',
		'}',
		'body > .hacked-container img {',
			'display: block;',
			'page-break-after: always;',
			'break-after: page;',
			'margin: auto;',
		'}',
		'@media print {',
			'body > :not(.hacked-container) {',
				'display: none;',
			'}',
		'}',
		'@page {',
			'margin: 0;',
		'}',
		'</style>'
	].join('\n');
}

function pad (n, l) {
	n = String(n);
	while (n.length < l) {
		n = '0' + n;
	}
	return n;
}

function getUrl (url, page, scale) {
	page = String(page);
	url = url.replace(/(file=(\S+)_jp2\/\2_)(\d+)(\.jp)/, function (all, pre, two, p, post) {
		return pre + pad(page, p.length) + post;
	}).replace(/(page=\D*)\d+/, '$1' + page);
	if (scale) {
		url = url.replace('scale=2', 'scale=4');
	}
	return url;
}

function getHtml (url, start, end, w) {
	var img = [], i, scale = false;
	start = Number(start);
	end = Number(end);
	if (end - start > 50 && w > 400) {
		scale = true;
	}
	for (i = start; i <= end; i++) {
		img.push('<img src="' + getUrl(url, i, scale) + '">');
	}
	return img.join('\n');
}

function getTotalPages () {
	try {
		return (/(?:of |\/)(\d+)/).exec(document.querySelector('.BRcurrentpage').textContent)[1];
	} catch (e) {
	}
	return '1';
}

function run () {
	var pages = window.prompt('Pages:', '1-' + getTotalPages()),
		img = document.querySelector('[alt="Book page image"]'),
		div = document.createElement('div');
	pages = pages.split('-');
	div.className = 'hacked-container';
	div.innerHTML = getStyle() + getHtml(
		img.src,
		pages[0],
		pages[1],
		img.width
	);
	document.body.appendChild(div);
}

run();
})();