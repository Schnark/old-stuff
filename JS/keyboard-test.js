function DefaultKeyboard (area, callback) {
	this.textarea = document.createElement('textarea');
	this.textarea.addEventListener('input', function () {
		callback(this.textarea.value);
	}.bind(this));
	area.appendChild(this.textarea);
	this.textarea.focus();
}

DefaultKeyboard.prototype.destroy = function () {
	this.textarea.blur();
	this.textarea.remove();
};



function KeyboardTest (text, Keyboard, duration, callback) {
	this.running = false;
	this.errors = 0;
	this.hasError = false;
	this.typedText = '';
	this.text = text;
	this.duration = duration;
	this.callback = callback;
	this.display = {
		correct: document.getElementById('correct'),
		wrong: document.getElementById('wrong'),
		missing: document.getElementById('missing')
	};
	this.updateDisplay();
	this.keyboard = new Keyboard(document.getElementById('keyboard'), this.updateText.bind(this));
}

KeyboardTest.now = window.performance && window.performance.now ? function () {
	return window.performance.now() / 1000;
} : function () {
	return (new Date()) / 1000;
};

KeyboardTest.prototype.start = function () {
	this.start = KeyboardTest.now();
	if (isFinite(this.duration)) {
		setTimeout(this.stop.bind(this), this.duration * 1000);
	}
};

KeyboardTest.prototype.stop = function () {
	var text, time;
	time = KeyboardTest.now() - this.start;
	this.keyboard.destroy();
	text = this.analyseText().correct;
	this.callback({
		chars: text.length,
		words: text.replace(/\S+/g, '').length,
		time: time,
		errors: this.errors
	});
};

KeyboardTest.prototype.analyseText = function () {
	var prefix = this.typedText;
	while (this.text.slice(0, prefix.length) !== prefix) {
		prefix = prefix.slice(0, -1);
	}
	return {
		correct: prefix,
		wrong: this.typedText.slice(prefix.length),
		missing: this.text.slice(prefix.length)
	};
};

KeyboardTest.prototype.updateText = function (text) {
	if (text && !this.running) {
		this.running = true;
		this.start();
	}
	this.typedText = text;
	this.updateDisplay();
	if (this.typedText === this.text) {
		if (!isFinite(this.duration)) {
			this.stop();
		} else {
			this.text = this.text + ' ' + this.text;
			this.updateDisplay();
		}
	}
};

KeyboardTest.prototype.updateDisplay = function () {
	var state = this.analyseText();
	this.display.correct.textContent = state.correct;
	this.display.wrong.textContent = state.wrong;
	this.display.missing.textContent = state.missing;
	if (state.wrong) {
		if (!this.hasError) {
			this.hasError = true;
			this.errors++;
		}
	} else {
		this.hasError = false;
	}
};