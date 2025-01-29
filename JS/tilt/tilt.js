/*global tiltControl: true*/
tiltControl =
(function () {
"use strict";

var hasDeviceorientation = false,
	pos = [0, 0],
	wakeLock;

function limit (x) {
	return Math.min(Math.max(x, -1), 1);
}

function detectDeviceorientation () {
	hasDeviceorientation = true;
}

function onDeviceorientation (e) {
	pos = [
		limit(e.beta / 90),
		limit(e.gamma / 90)
	];
}

function onMousemove (e) {
	pos = [
		2 * e.screenX / screen.width - 1,
		2 * e.screenY / screen.height - 1
	];
}

function initDeviceorientation () {
	window.addEventListener('deviceorientation', onDeviceorientation);
}

function exitDeviceorientation () {
	window.removeEventListener('deviceorientation', onDeviceorientation);
}

function initMouse () {
	document.documentElement.addEventListener('mousemove', onMousemove);
}

function exitMouse () {
	document.documentElement.removeEventListener('mousemove', onMousemove);
}

function enterFullscreen () {
	var el = document.documentElement;
	if (el.requestFullscreen) {
		el.requestFullscreen();
	} else if (el.mozRequestFullScreen) {
		el.mozRequestFullScreen();
	} else if (el.webkitRequestFullscreen) {
		el.webkitRequestFullscreen();
	} else if (el.msRequestFullscreen) {
		el.msRequestFullscreen();
	}
}

function exitFullscreen () {
	if (document.exitFullscreen) {
		document.exitFullscreen();
	} else if (document.mozCancelFullScreen) {
		document.mozCancelFullScreen();
	} else if (document.webkitCancelFullScreen) {
		document.webkitCancelFullScreen();
	} else if (document.msExitFullscreen) {
		document.msExitFullscreen();
	}
}

function lockOrientation () {
	if (screen.orientation && screen.orientation.lock) {
		screen.orientation.lock('portrait-primary');
	} else if (screen.lockOrientation) {
		screen.lockOrientation('portrait-primary');
	} else if (screen.mozLockOrientation) {
		screen.mozLockOrientation('portrait-primary');
	} else if (screen.msLockOrientation) {
		screen.msLockOrientation('portrait-primary');
	}
}

function unlockOrientation () {
	if (screen.orientation && screen.orientation.unlock) {
		screen.orientation.unlock();
	} else if (screen.unlockOrientation) {
		screen.unlockOrientation();
	} else if (screen.mozUnlockOrientation) {
		screen.mozUnlockOrientation();
	} else if (screen.msUnlockOrientation) {
		screen.msUnlockOrientation();
	}
}

function lockScreen () {
	if (navigator.requestWakeLock) {
		wakeLock = navigator.requestWakeLock('screen');
	}
}

function unlockScreen () {
	if (wakeLock) {
		wakeLock.unlock();
		wakeLock = false;
	}
}

function detect () {
	window.addEventListener('deviceorientation', detectDeviceorientation);
}

function init () {
	window.removeEventListener('deviceorientation', detectDeviceorientation);
	enterFullscreen();
	if (hasDeviceorientation) {
		lockOrientation();
		lockScreen();
		initDeviceorientation();
	} else {
		initMouse();
	}
}

function exit () {
	if (hasDeviceorientation) {
		exitDeviceorientation();
		unlockScreen();
		unlockOrientation();
	} else {
		exitMouse();
	}
	exitFullscreen();
}

function isDeviceorientation () {
	return hasDeviceorientation;
}

function getPos () {
	return pos;
}

detect();

return {
	init: init,
	exit: exit,
	isDeviceorientation: isDeviceorientation,
	getPos: getPos
};

})();