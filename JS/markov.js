function Markov (options) {
	this.reset(options);
}

Markov.prototype.n = 1;

Markov.prototype.split = function (text) {
	return text.split(/\s+/).filter(function (word) {
		return word;
	});
};

Markov.prototype.join = function (words) {
	return words.join(' ');
};

Markov.prototype.reset = function (options) {
	options = options || {};
	if (options.n) {
		this.n = options.n;
	}
	if (options.split) {
		this.split = options.split;
	}
	if (options.join) {
		this.join = options.join;
	}
	this.tokens = [];
	this.matrix = {};
};

Markov.prototype.import = function (data) {
	this.n = data.n;
	this.tokens = data.tokens;
	this.matrix = data.matrix;
};

Markov.prototype.export = function () {
	return {
		n: this.n,
		tokens: this.tokens,
		matrix: this.matrix
	};
};

Markov.prototype.wordsToTokens = function (words) {
	var tokens = [''], i;
	for (i = 0; i < words.length; i++) {
		tokens.push(words.slice(Math.max(0, i - this.n + 1), i + 1).join(' '));
	}
	tokens.push('');
	return tokens;
};

Markov.prototype.tokensToWords = function (tokens) {
	return tokens.filter(function (token) {
		return token;
	}).map(function (token, i) {
		return token.slice(token.lastIndexOf(' ') + 1);
	}).join(' ').split(' ');
};

Markov.prototype.getTokenIndex = function (token, noCreate) {
	var i = this.tokens.indexOf(token);
	if (i === -1 && !noCreate) {
		i = this.tokens.length;
		this.tokens.push(token);
	}
	return i;
};

Markov.prototype.addToMatrix = function (from, to) {
	from = this.getTokenIndex(from);
	to = this.getTokenIndex(to);
	if (!this.matrix[from]) {
		this.matrix[from] = {sum: 0};
	}
	if (!this.matrix[from][to]) {
		this.matrix[from][to] = 0;
	}
	this.matrix[from][to]++;
	this.matrix[from].sum++;
};

Markov.prototype.getNextTokens = function (token) {
	var next;
	token = this.getTokenIndex(token, true);
	if (token === -1) {
		return [];
	}
	next = this.matrix[token];
	next = Object.keys(next).filter(function (key) {
		return key !== 'sum';
	}).map(function (key) {
		return [this.tokens[key], next[key] / next.sum];
	}.bind(this));
	next.sort(function (a, b) {
		return b[1] - a[1];
	});
	return next;
};

Markov.prototype.train = function (data) {
	var i;
	data = this.wordsToTokens(this.split(data));
	for (i = 0; i < data.length - 1; i++) {
		this.addToMatrix(data[i], data[i + 1]);
	}
};

Markov.prototype.trainMulti = function (data) {
	var i;
	for (i = 0; i < data.length; i++) {
		this.train(data[i]);
	}
};

Markov.prototype.trainMultiAsync = function (data, callback, batch, pause) {
	var i = 0, markov = this;
	batch = batch || 10;
	pause = pause || 1;
	function next () {
		markov.trainMulti(data.slice(i, i + batch));
		i += batch;
		if (i < data.length) {
			window.setTimeout(next, pause);
		} else if (callback) {
			callback();
		}
	}
	next();
};

Markov.prototype.getNext = function (input) {
	return this.getNextTokens(this.split(input).slice(-this.n).join(' ')).map(function (data) {
		return [this.join([data[0].slice(data[0].lastIndexOf(' ') + 1)]), data[1]];
	}.bind(this));
};

Markov.prototype.getRandom = function () {
	var tokens = [''], r, next;
	while (tokens.length === 1 || tokens[tokens.length - 1] !== '') {
		r = Math.random();
		next = this.getNextTokens(tokens[tokens.length - 1]);
		while (r > next[0][1] && next.length > 1) {
			r -= next[0][1];
			next.shift();
		}
		tokens.push(next[0][0]);
	}
	return this.join(this.tokensToWords(tokens));
};


function openFile (callback) {
	var pick;

	function readFile (file, callback) {
		if (!file) {
			callback();
			return;
		}
		var reader = new FileReader();
		reader.onload = function (e) {
			callback(e.target.result);
		};
		reader.onerror = function () {
			callback();
		};
		reader.readAsText(file);
	}

	if (window.MozActivity) {
		pick = new MozActivity({
			name: 'pick',
			data: {
				type: [
					'text/plain',
					'text/*',
					'application/pdf' //this is ridiculous, but it does work
				]
			}
		});

		pick.onsuccess = function () {
			readFile(this.result.blob, callback);
		};

		pick.onerror = function () {
			callback();
		};
	} else {
		pick = document.createElement('input');
		pick.type = 'file';
		pick.style.display = 'none';
		document.getElementsByTagName('body')[0].appendChild(pick);
		pick.addEventListener('change', function () {
			readFile(pick.files[0], callback);
			document.getElementsByTagName('body')[0].removeChild(pick);
		}, false);
		pick.click();
	}
}

function trainFile (markov, separator, callback) {
	openFile(function (data) {
		if (data) {
			markov.trainMultiAsync(data.split(separator).filter(function (data) {
				return data;
			}), callback);
		} else if (callback) {
			callback();
		}
	});
}


function getSuggestions (markov, input, separator, n) {
	var i, part, next;
	i = input.lastIndexOf(separator);
	part = input.slice(i + 1);
	next = markov.getNext(i === -1 ? '' : input.slice(0, i)).map(function (data) {
		return data[0];
	}).filter(function (data) {
		return data.slice(0, part.length) === part;
	}).map(function (data) {
		return [data, data.slice(part.length) + separator];
	});
	n = n || 3;
	if (next.length > n) {
		next.length = n;
	}
	return next;
}



function addSuggestionsToTextarea (markov, textarea, suggestions) {
	function htmlEscape (text) {
		return text.replace(/&/g, '&amp;').replace(/"/g, '&quot;')
			.replace(/</g, '&lt;').replace(/>/g, '&gt;');
	}

	function onChange () {
		suggestions.innerHTML = getSuggestions(markov, textarea.value, ' ').map(function (suggestion) {
			return '<span data-suggestion="' + htmlEscape(suggestion[1]) + '">' + htmlEscape(suggestion[0]) + '</span>';
		}).join('\n');
	}

	textarea.addEventListener('input', onChange);
	suggestions.addEventListener('click', function (e) {
		var suggestion = e.target.dataset.suggestion;
		if (suggestion) {
			textarea.value += suggestion;
		}
		onChange();
	});
	onChange();
}



var markov = new Markov({n: 2});
trainFile(markov, '\n', function () {
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	console.log(markov.getRandom());
	document.body.innerHTML = '<div id="suggestions"></div><textarea id="textarea"></textarea>';
	addSuggestionsToTextarea(markov, document.getElementById('textarea'), document.getElementById('suggestions'));
});

//var word = new Markov({n: 3, split: function (word) {return word.split('');}, join: function (letters) {return letters.join('');}});
