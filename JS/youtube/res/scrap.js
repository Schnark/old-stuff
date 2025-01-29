/*global scrap: true*/
/*global load*/
scrap =
(function () {
"use strict";

function scrapJSON (text, search) {
	var i, j;
	i = text.indexOf(search) + search.length - 1;

	j = text.indexOf('};</script>', i);
	if (j !== -1) {
		try {
			return JSON.parse(text.slice(i, j + 1));
		} catch (e) {
		}
	}
	j = i;
	while (j < text.length) {
		j = text.indexOf('}', j + 1);
		try {
			return JSON.parse(text.slice(i, j + 1));
		} catch (e) {
		}
	}
}

function selectThumbnail (data, size) {
	var i;
	for (i = 0; i < data.length; i++) {
		if (data[i].width >= size) {
			return load.getUrl(data[i].url);
		}
	}
	return load.getUrl(data[data.length - 1].url);
}

function formatSize (size) {
	var units = ['B', 'KB', 'MB', 'GB'];
	while (units.length > 1 && size > 1024) {
		units.shift();
		size /= 1024;
	}
	return size.toFixed(1) + ' ' + units[0];
}

function makeLabel (data) {
	var label = [];
	if (data.qualityLabel) {
		label.push(data.qualityLabel);
	}
	if (data.width && data.height) {
		label.push(data.width + '×' + data.height);
	}
	if (data.contentLength) {
		label.push(formatSize(data.contentLength));
	}
	if (data.mimeType) {
		label.push(data.mimeType.replace(/; codecs="(.*)"/, ' ($1)'));
	}
	if (label.length === 0) {
		label.push('unknown');
	}
	return label.join(', ');
}

function getExtension (mime) {
	var map = {
		'audio/webm; codecs="opus"': 'opus'
	};
	return mime ? map[mime] || mime.replace(/;.*/, '').replace(/.*\//, '') : '';
}

function makeFormat (data) {
	return {
		label: makeLabel(data),
		extension: getExtension(data.mimeType),
		video: data.mimeType.slice(0, 5) !== 'audio',
		url: load.getUrl(data.url || decodeURIComponent(data.signatureCipher.replace(/.*&url=/, '')))
	};
}

function pad (n) {
	return n < 10 ? '0' + n : n;
}

function formatDuration (dur) {
	var parts = [];
	if (!dur) {
		return;
	}
	parts.unshift(pad(dur % 60));
	dur = Math.floor(dur / 60);
	if (dur < 60) {
		parts.unshift(dur);
	} else {
		parts.unshift(pad(dur % 60));
		parts.unshift(Math.floor(dur / 60));
	}
	return parts.join(':');
}

function getText (data) {
	if (data && data.simpleText) {
		return data.simpleText;
	}
	if (data && data.runs) {
		return data.runs.map(function (part) {
			return part.text;
		}).join('');
	}
	return data;
}

function makeVideoInfo (data) {
	return {
		id: data.videoId,
		poster: selectThumbnail(data.thumbnail.thumbnails, 300),
		title: getText(data.title),
		desc: getText(data.descriptionSnippet) || data.shortDescription || '',
		duration: getText(data.lengthText) || formatDuration(data.lengthSeconds),
		author: getText(data.ownerText) || data.author || getText(data.shortBylineText) || '',
		views: String(getText(data.viewCountText) || data.viewCount || '').replace(/\D+/g, ''),
		keywords: data.keywords || []
	};
}

function scrapVideoPage (text) {
	var data1 = scrapJSON(text, 'var ytInitialPlayerResponse = {'),
		data2 = scrapJSON(text, 'ytInitialData = {'),
		video = makeVideoInfo(data1.videoDetails);
	video.date = data1.microformat.playerMicroformatRenderer.publishDate;
	video.authorId = (data1.microformat.playerMicroformatRenderer.ownerProfileUrl || '').replace(/^.*\//, '');
	return {
		video: video,
		sources: data1.streamingData.formats.map(makeFormat)
			.concat(data1.streamingData.adaptiveFormats.map(makeFormat)),
		related: data2.contents.twoColumnWatchNextResults.secondaryResults.secondaryResults.results.map(function (data) {
			if (data.compactVideoRenderer) {
				return makeVideoInfo(data.compactVideoRenderer);
			}
			if (data.compactMovieRenderer) {
				return makeVideoInfo(data.compactMovieRenderer);
			}
		}).filter(function (data) {
			return data;
		})
	};
}

function scrapSearchPage (text) {
	var data = scrapJSON(text, 'var ytInitialData = {');
	return data.contents.twoColumnSearchResultsRenderer.primaryContents
		.sectionListRenderer.contents[0].itemSectionRenderer.contents
		.map(function makeSearchResult (data) {
			if (data.videoRenderer) {
				return makeVideoInfo(data.videoRenderer);
			}
			//playlistRenderer, shelfRenderer
		}).filter(function (data) {
			return data;
		});
}

function scrapAuthorPage (text) {
	var data = scrapJSON(text, 'var ytInitialData = {'),
		tabs = data.contents.twoColumnBrowseResultsRenderer.tabs;
	data = tabs.filter(function (tab) {
		return tab.tabRenderer && tab.tabRenderer.content;
	})[0].tabRenderer.content;
	return data.sectionListRenderer.contents[0]
		.itemSectionRenderer.contents[0]
		.gridRenderer.items.map(function (data) {
			if (data.gridVideoRenderer) {
				return makeVideoInfo(data.gridVideoRenderer);
			}
		}).filter(function (data) {
			return data;
		});
}

return {
	video: scrapVideoPage,
	search: scrapSearchPage,
	author: scrapAuthorPage
};
})();