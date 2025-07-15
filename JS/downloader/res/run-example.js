/*global ZipDownloader*/
/*global URL*/
(function () {
"use strict";
//http://gobetween.oklabs.org/
//http://www.whateverorigin.org/
//https://api.allorigins.win/raw?url=

function buildLink (blob) {
	return '<a href="' + URL.createObjectURL(blob) + '" download="download.zip" target="_blank">ZIP speichern</a>';
}

var downloader = new ZipDownloader({maxSize: 500 * 1024 * 1024});
downloader.add(
	[
		'https://phabricator.wikimedia.org/diffusion/MW/history/master/resources/', //regelmäßig
		//'https://phabricator.wikimedia.org/diffusion/GVED/history/master/', //semi-regelmäßig
		//'https://phabricator.wikimedia.org/diffusion/EVED/history/master/', //semi-regelmäßig
		//'https://phabricator.wikimedia.org/diffusion/SVEC/history/master/', //semi-regelmäßig
		//'https://de.wikipedia.org/wiki/Wikipedia:Projektneuheiten', //semi-regelmäßig
		//'https://de.wikipedia.org/wiki/Wikipedia:Technik/Skin/Werkstatt', //semi-regelmäßig
		'https://de.wikipedia.org/wiki/Wikipedia:Fragen_zur_Wikipedia' //regelmäßig
		//'https://de.wikipedia.org/wiki/Wikipedia:Verbesserungsvorschläge', //semi-regelmäßig
		//'https://2020.js13kgames.com/', //später
		//'https://medium.com/js13kgames', //später
		//'https://2020.js13kgames.com/submit',
	],
	{proxy: true, embed: true}
);

downloader.add(
	[
		//'https://github.com/foo/bar/archive/master.zip',
		//'https://github.com/search?q=foo+bar',
		//'https://www.google.com/search?q=foo+bar',
		//'https://archive.org/search.php?query=foo%20bar',
		//'https://archive.org/download/foo/foo.djvu',
	],
	{proxy: true, modify: true}
);
downloader.add(
	[
		//'https://lists.wikimedia.org/pipermail/wikitech-l/2020-September.txt.gz' //später
		//'https://www.stundengebet.de/jetzt-beten/' //semi-regelmäßig
	],
	{proxy: true}
);

downloader.add('https://www.der-postillon.com/', { //regelmäßig
	proxy: true,
	link: 1,
	linkFilter: 'https://www.der-postillon.com/*2020*'
});
downloader.add('https://xkcd.com/', { //regelmäßig
	proxy: true,
	embed: true,
	link: 1,
	linkFilter: '*/23??/'
});
downloader.add('http://www.sandraandwoo.com/', { //regelmäßig
	proxy: 'https://api.allorigins.win/raw?url=', //'https://api.codetabs.com/v1/proxy?quest=', //'https://goxcors.appspot.com/cors?method=GET&url=',
	embed: true,
	link: 1,
	embedFilter: '*sandraandwoo*',
	linkFilter: ['*/2020/09/*']
});
downloader.whenDone().then(function () {
	document.getElementById('body').innerHTML = buildLink(downloader.getBlob());
});

})();