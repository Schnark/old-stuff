(new JSBot({max: 1000, list: ['Category:']}))
.categorytree()
.categorymembers()
.getProps(['langlinks'])
.addProps(function (t, p) {
	var ll = p.langlinks || [], i;
	for (i = 0; i < ll.length; i++) {
		if (ll[i].lang === 'de') {
			return {de: ll[i]['*']};
		}
	}
	return {de: null};
})
.map(function (t, p) {
	return p.de;
})
.alert('#', botlog);

(new JSBot({max: 1000, list: ['Category:']))
.categorytree()
.categorymembers()
.getProps(['langlinks'])
.addProps(function (t, p) {
	var ll = p.langlinks || [], i;
	for (i = 0; i < ll.length; i++) {
		if (ll[i].lang === 'de') {
			return {de: ll[i]['*']};
		}
	}
	return {de: null};
})
.filter(function (t, p) {
	return !p.de;
})
.alert('#', botlog);