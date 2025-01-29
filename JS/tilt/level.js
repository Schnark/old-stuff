/*global level: true*/
/*global TYPE_NONE, TYPE_ABYSS, TYPE_WALL, TYPE_WATER, TYPE_SAND, TYPE_EXIT, TYPE_GRASS, TYPE_N, TYPE_E, TYPE_S, TYPE_W, TYPE_DOOR*/
/*global ITEM_NONE, ITEM_COIN, ITEM_HEAL*/

level =
(function () {
"use strict";

var level, doors = [];

function get (x, y) {
	var defaultEntry = {
		t: TYPE_NONE,
		f: 0,
		a: [0, 0],
		i: ITEM_NONE,
		r: 0
	};
	try {
		return level[y][x] || defaultEntry;
	} catch (e) {
		return defaultEntry;
	}
}

function getType (x, y) {
	return get(x, y).t;
}

function getItem (x, y, remove) {
	var data = get(x, y), item = data.i;
	if (remove) {
		data.i = ITEM_NONE;
	}
	return item;
}

function getFriction (x, y) {
	return get(x, y).f;
}

function getAccelleration (x, y) {
	return get(x, y).a;
}

function getTrigger (x, y) {
	return get(x, y).r;
}

function loadLevel (str) {
	var start = [1.5, 1.5];
	doors = [];
	level = str.split('\n').map(function (line, y) {
		return line.split('').map(function (c, x) {
			var base = {
				t: TYPE_GRASS,
				f: 0.03,
				a: [0, 0],
				i: ITEM_NONE,
				r: 0
			};
			switch (c) {
			case '$':
				base.i = ITEM_COIN;
				break;
			case '*':
				base.i = ITEM_HEAL;
				break;
			case '~':
				base.t = TYPE_WATER;
				break;
			case '#':
				base.t = TYPE_WALL;
				base.f = 0.1;
				break;
			case '-':
				base.t = TYPE_ABYSS;
				break;
			case '@':
				start = [x + 0.5, y + 0.5];
				break;
			case '%':
				base.t = TYPE_EXIT;
				break;
			case '.':
				base.t = TYPE_SAND;
				base.f = 0.2;
				break;
			case '<':
				base.t = TYPE_W;
				base.a = [-1, 0];
				break;
			case '>':
				base.t = TYPE_E;
				base.a = [1, 0];
				break;
			case '^':
				base.t = TYPE_N;
				base.a = [0, -1];
				break;
			case 'v':
				base.t = TYPE_S;
				base.a = [0, 1];
				break;
			case '+':
				base.t = TYPE_DOOR;
				doors.push([x, y]);
				break;
			case '_':
				base.t = TYPE_NONE;
				break;
			default:
				if ('1' <= c && c <= '9') {
					base.r = Number(c);
				} else if ('A' <= c && c <= 'Z') {
					base.r = c.charCodeAt(0) - 'A'.charCodeAt(0) + 10;
				}
			}
			return base;
		});
	});
	return start;
}

function openDoor (index) {
	var pos = doors[index];
	level[pos[1]][pos[0]].t = TYPE_GRASS;
}

function closeDoor (index) {
	var pos = doors[index];
	level[pos[1]][pos[0]].t = TYPE_DOOR;
}

return {
	getType: getType,
	getItem: getItem,
	getFriction: getFriction,
	getAccelleration: getAccelleration,
	getTrigger: getTrigger,
	load: loadLevel,
	openDoor: openDoor,
	closeDoor: closeDoor
};

})();