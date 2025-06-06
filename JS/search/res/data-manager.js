/*global dataManager: true*/
/*global l10n*/
dataManager =
(function () {
"use strict";

function getDefaultData () {
	return l10n.getDefaultSearchEngines();
}

function getData () {
	//TODO
	return getDefaultData();
}

function setData (data) {
	//TODO
	console.log(data);
}

return {
	get: getData,
	set: setData
};

})();