(function () {
"use strict";

var container, addedImages = {};

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
			'img {',
				'max-height: 100vh;',
			'}',
		'}',
		'@page {',
			'margin: 0;',
		'}',
		'</style>'
	].join('\n');
}

function addContainer () {
	container = document.createElement('div');
	container.className = 'hacked-container';
	container.innerHTML = getStyle();
	document.body.appendChild(container);
}

function showScrapProgress (all) {
	var ranges = [],
		i, n;
	for (i = 0; i < all.length; i++) {
		if (all[i].width && all[i].dataset.n) {
			n = Number(all[i].dataset.n);
			if (ranges.length === 0 || ranges[ranges.length - 1][1] + 1 < n) {
				ranges.push([n, n]);
			} else if (ranges[ranges.length - 1][1] < n) {
				ranges[ranges.length - 1][1]++;
			}
		}
	}
	ranges = ranges.map(function (range) {
		if (range[0] === range[1]) {
			return String(range[0] + 1);
		}
		return String(range[0] + 1) + '–' + String(range[1] + 1);
	}).join(', ');
	document.title = '[Scrapped: ' + ranges + '] ' + document.title.replace(/^\[.*?\] /, '');
}

function addImage (url, n) {
	var img = document.createElement('img'), node, all, i;
	img.src = url;
	if (n === -1) {
		container.appendChild(img);
	} else {
		img.dataset.n = String(n);
		node = container.firstChild;
		while (
			node && (
				(node.dataset.n && Number(node.dataset.n) < n) ||
				!node.dataset.n
			)
		) {
			node = node.nextSibling;
		}
		container.insertBefore(img, node);
	}
	all = document.querySelectorAll('.hacked-container img');
	if (all.length === 50) {
		for (i = 0; i < all.length; i++) {
			cropImage(all[i]);
		}
	}
	if (all.length >= 50) {
		cropImage(img);
	}
	showScrapProgress(all);
}

function getPagenumber (img) {
	var result = /pagediv(\d+)/.exec(img.parentElement.className);
	if (result) {
		return Number(result[1]);
	}
	return -1;
}

function cropOnLoad () {
	/*jshint validthis: true*///Eventhandler
	this.removeEventListener('load', cropOnLoad);
	cropImage(this);
}

function cropImage (img) {
	var W = 400,
		canvas, s;
	if (!img.width) {
		img.addEventListener('load', cropOnLoad);
		return;
	}
	if (img.width < W) {
		return;
	}
	canvas = document.createElement('canvas');
	s = img.width / W;
	canvas.width = Math.round(img.width / s);
	canvas.height = Math.round(img.height / s);
	canvas.getContext('2d').drawImage(img, 0, 0, canvas.width, canvas.height);
	img.src = canvas.toDataURL('image/png');
}

function addVisiblePages () {
	var pages = document.querySelectorAll('.BRpage-visible .BRpageimage'),
		i, url;
	for (i = 0; i < pages.length; i++) {
		url = pages[i].src;
		if (!addedImages[url]) {
			addedImages[url] = true;
			addImage(url, getPagenumber(pages[i]));
		}
	}
}

function run () {
	var i, buttons = document.querySelectorAll('button.book_flip_next, button.book_flip_prev');
	addContainer();
	addVisiblePages();
	for (i = 0; i < buttons.length; i++) {
		buttons[i].addEventListener('click', addVisiblePages);
	}
}

run();
})();