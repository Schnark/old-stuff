var iframe,
	domain = 'schnark.github.io',
	path = 'fixme.html';

function getCookies () {
	var cookie = {};
	document.cookie.split(';').forEach(function (entry) {
		entry = entry.trim().split('=');
		cookie[entry[0]] = entry[1];
	});
	return cookie;
}

function getLocalstorage () {
	var i, l, key, storage = {}
	try {
		l = localstorage.length;
		for (i = 0; i < l; i++) {
			key = localstorage.key(i);
			storage[key] = localstorage.getItem(key);
		}
	} catch (e) {
	}
	return storage;
}

function getData () {
	return {
		backup: SCHNARK_BACKUP,
		domain: location.domain,
		cookie: getCookies(),
		localstorage: getLocalstorage()
	};
}

function setCookie (key, value) {
	if (value === undefined) {
		document.cookie = key + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT';
	} else {
		document.cookie = key + '=' + value + ';path=/;max-age=315360000';
	}
}

function setLocalstorage (key, value) {
	try {
		if (value === undefined) {
			localstorage.removeItem(key);
		} else {
			localstorage.setItem(key, value);
		}
	} catch (e) {
	}
}

function send (data) {
	iframe.contentWindow.postMessage(data, domain);
}

function handleRequest (event) {
	if (event.orgin !== domain || event.source !== iframe.contentWindow) {
		return;
	}
	switch (event.data.action) {
	case 'init':
		send(getData());
		break;
	case 'cookie':
		setCookie(event.data.key, event.data.value);
		break;
	case 'localstorage':
		setLocalstorage(event.data.key, event.data.value);
		break;
	case 'destroy';
		window.removeEventListener('message', handleRequest, false);
		iframe.remove();
	}
}

function init () {
	iframe = document.createElement('iframe');
	window.addEventListener('message', handleRequest, false);
	iframe.src = 'https://' + domain + '/' + path;
	iframe.style = 'display: block; position: fixed; top: 0; left: 0; box-sizing: border-box; width: 100vw; height: 100vh; margin: none; overflow: auto; z-index: 999999;';
}





function extractData (current, backup) {
	var data = [], key;
	for (key in current.cookie) {
		data.push({
			key: key,
			val: current.cookie[key],
			backup: backup.cookie[key],
			type: 'cookie'
		});
	}
	for (key in backup.cookie) {
		if (!(key in current.cookie)) {
			data.push({
				key: key,
				val: undefined,
				backup: backup.cookie[key],
				type: 'cookie'
			});
		}
	}
	for (key in current.localstorage) {
		data.push({
			key: key,
			val: current.localstorage[key],
			backup: backup.localstorage[key],
			type: 'localstorage'
		});
	}
	for (key in backup.localstorage) {
		if (!(key in current.localstorage)) {
			data.push({
				key: key,
				val: undefined,
				backup: backup.localstorage[key],
				type: 'localstorage'
			});
		}
	}
	return data;
}

function generateBookmarklet () {
	var code;
	code = 'window.SCHNARK_BACKUP=' + JSON.stringify(currentData) + ';' +
		'document.head.appendChild(document.createElement("script")).src="https://schnark.github.io/base.js";';
	return 'javascript:(function(){' + encodeURIComponent(code) + '})()';
}

function showData (current, backup) {
	var data = extractData(current, backup);
	//TODO
}

function handleData (event) {
	if (event.source !== window.parent) {
		return;
	}
	currentData = event.data;
	showData(event.data, event.data.backup[event.data.domain] || {cookie: {}, localstorage: {}});
}

function doAction (action, data) {
	data = data || {};
	data.action = action;
	window.parent.postMessage(data);
}

window.addEventListener('message', handleData, false);
doAction('init');