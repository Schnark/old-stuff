//Dokumentation unter [[Benuzter:Schnark/js/map]] <nowiki>
/*global mediaWiki*/
(function ($, mw) {
"use strict";

var urls, getOpenLayerLibraryCache, getMultiMapDialogCache;

mw.messages.set({
	'schnark-map-title': 'Karte',
	'schnark-map-link': 'Karte',
	'schnark-map-tooltip': 'Zeigt eine interaktive Karte mit verschiedenen Funktionen an',
	'schnark-map-mapselect': 'Karte: ',
	'schnark-map-dataselect': 'Position: ',
	'schnark-map-keepview': 'Position beibehalten',
	'schnark-map-keepview-tooltip': 'Aktuelle Position bei Kartenwechsel übernehmen',
	'schnark-map-maps-name-wiwosm': 'OSM-Karte (über Labs)',
	'schnark-map-maps-name-wma': 'WikiMiniAtlas',
	'schnark-map-maps-name-karta': 'Karta',
	'schnark-map-maps-name-allcoords': 'Karte mit allen Koordinaten',
	'schnark-map-maps-name-osm': 'OSM-Karte',
	'schnark-map-maps-name-stamen': 'Künsterlische Karte',
	'schnark-map-maps-name-mapquest': 'Satellit',
	'schnark-map-maps-name-info': 'Informationen',
	'schnark-map-maps-name-debug': 'Debug-Angaben',
	'schnark-map-info-links': 'Links zu externen Karten:',
	'schnark-map-info-templates': 'Vorlagen für den Artikelgebrauch:',
	'schnark-map-data-name-main': 'Hauptkoordinate',
	'schnark-map-data-name-unnamed': '(unbekannte Koordinate)',
	'schnark-map-data-name-earth': 'Gesamtansicht',
	'schnark-map-data-name-geolocation': 'Eigener Standort'
});

urls = {
	openlayerjs: 'https://cors-anywhere.herokuapp.com/http://openlayers.org/en/v3.4.0/build/ol.js',
	openlayercss: 'https://cors-anywhere.herokuapp.com/http://openlayers.org/en/v3.4.0/css/ol.css',
	wiwosm: '//tools.wmflabs.org/wiwosm/osm-on-ol/kml-on-ol.php',
	wma: '//wma.wmflabs.org/iframe.html',
	karta: '//karta.wmflabs.org/static/',
	allcoords: '//tools.wmflabs.org/osm4wiki/cgi-bin/wiki/wiki-osm.pl'
};

function getOpenLayerLibrary () {
	if (!getOpenLayerLibraryCache) {
		getOpenLayerLibraryCache = $.Deferred();
		$.get(urls.openlayercss).done(function (css) {
			mw.util.addCSS(css);
			$.get(urls.openlayerjs).done(function (script) {
				$.globalEval(script);
				getOpenLayerLibraryCache.resolve(window.ol);
			});
		});
	}
	return getOpenLayerLibraryCache.promise();
}

function rToZoom (r) {
	return Math.round(Math.log(4.4e7 / r) / Math.log(2));
}

function zoomToR(zoom) {
	return Math.round(4.4e7 / Math.pow(2, zoom));
}

function getGISMaps (OO, features, specials) {

	function GISMap ($div, data) {
		this.$div = $div;
		this.data = $.extend({}, data);
		this.init();
		this.visible = true;
		this.reallyShow();
	}
	GISMap.static = {
		features: [],
		special: false
	};
	GISMap.prototype = {
		init: function () {
			throw 'abstract';
		},
		resize: function () {
		},
		canGetData: function () {
			return false;
		},
		getData: function () {
			throw 'abstract';
		},
		updateData: function (data) {
			$.extend(this.data, data);
			this.reallyUpdateData();
		},
		reallyUpdateData: function () {
			throw 'abstract';
		},
		hide: function () {
			if (!this.visible) {
				return;
			}
			this.$div.empty();
			this.visible = false;
		},
		show: function () {
			if (this.visible) {
				return;
			}
			this.reallyShow();
			this.visible = true;
		},
		reallyShow: function () {
			throw 'abstract';
		},
		destroy: function () {
			this.hide();
		}
	};

	function GISMapHtml () {
		GISMapHtml.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapHtml, GISMap);
	$.extend(GISMapHtml.prototype, {
		init: function () {
			this.$innerDiv = $('<div>');
			this.reallyUpdateData();
		},
		reallyUpdateData: function () {
			this.$innerDiv.html(this.generateHtml());
		},
		reallyShow: function () {
			this.$div.append(this.$innerDiv);
		},
		generateHtml: function () {
			throw 'abstract';
		}
	});

	function GISMapHtmlDebug () {
		GISMapHtmlDebug.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapHtmlDebug, GISMapHtml);
	$.extend(GISMapHtmlDebug.prototype, {
		canGetData: function () {
			return true;
		},
		getData: function () {
			return {
				lat: $('#schnark-map-debug-lat').val(),
				long: $('#schnark-map-debug-long').val(),
				zoom: $('#schnark-map-debug-zoom').val()
			};
		},
		makeInput: function (label, id, data) {
			return mw.html.element('label', {'for': id}, label) + mw.html.element('input', {id: id, value: data}) + mw.html.element('br');
		},
		generateHtml: function () {
			return this.makeInput('Lat: ', 'schnark-map-debug-lat', this.data.lat) +
				this.makeInput('Long: ', 'schnark-map-debug-long', this.data.long) +
				this.makeInput('Zoom: ', 'schnark-map-debug-zoom', this.data.zoom);
		}
	});
	$.extend(GISMapHtmlDebug.static, {
		special: 'debug'
	});

	function GISMapHtmlInfo () {
		GISMapHtmlInfo.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapHtmlInfo, GISMapHtml);
	$.extend(GISMapHtmlInfo.prototype, {
		replace: function (template) {
			return template
				.replace(/\$lat/g, this.data.lat).replace(/\$LAT/g, Math.abs(this.data.lat))
				.replace(/\$long/g, this.data.long).replace(/\$LONG/g, Math.abs(this.data.long))
				.replace(/\$ns/g, this.data.lat > 0 ? 'N' : 'S').replace(/\$we/g, this.data.long > 0 ? 'E' : 'W')
				.replace(/\$zoom/g, this.data.zoom).replace(/\$dim/g, zoomToR(this.data.zoom))
				.replace(/\$page/g, this.data.wikiTitle.replace(/ /g, '_')).replace(/\$lang/g, this.data.lang);
		},
		getLinks: function () {
			return [
				this.replace('//tools.wmflabs.org/geohack/geohack.php?pagename=$page&language=$lang&params=$LAT_$ns_$LONG_$we&dim=$dim GeoHack'),
				this.replace('http://openstreetmap.org/?lat=$lat&lon=$long&zoom=$zoom OpenStreetMap'),
				this.replace('http://opentopomap.org/#map=$zoom/$lat/$long OpenTopoMap'),
				this.replace('//maps.google.com/maps?ll=$lat,$long&z=$zoom&t=m&q=$lat,$lon Google Maps (Karte)'),
				this.replace('//maps.google.com/maps?ll=$lat,$long&z=$zoom&t=h&q=$lat,$lon Google Maps (Satellit)'),
				this.replace('http://www.bing.com/maps/default.aspx?v=2&cp=$lat~$long&style=h&lvl=$zoom Bing Maps (Satellit)')
			];
		},
		getTemplates: function () {
			return [
				this.replace('{{Coordinate|NS=$lat|EW=$long|type=|region=}}'),
				this.replace('{{Coordinate|NS=$lat|EW=$long|type=|region=|text=|name=}}'),
				this.replace('|lat        = $lat\n|long       = $long')
			];
		},
		generateHtml: function () {
			var html = '', links = this.getLinks(), templates = this.getTemplates();
			if (links.length) {
				html += mw.html.element('b', {}, mw.msg('schnark-map-info-links')) + mw.html.element('ul', {}, new mw.html.Raw(
					$.map(links, function (val) {
						var pos = val.indexOf(' ');
						return mw.html.element('li', {}, new mw.html.Raw(mw.html.element('a', {href: val.slice(0, pos), target: '_blank'}, val.slice(pos + 1))));
					}).join('')
				));
			}
			if (templates.length) {
				html += mw.html.element('b', {}, mw.msg('schnark-map-info-templates')) + mw.html.element('ul', {}, new mw.html.Raw(
					$.map(templates, function (t) {
						return mw.html.element('li', {}, new mw.html.Raw(
							mw.html.element('code', {}, new mw.html.Raw(
								mw.html.escape(t).replace(/\n/g, '<br>')
							))
						));
					}).join('')
				));
			}
			return html;
		}
	});

	function GISMapIframe () {
		GISMapIframe.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapIframe, GISMap);
	$.extend(GISMapIframe.prototype, {
		init: function () {
			this.$iframe = $('<iframe>').css({
				width: '100%', height: '100%',
				border: 'none'
			});
			this.reallyUpdateData();
		},
		buildUrl: function () {
			throw 'abstract';
		},
		reallyUpdateData: function () {
			this.$iframe.attr('src', this.buildUrl());
		},
		reallyShow: function () {
			this.$div.append(this.$iframe);
		},
		destroy: function () {
			GISMapIframe.parent.prototype.destroy.apply(this, arguments);
			this.$iframe.remove();
			this.$iframe = undefined;
		}
	});

	function GISMapIframeWiwosm () {
		GISMapIframeWiwosm.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapIframeWiwosm, GISMapIframe);
	$.extend(GISMapIframeWiwosm.prototype, {
		buildUrl: function () {
			var params = {
				params: Math.abs(this.data.lat) + '_' + (this.data.lat < 0 ? 'S' : 'N') +
					'_' + Math.abs(this.data.long) + '_' + (this.data.long < 0 ? 'W' : 'E') +
					'_dim:' + zoomToR(this.data.zoom) + 'm',
				lang: this.data.lang,
				uselang: this.data.uselang
			};
			if (this.data.wikiTitle) {
				params.title = this.data.wikiTitle;
			}
			return urls.wiwosm + '?' + $.param(params);
		}
	});

	function GISMapIframeWMA () {
		GISMapIframeWMA.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapIframeWMA, GISMapIframe);
	$.extend(GISMapIframeWMA.prototype, {
		buildUrl: function () {
			var params = {
				wma: this.data.lat + '_' + this.data.lon + '_600_400_' + this.data.lang + '_' + this.data.zoom + '_' + this.data.uselang,
				globe: 'Earth',
				lang: this.data.lang,
				awt: 0 //FIXME
			};
			if (this.data.globe) {
				params.globe = this.data.globe;
			}
			if (this.data.wikiTitle) {
				params.page = this.data.wikiTitle;
			}
			return urls.wma + '?' + $.param(params);
		}
	});
	$.extend(GISMapIframeWMA.static, {
		features: ['globe']
	});

	function GISMapIframeKarta () {
		GISMapIframeWMA.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapIframeKarta, GISMapIframe);
	$.extend(GISMapIframeKarta.prototype, {
		buildUrl: function () {
			return urls.karta + '#' + this.data.zoom + '/' + this.data.lat + '/' + this.data.long;
		}
	});

	function GISMapIframeAllCoords () {
		GISMapIframeAllCoords.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapIframeAllCoords, GISMapIframe);
	$.extend(GISMapIframeAllCoords.prototype, {
		buildUrl: function () {
			var params = {
				project: this.data.lang,
				article: this.data.wikiTitle
			};
			if (this.data.linksfrom) {
				params.linksfrom = 1;
			}
			if (this.data.section) {
				params.section = this.data.section;
			}
			if (this.data.category) {
				params.l = 0;
				params.article = mw.config.get('wgFormattedNamespaces')[14] + ':' + this.data.wikiTitle;
			}
			return urls.allcoords + '?' + $.param(params);
		}
	});
	$.extend(GISMapIframeAllCoords.static, {
		special: 'allcoords'
	});

	function GISMapOpenLayer () {
		GISMapOpenLayer.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapOpenLayer, GISMap);
	$.extend(GISMapOpenLayer.prototype, {
		init: function () {
			var that = this;
			this.$map = $('<div>');
			this.reallyShow(); //FIXME
			getOpenLayerLibrary().done(function (ol) {
				that.ol = ol;
				that.olMap = new ol.Map({
					layers: that.getLayers(ol),
					loadTilesWhileInteracting: true,
					target: that.$map[0],
					view: that.getView()
				});
			});
		},
		getLayers: function (/*ol*/) {
			throw 'abstract';
		},
		getView: function () {
			return new this.ol.View({
				center: this.ol.proj.transform(
					[this.data.long, this.data.lat],
					'EPSG:4326',
					'EPSG:3857'
				),
				zoom: this.data.zoom
			});
		},
		resize: function () {
			if (!this.olMap) {
				return;
			}
			this.olMap.updateSize();
		},
		canGetData: function () {
			return true;
		},
		getData: function () {
			if (!this.olMap) {
				return this.data;
			}
			var view, center;
			view = this.olMap.getView();
			center = this.ol.proj.transform(
				view.getCenter(),
				'EPSG:3857',
				'EPSG:4326'
			);
			return {
				lat: center[1], long: center[0],
				zoom: view.getZoom()
			};
		},
		reallyUpdateData: function () {
			if (this.olMap) {
				this.olMap.setView(this.getView());
			}
		},
		reallyShow: function () {
			this.$div.append(this.$map);
		},
		destroy: function () {
			GISMapOpenLayer.parent.prototype.destroy.apply(this, arguments);
			this.$map.remove();
			this.$map = undefined;
		}
	});

	function GISMapOpenLayerOSM () {
		GISMapOpenLayerOSM.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapOpenLayerOSM, GISMapOpenLayer);
	$.extend(GISMapOpenLayerOSM.prototype, {
		getLayers: function (ol) {
			return [
				new ol.layer.Tile({
					source: new ol.source.OSM()
				})
			];
		}
	});

	function GISMapOpenLayerStamen () {
		GISMapOpenLayerStamen.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapOpenLayerStamen, GISMapOpenLayer);
	$.extend(GISMapOpenLayerStamen.prototype, {
		getLayers: function (ol) {
			return [
				new ol.layer.Tile({
					source: new ol.source.Stamen({
						layer: 'watercolor'
					})
				}),
				new ol.layer.Tile({
					source: new ol.source.Stamen({
						layer: 'terrain-labels'
					})
				})
			];
		}
	});

	function GISMapOpenLayerMapQuest () {
		GISMapOpenLayerMapQuest.parent.apply(this, arguments);
	}
	OO.inheritClass(GISMapOpenLayerMapQuest, GISMapOpenLayer);
	$.extend(GISMapOpenLayerMapQuest.prototype, {
		getLayers: function (ol) {
			return [
				new ol.layer.Tile({
					source: new ol.source.MapQuest({layer: 'sat'})
				})
			];
		}
	});

	function testFeatures (actual, requested) {
		var i;
		for (i = 0; i < requested.length; i++) {
			if ($.inArray(requested[i], actual) === -1) {
				return false;
			}
		}
		return true;
	}

	function selectByFeatures (all, requested, specials) {
		var maps = {}, key, map;
		for (key in all) {
			if (all.hasOwnProperty(key)) {
				map = all[key];
				if (
					(map.static.special === false && testFeatures(map.static.features, requested)) ||
					$.inArray(map.static.special, specials) > -1
				) {
					maps[key] = map;
				}
			}
		}
		return maps;
	}

	return selectByFeatures({
		wiwosm: GISMapIframeWiwosm,
		wma: GISMapIframeWMA,
		karta: GISMapIframeKarta,
		allcoords: GISMapIframeAllCoords,
		osm: GISMapOpenLayerOSM,
		stamen: GISMapOpenLayerStamen,
		mapquest: GISMapOpenLayerMapQuest,
		info: GISMapHtmlInfo,
		debug: GISMapHtmlDebug
	}, features || [], specials || []);
}

function MultiMap (maps, data, $div) {
	this.mapDefs = maps;
	this.$div = $div;
	this.data = $.extend({}, data);
	this.dataVersion = 0;
	this.maps = {};
	this.mapDataVersion = {};
	this.current = false;
}

MultiMap.prototype = {
	init: function (type) {
		if (this.current) {
			this.maps[this.current].hide();
		}
		this.maps[type] = new this.mapDefs[type](this.$div, this.data);
		this.mapDataVersion[type] = this.dataVersion;
		this.current = type;
	},
	show: function (type) {
		if (this.current === type) {
			return;
		}
		if (this.current) {
			this.maps[this.current].hide();
		}
		if (this.mapDataVersion[type] < this.dataVersion) {
			this.maps[type].updateData(this.data);
			this.mapDataVersion[type] = this.dataVersion;
		}
		this.maps[type].show();
		this.current = type;
	},
	initOrShow: function (type) {
		if (this.maps[type]) {
			this.show(type);
		} else {
			this.init(type);
		}
	},
	resize: function () {
		if (this.current) {
			this.maps[this.current].resize();
		}
	},
	updateData: function (data, force) {
		$.extend(this.data, data);
		this.dataVersion++;
		if (force && this.current) {
			this.maps[this.current].updateData(this.data);
		}
	},
	destroy: function () {
		var map;
		for (map in this.maps) {
			if (this.maps.hasOwnProperty(map)) {
				this.maps[map].destroy();
			}
		}
	},
	getMap: function () {
		return this.current ? this.maps[this.current] : false;
	},
	getMaps: function () {
		var map, maps = [];
		for (map in this.mapDefs) {
			if (this.mapDefs.hasOwnProperty(map)) {
				maps.push(map);
			}
		}
		return maps;
	}
};

function MultiMapDialog (maps, data, dataNames) {
	var key;
	this.$mapDiv = $('<div>');
	this.data = data;
	this.dataNames = dataNames;
	this.dataKeys = [];
	for (key in data) {
		if (data.hasOwnProperty(key)) {
			this.dataKeys.push(key);
		}
	}
	this.multiMap = new MultiMap(maps, data[this.dataKeys[0]], this.$mapDiv);
}

MultiMapDialog.prototype = {
	init: function () {
		var that = this, $dataSelect, $mapSelect, $panel, $div;
		$dataSelect = this.buildDataSelect();
		$dataSelect.change(function () {
			var data = that.data[$dataSelect.val()];
			if ($.isFunction(data)) {
				data(function (d) {
					that.updateData(d);
				});
			} else {
				that.updateData(data);
			}
		});
		$mapSelect = this.buildMapSelect();
		$mapSelect.change(function () {
			that.changeMap($mapSelect.val(), that.$check.prop('checked'));
		});
		$panel = $('<div>')
			.append(mw.html.element('label', {'for': 'schnark-map-mapselect'}, mw.msg('schnark-map-mapselect')))
			.append($mapSelect)
			.append(' ')
			.append(mw.html.element('label', {'for': 'schnark-map-dataselect'}, mw.msg('schnark-map-dataselect')))
			.append($dataSelect)
			.append(' ')
			.append(this.buildCheck())
			.css({height: '2em', position: 'absolute'});
		this.$mapDiv.css({
			height: '100%',
			marginTop: '2em'
		});
		$div = $('<div>')
			.append($panel)
			.append(this.$mapDiv)
			.css({
				position: 'relative', //$panel absolute
				height: '100%'
			});
		this.dialog = createDialog({
			title: mw.msg('schnark-map-title'),
			$content: $div,
			onResize: function () {
				that.multiMap.resize();
			},
			onClose: function () {
				that.onClose();
			}
		});
		this.changeMap(this.multiMap.getMaps()[0], false);
		this.initialized = true;
	},
	getDataName: function (key) {
		if (isNaN(key)) {
			return mw.msg('schnark-map-data-name-' + key);
		}
		return this.dataNames[key];
	},
	buildDataSelect: function () {
		var dataKeys = this.dataKeys, options = [], i;
		for (i = 0; i < dataKeys.length; i++) {
			options.push(mw.html.element('option', {value: dataKeys[i], selected: i === 0}, this.getDataName(dataKeys[i])));
		}
		return $(mw.html.element('select', {id: 'schnark-map-dataselect'}, new mw.html.Raw(options.join(''))));
	},
	buildMapSelect: function () {
		var maps = this.multiMap.getMaps(), options = [], i;
		for (i = 0; i < maps.length; i++) {
			options.push(mw.html.element('option', {value: maps[i], selected: i === 0}, mw.msg('schnark-map-maps-name-' + maps[i])));
		}
		return $(mw.html.element('select', {id: 'schnark-map-mapselect'}, new mw.html.Raw(options.join(''))));
	},
	buildCheck: function () {
		this.$check = $(mw.html.element('input', {type: 'checkbox', id: 'schnark-map-check-keepview', title: mw.msg('schnark-map-keepview-tooltip')}));
		this.$label = $(mw.html.element('label', {'for': 'schnark-map-check-keepview', title: mw.msg('schnark-map-keepview-tooltip')}, mw.msg('schnark-map-keepview')));
		return $('<span>').append(this.$check).append(this.$label);
	},
	updateCheck: function (enabled) {
		this.$check.prop('disabled', !enabled);
		if (!enabled) {
			this.$check.prop('checked', false);
			this.$label.css('color', '#555');
		} else {
			this.$label.css('color', '#000');
		}
	},
	show: function () {
		if (!this.initialized) {
			this.init();
		}
		this.dialog.open();
	},
	hide: function () {
		this.dialog.close();
	},
	changeMap: function (type, update) {
		if (update) {
			this.multiMap.updateData(this.multiMap.getMap().getData());
		}
		this.multiMap.initOrShow(type);
		this.updateCheck(this.multiMap.getMap().canGetData());
	},
	updateData: function (data) {
		this.multiMap.updateData(data, true);
	},
	onClose: function () {
	},
	destroy: function () {
		this.multiMap.destroy();
		this.dialog.destroy();
	}
};

function createDialog (config) {
	var $dialog = config.$content.dialog({title: config.title, height: config.height || 500, width: config.width || 650, autoOpen: false});
	$dialog.on('dialogresize', config.onResize || $.noop);
	$dialog.on('dialogclose', config.onClose || $.noop);
	return {
		open: function () {
			$dialog.dialog('open');
		},
		close: function () {
			$dialog.dialog('close');
		},
		destroy: function () {
			$dialog.dialog('destroy');
		}
	};
}

function getMultiMapDialog (data) {
	if (data && getMultiMapDialogCache) {
		getMultiMapDialogCache.done(function (dialog) {
			dialog.destroy();
		});
		getMultiMapDialogCache = false;
	}
	if (!getMultiMapDialogCache) {
		getMultiMapDialogCache = $.Deferred();
		mw.loader.using(['oojs', 'jquery.ui.dialog'], function () {
			var dataNames, features, specials;
			if (data) {
				dataNames = data.names;
				features = data.features;
				specials = data.specials;
				delete data.names;
				delete data.features;
				delete data.specials;
			}
			getMultiMapDialogCache.resolve(
				new MultiMapDialog(getGISMaps(window.OO, features, specials), data, dataNames)
			);
		});
	}
	return getMultiMapDialogCache.promise();
}

function showMultiMapDialog (data, onClose) {
	getMultiMapDialog(data).done(function (dialog) {
		dialog.show();
		if (onClose) {
			dialog.onClose = onClose;
		}
	});
}

function hideMultiMapDialog () {
	getMultiMapDialog().done(function (dialog) {
		dialog.hide();
	});
}

function getDataPage (data) {
	data.lang = mw.config.get('wgDBname') === 'commonswiki' ? 'commons' : mw.config.get('wgContentLanguage'); //FIXME
	data.uselang = mw.config.get('wgUserLanguage');
	if (mw.config.get('wgNamespaceNumber') === 0) {
		data.wikiTitle = mw.config.get('wgTitle');
	}
	return data;
}

function makeNumber (n, vz) {
	n = n.split('_');
	while (n.length > 1) {
		n.push(n.pop() / 60 + n.pop());
	}
	return vz * n[0];
}

function parseParams (p) {
	var i, all, c, match, params = {};
	all = ('_c:' + p).split(/(_[a-z]+:)/);
	for (i = 1; i < all.length; i += 2) {
		params[all[i].slice(1, -1)] = all[i + 1];
	}
	c = params.c;
	delete params.c;
	match = /([\d.+-_]+)([NSZ])_([\d.+-_]+)([WEO])/.exec(c) || ['', '0', 'N', '0', 'W'];
	params.lat = makeNumber(match[1], match[2] === 'N' ? 1 : -1);
	params.long = makeNumber(match[3], match[4] === 'W' ? -1 : 1);
	params.digits = c.replace(/[^_]+/g, '').length + c.replace(/.*\./, '').replace(/\D.*/, '').length;
	return params;
}

function getZoom (data) {
	var typeToZoom = {
		airport: 8, edu: 8, pass: 8, landmark: 8, railwaystation: 8,
		event: 6, forest: 6, glacier: 6,
		adm3rd: 4, city: 4, mountain: 4, isle: 4, river: 4, waterbody: 4
	};
	if (data.scale) {
		return rToZoom(0.2667 * data.scale);
	}
	if (data.dim) {
		return rToZoom(data.dim.replace('k', '000').replace(/\D+/g, ''));
	}
	if (data.type in typeToZoom) {
		return typeToZoom[data.type];
	}
	return Math.round(data.digits * 3.3);
}

function getHrefType (href) {
	if (!href) {
		return false;
	}
	if (href.indexOf('params=') > -1) { //FIXME
		return 'geohack';
	}
	if (href.indexOf('wiki-osm.pl') > -1) {
		return 'allcoords';
	}
	return false;
}

function getDataGeohack (href) {
	var params = mw.util.getParamValue('params', href), data = {};
	if (!params) {
		return;
	}
	params = parseParams(params);
	data.lat = params.lat;
	data.long = params.long;
	data.zoom = getZoom(params);
	if (params.globe) {
		data.globe = params.globe.charAt(0).toUpperCase() + params.globe.slice(1).toLowerCase();
		data.features = ['globe'];
	}
	return data;
}

function getDataAllcoords (href, orig) {
	var data = {};
	if (mw.util.getParamValue('linksfrom', href)) {
		data.linksfrom = true;
	}
	if (mw.util.getParamValue('section', href)) {
		data.section = mw.util.getParamValue('section', href);
	}
	if (mw.config.get('wgNamespaceNumber') === 14) {
		data.category = true;
	}
	if (orig) {
		if (orig.linksfrom !== data.linksfrom) {
			data.linksfrom = false; //FIXME
		}
		if (orig.section !== data.section) {
			delete data.section;
		}
	}
	return data;
}

function getData () {
	var coords = [], names = [], features = [], specials = [], i, specialData, unnamed = false;
	specials.push('debug'); //FIXME
	function add () {
		/*jshint validthis: true*///.each()
		var href = this.href, type = getHrefType(href), data;
		if (type === 'geohack') {
			data = getDataGeohack(href);
		} else if (type === 'allcoords') {
			specialData = getDataAllcoords(href, specialData);
		}
		if (data) {
			if (data.features) {
				for (i = 0; i < data.features.length; i++) {
					if ($.inArray(data.features[i], features) === -1) {
						features.push(data.features[i]);
					}
				}
				delete data.features;
			}
			coords.push(getDataPage(data));
			if (mw.util.getParamValue('title', href)) {
				names.push(mw.util.getParamValue('title', href));
			} else if (!unnamed) {
				names.push(mw.msg('schnark-map-data-name-main'));
				unnamed = true;
			} else {
				names.push(mw.msg('schnark-map-data-name-unnamed'));
			}
		}
	}
	$('#coordinates, #coordinates-title').find('a.external.text').each(add);
	$('#mw-content-text').find('a.external.text').not('#coordinates a, #coordinates-title a').each(add);
	if (coords.length === 0) {
		coords.earth = getDataPage({lat: 0, long: 0, zoom: 12});
	}
	if (specialData) {
		specials.push('allcoords');
		$.extend(coords[0], specialData);
	}
	coords.names = names;
	coords.features = features;
	coords.specials = specials;
	if (navigator.geolocation) {
		coords.geolocation = function (callback) {
			navigator.geolocation.getCurrentPosition(function (data) {
				callback(getDataPage({
					lat: data.coords.latitude,
					long: data.coords.longitude,
					zoom: rToZoom(data.coords.accuracy || 1)
				}));
			});
		};
	}
	return coords;
}

function initMenu () {
	var oldData = {}, maybeUpdate, visible = false;
	mw.hook('wikipage.content').add(function () {
		maybeUpdate = true;
	});

	function retrieveData () {
		if (!maybeUpdate) {
			return false;
		}
		maybeUpdate = false;
		var data = getData();
		if ($.compareObject(oldData, data)) { //FIXME
			return false;
		}
		oldData = data;
		return data;
	}

	function onClick (e) {
		e.preventDefault();
		if (visible) {
			hideMultiMapDialog();
			visible = false;
		} else {
			showMultiMapDialog(retrieveData(), function () {
				visible = false;
			});
			visible = true;
		}
	}

	$(mw.util.addPortletLink('p-tb', '#', mw.msg('schnark-map-link'), 't-schnark-map', mw.msg('schnark-map-tooltip'))).click(onClick);
}

mw.loader.using(['mediawiki.util', 'jquery.mwExtension'], function () {
	$(initMenu);
});

})(jQuery, mediaWiki);
//</nowiki>