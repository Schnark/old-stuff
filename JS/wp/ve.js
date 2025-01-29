function searchGroup(needle, haystack) {
	var items = [], i;
	for (i = 0; i < haystack.include.length; i++) {
		items.push(haystack.include[i].group || haystack.include[i]);
	}
	return items.indexOf(needle) > -1;
}

function getGroupIndex (find) {
	var groups = ve.init.mw.Target.static.toobarGroups, i, translate;
	translate = {
		history: 'undo',
		style: 'textStyle',
		list: 'structure',
		insert: '*'
	};
	find = translate[find] || find;
	for (i = 0; i < groups.length; i++) {
		if (searchGroup(find, groups[i])) {
			return i;
		}
	}
	return -1;
}

function addToGroup (index, tool, config) {
	config = config || {};	
	var group = ve.init.mw.Target.static.toobarGroups[index];
	if (group.include !== '*') {
		group.include.push(tool);
	}
	switch (config.position) {
	case 'promote':
		if (!group.promote) {
			group.promote = [];
		}
		group.promote.push(tool);
		break;
	case 'demote':
		if (!group.demote) {
			group.demote = [];
		}
		group.demote.push(tool);
		break;
	case 'expand':
		if (!group.forceExpand) {
			group.forceExpand = [];
		}
		group.forceExpand.push(tool);
	}
}

function addGroup (index, config) {
	ve.init.mw.Target.static.toobarGroups.splice(index, 0, {
		label: config.title || OO.ui.deferMsg( 'visualeditor-toolbar-insert' ),
		indicator: config.indicator || 'down',
		include: []
	});
}











function makeCustomHelpDialog (name, title, $content) {
	function CustomHelpDialog (config) {
		CustomHelpDialog.parent.call(this, config);
	}
	OO.inheritClass(CustomHelpDialog, ve.ui.CommandHelpDialog);
	CustomHelpDialog.static.name = name;
	CustomHelpDialog.static.title = title;
	CustomHelpDialog.static.getCommandGroups = function () {
		return {};
	};
	CustomHelpDialog.prototype.initialize = function () {
		CustomHelpDialog.parent.prototype.initialize.call(this);
		this.$container.append($content);
	};
	ve.ui.windowFactory.register(CustomHelpDialog);
}

function InsertWithoutSelectCommand (name, content) {
	InsertWithoutSelectCommand.parent.call(this, name);
	this.content = content;
}
OO.inheritClass(InsertWithoutSelectCommand, ve.ui.Command);
InsertWithoutSelectCommand.prototype.execute = function (surface) {
	surface.getModel().getFragment().insertContent(this.content).collapseToEnd().select();
	return true;
};

function makeInsertAndSelectCommand (name, content) {
	ve.ui.commandRegistry.register(
		new ve.ui.Command(name, 'content', 'insert', {args: content})
	);
}

function makeInsertWithoutSelectCommand (name, content) {
	ve.ui.commandRegistry.register(
		new InsertWithoutSelectCommand(name, content)
	);
}

function makeInsertTool (name, config) {
	if (config.select) {
		makeInsertAndSelectCommand(name, config.insert);
	} else {
		makeInsertWithoutSelectCommand(name, config.insert);
	}

	function InsertTool () {
		InsertTool.parent.apply(this, arguments);
	}
	OO.inheritClass(InsertTool, ve.ui.Tool);
	InsertTool.static.name = name;
	if (config.icon) {
		InsertTool.static.icon = config.icon;
	}
	InsertTool.static.title = config.title;
	InsertTool.static.commandName = name;

	ve.ui.toolFactory.register(InsertTool);
}

function makeHelpTool (name, config) {
	makeCustomHelpDialog(name, config.title, $('<div>').html(config.help));

	function HelpDialogTool () {
		HelpDialogTool.parent.apply(this, arguments);
	}
	OO.inheritClass(HelpDialogTool, ve.ui.CommandHelpDialogTool);
	HelpDialogTool.static.name = name;
	HelpDialogTool.static.title = config.shortTitle || config.title;
	HelpDialogTool.static.commandName = name;

	ve.ui.toolFactory.register(HelpDialogTool);
}

function insertSpecialChar (config) {
	var list;
	try {
		list = JSON.parse(mw.msg('visualeditor-quick-access-characters.json'));
	} catch (e) {
		list = {};
	}
	list[config.charLabel || config.char] = config.char;
	mw.messages.set('visualeditor-quick-access-characters.json', JSON.stringify(list));
}

function makeGroup (name, config) {
	var index = getGroupIndex(config.after || 'insert');
	if (index === -1) {
		throw new Error('Unknown group "' + config.after + '"');
	}
	addGroup(index, config);
}

function addShortcut (name, shortcut) {
	ve.ui.triggerRegistry.register(name, getTrigger(shortcut));
}

function addToGroup (name, groupName, config) {
	var index = getGroupIndex(groupName);
	if (index === -1) {
		throw new Error('Unknown group "' + groupName + '"');
	}
	addToGroup(index, name, config);
}


function getTrigger (shortcut) {
	if (typeof shortcut === 'string') {
		return new ve.ui.Trigger(shortcut);
	}
	if (Array.isArray(shortcut)) {
		return shortcut.map(getTrigger);
	}
	return {mac: getTrigger(shortcut.mac), pc: getTrigger(shortcut.ps)};
}





function init () {
	readConfigEntries(mw.libs.ve.schnarkConfig || getDefaultConfig());
}

function readConfigEntries (config) {
	var i;
	for (i = 0; i < config.length; i++) {
		applyConfigEntry(getConfigEntry(config[i]));
	}
}

function getConfigEntry (entry) {
	if (typeof entry === 'string') {
		return getDefault(entry);
	}
	if (entry.name) {
		return $.extend({}, getDefault(entry.name), entry);
	}
	return entry;
}

function applyConfigEntry (entry) {
	var name = 'schnark-ve-config-name-' + (nameCount++);
	switch (entry.type || 'insert') {
	case 'insert':
		entry.group = entry.group || 'insert';
		makeInsertTool(name, entry);
		break;
	case 'help':
		entry.group = entry.group || 'help';
		makeHelpTool(name, entry);
		break;
	case 'special':
		insertSpecialChar(entry);
		return;
	default:
		throw new Error('Unknown type "' + entry.type + '"');
	}
	if (entry.shortcut) {
		addShortcut(name, entry.shortcut);
	}
	if (typeof entry.group !== 'string') {
		makeGroup(entry.group.name, entry.group);
		entry.group = entry.group.name;
	}
	addToGroup(name, entry.group, entry);
}
/*
{
	name: <string>
	type: 'insert'|'help'|'special'
	group: <string>|<object>
	content: <string>|<object>
	shortcut: <string>|<array>|<object>
	position: 'promote'|'demote'|'expand'
*/

mw.loader.using('ext.visualEditor.desktopArticleTarget.init').done(function () {
	mw.libs.ve.addPlugin(function () {
		return mw.loader.using(['ext.visualEditor.core']).done(init);
	});
	mw.libs.ve.schnarkConfig = [];
});