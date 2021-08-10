/*
How to use:
1. Scan and decode the QR code.
2. Call parseQRData with the string from the QR code.
3. Validate the signature:
   a) The parameters are in result.signatureData.params.
      (The key 1 is the algorithm, value -7 is ES256; the key 4 is the key identifier,
      which tells you which signature key to use.)
   b) The signed message is in result.signatureData.msg. (I'm not sure whether this is correct.)
   c) The signature is in result.signatureData.signature.
4. Examine the certificate:
   a) The raw data is in result.content.
   b) The parsed data is in result.parsed.
      i) There are result.parsed.issuer (country code),
         result.parsed.issuingDate, and result.parsed.expiringDate (both Date objects).
      ii) The owner is in result.parsed.owner, with subproperties dateOfBirth (YYYY-MM-DD, or shorter)
          and name, an object with properties gn (given name) and fn (family name),
          as well as gnt and fnt (converted to uppercase ASCII).
      iii) The certificate is result.parsed.certificate, with subproperties depending on the type.
The code relies on the pako library.
*/

function base45decode (str) {
	var result = [];

	function getVal (c) {
		if ('0' <= c && c <= '9') {
			return Number(c);
		}
		if ('A' <= c && c <= 'Z') {
			return c.charCodeAt(0) - 'A'.charCodeAt(0) + 10;
		}
		c = [' ', '$', '%', '*', '+', '-', '.', '/', ':'].indexOf(c);
		if (c === -1) {
			throw new Error('Invalid character');
		}
		return c + 36;
	}

	function readChars (n) {
		var i, c = 0, f = 1;
		if (n === 1) {
			throw new Error('Invalid length');
		}
		for (i = 0; i < n; i++) {
			c += getVal(str.charAt(0)) * f;
			f *= 45;
			str = str.slice(1);
		}
		if (n === 2) {
			if (c >= 256) {
				throw new Error('Invalid encoding');
			}
			result.push(c);
		} else {
			if (c >= 256 * 256) {
				throw new Error('Invalid encoding');
			}
			result.push(Math.floor(c / 256), c % 256);
		}
	}

	while (str.length > 0) {
		readChars(Math.min(3, str.length));
	}
	return result;
}

function uncompress (data) {
	return [].slice.call(pako.inflate(data));
}

function decodeCBOR (data) {
	var pos = 0, item;

	function take (n) {
		var result;
		if (pos + n > data.length) {
			throw new Error('Invalid');
		}
		result = data.slice(pos, pos + n);
		pos += n;
		return result;
	}

	function toInt (a) {
		var i = 0;
		while (a.length > 0) {
			i = i * 256 + a.shift();
		}
		return i;
	}

	function getItem () {
		var ib, mt, ai, val, result, i, key;
		ib = toInt(take(1));
		mt = ib >> 5;
		ai = ib & 0x1f;
		val = ai;
		switch (ai) {
		case 24:
			val = toInt(take(1));
			break;
		case 25:
			val = toInt(take(2));
			break;
		case 26:
			val = toInt(take(4));
			break;
		case 27:
			val = toInt(take(8));
			break;
		case 28:
		case 29:
		case 30:
			throw new Error('Invalid');
		case 31:
			throw new Error('not implemented');
		}
		switch (mt) {
		case 0: return val;
		case 1: return -1 - val;
		case 2: return take(val);
		case 3: return (new TextDecoder()).decode(take(val));
		case 4:
			result = [];
			for (i = 0; i < val; i++) {
				result.push(getItem());
			}
			return result;
		case 5:
			result = {};
			for (i = 0; i < val; i++) {
				key = getItem();
				if (key in result) {
					throw new Error('Duplicate key');
				}
				result[key] = getItem();
			}
			return result;
		case 6:
			return {
				tag: val,
				content: getItem()
			};
		case 7:
			if (val === 20) {
				return false;
			}
			if (val === 21) {
				return true;
			}
			if (val === 22) {
				return null;
			}
			if (val === 23) {
				return undefined;
			}
			throw new Error('unimplemented');
		}
	}

	item = getItem();
	if (pos !== data.length) {
		throw new Error('too much data');
	}
	return item;
}

