/*global URL, Blob*/
var acPlayer =
(function () {
"use strict";
var ac, AC = window.AudioContext || window.webkitAudioContext;

function dataToBuffer (data, sampleRate) {
	var buffer;
	if (!ac) {
		ac = new AC();
	}
	buffer = ac.createBuffer(1, data.length, sampleRate);
	buffer.getChannelData(0).set(data);
	return buffer;
}

function play (buffer, loop) {
	var source = ac.createBufferSource(); //since we have a buffer, ac is already initialized
	source.buffer = buffer;
	if (loop) {
		source.loop = true;
	}
	source.connect(ac.destination);
	if (ac.state === 'suspended') {
		ac.resume();
	}
	source.start();
	return source;
}

function stop (source) {
	source.stop();
}

function noop () {
}

return AC ? {
	prepare: dataToBuffer,
	play: play,
	stop: stop
} : {
	prepare: noop,
	play: noop,
	stop: noop
};

})();

var wavPlayer =
(function () {
"use strict";

function wavFromData (data, sampleRate) {
	/*jshint bitwise: false*/
	var buffer = new Int16Array(data.length + 23), i, d;

	buffer[ 0] = 0x4952; //"RI"
	buffer[ 1] = 0x4646; //"FF"
	buffer[ 2] = (2 * data.length + 15) & 0x0000ffff; //RIFF size
	buffer[ 3] = ((2 * data.length + 15) & 0xffff0000) >> 16;
	buffer[ 4] = 0x4157; //"WA"
	buffer[ 5] = 0x4556; //"VE"
	buffer[ 6] = 0x6d66; //"fm"
	buffer[ 7] = 0x2074; //"t "
	buffer[ 8] = 0x0012; //fmt size
	buffer[ 9] = 0x0000;
	buffer[10] = 0x0001; //format tag: PCM
	buffer[11] = 1; //channelCount
	buffer[12] = sampleRate & 0x0000ffff; //sample per sec
	buffer[13] = (sampleRate & 0xffff0000) >> 16;
	buffer[14] = (2 * sampleRate) & 0x0000ffff; //byte per sec
	buffer[15] = ((2 * sampleRate) & 0xffff0000) >> 16;
	buffer[16] = 0x0004; //block align
	buffer[17] = 0x0010; //bit per sample
	buffer[18] = 0x0000; //cb size
	buffer[19] = 0x6164; //"da"
	buffer[20] = 0x6174; //"ta"
	buffer[21] = (2 * data.length) & 0x0000ffff; //data size
	buffer[22] = ((2 * data.length) & 0xffff0000) >> 16;

	for (i = 0; i < data.length; i++) {
		d = data[i];
		buffer[i + 23] = d < 1 ? (d * (1 << 15) | 0) : (1 << 15) - 1;
	}

	return URL.createObjectURL(new Blob([buffer], {type: 'audio/wav'}));
}

function play (wav, loop) {
	var audio = new Audio(wav);
	if (loop) {
		audio.loop = true;
	}
	audio.play();
	return audio;
}

function stop (audio) {
	audio.pause();
}

return {
	prepare: wavFromData,
	play: play,
	stop: stop
};

})();

