(function () {
"use strict";
/*global OCR*/
/*
	image can be:
		URL to image
		<img>, <video>, <canvas>
		binary data
*/
function ocr (image, callback, options) {
	/*var img;
	if (typeof image === 'string') {
		img = new Image();
		img.src = image;
		image = img;
	}
	if (image.complete === false) {
			image.onload = function () {
				ocr(image, callback, options);
			};
			return;
	}*/
	setTimeout(function () {
		//actually, OCRAD *has* an async mode, but it seems not to work
		callback(OCRAD(image, options));
	}, 0);
}

function videoFromCamera (video, success, error) {
	var getUserMedia = navigator.getUserMedia ||
		navigator.mozGetUserMedia ||
		navigator.webkitGetUserMedia ||
		function (_, __, error) {
			error('navigator.getUserMedia nicht implementiert');
		};
	getUserMedia.call(navigator, {video: true}, function (stream) {
		if ('srcObject' in video) {
			video.srcObject = stream;
		} else if ('mozSrcObject' in video) {
			video.mozSrcObject = stream;
		} else if (window.URL) {
			video.src = URL.createObjectURL(stream);
		} else {
			video.src = stream;
		}
		video.play();
		success();
	}, error);
}

/*
{
  mandatory: {
    width: { min: 640 },
    height: { min: 480 }
  },
  optional: [
    { width: 650 },
    { width: { min: 650 }},
    { frameRate: 60 },
    { width: { max: 800 }},
    { facingMode: "user" }
  ]
}
*/

function init () {
	var video = document.getElementsByTagName('video')[0],
		result = document.getElementById('result');
	videoFromCamera(video, function () {
		video.addEventListener('click', function () {
			ocr(video, function (text) {
				result.value += text;
			});
		});
	}, function (e) {
		result.value = 'Fehler: ' + e;
	});
}

init();
})();