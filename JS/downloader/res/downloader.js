/*global Downloader: true*/
/*global Promise, TextDecoder, TextEncoder, URL*/
Downloader =
(function () {
"use strict";

var DEFAULT_PROXY = 'https://api.allorigins.win/raw?url=',
/*
https://cors-anywhere.herokuapp.com/
https://jsonp.afeld.me/?url=
https://api.codetabs.com/v1/proxy?quest=
https://goxcors.appspot.com/cors?method=GET&url=

https://jsonproxy.herokuapp.com/?url=

https://thingproxy.freeboard.io/fetch/
https://yacdn.org/proxy/
https://cors-proxy.htmldriven.com/?url=
https://crossorigin.me/
http://cors.io/?
http://gobetween.oklabs.org/
http://www.whateverorigin.org/
https://api.allorigins.win/raw?url=
*/
	urlToFilename = {};

function extend (a, b) {
	Object.keys(b).forEach(function (key) {
		if (!(key in a)) {
			a[key] = b[key];
		}
	});
	return a;
}

function escapeRE (pattern) {
	return pattern.replace(/([\\{}()|.?*+\-\^$\[\]])/g, '\\$1');
}

function matchesPattern (url, pattern) {
	var re, pos;
	pos = pattern.lastIndexOf('/');
	if (pattern.charAt(0) === '/' && pos > 0) {
		re = new RegExp(pattern.slice(1, pos), pattern.slice(pos + 1));
	} else {
		re = new RegExp('^' + escapeRE(pattern).replace(/\\\*/g, '.*').replace(/\\\?/g, '.') + '$');
	}
	return re.test(url);
}

function adjustPath (name, allNames) {
	var i;
	for (i = 0; i < allNames.length; i++) {
		if (name.slice(0, allNames[i].length + 1) === allNames[i] + '/') {
			return adjustPath(allNames[i] + '_/' + name.slice(allNames[i].length + 1), allNames);
		}
	}
	return name;
}

function adjustName (name, allNames) {
	var i, pos;
	for (i = 0; i < allNames.length; i++) {
		if (name === allNames[i] || allNames[i].slice(0, name.length + 1) === name + '/') {
			pos = name.lastIndexOf('.');
			return adjustName(name.slice(0, pos) + '_' + name.slice(pos), allNames);
		}
	}
	return name;
}

function getSuffix (url, forceSuffix, defaultSuffix) {
	var patterns, i, suffix;
	if (forceSuffix) {
		if (typeof forceSuffix === 'string') {
			return '.' + forceSuffix;
		}
		patterns = Object.keys(forceSuffix);
		for (i = 0; i < patterns.length; i++) {
			if (matchesPattern(url, patterns[i])) {
				return '.' + forceSuffix[patterns[i]];
			}
		}
	}
	suffix = /(\.[a-z0-9]{1,6})(?:\?|#|$)/.exec(url);
	if (suffix && ['.php', '.jsp'].indexOf(suffix[1]) === -1) {
		suffix = suffix[1];
	} else if (defaultSuffix) {
		suffix = '.' + defaultSuffix;
	} else {
		suffix = '.html';
	}
	return suffix;
}

function createFilename (url, forceSuffix, defaultSuffix) {
	var suffix = getSuffix(url, forceSuffix, defaultSuffix), name, allNames;
	name = encodeURIComponent(
		url.replace(/^\w+:\/*/, '')
	).replace(/(?:%2F|%3F)/g, '/').replace(/%/g, '_');
	if (name.charAt(name.length - 1) === '/') {
		name += 'index';
	}
	if (name.slice(-suffix.length) !== suffix) {
		name += suffix;
	}
	name = name.split('/').map(function (part) {
		return part.length < 64 ? part : part.slice(0, 30) + '...' + part.slice(-30);
	}).join('/');
	allNames = Object.keys(urlToFilename).map(function (url) {
		return urlToFilename[url];
	});
	return adjustName(adjustPath(name, allNames), allNames);
}

function getFilename (url, forceSuffix, defaultSuffix) {
	if (!urlToFilename[url]) {
		urlToFilename[url] = createFilename(url, forceSuffix, defaultSuffix);
	}
	return urlToFilename[url];
}

function getRelativePath (path1, path2) {
	path1 = path1.split('/');
	path2 = path2.split('/');
	while (path2.length > 1 && path1[0] === path2[0]) {
		path1.shift();
		path2.shift();
	}
	while (path2.length > 1) {
		path1.unshift('..');
		path2.shift();
	}
	return path1.join('/');
}

function isSpecialUrl (url) {
	return [
		'data', 'mailto', 'javascript', 'geo', 'about'
	].indexOf(url.split(':')[0].toLowerCase()) > -1;
}

function getUrl (url, proxy) {
	if (!proxy) {
		return url;
	}
	if (proxy === true) {
		proxy = DEFAULT_PROXY;
	}
	if (proxy.indexOf('?') > -1) {
		url = encodeURIComponent(url);
	}
	return proxy + url;
}

function matchesFilter (url, filter, defaultValue) {
	if (typeof filter === 'string') {
		return matchesPattern(url, filter);
	}
	if (!filter || filter.length === 0) {
		return defaultValue;
	}
	return filter.some(function (pattern) {
		return matchesPattern(url, pattern);
	});
}

function checkFilter (url, includeFilter, excludeFilter) {
	return matchesFilter(url, includeFilter || [], true) && !matchesFilter(url, excludeFilter || [], false);
}

function removeGoogleRedirect (url) {
	var googleRedirectStart = 'https://www.google.com/url?q=', i;
	if (url.slice(0, googleRedirectStart.length) === googleRedirectStart) {
		url = url.slice(googleRedirectStart.length);
		i = url.indexOf('&');
		url = url.slice(0, i);
		url = decodeURIComponent(url);
	}
	return url;
}

function extractMentionedUrls (text, options) {
	var urls = [];
	text.replace(/(https?:\/\/\w+.*?)["'<>\s]/g, function (all, url) {
		try {
			url = JSON.parse('"' + url + '"');
		} catch (e) {
		}
		if (options.mentionDoubleEncoded && url.indexOf('?') === -1) {
			try {
				url = decodeURIComponent(url);
			} catch (e) {
			}
		}
		if (checkFilter(url, options.mentionFilter, options.mentionExcludeFilter)) {
			urls.push(url);
		}
	});
	return urls;
}

function modifyCssText (css, baseUrl, baseName, options, loadedUrls) {
	var urls = [];

	function replaceUrl (url, type) {
		var hashIndex, hash = '';
		url = String(new URL(url, baseUrl));
		hashIndex = url.indexOf('#');
		if (hashIndex > -1) {
			hash = url.slice(hashIndex);
			url = url.slice(0, hashIndex);
		}
		if (
			loadedUrls.indexOf(url) > -1 ||
			(options.embed && checkFilter(url, options.embedFilter, options.embedExcludeFilter))
		) {
			urls.push(url);
			return getRelativePath(getFilename(url, options.suffixMap, type) + hash, baseName);
		}
		return url + hash;
	}

	css = css.replace(/(@namespace\s+(?:\S+\s+)?url)\(/ig, '$1['); //hide @namespace URLs
	css = css.replace(
		/(url\(["']?)(.*?)(["']?\))|(@import\s+["'])(.*?)(["'])/ig,
		function (all, pre1, url1, post1, pre2, url2, post2) {
			if (url1 && !isSpecialUrl(url1)) {
				return pre1 + replaceUrl(url1, 'png') + post1; //png might be wrong, but better than html
			} else if (url2 && !isSpecialUrl(url2)) {
				return pre2 + replaceUrl(url2, 'css') + post2;
			} else {
				return all;
			}
		}
	);
	css = css.replace(/(@namespace\s+(?:\S+\s+)?url)\[/ig, '$1(');

	return {
		content: css,
		urls: urls
	};
}

function modifyCssResponse (response, options, loadedUrls) {
	var result = modifyCssText(
		(new TextDecoder()).decode(response.content),
		response.finalUrl,
		response.name,
		options,
		loadedUrls
	);
	if (options.mention) {
		result.urls = result.urls.concat(extractMentionedUrls(result.content, options));
	}
	return {
		content: (new TextEncoder()).encode(result.content),
		urls: result.urls
	};
}

function modifyHtmlResponse (response, options, loadedUrls) {
	var html = (new TextDecoder()).decode(response.content), urls = [], base, encoding;
	if (html.indexOf('<!') === -1) {
		throw new Error('Does not look like HTML');
	}
	html = (new DOMParser()).parseFromString(html, 'text/html');
	if (html.querySelector('parsererror')) {
		throw new Error('Parsererror');
	}

	[].forEach.call(html.querySelectorAll('style'), function (style) {
		var res = modifyCssText(style.textContent, response.finalUrl, response.name, options, loadedUrls);
		style.textContent = res.content;
		res.urls.forEach(function (url) {
			urls.push(url);
		});
	});

	base = html.querySelector('base[href]');
	if (base) {
		base.href = String(new URL(base.getAttribute('href'), response.finalUrl));
	} else {
		base = html.createElement('base');
		html.querySelector('head').appendChild(base);
		base.href = response.finalUrl;
	}

	[].forEach.call(html.querySelectorAll('[href]:not(base), [src]'), function (el) {
		var url = el.href || el.src, isLink, isMeta, isEmbed,
			hashIndex = url.indexOf('#'), hash = '', type;
		isEmbed = el.src || (
			el.tagName === 'LINK' && (
				el.rel === 'stylesheet' ||
				(el.rel || '').split(' ').indexOf('icon') > -1
			)
		);
		isMeta = !isEmbed && el.tagName === 'LINK';
		isLink = !isEmbed && !isMeta;
		if (isSpecialUrl(url)) {
			return;
		}
		if (hashIndex > -1) {
			hash = url.slice(hashIndex);
			url = url.slice(0, hashIndex);
		}
		if (options.avoidRedirects) {
			url = removeGoogleRedirect(url);
		}
		if (el.href && isEmbed) {
			type = 'css';
		} else if (el.tagName === 'SCRIPT') {
			type = 'js';
		} else if (el.tagName === 'IMG') {
			type = 'png'; //perhaps wrong, but better than html
		}
		if (
			(loadedUrls.indexOf(url) > -1) ||
			(options.embed && isEmbed && checkFilter(url, options.embedFilter, options.embedExcludeFilter)) ||
			(options.link && isLink && checkFilter(url, options.linkFilter, options.linkExcludeFilter)) ||
			(options.link && options.meta && isMeta && checkFilter(url, options.linkFilter, options.linkExcludeFilter))
		) {
			urls.push(url);
			el.setAttribute(
				el.href ? 'href' : 'src',
				getRelativePath(getFilename(url, options.suffixMap, type), response.name) + hash
			);
		} else {
			el.setAttribute(
				el.href ? 'href' : 'src',
				url + hash
			);
		}
	});

	if (base.target) {
		base.href = '';
	} else {
		html.querySelector('head').removeChild(base);
	}
	encoding = html.inputEncoding || html.charset || html.characterSet || 'UTF-8';

	html = (new XMLSerializer()).serializeToString(html); //TODO outerHTML ?
	if (encoding !== 'UTF-8') { //since we force UTF-8, we have to add a BOM if the original encoding was different
		html = '\uFEFF' + html;
	}
	if (options.mention) {
		urls = urls.concat(extractMentionedUrls(html, options));
	}
	return {
		content: (new TextEncoder()).encode(html),
		urls: urls
	};
}

function reportHtml (duration) {
	function report () {
		window.parent.postMessage((new XMLSerializer()).serializeToString(document), '*');
	}
	window.setTimeout(report, isFinite(duration) ? duration : 10000);
	if (!isFinite(duration)) {
		window.addEventListener('load', report);
	}
	(document.currentScript || document.scripts[document.scripts.length - 1]).remove();
}

function executeJs (html, duration) {
	return new Promise(function (resolve) {
		var iframe = document.createElement('iframe');

		function onMessage (e) {
			if (e.source === iframe.contentWindow) {
				window.removeEventListener('message', onMessage);
				document.body.removeChild(iframe);
				resolve(e.data);
			}
		}

		iframe.style.height = '1px';
		iframe.style.width = '1px';
		window.addEventListener('message', onMessage);
		iframe.src = 'data:text/html,' + encodeURIComponent(
			html.replace(
				/<\/html>|$/i,
				'<script>(' + String(reportHtml) + ')(' + duration + ')</script></html>'
			) //TODO better place
		);
		document.body.appendChild(iframe);

		window.setTimeout(function () {
			resolve(html);
		}, isFinite(duration) ? duration + 2000 : 12000);
	});
}

function executeHtmlResponse (response, options, loadedUrls) {
	var data = modifyHtmlResponse(response, {}, []);
	return executeJs((new TextDecoder()).decode(data.content), options.js).then(function (html) {
		response.content = (new TextEncoder()).encode(html);
		return modifyHtmlResponse(response, options, loadedUrls);
	});
}

function modifyResponse (response, options, loadedUrls) {
	var isHtml = (
		getFilename(response.finalUrl).slice(-5) === '.html' ||
		getFilename(response.finalUrl).slice(-4) === '.htm'
	);
	try {
		if (
			options.embed &&
			getFilename(response.finalUrl).slice(-4) === '.css'
		) {
			return Promise.resolve(modifyCssResponse(response, options, loadedUrls));
		}
		if (options.js && isHtml) {
			return executeHtmlResponse(response, options, loadedUrls);
		}
		if (
			(options.embed || options.link || options.modify) &&
			isHtml
		) {
			return Promise.resolve(modifyHtmlResponse(response, options, loadedUrls));
		}
		if (options.mention) {
			return Promise.resolve({
				content: response.content,
				urls: extractMentionedUrls((new TextDecoder()).decode(response.content), options)
			});
		}
	} catch (e) {
	}
	return Promise.resolve({
		content: response.content,
		urls: []
	});
}

function Downloader (urls, options) {
	this.urlQueue = {};
	this.progressHandlers = [];
	this.logHandlers = [];
	this.defaults = {};
	if (urls) {
		this.add(urls, options);
		this.promise = this.handleQueue();
	}
}

Downloader.prototype.download = function (url, options) {
	if (this.isAborted) {
		return Promise.reject('Could not load ' + url + ' [aborted]');
	}
	options = options || {};
	return new Promise(function (resolve, reject) {
		var xhr = new XMLHttpRequest();
		this.currentXHR = xhr;
		xhr.onload = function () {
			resolve({
				name: getFilename(url, options.suffix || options.suffixMap),
				finalUrl: options.proxy ? url : xhr.responseURL || url, //TODO X-Final-URL
				content: new Uint8Array(xhr.response)
			});
		};
		xhr.ontimeout = function () {
			reject('Could not load ' + url + ' [timeout]');
		};
		xhr.onerror = function () {
			reject('Could not load ' + url);
		};
		xhr.open('GET', getUrl(url, options.proxy));
		if (options.timeout) {
			xhr.timeout = options.timeout;
		}
		xhr.responseType = 'arraybuffer';
		xhr.send();
	}.bind(this));
};

Downloader.prototype.abort = function () {
	this.isAborted = true;
	if (this.currentXHR) {
		this.currentXHR.abort();
	}
};

Downloader.prototype.queueUrls = function (urls, options) {
	var i;
	options = JSON.stringify(options || {});
	for (i = 0; i < urls.length; i++) {
		if (!this.urlQueue[urls[i]]) {
			this.log('add-url', urls[i]);
			this.urlQueue[urls[i]] = extend(JSON.parse(options), this.defaults);
		}
	}
};

Downloader.prototype.handleUrl = function (url, options) {
	this.log('download-start', url);
	return this.download(url, options).then(function (response) {
		this.log('download-success', url);
		return modifyResponse(response, options, Object.keys(this.urlQueue)).then(function (result) {
			if (options.link) {
				options.modify = true;
				options.link--;
			}
			if (options.mention) {
				options.mention--;
			}
			if (options.suffix) {
				options.suffix = false;
			}
			if (options.maxCount && result.urls.length > options.maxCount) {
				result.urls.length = options.maxCount;
			}
			this.queueUrls(result.urls, options);
			return {
				name: response.name,
				content: result.content
			};
		}.bind(this));
	}.bind(this), function (error) {
		this.log('download-error', url);
		return {
			name: getFilename(url),
			content: (new TextEncoder()).encode(error)
		};
	}.bind(this));
};

Downloader.prototype.handleQueue = function () {
	var url, hasPending = false;
	for (url in this.urlQueue) {
		if (!this.urlQueue[url].content) {
			hasPending = true;
			break;
		}
	}
	if (hasPending) {
		return this.handleUrl(url, this.urlQueue[url]).then(function (response) {
			this.urlQueue[url] = response;
			this.handleProgress();
			return this.handleQueue();
		}.bind(this));
	}
	this.handleProgress();
	return Promise.resolve(Object.keys(this.urlQueue).map(function (url) {
		return this.urlQueue[url];
	}.bind(this)));
};

Downloader.prototype.handleProgress = function () {
	var urls = Object.keys(this.urlQueue).filter(function (url) {
		return this.urlQueue[url].content;
	}.bind(this));
	this.progressHandlers.forEach(function (handlerData) {
		var newData = [], i;
		for (i = 0; i < urls.length; i++) {
			if (handlerData.urls.indexOf(urls[i]) === -1) {
				handlerData.urls.push(urls[i]);
				newData.push(this.urlQueue[urls[i]]);
			}
		}
		if (newData.length > 0) {
			handlerData.handler(newData);
		}
	}.bind(this));
};

Downloader.prototype.log = function (type, url) {
	this.logHandlers.forEach(function (handler) {
		handler(type, url);
	});
};

Downloader.prototype.add = function (urls, options) {
	if (typeof urls === 'string') {
		this.queueUrls([urls], options);
	} else if (Array.isArray(urls)) {
		this.queueUrls(urls, options);
	} else {
		Object.keys(urls).forEach(function (url) {
			this.queueUrls([url], urls[url]);
		}.bind(this));
	}
};

Downloader.prototype.setDefaults = function (newDefaults) {
	this.defaults = newDefaults;
};

Downloader.prototype.onProgress = function (handler) {
	this.progressHandlers.push({
		handler: handler,
		urls: []
	});
};

Downloader.prototype.onLog = function (handler) {
	this.logHandlers.push(handler);
};

Downloader.prototype.whenDone = function () {
	if (!this.promise) {
		this.promise = this.handleQueue();
	}
	return this.promise;
};

return Downloader;
})();

/*
proxy: false - kein Proxy, true - Standardproxy, String - eigener Proxy
timeout: Timeout für Anfrage
embed: true - eingebettete Dateien herunterladen und URL anpassen
embedFilter: nur auf Filter passende Dateien einbetten
embedExcludeFilter: auf Filter passende Dateien nicht einbetten
link: Zahl - verlinkte Dateien herunterladen bis zur angegebenen Tiefe
meta: true - auch Metalinks wie Links behandeln
linkFilter
linkExcludeFilter
mention: Zahl - auch (etwa in eingebettetem JS) erwähnte URLs bis zur angegebenen Tiefe herunterladen
mentionFilter
mentionExcludeFilter
mentionDoubleEncoded: true - URLs sind doppelt codiert
maxCount: Zahl - maximale Zahl der abhängigen Dateien, die heruntergeladen werden
modify: true - URLs anpassen (passiert mit embed oder link automatisch)
js: JavaScript ausführen
suffix: Suffix für Datei
suffixMap: Map mit Pattern: Suffix
avoidRedirects: true - Google-URL-Weiterleitungen umgehen
*/