/*global game: true*/
/*global tiltControl, level*/
/*global playSound, SOUND_DIE, SOUND_COIN, SOUND_HEAL, SOUND_BOUNCE, SOUND_DOOR, SOUND_WIN*/
/*global TYPE_NONE, TYPE_ABYSS, TYPE_WALL, TYPE_WATER, TYPE_SAND, TYPE_EXIT, TYPE_N, TYPE_E, TYPE_S, TYPE_W, TYPE_DOOR*/
/*global ITEM_COIN, ITEM_HEAL*/
game =
(function () {
"use strict";

var EXIT_TIME = 1000,
	WATER_DAMAGE = 0.3,
	AUTO_HEAL = 0.003,
	HEAL_AMOUNT = 0.2,
	BOUNCE_THRESHOLD = 1,
	RADIUS = 0.4,
	GHOST_SPEED = 0.3,
	GHOST_HUNGER = 0.3,
	GHOST_DAMAGE = 0.3,
	DELTA_T = 100,
	MAX_DELTA_T = 500,
	PANEL_SIZE = 4,
	TILES_PER_SCREEN_FACTOR = 12,
	x, y, vx, vy, health, dead, points, done, exitTimeout,
	ghosts,
	w, h, size, x0, y0,
	currentText = '',
	canvas, ctx,
	rAF = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame;

function setMessage (msg) {
	currentText = msg;
}

function releaseGhost (x, y) {
	ghosts.push([x, y, 0]);
}

function getAccellerationDevice () {
	return tiltControl.getPos().map(function (x) {
		return x * 2;
	});
}

function handleCurrentPos (t, total, trigger) {
	if (done) {
		return;
	}
	if (health === 0) {
		dead = true;
		playSound(SOUND_DIE);
		return;
	}
	switch (level.getType(Math.floor(x), Math.floor(y))) {
	case TYPE_ABYSS:
	case TYPE_WALL: //shouldn't happen, but if it happens it's certainly deadly
	case TYPE_DOOR: //as above
	case TYPE_NONE: //as above
		dead = true;
		playSound(SOUND_DIE);
		return;
	case TYPE_WATER:
		health -= t * WATER_DAMAGE;
		break;
	case TYPE_EXIT:
		if (!exitTimeout) {
			exitTimeout = setTimeout(function () {
				exitTimeout = false;
				done = true;
				playSound(SOUND_WIN);
			}, EXIT_TIME);
		}
		health += t * AUTO_HEAL;
		break;
	default:
		if (exitTimeout) {
			clearTimeout(exitTimeout);
			exitTimeout = false;
		}
		health += t * AUTO_HEAL;
	}
	switch (level.getItem(Math.floor(x), Math.floor(y), true)) {
	case ITEM_COIN:
		points++;
		playSound(SOUND_COIN);
		break;
	case ITEM_HEAL:
		health += HEAL_AMOUNT;
		playSound(SOUND_HEAL);
	}
	trigger(level.getTrigger(Math.floor(x), Math.floor(y)), total);
	handleGhosts(t);
	if (health > 1) {
		health = 1;
	} else if (health < 0) {
		health = 0;
	}
}

function handleGhosts (t) {
	var i, g, dx, dy, d;
	for (i = 0; i < ghosts.length; i++) {
		g = ghosts[i];
		dx = g[0] - x;
		dy = g[1] - y;
		d = Math.sqrt(dx * dx + dy * dy);
		if (d < RADIUS || d < GHOST_SPEED * t) {
			g[2] += GHOST_DAMAGE * t;
			health -= GHOST_DAMAGE * t;
		} else {
			g[0] = x + dx * (d - GHOST_SPEED * t) / d;
			g[1] = y + dy * (d - GHOST_SPEED * t) / d;
		}
	}
	ghosts = ghosts.filter(function (g) {
		return g[2] < GHOST_HUNGER;
	});
}

function move (t) {
	x += vx * t;
	y += vy * t;
}

function checkWall (xx, yy, d1, d2, pos) {
	var d, s, c, s2, c2, v, friction, vxOld, vyOld;
	d = Math.sqrt(d1 * d1 + d2 * d2) - RADIUS;
	if (d >= 0 || [TYPE_WALL, TYPE_DOOR].indexOf(level.getType(xx, yy)) === -1) {
		return 0;
	}
	pos += Math.atan2(d1, d2) * 2 / Math.PI;
	s = Math.sin(pos * Math.PI / 2);
	c = Math.cos(pos * Math.PI / 2);
	v = vx * s - vy * c;
	if (v <= 0) {
		x += d * s;
		y -= d * c;
		return 0;
	}
	s2 = Math.sin(pos * Math.PI);
	c2 = Math.cos(pos * Math.PI);
	friction = level.getFriction(xx, yy);
	x += 2 * d * s;
	y -= 2 * d * c;
	vxOld = vx * (1 - friction);
	vyOld = vy * (1 - friction);
	vx = c2 * vxOld + s2 * vyOld;
	vy = s2 * vxOld - c2 * vyOld;
	return 1;
}

function checkCollions () {
	var bounce = 0;
	//top, bottom
	bounce +=
		checkWall(Math.floor(x), Math.floor(y) - 1, 0, y % 1, 0) ||
		checkWall(Math.floor(x), Math.floor(y) + 1, 0, 1 - y % 1, 2);
	//right, left
	bounce +=
		checkWall(Math.floor(x) + 1, Math.floor(y), 0, 1 - x % 1, 1) ||
		checkWall(Math.floor(x) - 1, Math.floor(y), 0, x % 1, 3);
	//corners
	if (!bounce) {
		bounce +=
			checkWall(Math.floor(x) + 1, Math.floor(y) - 1, 1 - x % 1, y % 1, 0) ||
			checkWall(Math.floor(x) + 1, Math.floor(y) + 1, 1 - y % 1, 1 - x % 1, 1) ||
			checkWall(Math.floor(x) - 1, Math.floor(y) + 1, x % 1, 1 - y % 1, 2) ||
			checkWall(Math.floor(x) - 1, Math.floor(y) - 1, y % 1, x % 1, 3);
	}
	if (bounce && (vx * vx + vy * vy > BOUNCE_THRESHOLD)) {
		playSound(SOUND_BOUNCE);
	}
}

function accelerate (t) {
	var a1 = getAccellerationDevice(),
		a2 = level.getAccelleration(Math.floor(x), Math.floor(y)),
		friction = level.getFriction(Math.floor(x), Math.floor(y));
	vx += (a1[0] + a2[0]) * t - friction * vx;
	vy += (a1[1] + a2[1]) * t - friction * vy;
}

function drawCircle (x, y, r, color, stroke) {
	ctx.fillStyle = color;
	ctx.beginPath();
	ctx.arc(x, y, r, 0, 2 * Math.PI);
	ctx.fill();
	if (stroke) {
		ctx.stroke();
	}
}

function drawLine (x0, y0, x1, y1, color) {
	var dx = x1 - x0, dy = y1 - y0,
		l = Math.sqrt(dx * dx + dy * dy),
		steps = Math.round(l / (size / 10)), i;
	for (i = 0; i <= steps; i++) {
		drawCircle(x0 + i * dx / steps + Math.sin(i), y0 + i * dy / steps + Math.sin(2 * i), size / 10, color);
	}
}

function drawArrow (x, y, dir, color) {
	switch (dir) {
	case 0:
		drawLine(x + size * 0.3, y + size * 0.7, x + size * 0.5, y + size * 0.3, color);
		drawLine(x + size * 0.5, y + size * 0.3, x + size * 0.7, y + size * 0.7, color);
		break;
	case 1:
		drawLine(x + size * 0.3, y + size * 0.3, x + size * 0.7, y + size * 0.5, color);
		drawLine(x + size * 0.7, y + size * 0.5, x + size * 0.3, y + size * 0.7, color);
		break;
	case 2:
		drawLine(x + size * 0.3, y + size * 0.3, x + size * 0.5, y + size * 0.7, color);
		drawLine(x + size * 0.5, y + size * 0.7, x + size * 0.7, y + size * 0.3, color);
		break;
	case 3:
		drawLine(x + size * 0.7, y + size * 0.3, x + size * 0.3, y + size * 0.5, color);
		drawLine(x + size * 0.3, y + size * 0.5, x + size * 0.7, y + size * 0.7, color);
	}
}

function drawTile (type, x, y) {
	var color;
	switch (type) {
	case TYPE_NONE:
		return;
	case TYPE_ABYSS:
		color = 'black';
		break;
	case TYPE_WALL:
		color = 'brown';
		break;
	case TYPE_DOOR:
		color = 'darkgray';
		break;
	case TYPE_WATER:
		color = 'blue';
		break;
	case TYPE_SAND:
		color = 'yellow';
		break;
	case TYPE_EXIT:
		color = 'red';
		break;
	default:
		color = 'green';
	}
	ctx.fillStyle = color;
	ctx.fillRect(x0 + x, y0 + y, size, size);
	switch (type) {
	case TYPE_N:
		drawArrow(x0 + x, y0 + y, 0, 'darkgreen');
		break;
	case TYPE_E:
		drawArrow(x0 + x, y0 + y, 1, 'darkgreen');
		break;
	case TYPE_S:
		drawArrow(x0 + x, y0 + y, 2, 'darkgreen');
		break;
	case TYPE_W:
		drawArrow(x0 + x, y0 + y, 3, 'darkgreen');
		break;
	}
}

function drawItem (type, x, y) {
	var color;
	switch (type) {
	case ITEM_COIN:
		color = 'yellow';
		break;
	case ITEM_HEAL:
		color = 'darkgreen';
		break;
	default:
		return;
	}
	drawCircle(x0 + x, y0 + y, size * RADIUS, color);
}

function drawMarble (x, y) {
	drawCircle(x0 + x, y0 + y, dead ? size / 10 : size * RADIUS, 'black');
}

function drawTilt (x, y) {
	var pos = tiltControl.getPos();
	drawCircle(x + size, y + size, size * 0.75, 'white', true);
	drawCircle(x + size + pos[0] * size * 0.6, y + size + pos[1] * size * 0.6, size * 0.15, 'blue');
	ctx.beginPath();
	ctx.moveTo(x + size, y + size * 0.25);
	ctx.lineTo(x + size, y + size * 1.75);
	ctx.moveTo(x + size * 0.25, y + size);
	ctx.lineTo(x + size * 1.75, y + size);
	ctx.stroke();
}

function drawHealth (x, y, w, h) {
	ctx.fillStyle = 'white';
	ctx.fillRect(x, y, w, h);
	ctx.fillStyle = ['red', 'orange', 'yellow', 'green', 'darkgreen'][Math.floor(health * 4)];
	ctx.fillRect(x, y, w * health, h);
	ctx.strokeRect(x, y, w, h);
}

function drawPoints (x, y) {
	drawCircle(x + size * 0.5, y, size * RADIUS, 'yellow');
	ctx.textBaseline = 'middle';
	ctx.font = size + 'px sans-serif';
	ctx.fillText(points, x + 1.5 * size, y, 2 * size);
}

function drawInfo (x, y, w) {
	ctx.fillStyle = 'white';
	ctx.fillRect(x, y, w, size);
	ctx.fillStyle = 'black';
	ctx.textBaseline = 'middle';
	ctx.font = size * 0.7 + 'px monospace';
	ctx.fillText(currentText, x + size, y + size / 2, w - 2 * size);
}

function drawStatus () {
	ctx.fillStyle = 'gray';
	ctx.fillRect(x0, 0, w * size, 4 * size);
	drawTilt(x0, 0);
	drawHealth(x0 + (w / 2 - 1.5) * size, 0.5 * size, 3 * size, size);
	drawPoints(x0 + (w - 3) * size, size);
	drawInfo(x0, 2.5 * size, w * size);
}

function drawBackground (startX, startY) {
	var xx, yy;
	for (xx = startX; xx < startX + w; xx++) {
		for (yy = startY; yy < startY + h; yy++) {
			drawTile(level.getType(xx, yy), (xx - startX) * size, (yy - startY) * size);
			drawItem(level.getItem(xx, yy), (xx - startX + 0.5) * size, (yy - startY + 0.5) * size);
		}
	}
}

function drawGhost (x, y, c) {
	drawCircle(x0 + x, y0 + y, size * RADIUS, 'rgba(255, 255, 255,' + (GHOST_HUNGER - c) / GHOST_HUNGER * 0.7 + ')');
}

function drawGhosts (x, y) {
	var i, g;
	for (i = 0; i < ghosts.length; i++) {
		g = ghosts[i];
		if (x <= g[0] && g[0] <= x + w && y <= g[1] && g[1] <= y + h) {
			drawGhost((g[0] - x) * size, (g[1] - y) * size, g[2]);
		}
	}
}

function draw () {
	ctx.clearRect(0, 0, canvas.width, canvas.height);
	drawStatus();
	drawBackground(Math.floor(x / w) * w, Math.floor(y / h) * h);
	drawMarble((x % w) * size, (y % h) * size);
	drawGhosts(Math.floor(x / w) * w, Math.floor(y / h) * h);
}

function step (t, total, trigger, skipDraw) {
	handleCurrentPos(t, total, trigger);
	if (dead || done || !skipDraw) {
		draw();
	}
	if (dead || done) {
		return;
	}
	move(t);
	checkCollions();
	accelerate(t);
}

function start (levelStr, trigger, callback) {
	var init, startTime, last;

	function run (t) {
		var stepTime;
		if (!startTime) {
			startTime = t;
		} else {
			stepTime = Math.min(t - last, MAX_DELTA_T);
			while (!dead && !done && stepTime > DELTA_T) {
				step(DELTA_T / 1000, (t - startTime) / 1000, trigger, true);
				stepTime -= DELTA_T;
			}
			if (!dead && !done) {
				step(stepTime / 1000, (t - startTime) / 1000, trigger);
			}
		}
		if (dead || done) {
			if (exitTimeout) {
				clearTimeout(exitTimeout);
				exitTimeout = false;
			}
			callback(done, points, health, (t - startTime) / 1000);
		} else {
			rAF(run);
		}
		last = t;
	}

	init = level.load(levelStr);
	x = init[0];
	y = init[1];
	vx = 0;
	vy = 0;
	health = 1;
	points = 0;
	dead = false;
	done = false;
	ghosts = [];
	rAF(run);
}

function calcSize () {
	var totalWidth, totalHeight;
	totalWidth = window.innerWidth;
	totalHeight = window.innerHeight;
	canvas.width = totalWidth;
	canvas.height = totalHeight;
	size = 25;
	w = Math.max(
		TILES_PER_SCREEN_FACTOR,
		Math.round((totalWidth / size) / TILES_PER_SCREEN_FACTOR) * TILES_PER_SCREEN_FACTOR
	);
	h = Math.max(
		TILES_PER_SCREEN_FACTOR,
		Math.round(((totalHeight / size) - PANEL_SIZE) / TILES_PER_SCREEN_FACTOR) * TILES_PER_SCREEN_FACTOR
	);
	size = Math.floor(Math.min(totalWidth / w, totalHeight / (h + PANEL_SIZE)));
	/* For reasonable screens (including mobile and desktop) this will give us a value very near the original.
	It would be the same without max and round above, but this means that w and h only differ by at most
		TILES_PER_SCREEN_FACTOR / 2
	from the ideal values, so
		w / totalWidth
	and
		(h + PANEL_SIZE) / totalHeight
	differ at most by
		TILES_PER_SCREEN_FACTOR / (2 * totalX)
	from
		1 / size
	This means that
		1 / size
	falls into the range
		[0.02, 0.06]
	so we get a size in the range
		[16, 50]
	in the worst case.

	This also means
		size <= totalWidth / w
	and
		size <= totalHeight / (h + PANEL_SIZE)
	so
		totalWidth / size >= w
	and
		(totalHeight / size) - PANEL_SIZE >= h
	and since
		w >= TILES_PER_SCREEN_FACTOR
	and
		h >= TILES_PER_SCREEN_FACTOR
	we can be sure that we don't get 0 as width or height in the next steps.
	*/
	w = Math.floor((totalWidth / size) / TILES_PER_SCREEN_FACTOR) * TILES_PER_SCREEN_FACTOR;
	h = Math.floor(((totalHeight / size) - PANEL_SIZE) / TILES_PER_SCREEN_FACTOR) * TILES_PER_SCREEN_FACTOR;
	x0 = Math.round((totalWidth - size * w) / 2);
	y0 = Math.round((totalHeight - size * (h + PANEL_SIZE)) / 2 + PANEL_SIZE * size);
}

function init () {
	canvas = document.getElementById('c');
	ctx = canvas.getContext('2d');
	calcSize();
	window.addEventListener('resize', calcSize);
}

init();

return {
	start: start,
	releaseGhost: releaseGhost,
	setMessage: setMessage,
	openDoor: function (index, silent) {
		level.openDoor(index);
		if (!silent) {
			playSound(SOUND_DOOR);
		}
	},
	closeDoor: function (index, silent) {
		level.closeDoor(index);
		if (!silent) {
			playSound(SOUND_DOOR);
		}
	}
};

})();