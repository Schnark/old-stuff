(function () {
var i;
for (i = 1; i <= 19; i++) {
	if (i === 10) continue;
	u.paint(15 * i - 10, 50, 10, i);
}
})();
wall
sand
water
gas
cloner
fire
wood
lava
ice
-
plant
acid
stone
dust
mite
oil
rocket
fungus
seed

u.paint(x, y, 2, 1);


//Galton - Sandspiel
(function () {
"use strict";

function wall (x, y, l) {
	var i;
	for (i = 1 - l; i <= l - 1; i++) {
		u.paint(x + i, y, 2, 1);
	}
}

function walls (y, n, l) {
	var i;
	for (i = 0; i < n; i++) {
		wall(150 + l + 2 * l * i - l * n, y, l);
	}
}

function border (x, y) {
	var i;
	for (i = y; i < 300; i++) {
		u.paint(x, i, 2, 1);
	}
}

function galton (n) {
	var i, l = Math.floor(150 / (n + 1)) - 1;
	u.paint(149, 0, 2, 1);
	u.paint(150, 0, 2, 5);
	u.paint(151, 0, 2, 1);
	u.paint(149, 1, 2, 1);
	u.paint(150, 1, 2, 3);
	u.paint(151, 1, 2, 1);
	for (i = 0; i < n; i++) {
		walls(10 + l * i, i + 1, l);
	}
	for (i = 0; i <= n + 1; i++) {
		border(150 - n * l - l + 2 * l * i, 10 + n * l + l);
	}
}

galton(10);

})();



//Mandelbrot - Sandspiel
(function () {
"use strict";

var x0 = 0, y0 = 0, size = 4,
	palBlue = [9, 3],
	palBrown = [2, 7, 8, 6],
	palGray = [1, 13, 0],
	palViolet = [5, 15, 19],
	palRainbow = [17, 6, 12, 11, 9, 3, 19];

function convertCoordinates (i, j) {
	return {
		x: (i - 150) / 300 * size + x0,
		y: (150 - j) / 300 * size + y0
	};
}

function getColor (c) {
	var palette = palRainbow;
	if (c === -1) {
		return 16;
	}
	return palette[c % palette.length];
}

function calc (x0, y0, iter) {
	var x = x0, y = y0, c = 0, temp;
	while (true) {
		if (x * x + y * y > 4) {
			return c;
		}
		c++;
		if (c > iter) {
			return -1;
		}
		temp = x * x - y * y + x0;
		y = 2 * x * y + y0;
		x = temp;
	}
}

function createPainter (i, j, iter) {
	var coord = convertCoordinates(i, j);
	return function () {
		u.paint(i, j, 2, getColor(calc(coord.x, coord.y, iter)));
	};
}

function mandelbrot (x, y, s, iter) {
	var i, j;
	x0 = x;
	y0 = y;
	size = s;
	for (i = 0; i < 300; i++) {
		for (j = 0; j < 300; j++) {
			u.paint(i, j, 2, 0);
			setTimeout(createPainter(i, j, iter), 0);
		}
	}
}

mandelbrot(0, 0, 4, 100);
})();







