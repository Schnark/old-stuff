function GISMap (base, features) {
	that = this;
	map = GISMap.baseMaps[base]();
	if (!$.isArray(map)) {
		map = [map];
	}
	this.features = {};
	this.layers = [];
	for (i = 0; i < map.length; i++) {
		this.layers.push(map[i]);
	}
	for (f in features) {
		if (features.hasOwnProperty(f)) {
			this.features[f] = this.layers.length;
			this.layers.push(new ol.layer.Tile({
				visible: false,
				source: features[f]
			}));
		}
	}
	this.map = new ol.Map({
		layers: this.layers,
		loadTilesWhileInteracting: true,
		target: 'schnark-ol-map-' + base
	});
	this.setView(0, 0, 2);
	this.map.on('singleclick', function (e) {
		that.onClick(ol.coordinate.toStringHDMS(ol.proj.transform(e.coordinate, 'EPSG:3857', 'EPSG:4326')));
	});
}

GISMap.baseMaps = {
	osm: function () {
		return new ol.layer.Tile({
			source: new ol.source.OSM()
		});
	},
	mapQuest: function () {
		return new ol.layer.Tile({
			source: new ol.source.MapQuest({layer: 'sat'})
		});
	},
	stamen: function () {
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
};

GISMap.prototype = {
	show: function (f) {
		this.layers[this.features[f]].setVisible(true);
	},
	hide: function (f) {
		this.layers[this.features[f]].setVisible(false);
	},
	get: function (f) {
		this.layers[this.features[f]].getVisible();
	},
	getView: function () {
		return this.map.getView();
	},
	setView: function (lat, long, zoom) {
		if (long) {
			lat = new ol.View({
				center: [lat, long],
				zoom: zoom || this.getView.getZoom()
			});
		}
		this.map.setView(lat);
	},
	zoomTo: function (f) {
		this.getView.fitGeometry(this.features[f].getGeometry(), this.map.getSize(), {padding: {170, 50, 30, 150], constrainResolution: false, minResolution: 50});
	},
	onClick: function (/*lat, long, zoom*/) {
	}
};
