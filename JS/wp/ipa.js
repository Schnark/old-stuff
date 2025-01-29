var ipaToOggMap = {
//sollte *alle* Laute, inklusive Laute mit folgendem Längenzeichen, Vokale mit vorangestelltem Betonungszeichen, und ganze Silben enthalten, wobei nie ein Teilstring vor einem längerem Schlüssel stehen darf, die Audiodatei soll nur den Laut enthalten, sonst nichts, auch keine Pausen

	'a': 'Open front unrounded vowel.ogg',
	'ɐ': 'Near-open central unrounded vowel.ogg',
	'ɑ': 'Open back unrounded vowel.ogg',
	'ɒ': 'Open back rounded vowel.ogg',
	'æ': 'Near-open front unrounded vowel.ogg',
	'b': 'Voiced bilabial plosive.ogg',
	'ɓ': 'Voiced bilabial implosive.ogg',
	'ʙ': 'Bilabial trill.ogg',
	'β': 'Voiced bilabial fricative.ogg',
	'c': 'Voiceless palatal plosive.ogg',
	'ç': 'Voiceless palatal fricative.ogg',
	'ɕ': 'Voiceless alveolo-palatal sibilant.ogg',
	'd͡z': 'Voiced alveolar affricate.ogg',
	'd͡ʒ': 'Voiced palato-alveolar affricate.ogg',
	'd̠͡ʑ': 'Voiced alveolo-palatal affricate.ogg',
	'ɖ͡ʐ': 'Voiced retroflex affricate.ogg',
	'd': 'Voiced alveolar plosive.ogg',
	'ɗ': 'Voiced alveolar implosive.ogg',
	'ɖ': 'Voiced retroflex stop.oga',
	'ð': 'Voiced dental fricative.ogg',
	'e': 'Close-mid front unrounded vowel.ogg',
	'ə': 'Schwa.ogg',
	'ɘ': 'Close-mid central unrounded vowel.ogg',
	'ɛ': 'Open-mid front unrounded vowel.ogg',
	'ɜ': 'Open-mid central unrounded vowel.ogg',
	'f': 'Voiceless labiodental fricative.ogg',
	'ɡ': 'Voiced velar plosive.ogg',
	'ɠ': 'Voiced velar implosive.ogg',
	'ɢ': 'Voiced uvular stop.oga',
	'ʛ': 'Voiced uvular implosive.ogg',
	'ɣ': 'Voiced velar fricative.ogg',
	'ɤ': 'Close-mid back unrounded vowel.ogg',
	'h': 'Voiceless glottal fricative.ogg',
	'ħ': 'Voiceless pharyngeal fricative.ogg',
	'ɦ': 'Voiced glottal fricative.ogg',
	'ɧ': 'Voiceless dorso-palatal velar fricative.ogg',
	'ʜ': 'Voiceless epiglottal fricative.ogg',
	'ɥ': 'Labial-palatal approximant.ogg',
	'i': 'Close front unrounded vowel.ogg',
	'ɨ': 'Close central unrounded vowel.ogg',
	'ɪ': 'Near-close near-front unrounded vowel.ogg',
	'j': 'Palatal approximant.ogg',
	'ʝ': 'Voiced palatal fricative.ogg',
	'ɟ': 'Voiced palatal plosive.ogg',
	'ʄ': 'Voiced palatal implosive.ogg',
	'k': 'Voiceless velar plosive.ogg',
	'l': 'Alveolar lateral approximant.ogg',
	'ɫ': 'Velarized alveolar lateral approximant.ogg',
	'ɬ': 'Voiceless lateral fricative.ogg',
	'ɭ': 'Retroflex lateral approximant.ogg',
	'ʟ': 'Velar lateral approximant.ogg',
	'ɮ': 'Voiced lateral fricative.ogg',
	'm': 'Bilabial nasal.ogg',
	'ɱ': 'Labiodental nasal.ogg',
	'ɯ': 'Close back unrounded vowel.ogg',
	'ɰ': 'Voiced velar approximant.ogg',
	'n': 'Alveolar nasal.ogg',
	'ɲ': 'Palatal nasal.ogg',
	'ŋ': 'Velar nasal.ogg',
	'ɳ': 'Retroflex nasal.ogg',
	'ɴ': 'Uvular nasal.ogg',
	'o': 'Close-mid back rounded vowel.ogg',
	'ɵ': 'Close-mid central rounded vowel.ogg',
	'ø': 'Close-mid front rounded vowel.ogg',
	'ɞ': 'Open-mid central rounded vowel.ogg',
	'œ': 'Open-mid front rounded vowel.ogg',
	'ɶ': 'Open front rounded vowel.ogg',
	'ʊ': 'Near-close near-back rounded vowel.ogg',
	'p': 'Voiceless bilabial plosive.ogg',
	'ɸ': 'Voiceless bilabial fricative.ogg',
	'q': 'Voiceless uvular plosive.ogg',
	'r': 'Alveolar trill.ogg',
	'ɾ': 'Alveolar tap.ogg',
	'ɺ': 'Alveolar lateral flap.ogg',
	'ɽ': 'Retroflex flap.ogg',
	'ɹ': 'Alveolar approximant.ogg',
	'ɻ': 'Retroflex approximant.ogg',
	'ʀ': 'Uvular trill.ogg',
	'ʁ': 'Voiced uvular fricative.ogg',
	's': 'Voiceless alveolar sibilant.ogg',
	'ʂ': 'Voiceless retroflex sibilant.ogg',
	'ʃ': 'Voiceless palato-alveolar sibilant.ogg',
	't͡s': 'Voiceless alveolar sibilant affricate.oga',
	't͡ʃ': 'Voiceless palato-alveolar affricate.ogg',
	't̠͡ɕ': 'Voiceless alveolo-palatal affricate.ogg',
	'ʈ͡ʂ': 'Voiceless retroflex affricate.ogg',
	't': 'Voiceless alveolar plosive.ogg',
	'ʈ': 'Voiceless retroflex stop.oga',
	'θ': 'Voiceless dental fricative.ogg',
	'u': 'Close back rounded vowel.ogg',
	'ʉ': 'Close central rounded vowel.ogg',
	'v': 'Voiced labiodental fricative.ogg',
	'ʋ': 'Labiodental approximant.ogg',
	'ѵ': 'Labiodental flap.ogg',
	'ʌ': 'Open-mid back unrounded vowel.ogg',
	'w': 'Voiced labio-velar approximant.ogg',
	'ʍ': 'Voiceless labio-velar fricative.ogg',
	'x': 'Voiceless velar fricative.ogg',
	'χ': 'Voiceless uvular fricative.ogg',
	'y': 'Close front rounded vowel.ogg',
	'ʏ': 'Near-close near-front rounded vowel.ogg',
	'ʎ': 'Palatal lateral approximant.ogg',
	'z': 'Voiced alveolar sibilant.ogg',
	'ʑ': 'Voiced alveolo-palatal sibilant.ogg',
	'ʐ': 'Voiced retroflex sibilant.ogg',
	'ʒ': 'Voiced palato-alveolar sibilant.ogg',
	'ʔ': 'Glottal stop.ogg',
	'ʡ': 'Voiceless epiglottal plosive.ogg',
	'ʕ': 'Voiced pharyngeal fricative.ogg',
	'ʢ': 'Voiced epiglottal fricative.ogg',
	'ǀ': 'Dental click.ogg',
	'ǂ': 'Palatoalveolar click.ogg',
	'ǁ': 'Alveolar lateral click.ogg',
	'ǃ': 'Postalveolar click.ogg',

	'': false
};

