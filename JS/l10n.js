/**
 * Transform a message to the corresponding qqx message.
 *
 * @private
 * @param {string} key Message key
 * @param {string} msg Message (usually English)
 * @return {string} Message transformed to qqx.
 */
function getQqx( key, msg ) {
	var parameters, max, paramlist, i;
	parameters = msg.match( /\$\d+/g );
	if ( parameters ) {
		max = Math.max.apply( Math, $.map( parameters, function ( param ) {
			// remove the leading '$'
			return param.slice( 1 );
		} ) );
	} else {
		max = 0;
	}
	if ( max === 0 ) {
		paramlist = '';
	} else {
		paramlist = [];
		for ( i = 1; i <= max; i++ ) {
			paramlist.push( i );
		}
		paramlist = ': $' + paramlist.join( ', $' );
	}
	return '(' + key + paramlist + ')';
}

/**
 * Transform an object of messages to the corresponding qqx messages.
 *
 * @private
 * @param {Object} messages Messages (usually English) to derive qqx messages from
 * @return {Object} Object with same keys, but messages transformed to qqx.
 */
function transformToQqx( messages ) {
	var result, key;
	result = {};
	for ( key in messages ) {
		if ( messages.hasOwnProperty( key ) ) {
			result[ key ] = getQqx( key, messages[ key ] );
		}
	}
	return result;
}

/**
 * Set localized messages based on the current UI language,
 * using the language fallback chain.
 *
 * This function is meant to be used from user scripts etc.
 * If you are able to register a proper ResourceLoader module,
 * then use it's mechanism to load all required messages.
 *
 *     @example
 *
 *     // Let's assume the wiki changed the 'pagetitle' message to 'MyWiki: $1',
 *     // and some ResourceLoader module loaded this message:
 *     mw.messages.set( 'pagetitle', 'MyWiki: $1' );
 *     // Now add your localizations
 *     mw.language.addLocalizations( {
 *         en: {
 *             'pagetitle': '$1 - {{SITENAME}}',
 *             'questionmark': '?',
 *             'my-cool-message': 'My cool message!'
 *         },
 *         de: {
 *             'pagetitle': '$1 – {{SITENAME}}', // note the en dash
 *             'my-cool-message': 'Meine heiße Nachricht!'
 *         }
 *     } );
 *     // If the current UI language is 'pfl' (or any other language, that falls back -> 'de' -> 'en'),
 *     // the result is:
 *     console.log( mw.messages.get( 'pagetitle' ) ); // 'MyWiki: $1'
 *     console.log( mw.messages.get( 'questionmark' ) ); // '?'
 *     console.log( mw.messages.get( 'my-cool-message' ) ); // 'Meine heiße Nachricht!'
 *
 * @param {Object} l10n Object with localizations.
 *  The keys must be language codes (in lower case), the values objects with messages for this language.
 *  These objects have message names as keys and the messages as values.
 * @param {boolean} [override=false] Whether to override messages that already existed.
 */
addLocalizations: function ( l10n, override ) {
	var origMsg, chain, i, lang;
	if ( !override ) {
		// .get() returns all messages, but by reference.
		// $.extend() is an easy way to get a copy of an object.
		origMsg = $.extend( {}, mw.messages.get() );
	}
	if ( mw.config.get( 'wgUserLanguage' ) === 'qqx' ) {
		mw.messages.set( transformToQqx( l10n.en ) );
	} else {
		chain = mw.language.getFallbackLanguageChain();
		for ( i = chain.length - 1; i >= 0; i-- ) {
			lang = chain[ i ].toLowerCase();
			if ( lang in l10n ) {
				mw.messages.set( l10n[ lang ] );
			}
		}
	}
	if ( !override ) {
		mw.messages.set( origMsg );
	}
}

	QUnit.module( 'mediawiki.language', QUnit.newMwEnvironment( {
		setup: function () {
			this.liveLangData = mw.language.data.values;
			this.liveMessages = mw.messages.values;
			mw.language.data.values = $.extend( true, {}, this.liveLangData );
			mw.messages.values = $.extend( true, {}, this.liveMessages );
		},
		teardown: function () {
			mw.language.data.values = this.liveLangData;
			mw.messages.values = this.liveMessages;
		}
	} ) );


QUnit.test( 'mw.language.addLocalizations test', 3, function ( assert ) {
	var l10n, keys, wgUserLanguage;
	l10n = {
		en: {
			'pagetitle': '$1 - {{SITENAME}}',
			'questionmark': '?',
			'my-cool-message': 'My cool message! ($3, $2 = $2)'
		},
		de: {
			'pagetitle': '$1 – {{SITENAME}}',
			'my-cool-message': 'Meine heiße Nachricht! ($3, $2 = $2)'
		}
	};
	keys = ['pagetitle', 'questionmark', 'my-cool-message'];
	wgUserLanguage = mw.config.get( 'wgUserLanguage' );

	mw.config.set( 'wgUserLanguage', 'pfl' );
	mw.language.setData( 'pfl', 'fallbackLanguages', ['de', 'en'] );
	mw.messages.set( 'pagetitle', 'MyWiki: $1' );

	mw.language.addLocalizations( l10n );
	assert.deepEqual( mw.messages.get( keys ), {
		'pagetitle': 'MyWiki: $1',
		'questionmark': '?',
		'my-cool-message': 'Meine heiße Nachricht! ($3, $2 = $2)'
	}, 'Localizations for pfl' );

	mw.language.addLocalizations( l10n, true );
	assert.deepEqual( mw.messages.get( keys ), {
		'pagetitle': '$1 – {{SITENAME}}',
		'questionmark': '?',
		'my-cool-message': 'Meine heiße Nachricht! ($3, $2 = $2)'
	}, 'Localizations for pfl with overriding' );

	mw.config.set( 'wgUserLanguage', 'qqx' );
	mw.language.addLocalizations( l10n, true );
	assert.deepEqual( mw.messages.get( keys ), {
		'pagetitle': '(pagetitle: $1)',
		'questionmark': '(questionmark)',
		'my-cool-message': '(my-cool-message: $1, $2, $3)'
	}, 'Localizations for qqx' );

	mw.config.set( 'wgUserLanguage', wgUserLanguage );
} );