/*global menu: true*/
/*global tiltControl, game*/
menu =
(function () {
"use strict";
var STORE_KEY = 'schnark-tilt-result',
	BANNER_TIMEOUT = 2000,
/*
	t: title
	l: levels required to unlock
	p: points required to unlock
	m: possible points
	s: game string
	c: game callback

	r: result, falsy or [points, time]
*/
	levels = [],
	banner, bannerTimeout,
	menu;

function loadSavedResults () {
	try {
		JSON.parse(localStorage.getItem(STORE_KEY)).forEach(function (r, i) {
			levels[i].r = r;
		});
	} catch (e) {
	}
}

function saveResults () {
	try {
		localStorage.setItem(STORE_KEY, JSON.stringify(levels.map(function (l) {
			return l.r;
		})));
	} catch (e) {
	}
}

function clearResults () {
	var i;
	try {
		localStorage.removeItem(STORE_KEY);
	} catch (e) {
	}
	for (i = 0; i < levels.length; i++) {
		levels[i].r = false;
	}
}

function pad (n) {
	return n < 10 ? '0' + String(n) : String(n);
}

function formatTime (s) {
	return Math.floor(s / 60) + ':' + pad(s % 60);
}

function getCounts () {
	var solved = 0, points = 0;
	levels.forEach(function (l) {
		if (l.r) {
			solved++;
			points += l.r[0];
		}
	});
	return [solved, points];
}

function createButton (i, counts) {
	var l = levels[i], cls = '', points = '', time = '';
	if (l.r) {
		if (l.r[0] === l.m) {
			cls = 'perfect';
		} else {
			cls = 'solved';
		}
		points = l.r[0];
		time = ' (' + formatTime(l.r[1]) + ')';
	} else {
		if (counts[0] >= l.l && counts[1] >= l.p) {
			time = '—';
		} else {
			cls = 'locked';
		}
	}
	return '<button ' + (cls === 'locked' ? 'disabled' : 'id="level-' + i + '"') +
		' class="' + cls + '">' + l.t + '<br>' + points + time + '</button>';
}

function showBanner (text, cb) {
	if (bannerTimeout) {
		clearTimeout(bannerTimeout);
	}
	bannerTimeout = setTimeout(function () {
		banner.style.display = 'none';
		bannerTimeout = false;
		if (cb) {
			cb();
		}
	}, BANNER_TIMEOUT);
	banner.innerHTML = text;
	banner.style.display = '';
}

function showMenu () {
	var html = [], counts = getCounts(), i;
	for (i = 0; i < levels.length; i++) {
		html.push(createButton(i, counts));
	}
	menu.innerHTML = html.join(' ');
	menu.style.display = '';
}

function hideMenu () {
	menu.style.display = 'none';
}

function playGame (i) {
	var l = levels[i];
	showBanner('Get ready …', function () {
		hideMenu();
		game.start(l.s, l.c, function (solved, points, health, time) {
			var status = 'Try again.';
			if (solved) {
				time = Math.ceil(time - health * 0.5); //round
				if (l.r) {
					status = 'Solved again.';
					if (points > l.r[0]) {
						status = 'Result improved!';
						l.r[0] = points;
					}
					if (time < l.r[1]) {
						status = 'Result improved!';
						l.r[1] = time;
					}
				} else {
					status = 'Level solved!';
					l.r = [points, time];
				}
				if (l.r[0] < l.m) {
					status += ' Try to get all ' + l.m + ' points next time.';
				}
				saveResults();
			}
			showBanner(status, function () {
				showBanner(status);
				showMenu();
			});
		});
		l.c(0, -1);
	});
}

function init (data) {
	levels = data;
	loadSavedResults();
	banner = document.getElementById('b');
	banner.style.display = 'none';
	menu = document.getElementById('m');
}

function start () {
	tiltControl.init();
	menu.addEventListener('click', function (e) {
		var id = e.target.id || '';
		if (id.slice(0, 6) === 'level-') {
			playGame(id.slice(6));
		}
	});
	showMenu();
}

return {
	init: init,
	start: start,
	reset: clearResults
};
})();