function filenameToUrl (file) {
	//return 'file:///media/USBDRIVE/' + file.replace(/ /g, '_');
	return mw.util.getUrl('Special:Filepath/' + file);
}

function fixStress (ipa) {
	var stress = 'ˈ', vowls = 'aɐɑɒæʌeəɘɛɜiĩɨɪɯoõɵøɞœɶɔɤʊʘuũʉʊyʏɥ', i;
	if (ipa.charAt(0) === 'ˌ') {
		return stress + ipa.substr(1);
	}
	if (ipa.charAt(0) === stress) {
		i = 1;
		while (i < ipa.length) {
			if (ipa.charAt(i) === ' ') {
				return false;
			}
			if (vowls.indexOf(ipa.charAt(i)) !== -1) {
				return ipa.substr(1, i - 1) + stress + ipa.substr(i);
			}
			i++;
		}
		return false;
	}
	return false;
}

function ipaToOgg (ipa) {
	var ogg = [], key, ret;
	whileLoop: while (ipa !== '') {
		for (key in ipaToOggMap) {
			if (key !== '' && ipa.indexOf(key) === 0) {
				if (ipaToOggMap[key]) {
					ogg.push(filenameToUrl(ipaToOggMap[key]));
				}
				ipa = ipa.substr(key.length);
				continue whileLoop;
			}
		}
		ret = fixStress(ipa);
		if (ret) {
			ipa = ret;
			continue whileLoop;
		}
		ogg.push(ipaToOggMap['']);
		ipa = ipa.substr(1);
	}
	return ogg;
}

function makeAudio (url, canPlay, end) {
	var audio = document.createElement('audio');
	audio.oncanplaythrough = canPlay;
	audio.onended = end;
	audio.src = url;
	return audio;
}

function play (ogg, callback) {
	var i, loaded = 0, audio = [];

	callback = callback || function () {};

	function onload () {
		loaded++;
		if (loaded === ogg.length) {
			audio[0].play();
		}
	}

	function next (j) {
		return j === ogg.length ? callback : function () {
			audio[j].play();
		};
	}

	for (i = 0; i < ogg.length; i++) {
		audio.push(makeAudio(ogg[i], onload, next(i + 1)));
	}
}

function playIPA (ipa) {
	play(ipaToOgg(ipa));
}

playIPA('mɪxaəl');