var melodyToData =
(function () {
"use strict";

var PI2 = Math.PI * 2, buffer = [];

function getFreq (note, key) {
	return key[note];
}

function addNote (time, freq, dur, volume, sampleRate) {
	var start = time * sampleRate, end = (time + dur) * sampleRate,
		i, t, s;
	for (i = start; i < end; i++) {
		t = (i - start) / sampleRate;
		if (t < 0.05) {
			s = t / 0.05;
		} else if (t > dur - 0.05) {
			s = (dur - t) / 0.05;
		} else {
			s = 1;
		}
		s *= Math.sin(t * freq * PI2);
		//s *= 1 - 4 * Math.abs(Math.round(t * freq) - t * freq);
		//s *= 1 - (2 * t * freq) % 2;
		//s *= (t * freq) % 1 < 0.5 ? -1 : 1;
		s *= volume;
		buffer[i] = (buffer[i] || 0) + s;
	}
}

function addStaff (staff, sampleRate) {
	var i, j, notes, time = 0, dur;
	for (i = 0; i < staff.notes.length; i++) {
		notes = staff.notes[i];
		dur = notes[1] * staff.baseDur;
		if (notes[0][0] !== 'z') {
			for (j = 0; j < notes[0].length; j++) {
				addNote(time, getFreq(notes[0][j], staff.key), dur, staff.volume, sampleRate);
			}
		}
		time += dur;
	}
}

function parseNotes (notes) {
	return notes.split(' ').map(function (n) {
		var l;
		n = n.split(/([\^_]?[a-zA-Z][',]*)/);
		l = Number(n.pop() || 1);
		return [
			n.filter(function (a) {
				return a;
			}),
			l
		];
	});
}

function dataToBuffer (data, baseDur, sampleRate) {
	var i;
	for (i = 0; i < data.length; i++) {
		addStaff({
			notes: parseNotes(data[i][0]),
			key: data[i][1],
			volume: data[i][2],
			baseDur: baseDur
		}, sampleRate);
	}
	return buffer;
}

return dataToBuffer;
})();

(function () {
"use strict";

var sampleRate = 44100, data;

function wavPlay () {
	wavPlayer.play(wavPlayer.prepare(data, sampleRate), true);
}

function acPlay () {
	acPlayer.play(acPlayer.prepare(data, sampleRate), true);
}

function initMelody () {
	var cMajorWithGSharp, cMajorOctaveLower, voice0, voice1;

	//Їхав козак за Дунай

	cMajorWithGSharp = {
		E: Math.pow(2, -5 / 12) * 440,
		//F: Math.pow(2, -4 / 12) * 440,
		G: Math.pow(2, -1 / 12) * 440,
		A: 440,
		B: Math.pow(2, 2 / 12) * 440,
		c: Math.pow(2, 3 / 12) * 440,
		d: Math.pow(2, 5 / 12) * 440,
		e: Math.pow(2, 7 / 12) * 440
	};

	voice0 =
		'A A A A A c B A G G G G G B A G ' +
		'A A A A A c B A G e E G A2 z2 ' +
		'c c c c c e d c B B B B B d c B ' +
		'A A A A A c B A G B e0.5 d0.5 c0.5 B0.5 A2 z2';

	cMajorOctaveLower = {
		'E,': Math.pow(2, -17 / 12) * 220,
		'^F,': Math.pow(2, -15 / 12) * 220,
		'G,': Math.pow(2, -14 / 12) * 220,
		'^G,': Math.pow(2, -13 / 12) * 220,
		'A,': 0.5 * 220,
		'B,': Math.pow(2, -10 / 12) * 220,
		C: Math.pow(2, -9 / 12) * 220,
		D: Math.pow(2, -7 / 12) * 220,
		E: Math.pow(2, -5 / 12) * 220,
		//F: Math.pow(2, -4 / 12) * 220,
		G: Math.pow(2, -2 / 12) * 220,
		'^G': Math.pow(2, -1 / 12) * 220,
		A: 220,
		B: Math.pow(2, 2 / 12) * 220,
		c: Math.pow(2, 3 / 12) * 220,
		d: Math.pow(2, 5 / 12) * 220,
		e: Math.pow(2, 7 / 12) * 220,
		f: Math.pow(2, 8 / 12) * 220
	};

	voice1 =
		'A, Ace E Ace A, Ace E Ace E ^Gde B, ^Gde E ^Gde B, ^Gde ' +
		'A, Ace E Ace A, Ace E Ace E ^Gde B, ^Gde A, Ace G,GBf2 ' +
		'C Gce G, Gce C Gce G, Gce G, GBd D GBd G, E, ^F, ^G, ' +
		'A, Ace E Ace A, Ace E Ace E ^Gde B, ^Gde A, Ace A,Ace2';

	return melodyToData([
		[voice0, cMajorWithGSharp, 0.1],
		[voice1, cMajorOctaveLower, 0.15]
	], 60 / 120, sampleRate);
}

data = initMelody();
acPlay();
})();