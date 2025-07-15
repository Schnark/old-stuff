/*global ZipDownloader*/
/*global URL*/
(function () {
"use strict";

function buildLink (blob) {
	return '<a href="' + URL.createObjectURL(blob) + '" download="download.zip" target="_blank">ZIP speichern</a>';
}

var downloader = new ZipDownloader(/*{maxSize: 5000}*/);
downloader.add(
	'file:///home/michael/Documents/Programme/apps/wallpaper/index.html',
	{link: 5, embed: true, linkFilter: '*q*'}
); //proxy: true, timeout: 2000
downloader.add(
	'file:///home/michael/Documents/Programme/apps/install.html?id=barcode-reader',
	{js: 5000, embed: true}
);
downloader.whenDone().then(function () {
	document.getElementById('body').innerHTML = buildLink(downloader.getBlob());
});

})();