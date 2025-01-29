function Melody (notes, modifiers, durations) {
	this.notes = notes;
	this.modifiers = modifiers || notes.map(function () {
		return 0;
	});
	this.durations = durations || notes.map(function () {
		return 1;
	}); //0.5, 0.5 means: play note[i], then note[i] + modifiers[i] each for half of standard length etc.
}

Melody.prototype.clone = function () {
	return new Melody(this.notes.slice(), this.modifiers.slice(), this.durations.slice());
};

Melody.prototype.transpose = function (d) {
	this.notes = this.notes.map(function (note) {
		return note + d;
	});
	return this;
};

Melody.prototype.reverse = function () {
	this.notes.reverse();
	this.modifiers.reverse();
	this.durations.reverse();
	return this;
};

Melody.prototype.reflect = function () {
	var notes = [this.notes[0]], i;
	for (i = 1; i < this.notes.length; i++) {
		notes.push(notes[i - 1] - (this.notes[i] - this.notes[i - 1]));
	}
	this.notes = notes;
	return this;
};


