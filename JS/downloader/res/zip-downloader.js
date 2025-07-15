/*global ZipDownloader: true*/
/*global Downloader, ZipBuilder*/
ZipDownloader =
(function () {
"use strict";

function ZipDownloader (options) {
	this.options = options || {};
	this.downloader = new Downloader();
	this.zip = new ZipBuilder();
	this.logEntries = [];
	this.downloader.onProgress(this.onProgress.bind(this));
	this.downloader.onLog(this.log.bind(this));
}

ZipDownloader.prototype.onProgress = function (data) {
	data.forEach(function (d) {
		this.zip.addFile(d);
	}.bind(this));
	if (this.options.maxSize && this.options.maxSize <= this.zip.getCurrentSize()) {
		this.downloader.abort();
	}
	if (this.options.maxFiles && this.options.maxFiles <= this.zip.getCurrentCount()) {
		this.downloader.abort();
	}
};

ZipDownloader.prototype.log = function (type, url) {
	var now = new Date();

	function pad (n) {
		return n < 10 ? '0' + String(n) : String(n);
	}

	now = pad(now.getHours()) + ':' + pad(now.getMinutes()) + ':' + pad(now.getSeconds()) +
		'.' + String(now.getMilliseconds() + 1000).slice(1);

	this.logEntries.push('[' + now + '] ' + type + ': ' + url);
};

ZipDownloader.prototype.add = function (urls, options) {
	this.downloader.add(urls, options);
};

ZipDownloader.prototype.abort = function () {
	this.downloader.abort();
};

ZipDownloader.prototype.whenDone = function () {
	return this.downloader.whenDone();
};

ZipDownloader.prototype.setDefaults = function (defaults) {
	this.downloader.setDefaults(defaults);
};

ZipDownloader.prototype.getBlob = function () {
	this.zip.addFile({
		name: 'log.txt',
		content: this.logEntries.join('\n')
	});
	return this.zip.getBlob();
};

return ZipDownloader;

})();