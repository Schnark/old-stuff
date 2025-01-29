/*global SimpleRayTracer*/
/*global performance, console*/
(function () {
"use strict";

function buildTree (rt, objects, group) {
	var axis, l, r;

	function addGroup (objects) {
		var min = objects[0].min, max = objects[0].max, i, j;
		for (i = 1; i < objects.length; i++) {
			for (j = 0; j < 3; j++) {
				min[j] = Math.min(min[j], objects[i].min[j]);
				max[j] = Math.max(max[j], objects[i].max[j]);
			}
		}
		return rt.addGroup({
			bound: 'aabb',
			minCorner: min,
			maxCorner: max
		}, group);
	}

	if (objects.length < 3) {
		objects.forEach(function (object) {
			rt.addObject(object.o, group);
		});
		return;
	}
	axis = Math.floor(Math.random() * 3);
	objects.sort(function (a, b) {
		return a.min[axis] - b.min[axis];
	});
	l = objects.slice(0, Math.floor(objects.length / 2 + Math.random()));
	r = objects.slice(l.length);
	if (l.length === 1) {
		rt.addObject(l[0].o, group);
	} else {
		buildTree(rt, l, addGroup(l));
	}
	if (r.length === 1) {
		rt.addObject(r[0].o, group);
	} else {
		buildTree(rt, r, addGroup(r));
	}
}

function getSceneWeekend (rt) {
	//https://raytracing.github.io/books/RayTracingInOneWeekend.html
	var objects = [], a, b, material, center, object, N = 4; //N = 11
	rt.setCamera({
		lookFrom: [13, 2, 3],
		lookAt: [3.4, 0.5, 0.8],
		vfov: 20,
		blur: 0.1
	});
	rt.setBackground({
		texture: 'gradient',
		color0: [1, 1, 1],
		color1: [0.5, 0.7, 1],
		orientation: [0, 1]
	});

	function addObject (o, min, max) {
		if (!min) {
			rt.addObject(o);
		} else {
			objects.push({o: o, min: min, max: max});
		}
	}

	addObject({
		geometry: 'sphere',
		center: [0, -1000, 0],
		radius: 1000,
		material: 'diffuse',
		texture: 'checkerboard',
		size: [6e-3, 2e-4],
		color0: [0.2, 0.3, 0.1],
		color1: [0.9, 0.9, 0.9]
	}, [-1000, -2000, -1000], [1000, 0, 1000]);
	for (a = -N; a < N; a++) {
		for (b = -N; b < N; b++) {
			material = Math.random();
			center = [a + 0.9 * Math.random(), 0.2, b + 0.9 * Math.random()];
			if (Math.hypot(center[0] - 4, center[2]) > 0.9) {
				object = {
					geometry: 'sphere',
					center: center,
					radius: 'r'
				};
				if (material < 0.8) {
					object.material = 'diffuse';
					object.color = [
						Math.random() * Math.random(),
						Math.random() * Math.random(),
						Math.random() * Math.random()
					];
				} else if (material < 0.95) {
					object.material = 'mirror';
					object.color = [Math.random() / 2 + 0.5, Math.random() / 2 + 0.5, Math.random() / 2 + 0.5];
					object.fuzz = Math.random() / 2;
				} else {
					object.material = 'transparent';
					object.ir = 1.5;
					object.color = [1, 1, 1];
				}
				addObject(object, [center[0] - 0.2, 0, center[2] - 0.2], [center[0] + 0.2, 0.4, center[2] + 0.2]);
			}
		}
	}
	addObject({
		geometry: 'sphere',
		center: [0, 1, 0],
		radius: 1,
		material: 'transparent',
		ir: 1.5,
		color: [1, 1, 1]
	}, [-1, 0, -1], [1, 2, 1]);
	addObject({
		geometry: 'sphere',
		center: [-4, 1, 0],
		radius: 1,
		material: 'diffuse',
		color: [0.4, 0.2, 0.1]
	}, [-5, 0, -1], [-3, 2, 1]);
	addObject({
		geometry: 'sphere',
		center: [4, 1, 0],
		radius: 1,
		material: 'mirror',
		color: [0.7, 0.6, 0.5]
	}, [3, 0, -1], [5, 2, 1]);

	buildTree(rt, objects);

	return {
		update: function (time) {
			rt.setParam('r', Math.sin(time / 1000) * 0.05 + 0.15);
		},
		params: {iterations: 4, samples: 4},
		w: 320,
		h: 240
	};
}

function getSceneDemo (rt) {
	//http://hoxxep.github.io/webgl-ray-tracing-demo/
	var i;
	rt.setCamera({
		lookFrom: 'lookFrom',
		lookAt: 'lookAt',
		vfov: 90
	});
	rt.setBackground({
		color: [0.1, 0.1, 0.1]
	});
	rt.addLight({
		light: 'ambient',
		color: [0.2, 0.2, 0.2]
	});
	rt.addLight({
		light: 'directional',
		dir: [5773.50269, 5773.50269, -5773.50269],
		color: [2, 2, 2]
	});
	rt.addLight({
		light: 'directional',
		dir: [5000, 10000, 10000]
	});
	rt.addObject({
		geometry: 'plane',
		center: [0, -2.7, 0],
		normal: [0, 1, 0],
		material: 'mirror',
		texture: 'checkerboard',
		size: [5, 5],
		color0: [1, 1, 1],
		color1: [0, 0.45, 0.4]
	}, rt.addGroup({
		bound: 'sphere',
		center: [0, -2.7, 0],
		radius: Math.sqrt(300)
	}));
	for (i = 0; i < 64; i++) {
		rt.addObject({
			geometry: 'sphere',
			center: 'c' + i,
			radius: 1,
			material: 'mirror',
			color: [Math.sin(1 / (i / 32 + 0.01)) / 2 + 0.5, Math.sin(i / 32) / 2 + 0.5, Math.cos(i / 32) / 2 + 0.5]
		});
	}
	return {
		update: function (time) {
			var lookFrom, i, v;
			lookFrom = [
				Math.sin(time * 0.0008) * 18,
				Math.sin(time * 0.00026) * 5 + 5,
				Math.cos(time * 0.0008) * 18
			];
			rt.setParam('lookFrom', lookFrom);
			rt.setParam('lookAt', [0.9 * lookFrom[0], 0.9 * lookFrom[1], 0.9 * lookFrom[2]]);
			for (i = 0; i < 64; i++) {
				v = i % 16;
				rt.setParam('c' + i, [
					3 * (v % 4) + Math.sin(time / 100 + i) * 0.15 - 6,
					3 * Math.floor(v / 4) + Math.sin(time / 100 + i) * 0.15,
					3 * Math.floor(i / 16) + Math.sin(time / 100 + i) * 0.15 - 6
				]);
			}
		},
		params: {iterations: 10, samples: 1},
		w: 320,
		h: 240
	};
}

function getSceneWeek2 (rt) {
	//https://raytracing.github.io/books/RayTracingTheNextWeek.html
	//var floorGroup, i, j, h;
	rt.setCamera({
		lookFrom: [478, 278, -600],
		lookAt: [270, 278, 0],
		vfov: 40
	});
	rt.setBackground({
		color: [0, 0, 0]
	});
	/*floorGroup = rt.addGroup({
		bound: 'aabb',
		minCorner: [-1000, 0, -1000],
		maxCorner: [1000, 100, 1000]
	});
	for (i = 0; i < 20; i++) {
		for (j = 0; j < 20; j++) {
			h = Math.random() * 100;
			rt.addObject({
				geometry: 'box',
				center: [-9950 + i * 100, h / 2, -9950 + j * 100],
				a: [50, 0, 0],
				b: [0, h / 2, 0],
				c: [0, 0, 50],
				material: 'diffuse',
				color: [0.48, 0.83, 0.53]
			}, floorGroup);
		}
	}*/
	rt.addObject({
		geometry: 'plane',
		center: [0, 50, 0],
		normal: [0, 1, 0],
		material: 'diffuse',
		color: [0.48, 0.83, 0.53]
	});
	rt.addLight({
		light: 'rect',
		corner: [123, 554, 147],
		a: [300, 0, 0],
		b: [0, 0, 265],
		color: [1, 1, 1]
	});
	rt.addObject({
		geometry: 'plane',
		center: [123, 554.5, 147],
		normal: [0, 1, 0],
		material: 'diffuse'
	}, rt.addGroup({
		bound: 'aabb',
		minCorner: [123, 554, 147],
		maxCorner: [423, 555, 412]
	}));
	rt.addObject({
		geometry: 'sphere',
		center: 'c',
		radius: 50,
		material: 'diffuse',
		color: [0.7, 0.3, 0.1]
	});
	rt.addObject({
		geometry: 'sphere',
		center: [260, 150, 45],
		radius: 50,
		material: 'transparent',
		ir: 1.5,
		schlick: true
	});
	rt.addObject({
		geometry: 'sphere',
		center: [0, 150, 145],
		radius: 50,
		material: 'mirror',
		blur: 1,
		color: [0.8, 0.8, 0.9]
	});
	rt.addObject({
		geometry: 'sphere',
		center: [360, 150, 145],
		radius: 70,
		material: 'transparent',
		ir: 1.5,
		schlick: true
	});
	rt.addObject({
		geometry: 'volume',
		density: 0.2,
		material: 'diffuse',
		color: [0.2, 0.4, 0.9]
	}, rt.addGroup({
		bound: 'sphere',
		center: [360, 150, 145],
		radius: 70
	}));
	rt.addObject({
		geometry: 'volume',
		density: 0.0001,
		material: 'diffuse'
	});
	rt.addObject({
		geometry: 'sphere',
		center: [400, 200, 400],
		radius: 100,
		material: 'diffuse',
		texture: 'image',
		sampler: rt.getTexture(
			'https://upload.wikimedia.org/wikipedia/commons/thumb/' +
			'3/3e/Blue_marble%2C_with_the_Americas_on_the_right.png/' +
			'320px-Blue_marble%2C_with_the_Americas_on_the_right.png'
		)
	});
	//TODO noisy sphere
	//TODO many spheres
	return {
		update: function (time) {
			rt.setParam('c', [415 + 15 * Math.sin(time / 1000), 400, 200]);
		},
		params: {iterations: 10, samples: 10},
		w: 320,
		h: 240
	};
}

function getSceneCornell (rt) {
	rt.setCamera({
		lookFrom: [278, 278, -800],
		lookAt: [278, 278, 0],
		vfov: 40
	});
	rt.addObject({
		geometry: 'plane',
		center: [0, 555, 555],
		normal: [1, 0, 0],
		material: 'diffuse',
		color: [0.65, 0.05, 0.05]
	});
	rt.addObject({
		geometry: 'plane',
		center: [555, 555, 555],
		normal: [1, 0, 0],
		material: 'diffuse',
		color: [0.12, 0.45, 0.15]
	});
	rt.addObject({
		geometry: 'plane',
		center: [555, 0, 555],
		normal: [0, 1, 0],
		material: 'diffuse',
		color: [0.73, 0.73, 0.73]
	});
	rt.addObject({
		geometry: 'plane',
		center: [555, 555, 555],
		normal: [0, 1, 0],
		material: 'diffuse',
		color: [0.73, 0.73, 0.73]
	});
	rt.addObject({
		geometry: 'plane',
		center: [555, 555, 555],
		normal: [0, 0, 1],
		material: 'diffuse',
		color: [0.73, 0.73, 0.73]
	});
	rt.addObject({
		geometry: 'box',
		center: [212.5, 82.5, 147.5],
		a: [79.7, 0, 21.4],
		b: [0, 82.5, 0],
		c: [-21.4, 0, 79.7],
		material: 'diffuse',
		color: [0.73, 0.73, 0.73]
	});
	rt.addObject({
		geometry: 'box',
		center: [347.5, 165, 377.5],
		a: [78.5, 0, -25.5],
		b: [0, 165, 0],
		c: [25.5, 0, 78.5],
		material: 'diffuse',
		color: [0.73, 0.73, 0.73]
	});
	rt.addLight({
		light: 'rect',
		corner: [213, 554, 227],
		a: [130, 0, 0],
		b: [0, 0, 105],
		color: [0.5, 0.5, 0.5]
	});
	return {
		update: function () {},
		params: {iterations: 10, samples: 10},
		w: 320,
		h: 240
	};
}

function getSceneRDF (rt) {
	rt.setBackground({
		texture: 'gradient',
		color0: [1, 1, 1],
		color1: [0.5, 0.7, 1],
		orientation: [0, 1]
	});
	rt.setCamera({
		lookFrom: [0, 12, -44],
		lookAt: [0, 3, -11]
	});
	rt.addObject({
		geometry: 'torus',
		radius0: 10,
		radius1: 1,
		invTransform: 'invTransform',
		material: 'diffuse',
		color: [1, 0, 0]
	});
	return {
		update: function (time) {
			var s = Math.sin(time / 1000), c = Math.cos(time / 1000);
			rt.setParam('invTransform', [
				1, 0, 0, 0,
				0, s, c, 0,
				0, -c, s, 0,
				0, 0, 0, 1
			]);
		},
		params: {iterations: 10, samples: 10},
		w: 320,
		h: 240
	};
}

function getScene (scene, rt) {
	switch (scene) {
	case 'weekend': return getSceneWeekend(rt);
	case 'demo': return getSceneDemo(rt);
	case 'week2': return getSceneWeek2(rt);
	case 'cornell': return getSceneCornell(rt);
	case 'rdf': return getSceneRDF(rt);
	default: throw new Error('unknown scene');
	}
}

function renderScene (scene) {
	var canvas = document.getElementById('canvas'),
		rt = new SimpleRayTracer(canvas),
		data = getScene(scene, rt),
		t0, t1;

	canvas.width = data.w;
	canvas.height = data.h;

	t0 = performance.now();
	rt.compile(data.params);
	t1 = performance.now();
	console.log('Compile: ' + (t1 - t0) + 'ms');
	t0 = performance.now();
	data.update(0);
	rt.render();
	t1 = performance.now();
	console.log('First render: ' + (t1 - t0) + 'ms');

	SimpleRayTracer.animate(function (time) {
		t0 = performance.now();
		data.update(time);
		rt.render();
		t1 = performance.now();
		console.log('Render (' + time + '): ' + (t1 - t0) + 'ms');
		if (time > 20000) {
			return true;
		}
	});
}

document.getElementById('button').addEventListener('click', function () {
	renderScene(document.getElementById('select').value);
});

})();