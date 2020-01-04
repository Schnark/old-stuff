(function (console) {

var panel;

function createPanel () {
	var panelOuter = document.createElement('div'), placeholder = document.createElement('div'), body;
	panelOuter.innerHTML = '<div id="xowa-debug-console-log" style="position: absolute; margin-bottom: 1em; height: 100%; width: 100%; white-space: pre-wrap; overflow-x: scroll; overflow-y: auto; -moz-box-sizing: borderBox;"></div><form id="xowa-debug-console-form"><input id="xowa-debug-console-input" style="width: 100%; height: 1em; position: absolute; bottom: 0;" /></form>';
	panelOuter.setAttribute('style', 'position: fixed; bottom: 0; width: 100%; height: 15em; border-top: 2px solid black; background-color: #ddf;');
	placeholder.setAttribute('style', 'widht: 100%; height: 15em; border-top: 2px;');
	body = document.getElementsByTagName('body')[0];
	body.appendChild(panelOuter);
	body.appendChild(placeholder);
	panel = document.getElementById('xowa-debug-console-log');
	document.getElementById('xowa-debug-console-form').addEventListener('submit', onSubmit, false);
}

function addCSS (css) {
	var s = document.createElement('style');
	document.getElementsByTagName('head')[0].appendChild(s);
	s.appendChild(document.createTextNode(css));
}

function stringify (data) {
	var type = typeof data, str = String(data), f;
	if (type === 'string') {
		return data;
	}
	if (/^\w*Error:/.test(str)) {
		return str;
	}
	if (type === 'object') {
		for (f in data) {
			if (typeof data[f] === 'function') {
				data[f] = '(function)';
			} else if (data[f] === data) {
				data[f] = '(self)';
			}
		}
	}
	try {
		return JSON.stringify(data);
	} catch (e) {
		return str;
	}
}

function log (data) {
	panel.textContent += '\n' + stringify(data);
	panel.scrollTop = panel.scrollHeight - panel.clientHeight;
}

function looksLikeCSS (code) {
	return (/.*\{[^{}]+\}$/).test(code);
}

function execute (code) {
	var ret;
	log('< ' + code);
	try {
		ret = eval(code);
		log(ret);
	} catch (e) {
		if (looksLikeCSS(code)) {
			addCSS(code);
			log('Added as CSS');
		} else {
			log(e);
		}
	}
}

function onSubmit (e) {
	e.preventDefault();
	var input = document.getElementById('xowa-debug-console-input');
	execute(input.value);
	input.value = '';
}

console = {
	log: log
};

document.addEventListener('DOMContentLoaded', createPanel, false);

})(window.console);