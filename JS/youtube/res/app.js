/*global load, format*/
(function () {
"use strict";

var dom = {};

function isSupportedType (type) {
	return ['video', 'related', 'search', 'author'].indexOf(type) > -1;
}

function updateLocation (type, data) {
	var parts, location;
	if (!isSupportedType(type)) {
		return;
	}
	parts = getTypeAndData(data);
	if (parts[0] === type && parts[1] === data) {
		location = data;
	} else {
		location = type + ':' + data;
	}
	dom.input.value = location;
	//TODO update URL
}

function show (html) {
	dom.body.innerHTML = html;
	//TODO scroll up
}

function showError (error) {
	show('<p class="error">' + format.htmlEscape(error) + '</p>');
}

function runAction (type, data) {
	switch (type) {
	case 'video':
		load.video(data).then(format.videoPage).then(show, showError);
		break;
	case 'related':
		load.video(data).then(function (data) {
			return format.videoList(data.related);
		}).then(show, showError);
		break;
	case 'search':
		load.search(data).then(format.videoList).then(show, showError);
		break;
	case 'author':
		load.author(data).then(format.videoList).then(show, showError);
		break;
	case 'play-video':
		show(format.videoPlayer(data));
		break;
	case 'play-audio':
		show(format.audioPlayer(data));
		break;
	case 'download':
		load.download(data.split('#')[0], data.split('#')[1]);
		break;
	default:
		showError('Unsupported type ' + type);
	}
	updateLocation(type, data);
}

function getTypeAndData (data) {
	var pos, type;
	if (/^[a-zA-Z0-9_\-]{11}$/.test(data)) {
		return ['video', data];
	}
	pos = data.indexOf(':');
	if (pos > -1) {
		type = data.slice(0, pos);
		if (isSupportedType(type)) {
			return [type, data.slice(pos + 1)];
		}
	}
	return ['search', data];
}

function onBodyClick (e) {
	var el = e.target;
	while (el && !el.dataset.action) {
		el = el.parentNode;
	}
	if (el.dataset.action) {
		runAction(el.dataset.action, el.dataset.data);
	}
}

function init () {
	dom.body = document.getElementById('body');
	dom.input = document.getElementById('input');
	dom.body.addEventListener('click', onBodyClick);
	document.getElementById('form').addEventListener('submit', function (e) {
		var data;
		e.preventDefault();
		data = getTypeAndData(dom.input.value);
		runAction(data[0], data[1]);
	});
}

init();

})();