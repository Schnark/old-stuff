/*global load: true*/
load =
(function () {
"use strict";

function getUrl (url) {
	return 'data:image/svg+xml,<!--' + url.replace(/-+/g, '-') + '-->' +
		'<svg%20xmlns="http://www.w3.org/2000/svg"%20width="100"%20height="100">' +
		'<rect%20x="0"%20y="0"%20width="100"%20height="100"%20fill="rgb(200,200,200)"/></svg>';
}

return {
	getUrl: getUrl
};
})();

/*global scrap, format*/
(function () {
"use strict";

function readFile (file, callback) {
	if (!file) {
		callback();
		return;
	}
	var reader = new FileReader();
	reader.onload = function (e) {
		callback(e.target.result);
	};
	reader.onerror = function () {
		callback();
	};
	reader.readAsText(file);
}

function openFile (callback) {
	var pick;
	pick = document.createElement('input');
	pick.type = 'file';
	pick.style.display = 'none';
	document.getElementsByTagName('body')[0].appendChild(pick);
	pick.addEventListener('change', function () {
		readFile(pick.files[0], callback);
		document.getElementsByTagName('body')[0].removeChild(pick);
	}, false);
	pick.click();
}

function onVideoDebug () {
	openFile(function (html) {
		var data = scrap.video(html);
		document.getElementById('output').innerHTML =
			'<h2>Video</h2>' + format.videoPage(data) +
			'<h2>Related</h2>' + format.videoList(data.related);
		document.getElementById('json').textContent = JSON.stringify(data, null, '\t');
	});
}

function onSearchDebug () {
	openFile(function (html) {
		var data = scrap.search(html);
		document.getElementById('output').innerHTML = format.videoList(data);
		document.getElementById('json').textContent = JSON.stringify(data, null, '\t');
	});
}

function onAuthorDebug () {
	openFile(function (html) {
		var data = scrap.author(html);
		document.getElementById('output').innerHTML = format.videoList(data);
		document.getElementById('json').textContent = JSON.stringify(data, null, '\t');
	});
}

function init () {
	document.getElementById('video').addEventListener('click', onVideoDebug);
	document.getElementById('search').addEventListener('click', onSearchDebug);
	document.getElementById('author').addEventListener('click', onAuthorDebug);
}

init();

})();