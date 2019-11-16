function Postprocessor (options) {
	var compressor, l, buffer, c0, c1, i, convolver, gain;
	options = options || {};

	if (options.context) {
		this.context = options.context;
	} else if (options.destination) {
		this.context = options.destination.context;
	} else {
		this.context = new AudioContext();
	}

	compressor = this.context.createDynamicsCompressor();
	compressor.connect(options.destination || this.context.destination);

	this.node = this.context.createGain();
	this.node.connect(compressor);

	if (options.reverb || options.reverb === undefined) {
		l = this.context.sampleRate / 2;
		buffer = this.context.createBuffer(2, l, this.context.sampleRate);
		c0 = buffer.getChannelData(0);
		c1 = buffer.getChannelData(1);
		for (i = 0; i < l; i++) {
			if (i / l < Math.random()) {
				c0[i] = Math.exp(-3 * i / l) * (Math.random() - 0.5) / 2;
				c1[i] = Math.exp(-3 * i / l) * (Math.random() - 0.5) / 2;
			}
		}

		convolver = this.context.createConvolver();
		convolver.buffer = buffer;

		gain = this.context.createGain();
		gain.gain.value = options.reverb || 0.3;

		convolver.connect(gain);
		gain.connect(compressor);
		this.node.connect(convolver);
	}
}

Postprocessor.prototype.getNode = function () {
	return this.node;
};

/*
context: AudioContext (defaults to context of destination or a new AudioContext)
destination: destination node within context (defaults to context.destination)
waveForm: wave form (defaults to sine), can be a string, an array of coefficients, or an object with real and/or imaginary coefficients
c: maximal number of notes that can be played at the same time (defaults to 2)
baseVolume: base volume (defaults to 1)
duration: base duration in seconds of a note (defaults to 0.5)
envelope: envelope (array of 3 relative durations: to increase, to hold and to decrease the volume, defaults to [0.2, 0.6, 1])
*/
function Instrument (options) {
	var i, waveForm, array, mod;
	options = options || {};

	if (options.context) {
		this.context = options.context;
	} else if (options.destination) {
		this.context = options.destination.context;
	} else {
		this.context = new AudioContext();
	}
	this.mainGain = this.context.createGain();
	this.mainGain.connect(options.destination || this.context.destination);
	this.nextTime = 0;

	waveForm = options.waveForm;
	if (Array.isArray(waveForm)) {
		waveForm = {r: waveForm};
	}
	if (waveForm && (Array.isArray(waveForm.r) || Array.isArray(waveForm.i))) {
		if (waveForm.r) {
			array = waveForm.r.slice();
			array.unshift(0);
			waveForm.r = new Float32Array(array);
		}
		if (waveForm.i) {
			array = waveForm.i.slice();
			array.unshift(0);
			waveForm.i = new Float32Array(array);
		}
		if (!waveForm.r) {
			waveForm.r = new Float32Array(waveForm.i.length);
		}
		if (!waveForm.i) {
			waveForm.i = new Float32Array(waveForm.r.length);
		}
		waveForm = this.context.createPeriodicWave(waveForm.r, waveForm.i);
	}

	mod = this.context.createOscillator();
	mod.frequency.value = 5;
	mod.start();
	this.mod = this.context.createGain();
	this.mod.gain.value = 5;
	mod.connect(this.mod);

	this.nodes = [];
	for (i = 0; i < (options.c || 2); i++) {
		this.nodes.push(this.createNode(waveForm, 5));
	}
	this.currentNode = 0;

	this.baseVolume = options.baseVolume || 1;
	this.duration = options.duration || 0.5;
	this.envelope = options.envelope || [0.3, 0.6, 1.2];
}

Instrument.FLUTE = [0.1, 0.9, 0.4, 0.2];
Instrument.OBOE = [0.5, 1.1, 0.1, 0.1, 0.2, 0.3, 0.1, 0.1];
Instrument.CLARINET = [1, 0.4, 0.3, 0, 0.1, 0.2];
Instrument.HORN = [1, 0.4, 0.2, 0.2];
Instrument.GUITAR = [1, 0.7, 1.2, 0.1, 0.1, 0.1];
Instrument.PIANO = [1, 0.1, 0.3, 0.1];

