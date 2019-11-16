var localStorageManager = (function () {
	var cache;
	function get () {
		if (!cache) {
			cache = localStorage.getItem('schnark-assistant');
			if (cache !== null) {
				cache = JSON.parse(cache);
			} else {
				cache = {};
			}
		}
		return cache;
	}
	function set (data) {
		cache = data;
		localStorage.setItem('schnark-assistant', JSON.stringify(data));
	}
	return {
		get: get,
		set: set
	};
})(),

dataStore = (function (storage) {
	var cachedData;
	function getFromForm (type) {
		return 'FIXME';
	}
	function getPersistentData (title) {
		var data = storage.get();
		if (hasOwn.call(data, title)) {
			return data[title];
		}
		return {
			extra: {},
			oldText: getFromForm('text'),
			start: $.now(),
			previewCount: -1
		};
	}
	function getCachedData () {
		if (!cachedData) {
			cachedData = getPersistentData(mw.config.get('wgPageName'));
		}
		return cachedData;
	}
	function saveCachedData () {
		var data = storage.get();
		data[mw.config.get('wgPageName')] = cachedData;
		storage.set(data);
	}
	function deletePersistentData (title) {
		var data = storage.get();
		delete data[title];
		storage.set(data);
		cachedData = undefined;
	}
	function updateData (type) {
		var data, title, changed = false, now = $.now();
		switch (type) {
		case 'edit':
			getCachedData();
			cachedData.previewCount++;
			saveCachedData();
			break;
		case 'saved':
			deletePersistentData(mw.config.get('wgPageName'));
			break;
		default:
			data = storage.get();
			for (title in data) {
				if (hasOwn.call(data, title)) {
					if (now - data[title].start > 1000 * 60 * 60 * 24) {
						delete data[title];
						changed = true;
					}
				}
			}
			if (changed) {
				storage.set(data);
			}
		}
	}
	function addExtraData (key, data) {
		getCachedData();
		cachedData.extra[key] = data;
		saveCachedData();
	}
	function getOtherData () {
		return {
			newText: getFromForm('text'),
			summary: getFromForm('summary'),
			section: getFromForm('section'),
			minor: getFromForm('minor'),
			ns: mw.config.get('wgNamespaceNumber'),
			title: mw.config.get('wgTitle')
		};
	}
	function getData () {
		return $.extend(true, {}, getCachedData(), getOtherData());
	}

	return {
		getData: getData,
		addExtraData: addExtraData,
		updateData: updateData
	};
})(localStorageManager),

hooks = (function (dataStore) {
	var allHooks = {}, activeHooks = {}, suggestions = [], activated = false;
	function register (name, func) {
		if (hasOwn.call(allHooks, name)) {
			return false;
		}
		allHooks[name] = func;
		if (activated) {
			activateOne(name);
		}
		return true;
	}
	function activateOne (name) {
		var result = allHooks[name](dataStore.getData());
		if (result && $.isFunction(result.done)) {
			result.done(function (data) {
				dataStore.addExtraData(name, data);
				activateOne(name, dataStore);
			});
		} else if ($.isFunction(result)) {
			activeHooks[name] = result;
		}
	}
	function activateHooks () {
		var name;
		for (name in allHooks) {
			if (hasOwn.call(allHooks, name)) {
				activateOne(name);
			}
		}
		activated = true;
	}
	function addSuggestions (name, suggestion) {
		var i, prio, html;
		if (!suggestion) {
			return;
		}
		if ($.isArray(suggestion)) {
			for (i = 0; i < suggestion.length; i++) {
				addSuggestions(name, suggestion[i]);
			}
			return;
		}
		if (typeof suggestion === 'string') {
			html = mw.html.escape(suggestion);
			prio = 4;
		} else {
			html = suggestion.html || mw.html.escape(suggestion.text);
			prio = suggestion.prio || 4;
		}
		prio = Math.round(prio);
		if (prio > 9) {
			prio = 9;
		} else if (prio < 1) {
			prio = 1;
		}
		suggestions.push({key: String(prio) + name, html: html});
	}
	function getSuggestions () {
		var i, result;
		suggestions.sort(function (a, b) {
			if (a.key < b.key) {
				return -1;
			}
			if (a.key > b.key) {
				return 1;
			}
			return 0;
		});
		for (i = 0; i < suggestions.length; i++) {
			result.push(suggestions[i].html);
		}
		return result;
	}
	function runActiveHooks () {
		var name, data = dataStore.getData();
		suggestions = [];
		for (name in activeHooks) {
			if (hasOwn.call(activeHooks, name)) {
				addSuggestions(name, activeHooks[name](data));
			}
		}
		return getSuggestions();
	}

	return {
		register: register,
		activateHooks: activateHooks,
		runActiveHooks: runActiveHooks
	};
})(dataStore),

registration = (function (register) {
	return function () {
		//FIXME
	};
})(hooks.register),

work = (function (dataStore, hooks, registration) {
	function show (suggestions) {
		var hasSuggestions = !!suggestions.length, html = $.map(suggestions, function (suggestion) {
			return '<li>' + suggestion + '</li>';
		}).join();
		html = '<ul>' + html + '</ul>';
		//FIXME
	}
	function manage (type) {
		dataStore.updateData(type);
		if (type === 'edit') {
			registration();
			hooks.activateHooks();
			window.setInterval(function () {
				show(hooks.runActiveHooks());
			}, 10000);
		}
	}
	return manage;
})(dataStore, hooks, registration);

if ($.inArray(mw.config.get('wgAction'), ['edit', 'submit'])) {
	work('edit');
}
work();
mw.hooks('FIXME').add(function () {
	work('saved');
});

