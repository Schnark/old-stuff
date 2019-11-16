(function (parent) {
"use strict";

var DELTA = 1 / (1024 * 1024),
	MAXA = 4 / DELTA,
	MAXB = 2 / DELTA,
	cache = {};

/* Coordinate systems:
There are 3 coordinate systems:
* (x, y): mathematical system
* (i, j): canvas pixels, with x = x0 + i * e, y = y0 - j * e
* (a, b): value cache, with a = (2 + x) / DELTA, b = abs(y) / DELTA
So when we want to paint the pixel (i, j), we have to look at (a, b) with
a = (2 + x0) / DELTA + i * (e / DELTA)
b = abs(y0 / DELTA - j * (e / DELTA))
With a0 = (2 + x0) / DELTA, b0 = y0 / DELTA, d = e / DELTA
this is a = a0 + i * d, b = abs(b0 - j * d)
The (x, y) for (a, b) is
x = a * DELTA - 2
y = b * DELTA (or -b * DELTA)
*/

function getFromCache (a, b, dontInit) {
	var x, y;
	if (a < 0 || a > MAXA) {
		return 0;
	}
	b = Math.abs(b);
	if (b > MAXB) {
		return 0;
	}
	if (cache[a] && cache[a][b]) {
		return cache[a][b];
	}
	if (dontInit) {
		return;
	}
	x = -2 + a * DELTA;
	y = b * DELTA;
	if (x * x + y * y >= 4) {
		setToCache(a, b, 0);
		return 0;
	}
	setToCache(a, b, {x: x, y: y, x0: x, y0: y, n: 0});
	return cache[a][b];
}

function setToCache (a, b, v) {
	if (a < 0 || a > MAXA) {
		return;
	}
	b = Math.abs(b);
	if (b > MAXB) {
		return;
	}
	if (!cache[a]) {
		cache[a] = {};
	}
	cache[a][b] = v;
}

function getColor (n) {
	var BLACK = [0, 0, 0],
		COLORS = [[255, 0, 0], [255, 127, 0], [255, 255, 0], [127, 255, 0], [0, 255, 0], [0, 255, 127],
			[0, 255, 255], [0, 127, 255], [0, 0, 255], [127, 0, 255], [255, 0, 255], [255, 0, 127]];
	if (n === false) {
		return BLACK;
	}
	return COLORS[n % COLORS.length];
}

function calc (a, b, n) {
	var data = getFromCache(a, b), x, y;
	if (typeof data === 'number') {
		return data;
	}
	if (data.n >= n) {
		return false;
	}
	while (data.n < n) {
		x = data.x * data.x - data.y * data.y + data.x0;
		y = 2 * data.x * data.y + data.y0;
		data.n++;
		if (x * x + y * y >= 4) {
			data = data.n;
			break;
		}
		data.x = x;
		data.y = y;
	}
	setToCache(a, b, data);
	return typeof data === 'number' ? data : false;
}

function guess (a0, b0, w, h, d, request, imageData) {
	var data, prevData, n, i, j, a, b, idx = 0;
	b = b0;
	for (j = 0; j < h; j++) {
		prevData = false;
		a = a0;
		for (i = 0; i < w; i++) {
			data = getFromCache(a, b, true);
			if (data === undefined) {
				data = prevData;
			} else {
				prevData = data;
			}
			if (typeof data === 'number') {
				n = data;
			} else {
				n = false;
			}
			paint(imageData, idx, getColor(n));
			idx += 4;
			a += d;
		}
		b += d;
	}
	syncImage(imageData, request, -1);
}

function draw (a0, b0, w, h, d, n, request, imageData) {
	var i, j, a, b, idx = 0;
	if (n === -1) {
		guess(a0, b0, w, h, d, request, imageData);
		return;
	}
	b = b0;
	for (j = 0; j < h; j++) {
		a = a0;
		for (i = 0; i < w; i++) {
			paint(imageData, idx, getColor(calc(a, b, n)));
			idx += 4;
			a += d;
		}
		b += d;
	}
	syncImage(imageData, request, n);
}

function receiveDrawRequest (data) {
	draw(data.a0, data.b0, data.imageData.width, data.imageData.height, data.d, data.n, data.request, data.imageData);
}

function paint (imageData, idx, c) {
	imageData.data[idx] = c[0];
	imageData.data[idx + 1] = c[1];
	imageData.data[idx + 2] = c[2];
	imageData.data[idx + 3] = 255;
}

function syncImage (imageData, request, n) {
	parent.postMessage({imageData: imageData, request: request, n: n}, [imageData]);
}

parent.onmessage = function (e) {
	receiveDrawRequest(e.data);
};
parent.postMessage(DELTA);

})(this);
