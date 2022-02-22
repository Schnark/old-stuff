/*global format: true*/
format =
(function () {
"use strict";

var canDownload = 'download' in document.createElement('a');

function htmlEscape (str) {
	return String(str)
		.replace(/&/g, '&amp;').replace(/"/g, '&quot;')
		.replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function openTag (tag, attr) {
	return '<' + tag + ' ' + Object.keys(attr).map(function (key) {
		var val = attr[key];
		if (val === false) {
			return '';
		}
		if (val === true) {
			return key;
		}
		return key + '="' + htmlEscape(attr[key]) + '"';
	}).join(' ') + '>';
}

function formatVideoInfo (data, forList) {
	return [
		data.duration ? data.duration : '',
		forList ?
			htmlEscape(data.author) :
			openTag('span', {
				tabindex: 0, 'data-action': 'author', 'data-data': data.authorId || data.author
			}) + htmlEscape(data.author) + '</span>',
		data.views ? data.views + ' views' : ''
	].filter(function (part) {
		return part;
	}).join(', ');
}

function formatVideoPreview (data, forList) {
	return (
		forList ?
			openTag('li', {tabindex: 0, 'data-action': 'video', 'data-data': data.id, 'class': 'video'}) :
			'<div class="video">'
	) + [
		data.poster ? openTag('img', {src: data.poster}) : '',
		'<p><b>' + htmlEscape(data.title) + '</b><br>' + formatVideoInfo(data, forList) + '</p>',
		data.desc ? '<p>' + htmlEscape(data.desc) + '</p>' : '',
		data.keywords && data.keywords.length ? '<p>' + htmlEscape(data.keywords.join(', ')) + '</p>' : ''
	].join('') +
	(forList ? '</li>' : '</div>');
}

function formatSourcesList (data, name) {
	return '<ul class="sources">' + data.map(function (entry) {
		var watch, download;
		watch = openTag('span', {
			tabindex: 0, 'data-action': entry.video ? 'play-video' : 'play-audio',
			'data-data': entry.url
		}) + (entry.video ? 'watch' : 'listen') + '</span>';
		if (canDownload) {
			download = entry.url + (entry.extension ? '#' + name + '.' + entry.extension : '');
			download = openTag('span', {
				tabindex: 0, 'data-action': 'download', 'data-data': download
			}) + 'download</span>';
		} else {
			download = openTag('a', {
				href: entry.url, target: '_blank', rel: 'noopener'
			}) + 'download</a>';
		}
		return '<li>' + htmlEscape(entry.label) + ': ' + watch + ', ' + download + '</li>';
	}).join('') + '</ul>';
}

function formatVideoList (data) {
	return '<ul>' + data.map(function (video) {
		return formatVideoPreview(video, true);
	}).join('') + '</ul>';
}

function formatVideoPage (data) {
	return formatVideoPreview(data.video) +
		formatSourcesList(data.sources, data.video.id) +
		'<p>' + openTag('span', {
			tabindex: 0, 'data-action': 'related', 'data-data': data.video.id
		}) + 'Related videos' + '</span></p>';
}

function formatVideoPlayer (url) {
	return openTag('video', {src: url, autoplay: true, controls: true}) + '</video>';
}

function formatAudioPlayer (url) {
	return openTag('audio', {src: url, autoplay: true, controls: true}) + '</audio>';
}

return {
	htmlEscape: htmlEscape,
	videoPage: formatVideoPage,
	videoList: formatVideoList,
	videoPlayer: formatVideoPlayer,
	audioPlayer: formatAudioPlayer
};

})();