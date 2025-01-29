/*global Uint8ClampedArray*/
(function (worker) {
"use strict";

var config;

function pythagoras (x, y) {
	return Math.sqrt(x * x + y * y);
}

function createImageData (w, h) {
	return {
		width: w,
		height: h,
		data: new Uint8ClampedArray(w * h * 4)
	};
}

function getColor (imageData, x, y) {
	var i;
	if (x < 0 || x >= imageData.width || y < 0 || y >= imageData.height) {
		return [255, 255, 255, 255];
	}
	i = 4 * (x + imageData.width * y);
	return [imageData.data[i], imageData.data[i + 1], imageData.data[i + 2], imageData.data[i + 3]];
}

function kirsch (input, dTop, dBottom, dLeft, dRight) {
	var line, gray, edges, x, y, c;

	function kirschPixel (x, y) {
		var c, g = [], i, j;
		if (
			x === 0 || y === 0 ||
			x === input.width - 1 || y === input.height - 1 ||
			(x > dLeft && x < dRight && y > dTop && y < dBottom)
		) {
			return 0;
		}
		c = [
			gray[y - 1][x - 1],
			gray[y - 1][x],
			gray[y - 1][x + 1],
			gray[y][x + 1],
			gray[y + 1][x + 1],
			gray[y + 1][x],
			gray[y + 1][x - 1],
			gray[y][x - 1]
		];
		for (i = 0; i < 4; i++) {
			g[i] = 0;
			for (j = 0; j < 8; j++) {
				g[i] += (j < 3 ? 5 : -3) * c[(i + j) % 8];
			}
			g[i] = Math.abs(g[i]);
		}
		return Math.max.apply(Math, g) / (15 * 255);
	}

	gray = [];
	for (y = 0; y < input.height; y++) {
		line = [];
		for (x = 0; x < input.width; x++) {
			c = getColor(input, x, y);
			line.push(c[0] + c[1] + c[2]);
		}
		gray.push(line);
	}

	edges = [];
	for (y = 0; y < input.height; y++) {
		line = [];
		for (x = 0; x < input.width; x++) {
			line.push(kirschPixel(x, y));
		}
		edges.push(line);
	}
	return edges;
}

function hough (
	edges,
	xMin, xMax,
	yMin, yMax,
	t,
	aMin, aMax, aStep,
	dMin, dMax
) {
	var line, houghData, a, d, x, y, w, aBest, dBest;

	houghData = [];
	for (a = aMin; a < aMax; a += aStep) {
		line = [];
		for (d = dMin; d < dMax; d++) {
			line.push(0);
		}
		houghData.push(line);
	}

	for (y = yMin; y < yMax; y++) {
		for (x = xMin; x < xMax; x++) {
			w = edges[y][x];
			if (w > t) {
				for (a = aMin; a < aMax; a += aStep) {
					d = Math.round(x * Math.cos(a * Math.PI / 180) + y * Math.sin(a * Math.PI / 180));
					if (dMin <= d && d < dMax) {
						houghData[(a - aMin) / aStep][d - dMin] += w;
					}
				}
			}
		}
	}

	w = -1;
	for (a = aMin; a < aMax; a += aStep) {
		for (d = dMin; d < dMax; d++) {
			if (houghData[(a - aMin) / aStep][d - dMin] > w) {
				w = houghData[(a - aMin) / aStep][d - dMin];
				aBest = a;
				dBest = d;
			}
		}
	}

	return {a: aBest, d: dBest};
}

function intersect (l1, l2) {
	var ca1 = Math.cos(l1.a * Math.PI / 180), sa1 = Math.sin(l1.a * Math.PI / 180),
		ca2 = Math.cos(l2.a * Math.PI / 180), sa2 = Math.sin(l2.a * Math.PI / 180),
		x, y;
	y = (l1.d * ca2 - l2.d * ca1) / (sa1 * ca2 - sa2 * ca1);
	x = (l2.d - y * sa2) / ca2;
	return {x: x, y: y};
}

/*function visualiseEdges (edges, l) {
	var w = edges[0].length, h = edges.length, output = createImageData(w, h), i, x, y, online, c;
	i = 0;
	for (y = 0; y < h; y++) {
		for (x = 0; x < w; x++) {
			c = Math.round(255 * (1 - edges[y][x]));
			online = l && (x * Math.cos(l.a * Math.PI / 180) + y * Math.sin(l.a * Math.PI / 180) - l.d) < 0;
			output.data[i] = online ? 255 : c;
			output.data[i + 1] = c;
			output.data[i + 2] = c;
			output.data[i + 3] = 255;
			i += 4;
		}
	}
	return output;
}*/

function getCorners (input, extract) {
	var edges, dh, dw, top, bottom, left, right;
	if (!extract) {
		return [
			{x: 0, y: 0},
			{x: input.width, y: 0},
			{x: 0, y: input.height},
			{x: input.width, y: input.height}
		];
	}

	dh = Math.round(input.height / 6);
	dw = Math.round(input.width / 5);
	edges = kirsch(input, dh, input.height - dh, dw, input.width - dw);
	top = hough(
		edges,
		1, input.width - 1,
		1, dh,
		0.1,
		80, 100, 2,
		-dh, 2 * dh
	);
	bottom = hough(
		edges,
		1, input.width - 1,
		input.height - dh, input.height - 1,
		0.1,
		80, 100, 2,
		input.height - 2 * dh, input.height + dh
	);
	left = hough(
		edges,
		1, dw,
		1, input.height - 1,
		0.1,
		-10, 10, 2,
		-dw, 2 * dw
	);
	right = hough(
		edges,
		input.width - dw, input.width - 1,
		1, input.height - 1,
		0.1,
		-10, 10, 2,
		input.width - 2 * dw, input.width + dw
	);
	return [
		intersect(top, left),
		intersect(top, right),
		intersect(bottom, left),
		intersect(bottom, right)
	];
}

function getWidthHeight (corners, storedData, aspectRatio, diagonalLength) {
	var h;
	if (!aspectRatio) {
		aspectRatio =
			(
				pythagoras(corners[1].x - corners[0].x, corners[1].y - corners[0].y) +
				pythagoras(corners[3].x - corners[2].x, corners[3].y - corners[2].y)
			) / (
				pythagoras(corners[2].x - corners[0].x, corners[2].y - corners[0].y) +
				pythagoras(corners[3].x - corners[1].x, corners[3].y - corners[1].y)
			);
		if (storedData.n) {
			aspectRatio = (storedData.n * storedData.width / storedData.height + aspectRatio) / (storedData.n + 1);
		}
	}
	if (!diagonalLength) {
		diagonalLength = (
			pythagoras(corners[3].x - corners[0].x, corners[3].y - corners[0].y) +
			pythagoras(corners[2].x - corners[1].x, corners[2].y - corners[1].y)
		) / 2;
		if (storedData.n) {
			diagonalLength = (storedData.n * pythagoras(storedData.width, storedData.height) + diagonalLength) / (storedData.n + 1);
		}
	}
	h = Math.sqrt(diagonalLength * diagonalLength / (aspectRatio * aspectRatio + 1));
	return {
		width: Math.round(aspectRatio * h),
		height: Math.round(h)
	};
}

function transformInput (input, corners, dimensions) {
	var output = createImageData(dimensions.width, dimensions.height),
	v0 = {x: corners[1].x - corners[0].x, y: corners[1].y - corners[0].y},
	v1 = {x: corners[2].x - corners[0].x, y: corners[2].y - corners[0].y},
	v2 = {
		x: corners[0].x - corners[1].x - corners[2].x + corners[3].x,
		y: corners[0].y - corners[1].y - corners[2].y + corners[3].y
	},
	x, y, i, point, color;

	function get (x, y) {
		//TODO
		return getColor(input, Math.round(x), Math.round(y));
	}

	function transform (x, y) {
		x = x / dimensions.width;
		y = y / dimensions.height;
		return {
			x: corners[0].x + v0.x * x + v1.x * y + v2.x * x * y,
			y: corners[0].y + v0.y * x + v1.y * y + v2.y * x * y
		};
	}

	i = 0;
	for (y = 0; y < dimensions.height; y++) {
		for (x = 0; x < dimensions.width; x++) {
			point = transform(x, y);
			color = get(point.x, point.y);
			output.data[i] = color[0];
			output.data[i + 1] = color[1];
			output.data[i + 2] = color[2];
			output.data[i + 3] = color[3];
			i += 4;
		}
	}
	return output;
}

function addToStoredData (storedData, newData) {
	var n = storedData.n, i;
	if (n === 0) {
		newData.n = 1;
		return newData;
	}
	if (storedData.width !== newData.width || storedData.height !== storedData.height) {
		storedData = transformInput(
			storedData,
			[
				{x: 0, y: 0},
				{x: storedData.width, y: 0},
				{x: 0, y: storedData.height},
				{x: storedData.width, y: storedData.height}
			], {
				width: newData.width,
				height: newData.height
			}
		);
	}
	for (i = 0; i < storedData.data.length; i++) {
		storedData.data[i] = Math.round((storedData.data[i] * n + newData.data[i]) / (n + 1));
	}
	storedData.n = n + 1;
	return storedData;
}

function toGrayScale (array) {
	var i, g;
	for (i = 0; i < array.length; i += 4) {
		g = array[i];
		g += array[i + 1];
		g += array[i + 2];
		g = Math.round(g / 3);
		array[i] = g;
		array[i + 1] = g;
		array[i + 2] = g;
	}
}

function init (data) {
	config = {
		storedData: {n: 0},
		extract: data.extract || false,
		aspectRatio: data.aspectRatio || 0,
		diagonalLength: data.diagonalLength || 0,
		grayScale: data.grayScale || false
	};
}

function processInput (input) {
	var corners, dimensions, output;
	corners = getCorners(input, config.extract);
	dimensions = getWidthHeight(corners, config.storedData, config.aspectRatio, config.diagonalLength);
	output = transformInput(input, corners, dimensions);
	config.storedData = addToStoredData(config.storedData, output);
	output = createImageData(config.storedData.width, config.storedData.height);
	output.data.set(config.storedData.data);
	if (config.grayScale) {
		toGrayScale(output.data);
	}
	return output;
}

worker.addEventListener('message', function (e) {
	var output;
	switch (e.data.type) {
	case 'init':
		init(e.data);
		worker.postMessage({type: 'init'});
		break;
	case 'input':
		output = processInput(e.data.input);
		worker.postMessage({type: 'input', imageData: output}/*, [output.data]*/);
	}
});
worker.postMessage({type: 'ready'});

})(this);