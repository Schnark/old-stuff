fileSystem = {
	getFileNames: function (pattern) {return Promise.resolve([]);},
	readFile: function (name) {return Promise.resolve('');},
	writeFile: function (name, content) {return Promise.resolve();}
};


//for handlebars
templateEngine = {
	compileTemplate: Handlebars.compile,
	applyTemplate: function (template, data) {
		return template(data);
	}
};



parsers =
(function () {
"use strict";

var parsers = [];

function defineParser (select, parser, weight) {
	parsers.push({select: select, parser: parser, weight: weight});
}

function selectParser (name) {
	var i, bestIndex = -1, bestWeight = -1;
	for (i = 0; i < parsers.length; i++) {
		if (parsers[i].weight > bestWeight && parsers[i].select(name)) {
			bestIndex = i;
			bestWeight = parsers[i].weight;
		}
	}
	return parsers[bestIndex].parser;
}

return {
	defineParser: defineParser,
	selectParser: selectParser
};
})();

parsers.defineParser(function (path) {
	return path.slice(-5) === '.json';
}, function (content) {
	return JSON.parse(content);
}, 1);

parsers.defineParser(function () {
	return true;
}, function (content) {
	return {
		content: content
	};
}, 0);

function parseFile (name, content) {
	var parser = parsers.selectParser(name), data;
	data = parser(content);
	data.source = name;
	return data;
}



preparers =
(function () {
"use strict";

var preparers = {};

function definePreparer (name, prepare) {
	preparers[name] = prepare;
}

function getPreparer (name) {
	return preparers[name];
}

return {
	definePreparer: definePreparer,
	getPreparer: getPreparer
};
})();

function sort (data, key, reverse) {
	if (key) {
		data.sort(function (a, b) {
			var i = 0;
			if (Array.isArray(key)) {
				while (i < key.length - 1 && a[key[i]] === b[key[i]]) {
					i++;
				}
				a = a[key[i]];
				b = b[key[i]];
			} else {
				a = a[key];
				b = b[key];
			}
			return a < b ? -1 : a > b ? 1 : 0;
		});
	}
	if (reverse) {
		data.reverse();
	}
}

preparers.definePreparer('default', function (data, config) {
	sort(data, config.sort, config.reverse);
	return data;
});

preparers.definePreparer('paged', function (data, config) {
	var pages = [], pagesize = config.pagesize || 10, i;
	sort(data, config.sort, config.reverse);
	for (i = 0; i < data.length / pagesize; i++) {
		pages.push({
			page: i + 1,
			path: createPath(config.path || '%p.%e'), //TODO
			entries: data.slice(i * pagesize, pagesize)
		});
	}
	return pages;
});

//TODO chunked, i.e. paged e.g. by part of date

function preparePages (name, data, config) {
	var prepare = preparers.getPreparer(name);
	return prepare(data, config);
}



var cachedTemplates = {};

function getTemplate (name) {
	if (!cachedTemplates[name]) {
		cachedTemplates[name] = templateEngine.compileTemplate(fileSystem.readFile(name));
	}
	return cachedTemplates[name];
}

function extend (to, from) {
	Object.keys(from).forEach(function (key) {
		if (!(key in to)) {
			to[key] = from[key];
		}
	});
}

function makeExpandedValue (simple, expanded) {
	expanded.toString = function () {
		return simple;
	};
	return expanded;
}

function expandFileName (data, key) {
	var name = data[key];
	if (name) {
		data[key] = makeExpandedValue(name, parseFile(name, fileSystem.readFile(name))); //FIXME
	}
}

function parseTimestamp (ts) {
	var parts, data;
	if (!ts) {
		return;
	}
	parts = ts.match(/^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2}):(\d{2})(?\.\d+)?Z?)?$/); //TODO
	if (!parts) {
		return;
	}
	data = {
		yy: parts[1],
		y: Number(parts[1]),
		mm: parts[2],
		m: Number(parts[2]),
		n: Number(parts[2]) - 1,
		dd: parts[3],
		d: Number(parts[3])
		//TODO w
	};
	if (parts[4]) {
		data.hh = parts[4];
		data.h = Number(parts[4]);
		data.MM = parsts[5];
		data.M = Number(parts[5]);
		data.ss = parts[6];
		data.s = Number(parts[6]);
	}
	return data;
}

function expandTimestamp (data, key) {
	var ts = parseTimestamp(data[key]);
	if (ts) {
		data[key] = makeExpandedValue(data[key], ts);
	}
}

function createPath (pattern, data) {
	return pattern.replace(/%(.)/g, function (all, c) {
		switch (c) {
		case '%': return '%';
		case 'e': return data.template.slice(data.template.lastIndexOf('.') + 1);
		case 'p': return data.page;
		case 's': return data.source.slice(0, data.source.lastIndexOf('.'));
		default: return all;
		}
	});
}

function readInputData (input) {
	return fileSystem.getFileNames(input).then(function (names) {
		return Promise.all(names.map(function (name) {
			return parseFile(name, fileSystem.readFile(name));
		}));
	});
}

function createPages (data, config, defaults) {
	var pages, i;
	pages = preparePages(config.type || 'default', data, config);
	for (i = 0; i < pages.length, i++) {
		if (config.defaults) {
			extend(pages[i], config.defaults);
		}
		if (defaults) {
			extend(pages[i], defaults);
		}
		extend(pages[i], {
			all: pages,
			prev: i === 0 ? null : pages[i - 1],
			next: i === pages.length - 1 ? null : pages[i + 1]
		});
		if (!pages[i].path) {
			pages[i].path = createPath(config.path || '%s.%e', pages[i]);
		}
		if (config.fileProperties) {
			config.fileProperties.forEach(function (key) {
				expandFileName(pages[i], key);
			});
		}
		if (config.tsProperties) {
			config.tsProperties.forEach(function (key) {
				expandTimestamp(pages[i], key);
			});
		}
	}
}

function writeOutputData (pages) {
	return Promise.all(pages.map(function (page) {
		var content;
		if (page.template) {
			content = templateEngine.applyTemplate(getTemplate(page.template), page);
		} else {
			content = page.content;
		}
		return fileSystem.writeFile(page.path, content);
	}));
}

function runBatch (config, defaults) {
	return readInputData(config.input).then(function (data) {;
		var pages;
		pages = createPages(data, config, defaults);
		return writeOutputData(pages);
	})
}