(function () {
"use strict";

var MINITER = 128,
	ITERSTEP = 64,
	MAXITER = 128 + 4 * 64,
	worker = new Worker('mandelbrot-worker.js'),
	currentPos,
	canvas = document.getElementById('canvas'),
	canvasCtx = canvas.getContext('2d'),
	requestCount = 0,
	prevTouches = [];

worker.onmessage = function (e) {
	init(e.data);
};

function paint (data) {
	if (data.request !== requestCount) {
		return;
	}
	canvasCtx.putImageData(data.imageData, 0, 0);
	if (data.n === -1) {
		setView(MINITER);
	} else if (data.n < MAXITER) {
		setView(data.n + ITERSTEP);
	}
}

function init (delta) {
	currentPos = startPos(delta);
	canvas.mozOpaque = true;
	worker.onmessage = function (e) {
		paint(e.data);
	};
	setView(MINITER);
}

function startPos (delta) {
	var w = canvas.width, h = canvas.height,
		d = Math.round(4 / (delta * Math.min(w, h))),
		a0 = Math.round(2 / delta - w * d / 2),
		b0 = -Math.round(h * d / 2);
	return {a0: a0, b0: b0, d: d};
}

function handleTouches (touches) {
	var x, y, f;
	switch (Math.min(prevTouches.length, touches.length)) {
	case 1:
		move(touches[0].x - prevTouches[0].x, touches[0].y - prevTouches[0].y);
		break;
	case 2:
		x = Math.round((prevTouches[0].x + prevTouches[1].x + touches[0].x + touches[1].x) / 4);
		y = Math.round((prevTouches[0].y + prevTouches[1].y + touches[0].y + touches[1].y) / 4);
		f = Math.sqrt(
			(Math.pow(touches[0].x - touches[1].x, 2) + Math.pow(touches[0].y - touches[1].y, 2)) /
			(Math.pow(prevTouches[0].x - prevTouches[1].x, 2) + Math.pow(prevTouches[0].y - prevTouches[1].y, 2))
		);
		if (f > 100) {
			f = 100;
		} else if (f < 1 / 100) {
			f = 1 / 100;
		}
		zoom(x, y, f);
	}
	prevTouches = touches;
}

function resize () {
	setView();
}

function switchOrientation () {
	var d = Math.round((canvas.width - canvas.height) / 2);
	move(d, -d);
}

function move (dx, dy) {
	console.log('move (' + dx + ', ' + dy + ')');
	currentPos.a0 -= dx * currentPos.d;
	currentPos.b0 -= dy * currentPos.d;
	setView();
}

function zoom (x, y, f) {
	console.log('zoom (' + x + ', ' + y + ') - ' + f);
 	var dnew = Math.round(currentPos.d / f);
	if (dnew < 1) {
		dnew = 1;
	}
	f = dnew - currentPos.d;
	currentPos.d = dnew;
	currentPos.a0 -= x * f;
	currentPos.b0 -= y * f;
	setView();
}

function setView (n) {
	var imageData;
	if (n === undefined) {
		//n = MINITER;
		n = -1;
	}
	requestCount = (requestCount + 1) % 1024;
	imageData = canvasCtx.createImageData(canvas.width, canvas.height);
	worker.postMessage({a0: currentPos.a0, b0: currentPos.b0, d: currentPos.d, n: n, request: requestCount, imageData: imageData}, [imageData.data]);
}


canvas.onclick = function (e) {
	zoom(e.clientX, e.clientY, e.buttons === 1 ? 2 : 0.5);
};
canvas.onmousemove = function (e) {
	if (e.buttons) {
		handleTouches([{x: e.clientX, y: e.clientY}]);
	}
};
canvas.onwheel = function (e) {
	zoom(e.clientX, e.clientY, e.deltaX > 0 ? 2 : 0.5);
}

})();