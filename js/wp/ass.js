(function () {
/*
 userjs.schnark-assistant.action.
 view
 diff
 edit.start
 edit.editing
 edit.idle
 edit.presave
 edit.preview
 edit.diff
 edit.saved
*/

function fire (name, data) {
	mw.hook('userjs.schnark-assistant.action.' + name).fire(data);
}

function getData (hook) {
	switch (hook) {
	case 'view': return $('#mw-content-text');
	case 'diff': return $('#diff');
	//FIXME
	}
}

function run () {
	//FIXME
	fire(hook, getData(hook));
}

$(run);

})();

/*
 userjs.schnark-assistant.show.
 animation
 tip
 once
 auto
*/