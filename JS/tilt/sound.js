/*global playSound: true*/
/*global SOUND_DIE, SOUND_COIN, SOUND_HEAL, SOUND_BOUNCE, SOUND_DOOR, SOUND_WIN*/
playSound =
(function () {
"use strict";

var muted = false;

function playSound (sound) {
	var str;
	if (muted) {
		return;
	}
	switch (sound) {
	case SOUND_DIE:
		str = 'die';
		break;
	case SOUND_COIN:
		str = 'coin';
		break;
	case SOUND_HEAL:
		str = 'heal';
		break;
	case SOUND_BOUNCE:
		str = 'bounce';
		break;
	case SOUND_DOOR:
		str = 'door';
		break;
	case SOUND_WIN:
		str = 'win';
	}
	console.log('Sound: ' + str);
}

return playSound;
})();