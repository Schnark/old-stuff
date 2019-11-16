(function () {
"use strict";

var contentHash = {}, moduleStack = [];

function require (name) {
	var path = require.resolve(name), module = require.cache[path] || createModuleObject(path);
	if (moduleStack.length) {
		topStack().children.push(module);
	} else {
		require.main = module;
	}
	if (!(path in require.cache)) {
		moduleStack.push(module);
		updateGlobals(module);
		getExecutable(path)();
		module.loaded = true;
		moduleStack.pop();
	}
	return module.exports;
}

function initGlobals () {
	window.global = window;
	window.require = require;
}

function updateGlobals (module) {
	window.module = module;
	window.exports = module.exports;
	window.__filename = module.filename;
	window.__dirname = getDir(module.filename);
}

function createModuleObject (path) {
	var module = {};
	module.children = [];
	module.exports = {};
	module.filename = path;
	module.id = path;
	module.loaded = false;
	module.parent = topStack();
	module.require = function (name) {
		var result;
		moduleStack.push(module);
		result = require(name);
		moduleStack.pop();
		return result;
	};
	return module;
}

function topStack () {
	return moduleStack.length ? moduleStack[moduleStack.length - 1] : null;
}

function getDir (path) {
	return path.replace(/\/[^\/]*$/, '/');
}

function getExecutable (path) {
	var code = contentHash[path];
	if (/\.json$/.test(path)) {
		code = 'module.exports=' + code;
	}
	return typeof code === 'string' ? new Function(code) : code;
}

function simplifyPath (path) {
	var i;
	while (true) {
		i = path.lastIndexOf('//');
		if (i > -1) {
			path = path.slice(i + 1);
			continue;
		}
		i = path.indexOf('/./');
		if (i > -1) {
			path = path.slice(0, i + 1) + path.slice(i + 3);
			continue;
		}
		i = path.indexOf('/../');
		if (i > -1) {
			path = path.slice(0, path.slice(0, i).lastIndexOf('/') + 1) + path.slice(i + 4);
			continue;
		}
		return path;
	}
}

function throwMissing () {
	var error;
	error = new Error();
	error.code = 'MODULE_NOT_FOUND';
	throw error;
}

require.cache = {};
require.resolve = function (name) {
	if (name in contentHash) {
		return name;
	}
	if (/^\.?\.?\//.test(name)) {
		name = simplifyPath(getDir((topStack() || {filename: ''}).filename) + name);
		if (name in contentHash) {
			return name;
		}
		if ((name + '.js') in contentHash) {
			return name + '.js';
		}
		if ((name + '.json') in contentHash) {
			return name + '.json';
		}
	}
	//FIXME
	throwMissing();
};
require._addContent = function (path, content) {
	contentHash[path] = content;
};

initGlobals();

})();