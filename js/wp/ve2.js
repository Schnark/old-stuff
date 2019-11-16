var toolCount = 0;
function makeName () {
	return 'schnark-ve-tool-' + (toolCount++);
}

function makeSmallTool () {
	ve.ui.commandRegistry.register(
		new ve.ui.Command(
			'small', 'annotation', 'toggle',
			{args: ['textStyle/small'], supportedSelections: ['linear', 'table']}
		)
	);

	/* Funktioniert nicht
	ve.ui.triggerRegistry.register(
		'small', {mac: new ve.ui.Trigger('cmd+shift+-'), pc: new ve.ui.Trigger('ctrl+shift+-')}
	);
	*/

	function SmallAnnotationTool(toolGroup, config) {
		ve.ui.AnnotationTool.call(this, toolGroup, config);
	}
	OO.inheritClass(SmallAnnotationTool, ve.ui.AnnotationTool);
	SmallAnnotationTool.static.name = 'small';
	SmallAnnotationTool.static.group = 'textStyle';
	SmallAnnotationTool.static.icon = 'smaller';
	SmallAnnotationTool.static.title = 'Kleine Schriftgröße'; //FIXME lokalisieren
	SmallAnnotationTool.static.annotation = {name: 'textStyle/small'};
	SmallAnnotationTool.static.commandName = 'small';
	ve.ui.toolFactory.register(SmallAnnotationTool);
	/*
	ve.ui.commandHelpRegistry.register('textStyle', 'small', {
		shortcuts: [{mac: 'cmd+shift+-', pc: 'ctrl+shift+-'}],
		label: 'Kleine Schriftgröße' //FIXME lokalisieren
	});
	*/
}

function enableSignEverywhere (all) {
	var ns;
	if (!all) {
		all = [];
		for (ns in mw.config.get('wgFormattedNamespaces')) {
			if (!isNaN(ns) && ns >= 0) {
				all.push(Number(ns));
			}
		}
	}
	mw.config.get('wgVisualEditorConfig').signatureNamespaces = all;

}

function makeTrigger (trigger, string) {
	return string ?
		{mac: trigger.replace('ctrl', 'cmd'), pc: trigger} :
		{mac: new ve.ui.Trigger(trigger.replace('ctrl', 'cmd')), pc: new ve.ui.Trigger(trigger)};
}


function makeInsertTool(config) {
	var name = makeName(), Command;
	config = $.extend({
		parent: ve.ui.MWTransclusionDialogTool,
		group: 'object',
		icon: '',
		title: '',
		insert: [],
		annotate: false,
		collapseToEnd: true,
		selections: ['linear']
	}, config);

	function InsertAndOpenDialogCommand () {
		ve.ui.Command.apply(this, arguments);
	}
	OO.inheritClass(InsertAndOpenDialogCommand, ve.ui.Command);
	InsertAndOpenDialogCommand.prototype.execute = function (surface) {
		return ve.ui.Command.prototype.execute.apply(this, arguments) && this.delay(function () {
			surface.executeCommand('transclusion');
		});
	};
	InsertAndOpenDialogCommand.prototype.delay = function (f, until) {
		//FIXME
		var id;
		if (typeof until === 'string') {
			id = window.setInterval(function () {
				if ($(until).length) {
					window.clearTimeout(id);
					f();
				}
			}, 50);
			window.setTimeout(function () {
				window.clearTimeout(id);
			}, 10000);
		} else {
			window.setTimeout(f, until || 1000);
		}
		return true;
	};

	function InsertTool (toolGroup, conf) {
		config.parent.call(this, toolGroup, conf);
	}
	OO.inheritClass(InsertTool, config.parent);

	InsertTool.static.name = name;
	InsertTool.static.group = config.group;
	InsertTool.static.icon = config.icon;
	InsertTool.static.title = config.title;
	InsertTool.static.commandName = name;
	ve.ui.toolFactory.register(InsertTool);

	Command = config.openDialog ? InsertAndOpenDialogCommand : ve.ui.Command;

	ve.ui.commandRegistry.register(
		new Command(name, 'content', 'insert', {
			args: [config.insert, config.annotate, config.collapseToEnd],
			supportedSelections: config.selections
		})
	);
	if (config.sequence) {
		ve.ui.sequenceRegistry.register(
			new ve.ui.Sequence(name, name, config.sequence, config.sequence.length)
		);
	}
	if (config.trigger) {
		ve.ui.triggerRegistry.register(
			name, makeTrigger(config.trigger)
		);
	}
	if (config.help) {
		ve.ui.commandHelpRegistry.register('insert', name, {
			sequences: config.sequence ? [name] : [],
			shortcuts: config.trigger ? [makeTrigger(config.trigger, true)] : [],
			label: config.help
		});
	}
}


function makeLATool (ext) {
	var la = [{
		type: 'mwTransclusion',
		attributes: {
			mw: {
				parts: [{
					template: {
						target: {
							href: 'Vorlage:Löschantrag',
							wt: 'subst:Löschantrag'
						},
						params: {
							1: {
								wt: '\'\'Grund\'\' --~~~~'
							}
						}
					}
				}]
			}
		}
	}];
	if (ext) {
		makeInsertTool({insert: la, title: 'Löschantrag', help: 'LA-Vorlage', sequence: '{LA}', icon: 'tag', trigger: 'ctrl+shift+l', openDialog: true});
	} else {
		makeInsertTool({insert: la, title: 'Löschantrag'});
	}
}

function makeBRTool () {
	makeInsertTool({insert: [{type: 'break'}, {type: '/break'}], title: 'Zeilenumbruch', help: 'Zeilenumbruch', icon: 'newline'});
}

mw.loader.using('ext.visualEditor.desktopArticleTarget.init').done(function () {
	enableSignEverywhere();
	mw.libs.ve.addPlugin(function () {
		return mw.loader.using(['ext.visualEditor.core', 'ext.visualEditor.mwtransclusion'])
			.done(function () {
				makeSmallTool();
				makeBRTool();
				makeLATool(true);
			});
	});
});