//Image - Sandspiel
(function () {
"use strict";

var colorsReal = {
	0: [255, 235, 235],
	1: [96, 96, 96],
	2: [200, 160, 100],
	3: [80, 90, 200],
	4: [200, 170, 170],
	5: [128, 96, 112],
	6: [255, 160, 100],
	7: [112, 80, 80],
	8: [200, 100, 80],
	9: [150, 180, 255],
	11: [80, 120, 100],
	12: [200, 250, 30],
	13: [128, 120, 128],
	15: [160, 40, 200],
	16: [64, 64, 64],
	17: [240, 127, 127],
	18: [255, 255, 255],
	19: [160, 120, 255]
},
colorsReal2 = {
	0: [0xF3, 0xE4, 0xE4],
	1: [0x63, 0x5F, 0x5A],
	2: [0xD4, 0xA9, 0x6A],
	3: [0x51, 0x82, 0xCB],
	4: [0xED, 0xB3, 0xB3],
	5: [0x89, 0x60, 0x79],
	6: [0xFC, 0x9E, 0x5E],
	7: [0x70, 0x59, 0x4F],
	8: [0xCC, 0x75, 0x52],
	9: [0x8C, 0xB1, 0xE9],
	11: [0x52, 0x89, 0x68],
	12: [0xD0, 0xE1, 0x17],
	13: [0x88, 0x7B, 0x87],
	15: [0xA3, 0x14, 0xC7],
	16: [0x42, 0x43, 0x44],
	17: [0xE0, 0x86, 0x86],
	18: [0xFF, 0xDD, 0xE9],
	19: [0x9C, 0x76, 0xFF]
},
colorsComic = {
	0: [255, 255, 255],
	3: [0, 0, 255],
	6: [255, 0, 0],
	9: [0, 255, 255],
	11: [0, 255, 0],
	12: [255, 255, 0],
	16: [0, 0, 0],
	17: [255, 0, 255]
},
colorsBW = {
	0: [255, 255, 255],
	16: [0, 0, 0]
},
colorsGray = {
	0: [255, 255, 255],
	1: [85, 85, 85],
	13: [170, 170, 170],
	16: [0, 0, 0]
},
colorsWall = {
	0: [255, 255, 255],
	1: [0, 0, 0]
},
colors, mode;

function getWeight (a1, a2) {
	var d, s;
	d = a1[0] - a2[0];
	s = d * d;
	d = a1[1] - a2[1];
	s += d * d;
	d = a1[2] - a2[2];
	s += d * d;
	return 1 / (s * s);
}

function getColorRandom (r, g, b) {
	var c, weights = [], total = 0;
	for (c in colors) {
		total += getWeight([r, g, b], colors[c]);
		weights.push([c, total])
	}
	total *= Math.random();
	for (c = 0; c < weights.length; c++) {
		if (total <= weights[c][1]) {
			return weights[c][0];
		}
	}
}

function getColorBest (r, g, b) {
	var best = 0, bestColor, weight, c;
	for (c in colors) {
		weight = getWeight([r, g, b], colors[c]);
		if (weight > best) {
			best = weight;
			bestColor = c;
		}
	}
	return bestColor;
}

function getColor (r, g, b) {
	if (mode === 'random') {
		return getColorRandom(r, g, b);
	}
	return getColorBest(r, g, b);
}

function paint (image) {
	var i, j, pos;
	for (i = 0; i < 300; i++) {
		for (j = 0; j < 300; j++) {
			pos = 4 * (j * 300 + i);
			u.paint(i, j, 2, 0);
			u.paint(i, j, 2, getColor(image[pos], image[pos + 1], image[pos + 2]));
		}
	}
}

function paintImage (img, x0, y0, x1, y1) {
	var canvas = document.createElement('canvas'), ctx, scale, x, y;
	canvas.width = 300;
	canvas.height = 300;
	ctx = canvas.getContext('2d');
	ctx.fillStyle = "white";
	ctx.fillRect(0, 0, 300, 300);
	scale = Math.min(300 / (x1 - x0), 300 / (y1 - y0));
	x = (300 - scale * (x1 - x0)) / 2;
	y = (300 - scale * (y1 - y0)) / 2;
	ctx.drawImage(img, x0, y0, x1 - x0, y1 - y0, x, y, scale * (x1 - x0), scale * (y1 - y0));
	paint(ctx.getImageData(0, 0, 300, 300).data);
}

function loadImage (url, x0, y0, x1, y1) {
	var img = new Image();
	img.onload = function () {
		x0 = x0 || 0;
		y0 = y0 || 0;
		x1 = x1 || img.width - x0;
		y1 = y1 || img.height - y0;
		paintImage(img, x0, y0, x1, y1);
	};
	img.crossOrigin = "anonymous";
	img.src = url;
}

colors = colorsReal2;
mode = 'random';
loadImage('https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Da_Vinci%27s_Mona_Lisa_with_original_colors_approximation.jpg/401px-Da_Vinci%27s_Mona_Lisa_with_original_colors_approximation.jpg');
//https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/The_Great_Wave_off_Kanagawa.jpg/800px-The_Great_Wave_off_Kanagawa.jpg
//https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/The_Scream.jpg/470px-The_Scream.jpg
//https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg/800px-Michelangelo_-_Creation_of_Adam_%28cropped%29.jpg, 200, 50, 400, 250
//https://cors-anywhere.herokuapp.com/
})();