function manageCOSE (obj) {
	if (obj.tag !== 18) {
		throw new Error('not signed');
	}

	function merge (a, b) {
		var result = {};
		Object.keys(b).forEach(function (key) {
			result[key] = b[key];
		});
		Object.keys(a).forEach(function (key) {
			result[key] = a[key];
		});
		return result;
	}

	function bstr (data) {
		var l = data.length;
		data = data.slice();
		if (l < 24) {
			data.unshift(64 + l);
		} else if (l < 256) {
			data.unshift(64 + 24, l);
		} else if (l < 265 * 265) {
			data.unshift(64 + 25, Math.floor(l / 265), l % 256);
		} else {
			throw new Error('not implemented');
		}
		return data;
	}

	return {
		signatureData: {
			params: merge(decodeCBOR(obj.content[0]), obj.content[1]),
			//FIXME is this correct?
			msg: [132, 106, 83, 105, 103, 110, 97, 116, 117, 114, 101, 49].concat(bstr(obj.content[0]), bstr([]), bstr(obj.content[2])),
			//      [    "   S    i    g    n   a    t    u    r    e   1
			signature: obj.content[3]
		},
		content: decodeCBOR(obj.content[2])
	};
}

function translateValue (val, type) {
	var data = {
		target: {
			840539006: 'COVID-19'
		},
		vaccineType: {
			1119305005: 'antigen',
			1119349007: 'mRNA',
			J07BX03: 'other'
		},
		vaccineProduct: {
			'EU/1/20/1526': 'Comirnaty',
			'EU/1/20/1507': 'Spikevax',
			'EU/1/21/1529': 'Vaxzevria',
			'EU/1/20/1525': 'COVID-19 Vaccine Janssen'
		},
		vaccineManufacturer: {
			'ORG-100001699': 'AstraZeneca',
			'ORG-100030215': 'Biontech',
			'ORG-100001417': 'Janssen-Cilag',
			'ORG-100031184': 'Moderna'
		},
		testType: {
			'LP6464-4': 'NAAT',
			'LP217198-3': 'RAT'
		},
		testDevice: {},
		testResult: {
			260415000: 'not detected'
		}
	};
	return data[type][val] || ('unknown (' + val + ')');
}

function parseCertificate (certificate, type) {
	var data = {};
	data.type = type;
	data.id = certificate.ci;
	data.country = certificate.co;
	data.issuer = certificate.is;
	data.target = translateValue(certificate.tg, 'target');
	if (type === 'vaccination') {
		data.vaccineType = translateValue(certificate.vp, 'vaccineType');
		data.vaccineProduct = translateValue(certificate.mp, 'vaccineProduct');
		data.vaccineManufacturer = translateValue(certificate.ma, 'vaccineManufacturer');
		data.sequenceNumber = certificate.dn;
		data.totalNumber = certificate.sd;
		data.vaccinationDate = certificate.dt;
	} else if (type === 'test') {
		data.testType = translateValue(certificate.tt, 'testType');
		data.testName = certificate.nm;
		data.testDevice = translateValue(certificate.na, 'testDevice');
		data.testDate = certificate.sc;
		data.testResult = translateValue(certificate.tr, 'testResult');
		data.testFacility = certificate.tc;
	} else if (type === 'recovery') {
		data.positiveTestDate = certificate.fr;
		data.startDate = certificate.df;
		data.endDate = certificate.du;
	}
	return data;
}

function parseQRData (str) {
	var result, data;
	if (str.slice(0, 4) !== 'HC1:') {
		throw new Error('No health certificate');
	}
	result = manageCOSE(decodeCBOR(uncompress(base45decode(str.slice(4)))));
	result.parsed = {};
	if (result.content[1]) {
		result.parsed.issuer = result.content[1];
	}
	if (result.content[6]) {
		result.parsed.issuingDate = new Date(result.content[6] * 1000);
	}
	if (result.content[4]) {
		result.parsed.expiringDate = new Date(result.content[4] * 1000);
	}
	if (result.content[-260] && result.content[-260][1]) {
		data = result.content[-260][1];
		result.parsed.owner = {
			dateOfBirth: data.dob,
			name: data.nam
		};
		if (data.v && data.v[0]) {
			result.parsed.certificate = parseCertificate(data.v[0], 'vaccination');
		} else if (data.t && data.t[0]) {
			result.parsed.certificate = parseCertificate(data.t[0], 'test');
		} else if (data.r && data.r[0]) {
			result.parsed.certificate = parseCertificate(data.r[0], 'recovery');
		}
	}
	return result;
}