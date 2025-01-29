if (!Math.log10) {
	Math.log10 = function (x) {
		return Math.log(x) / Math.log(10);
	};
}
var conversionData = {
"Länge": {
	"Meter": 1,
	"Parsec": 3.0856776e16,
	"Lichtjahre": 9.460528e15,
	"AE": 1.49597870691e11,
	"Seemeilen": 1852,
	"Meilen": 1482,
	"Kilometer": 1000,
	"foot": 0.3048,
	"Zoll (inch)": 0.0254,
	"Zentimeter": 0.01,
	"Millimeter": 0.001,
	"Punkt": 0.000375
},
"Fläche": {
	"Quadratmeter": 1,
	"Quadratzentimeter": 0.0001
},
"Volumen": {
	"Kubikmeter": 1,
	"Barrel": 0.158987294928,
	"Kubikfuß": 0.028316846592,
	"Liter": 0.001,
	"Gallonen": 0.003785411784,
	"Pint": 0.000473176473
},
"Masse": {
	"Gramm": 1,
	"Kilogramm": 1000,
	"Tonnen": 1e6,
	"Milligramm": 0.001,
	"Doppelzentner": 100000,
	"Zentner": 50000,
	"Karat": 0.205,
	"Unzen": 28.349523125,
	"Pfund": 500
},
"Geschwindigkeit": {
	"Kilometer pro Stunde (km/h)": 1,
	"Meter pro Sekunde (m/s)": 3.6,
	"Knoten": 1.852,
	"Miles per hour (mph)": 1.609344
},
"Druck": {
	"Pascal": 1,
	"Bar": 1e5,
	"Technische Atmosphäre (at)": 9.8067e4,
	"Physikalische Atmosphäre (atm)": 1.0133e5,
	"Torr (mm Hg)": 1.3332e2
},
"Temperatur": {
	"Kelvin": [1, 0],
	"Celsius": [1, -273.15],
	"Fahrenheit": [0.5556, -459.67]
},
"Währungen (Wechselkurse August 2015)": {
	"Euro (€)": 1,
	"US-Dollar ($)": 0.869112,
	"Schweizer Franken": 1.08342,
	"Britische Pfund": 1.37174,
	"Yen": 0.00725479,
	"Deutsche Mark (DM)": 0.511292
}
};

function format (value) {
	var sign = '', exp = '', e, FORMAT = ['−', '·10<sup>', '</sup>', ','];
	if (isNaN(value) || value === 0) {
		return '0';
	}
	if (value < 0) {
		sign = FORMAT[0];
		value = -value;
	}
	e = Math.log10(value);
	e = Math.abs(e) >= 4 ? 3 * Math.round(e / 3) : 0;
	if (e) {
		exp = FORMAT[1] + (e < 0 ? FORMAT[0] + (-e) : e) + FORMAT[2];
		value = value / Math.pow(10, e);
	}
	value = Math.round(value * 10000) / 10000;
	return sign + String(value).replace(/\./, FORMAT[3]) + exp;
}

function convert (value, from, to) {
	if (Array.isArray(from)) {
		value = (value - from[1]) * from[0]
	} else {
		value = value * from;
	}
	if (Array.isArray(to)) {
		value = value / to[0] + to[1];
	} else {
		value = value / to;
	}
	return value;
}

function convertAll (data, value, unit) {
	var to, v, i, result = [];
	for (to in data) {
		if (to !== unit) {
			v = convert(value, data[unit], data[to]);
			result.push([format(v) + ' ' + to, Math.abs(Math.log10(Math.abs(v ? v : 1)))]);
		}
	}
	result.sort(function (a, b) {
		return a[1] - b[1];
	});
	for (i = 0; i < result.length; i++) {
		result[i] = result[i][0];
	}
	return result;
}

function makeSelect (data) {
	var html = '', key;
	function makeGroup (group, data) {
		var key;
		html += '<optgroup label="' + group + '">';
		for (key in data) {
			html += '<option value="' + group + '|' + key + '">' + key + '</option>';
		}
		html += '</optgroup>';
	}
	for (key in data) {
		makeGroup(key, data[key]);
	}
	return '<select id="unit" size="1">' + html + '</select>';
}

function onUpdate () {
	var val = Number(document.getElementById('value').value.replace(/\,/, '.')), unit = document.getElementById('unit'), html;
	unit = unit.options[unit.selectedIndex].value.split('|');
	if (isNaN(val) || val === 0) {
		html = '';
	} else {
		html = '<ul><li>' + convertAll(conversionData[unit[0]], val, unit[1]).join('</li><li>') + '</li></ul>';
	}
	document.getElementById('result').innerHTML = html;
}

function initHtml () {
	var html = '', val;
	html += '<input type="number" id="value" value="1" />';
	html += makeSelect(conversionData);
	html += '<p id="result"></p>';
	document.body.innerHTML = html;
	val = document.getElementById('value');
	val.oninput = onUpdate;
	val.onkeypress = onUpdate;
	document.getElementById('unit').onchange = onUpdate;
	onUpdate();
}

initHtml();