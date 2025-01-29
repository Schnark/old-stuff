/*global load: true*/
/*global scrap*/
/*global Promise, URL, Blob*/
load =
(function () {
"use strict";

var cache = {
	video: {},
	search: {},
	author: {}
}, getUrl = {
	proxy: function (url) {
		return 'https://api.allorigins.win/raw?url=' + encodeURIComponent(url);
	},
	video: function (id) {
		return 'https://www.youtube.com/watch?v=' + id;
	},
	search: function (query) {
		return 'https://www.youtube.com/results?search_query=' + encodeURIComponent(query);
	},
	author: function (name) {
		return 'https://www.youtube.com/c/' + encodeURIComponent(name) + '/videos';
	}
};

function get (url) {
	return new Promise(function (resolve, reject) {
		var xhr = new XMLHttpRequest();
		xhr.onload = function () {
			resolve(xhr.response);
		};
		xhr.ontimeout = function () {
			reject('Could not load ' + url + ' [timeout]');
		};
		xhr.onerror = function () {
			reject('Could not load ' + url);
		};
		xhr.open('GET', getUrl.proxy(url));
		xhr.send();
	});
}

function getData (type, query) {
	if (!cache[type][query]) {
		cache[type][query] = get(getUrl[type](query)).then(scrap[type]);
	}
	return cache[type][query];
}

function download (url, name) {
	get(url).then(function (data) {
		var a = document.createElement('a'), file;
		file = URL.createObjectURL(new Blob([data], {type: 'video/mp4'})); //FIXME
		a.href = file;
		a.download = name || '';
		a.style.display = 'none';
		document.body.appendChild(a);
		a.click();
		document.body.removeChild(a);
		URL.revokeObjectURL(file);
	});
}

return {
	getUrl: getUrl.proxy,
	video: function (id) {
		return getData('video', id);
	},
	search: function (query) {
		return getData('search', query);
	},
	author: function (name) {
		return getData('author', name);
	},
	download: download
};
})();