Instrument.prototype.createNode = function (waveForm, vary) {
	var oscillator = this.context.createOscillator(),
		gain = this.context.createGain();

	if (vary) {
		var delay = this.context.createDelay(0.1),
			gain2 = this.context.createGain();
		delay.connect(oscillator.detune);
		oscillator.connect(gain2);
		gain2.connect(delay);
		gain2.gain.value = vary;
	}

	this.mod.connect(oscillator.detune);

	gain.gain.value = 0;
	if (typeof waveForm === 'string') {
		oscillator.type = waveForm;
	} else if (waveForm) {
		oscillator.setPeriodicWave(waveForm);
	}
	oscillator.connect(gain);
	gain.connect(this.mainGain);
	oscillator.start();
	return {oscillator: oscillator, gain: gain};
};

Instrument.prototype.play = function (freq, duration, volume) {
	duration = duration || 1;
	volume = volume || 1;
	duration = duration * this.duration;
	volume = volume * this.baseVolume;
	if (this.context.currentTime > this.nextTime) {
		this.nextTime = this.context.currentTime;
	}

	this.nodes[this.currentNode].oscillator.frequency.setValueAtTime(freq, this.nextTime);
	this.nodes[this.currentNode].gain.gain.setValueAtTime(
		0,
		this.nextTime
	);
	this.nodes[this.currentNode].gain.gain.linearRampToValueAtTime(
		volume,
		this.nextTime + duration * this.envelope[0]
	);
	this.nodes[this.currentNode].gain.gain.setValueAtTime(
		volume,
		this.nextTime + duration * this.envelope[1]
	);
	this.nodes[this.currentNode].gain.gain.linearRampToValueAtTime(
		0,
		this.nextTime + duration * this.envelope[2]
	);

	this.currentNode = (this.currentNode + 1) % this.nodes.length;
	this.nextTime += duration;
};

Instrument.prototype.pause = function (duration) {
	if (this.context.currentTime > this.nextTime) {
		this.nextTime = this.context.currentTime;
	}
	this.nextTime += (duration || 1) * this.duration;
};

Instrument.prototype.getCachedCount = function () {
	return (this.nextTime - this.context.currentTime) / this.duration;
};

Instrument.prototype.setMainVolume = function (volume) {
	this.mainGain.gain.value = volume;
};

function Tuning (options) {
	options = options || {};
	this.notes = options.notes || ['c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#', 'a', 'a#', 'b'];
	this.baseFrequency = options.baseFrequency || 440;
	this.baseNote = 'baseNote' in options ? options.baseNote : (options.notes ? 0 : 9);
	this.tuning = options.tuning || this.notes.map(function (note, i) {
		return Math.pow(2, i / this.notes.length);
	}, this);
}

Tuning.PYTHAGOREAN = [1, 2187/2048, 9/8, 19683/16384, 81/64, 4/3, 729/512, 3/2, 6561/4096, 27/16, 59049/32768, 243/128];

Tuning.prototype.frequency = function (note, octave) {
	note = this.notes.indexOf(note);
	if (note === -1) {
		return 0;
	}
	return this.baseFrequency * this.tuning[note] / this.tuning[this.baseNote] * Math.pow(2, octave || 0);
};

var instrument, tuning;

instrument = new Instrument({
	destination: (new Postprocessor()).getNode(),
	waveForm: Instrument.FLUTE
});
tuning = new Tuning({tuning: Tuning.PYTHAGOREAN});

instrument.pause();
instrument.play(tuning.frequency('c'));
instrument.play(tuning.frequency('d'));
instrument.play(tuning.frequency('e'));
instrument.play(tuning.frequency('f'));
instrument.play(tuning.frequency('g'));
instrument.play(tuning.frequency('a'));
instrument.play(tuning.frequency('b'));
instrument.play(tuning.frequency('c', 1));


