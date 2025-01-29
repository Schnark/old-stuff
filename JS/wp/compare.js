//<nowiki>
/*global mediaWiki*/
(function ($, mw) {
"use strict";

var cachedQueries = {}, bucketFunctions = {
	ns: function (data) {
		return data.ns;
	},
	hour: function (data) {
		return data.timestamp.slice(11, 13);
	},
	day: function (data) {
		return (new Date(data.timestamp)).getDay();
	},
	date: function (data) {
		return data.timestamp.slice(0, 10);
	},
	size: function (data) {
		return Math.floor(data.sizediff / 50);
	},
	top: function (data) {
		return data.top === '';
	},
	minor: function (data) {
		return data.minor === '';
	},
	hasComment: function (data) {
		if (!data.comment) {
			return 0;
		}
		if (/\s*\/\*.*\*\/\s*/.test(data.comment)) {
			return 1;
		}
		return 2;
	},
	commentLength: function (data) {
		return Math.floor(data.comment.length / 5);
	},
	title: function (data) {
		return data.title;
	}
};

function getContribsFromApi (user) {
	var d = $.Deferred();
	$.getJSON(mw.util.wikiScript('api'), {
		action: 'query',
		list: 'usercontribs',
		ucuser: user,
		uclimit: 'max',
		ucprop: 'title|timestamp|comment|sizediff|flags',
		//ucstart
		//ucend
		//continue: ''
		format: 'json'
	}).always(function (data) {
		if (data && data.query && data.query.usercontribs) {
			d.resolve(data.query.usercontribs);
		} else {
			d.resolve([]);
		}
	});
	return d.promise();
}

function getContribs (user) {
	if (!(user in cachedQueries)) {
		cachedQueries[user] = getContribsFromApi(user);
	}
	return cachedQueries[user];
}

function sortIntoBuckets (contribs, getBucket) {
	var buckets = {}, bucket, i;
	for (i = 0; i < contribs.length; i++) {
		bucket = getBucket(contribs[i]);
		buckets[bucket] = (buckets[bucket] || 0) + 1;
	}
	return buckets;
}

function compareBuckets (buckets1, buckets2) {
	var scalar = 0, norm1 = 0, norm2 = 0, bucket;
	for (bucket in buckets1) {
		norm1 += buckets1[bucket] * buckets1[bucket];
		if (bucket in buckets2) {
			scalar += buckets1[bucket] * buckets2[bucket];
		}
	}
	for (bucket in buckets2) {
		norm2 += buckets2[bucket] * buckets2[bucket];
	}
	return scalar / Math.sqrt(norm1 * norm2);
}

function compareUsers (user1, user2, getBucket) {
	var d = $.Deferred();
	getContribs(user1).done(function (contribs1) {
		getContribs(user2).done(function (contribs2) {
			d.resolve(compareBuckets(sortIntoBuckets(contribs1, getBucket), sortIntoBuckets(contribs2, getBucket)));
		});
	});
	return d.promise();
}

function runConsole (user1, user2, bucket) {
	compareUsers(user1, user2, bucketFunctions[bucket]).done(function (result) {
		console.log(user1 + ' vs. ' + user2 + ' (' + bucket + '): ' + result);
	});
}

window.compareUsersConsole = runConsole;

})(jQuery, mediaWiki);
//</nowiki>