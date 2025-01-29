/*global URL*/
(function () {
"use strict";

function getImageWorker (callback) {
	var imageWorker, currentCallbacks = [];

	function setCallback (callback) {
		currentCallbacks.push(callback);
	}

	function createInterface () {
		return {
			init: function (data) {
				data = data || {};
				setCallback(data.callback);
				delete data.callback;
				data.type = 'init';
				imageWorker.postMessage(data);
			},
			processInput: function (imageData, callback) {
				setCallback(function (data) {
					callback(data.imageData);
				});
				imageWorker.postMessage({
					type: 'input',
					input: imageData
				}/*, [imageData.data]*/);
			}
		};
	}

	function onMessage (e) {
		var callback = currentCallbacks.shift();
		if (callback) {
			callback(e.data);
		}
	}

	setCallback(function () {
		callback(createInterface());
	});
	imageWorker = new Worker('image-worker.js');
	imageWorker.addEventListener('message', onMessage);
}

function getProcessor (input, output, callback) {
	getImageWorker(function (imageWorker) {
		var initData = {}, needsStart = true, needsStop = false, needsInit = true, isRunning = false, inputCanvasContext;

		function sendData () {
			var w, h;
			w = input.videoWidth || input.naturalWidth || input.width;
			h = input.videoHeight || input.naturalHeight || input.height;
			inputCanvasContext.canvas.width = w;
			inputCanvasContext.canvas.height = h;
			inputCanvasContext.drawImage(input, 0, 0, w, h);
			imageWorker.processInput(
				inputCanvasContext.getImageData(0, 0, w, h),
				function (imageData) {
					var realImageData = output.createImageData(imageData.width, imageData.height);
					realImageData.data.set(imageData.data);
					output.canvas.width = imageData.width;
					output.canvas.height = imageData.height;
					output.putImageData(realImageData, 0, 0);
					process();
				}
			);
		}

		function process () {
			if (needsStop) {
				needsStart = true;
				needsStop = false;
				return;
			}
			needsStart = false;
			if (!isRunning || needsInit) {
				needsInit = false;
				initData.callback = sendData;
				imageWorker.init(initData);
			} else {
				sendData();
			}
		}

		inputCanvasContext = document.createElement('canvas').getContext('2d');
		output = output.getContext('2d');

		callback({
			init: function (data) {
				initData = data || {};
				needsInit = true;
				needsStop = false;
				if (needsStart) {
					process();
				}
			},
			start: function () {
				isRunning = true;
				needsInit = true;
				needsStop = false;
				if (needsStart) {
					process();
				}
			},
			stop: function () {
				isRunning = false;
				needsInit = true;
				needsStop = true;
			}
		});
	});
}

function getUserMedia (constraints, success, error) {
	if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
		navigator.mediaDevices.getUserMedia(constraints).then(success, error);
	} else if (navigator.getUserMedia) {
		navigator.getUserMedia(constraints, success, error);
	} else if (navigator.mozGetUserMedia) {
		navigator.mozGetUserMedia(constraints, success, error);
	} else if (navigator.webkitGetUserMedia) {
		navigator.webkitGetUserMedia(constraints, success, error);
	} else {
		error();
	}
}

function initCamera (callback) {
	var video = document.createElement('video');
	getUserMedia({video: true}, function (stream) {
		var playing = false;
		if ('srcObject' in video) {
			video.srcObject = stream;
		} else if ('mozSrcObject' in video) {
			video.mozSrcObject = stream;
		} else if (window.URL) {
			video.src = URL.createObjectURL(stream);
		} else {
			video.src = stream;
		}
		video.addEventListener('loadeddata', function () {
			if (!playing && video.readyState >= 2) {
				playing = true;
				video.play();
				callback(video);
			}
		});
	}, callback);
}

function getOptions () {
	return {
		extract: document.getElementById('extract').checked,
		diagonalLength: document.getElementById('diagonal-c').checked ?
			Number(document.getElementById('diagonal-v').value) : 0,
		aspectRatio: document.getElementById('aspect-c').checked ?
			Math.pow(2, Number(document.getElementById('aspect-v').value) / 10) : 0,
		grayScale: document.getElementById('grayscale').checked
	};
}

function onOptionUpdate (processor, special) {
	var canvas;
	switch (special) {
	case 'diagonal':
		if (document.getElementById('diagonal-c').checked) {
			canvas = document.getElementById('output');
			document.getElementById('diagonal-v').value =
				Math.round(Math.sqrt(canvas.width * canvas.width + canvas.height * canvas.height));
			document.getElementById('diagonal-v').disabled = false;
		} else {
			document.getElementById('diagonal-v').disabled = true;
		}
		break;
	case 'aspect':
		if (document.getElementById('aspect-c').checked) {
			canvas = document.getElementById('output');
			document.getElementById('aspect-v').value =
				Math.round(1000 * Math.log(canvas.width / canvas.height) / Math.log(2)) / 100;
			document.getElementById('aspect-v').disabled = false;
		} else {
			document.getElementById('aspect-v').disabled = true;
		}
	}
	processor.init(getOptions());
}

function initEvents (processor) {
	var state = 'auto', button, options;
	['extract', 'diagonal-c', 'diagonal-v', 'aspect-c', 'aspect-v', 'grayscale'].forEach(function (id) {
		var el = document.getElementById(id);
		el.addEventListener('change', function () {
			onOptionUpdate(processor, {'diagonal-c': 'diagonal', 'aspect-c': 'aspect'}[id]);
		});
	});
	button = document.getElementById('start-stop');
	options = document.getElementById('options');
	button.addEventListener('click', function () {
		switch (state) {
		case 'auto':
			processor.start();
			button.textContent = 'Stop';
			state = 'started';
			options.disabled = true;
			break;
		case 'started':
			processor.stop();
			button.textContent = 'Continue';
			state = 'stopped';
			break;
		case 'stopped':
			processor.init(getOptions());
			button.textContent = 'Accumulate';
			state = 'auto';
			options.disabled = false;
		}
	});
	document.getElementById('download').addEventListener('click', download);
}

function fileSaveAs (file, name) {
	var a = document.createElement('a');
	if (typeof file !== 'string') {
		file = URL.createObjectURL(file);
	}
	a.href = file;
	if ('download' in a) {
		a.download = name || '';
	} else {
		a.target = '_blank';
	}
	a.style.display = 'none';
	document.body.appendChild(a);
	a.click();
	document.body.removeChild(a);
}

function download () {
	fileSaveAs(document.getElementById('output').toDataURL('image/jpeg'));
}

function run (video) {
	getProcessor(video, document.getElementById('output'), function (processor) {
		initEvents(processor);
		processor.init(getOptions());
	});
}

initCamera(function (video) {
	if (!video) {
		video = new Image();
		video.onload = function () {
			run(video);
		};
		video.src = 'test.jpg';
	} else {
		run(video);
	}
});

})();