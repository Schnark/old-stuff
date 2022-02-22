/*global SimpleRayTracer: true*/
SimpleRayTracer =
(function () {
"use strict";

function SimpleRayTracer (canvas) {
	this.gl = canvas.getContext('webgl', {alpha: false}) || canvas.getContext('experimental-webgl', {alpha: false});
	this.textureCount = 0;
	this.currentSize = [canvas.width, canvas.height];
	this.parameters = {
		resolution: {type: 'vec2', value: [canvas.width, canvas.height]}
	};
	this.world = {
		camera: {camera: 'default'},
		background: {},
		groups: [{ids: []}],
		objects: [],
		lights: []
	};
}

SimpleRayTracer.animate = function (callback) {
	var start, prev, rAF = window.requestAnimationFrame || window.mozRequestAnimationFrame;
	function step (time) {
		var shouldStop;
		if (!start) {
			start = time;
			prev = time;
		}
		shouldStop = callback(time - start, time - prev);
		if (!shouldStop) {
			prev = time;
			rAF(step);
		}
	}
	rAF(step);
};

SimpleRayTracer.loadImage = function (url, callback) {
	var image = new Image();
	image.crossOrigin = '';
	image.onload = function () {
		callback(image);
	};
	image.src = url;
};

SimpleRayTracer.camera = {
	'default': {
		global: [
			'vec3 origin,',
			'screenCorner,',
			'horizontal,',
			'vertical,',
			'u, v;'
		].join(''),
		params: [
			{name: 'vfov', type: 'float', value: 90},
			{name: 'lookFrom', type: 'vec3', value: [0, 0, 0]},
			{name: 'lookAt', type: 'vec3', value: [0, 0, -1]},
			{name: 'vup', type: 'vec3', value: [0, 1, 0]},
			{name: 'blur', type: 'float', value: 0}
		],
		init: [
			'float aspect = resolution.x / resolution.y;',
			'float height = 2.0 * tan(radians(vfov / 2.0));',
			'float width = aspect * height;',
			'float f = length(lookFrom - lookAt);',

			'vec3 w = normalize(lookFrom - lookAt);',
			'u = normalize(cross(vup, w));',
			'v = cross(w, u);',

			'origin = lookFrom;',
			'horizontal = f * width * u;',
			'vertical = f * height * v;',
			'screenCorner = lookFrom - horizontal / 2.0 - vertical / 2.0 - f * w;'
		].join(''),
		ray: [
			'if (bool(blur)) {',
				'float a = 2.0 * PI * random();',
				'float r = blur * sqrt(random());',
				'rayStart = origin + u * r * sin(a) + v * r * cos(a);',
			'} else {',
				'rayStart = origin;',
			'}',
			'rayDir = screenCorner',
				'+ pos.x * horizontal',
				'+ pos.y * vertical',
				'- rayStart;'
		].join('')
	}
};

SimpleRayTracer.bound = {
	aabb: {
		params: [
			{name: 'minCorner', type: 'vec3', value: [0, 0, 0]},
			{name: 'maxCorner', type: 'vec3', value: [0, 0, 0]}
		],
		bounds: [
			'vec3 t0 = (minCorner - rayStart) / rayDir;',
			'vec3 t1 = (maxCorner - rayStart) / rayDir;',
			'vec3 tMin = min(t0, t1);',
			'vec3 tMax = max(t0, t1);',
			'return vec2(max(max(tMin.x, tMin.y), tMin.z), min(min(tMax.x, tMax.y), tMax.z));'
		].join('')
	},
	sphere: {
		params: [
			{name: 'center', type: 'vec3', value: [0, 0, 0]},
			{name: 'radius', type: 'float', value: 1}
		],
		bounds: [
			'vec3 oc = rayStart - center;',
			'float a = dot(rayDir, rayDir);',
			'float b2 = dot(oc, rayDir);',
			'float c = dot(oc, oc) - radius * radius;',
			'float d = b2 * b2 - a * c;',
			'if (d < 0.0) {',
				'return vec2(1, -1);',
			'}',
			'float sqrtD = sqrt(d);',
			'return vec2((-b2 - sqrtD) / a, (-b2 + sqrtD) / a);'
		].join('')
	}
};

SimpleRayTracer.geometry = {
	sphere: {
		params: [
			{name: 'center', type: 'vec3', value: [0, 0, 0]},
			{name: 'radius', type: 'float', value: 1}
		],
		intersect: [
			'vec3 oc = rayStart - center;',
			'float a = dot(rayDir, rayDir);',
			'float b2 = dot(oc, rayDir);',
			'float c = dot(oc, oc) - radius * radius;',
			'float d = b2 * b2 - a * c;',
			'if (d < 0.0) {',
				'return vec2(0);',
			'}',
			'float sqrtD = sqrt(d);',
			'float t = (-b2 - sqrtD) / a;',
			'if (t < tMin || t > tMax) {',
				't = (-b2 + sqrtD) / a;',
				'if (t < tMin || t > tMax) {',
					'return vec2(0);',
				'}',
			'}',
			'return vec2(1, t);'
		].join(''),
		normal: 'return (point - center) / radius;',
		texture: [
			'vec3 normal = normalize(point - center);',
			'float u = normal.x == 0.0 && normal.z == 0.0 ? 0.0 : atan(-normal.z, normal.x);',
			'u = 0.5 * (u / PI + 1.0);',
			'float v = acos(-normal.y) / PI;',
			'return vec2(u, v);'
		].join('')
	},
	plane: {
		params: [
			{name: 'center', type: 'vec3', value: [0, 0, 0]},
			{name: 'normal', type: 'vec3', value: [0, 1, 0]}
		],
		intersect: [
			'float a = -dot(rayDir, normal);',
			'if (a == 0.0) {',
				'return vec2(0);',
			'}',
			'float t = dot(rayStart - center, normal) / a;',
			'if (t < tMin || t > tMax) {',
				'return vec2(0);',
			'}',
			'return vec2(1, t);'
		].join(''),
		normal: 'return normalize(normal);',
		texture: [
			'vec3 a = vec3(normal.yx, 0);',
			'if (a.x == 0.0 && a.y == 0.0) {',
				'a = vec3(1, 0, 0);',
			'}',
			'vec3 b = cross(a, normal);',
			'return vec2(dot(a, point - center), dot(b, point - center));'
		].join('')
	},
	volume: {
		params: [
			{name: 'density', type: 'float', value: 1}
		],
		intersect: [
			'float t = tMin - log(random()) / (length(rayDir) * density);',
			'if (t > tMax) {',
				'return vec2(0);',
			'}',
			'return vec2(1, t);'
		].join(''),
		normal: 'return randomVector();',
		texture: 'return vec2(0);'
	},
	box: {
		params: [
			{name: 'center', type: 'vec3', value: [0, 0, 0]},
			{name: 'a', type: 'vec3', value: [1, 0, 0]},
			{name: 'b', type: 'vec3', value: [0, 1, 0]},
			{name: 'c', type: 'vec3', value: [0, 0, 1]}
		],
		intersect: [
			'float aa = dot(a, a);',
			'float bb = dot(b, b);',
			'float cc = dot(c, c);',
			'vec3 cr = center - rayStart;',
			'float cra = dot(cr, a);',
			'float crb = dot(cr, b);',
			'float crc = dot(cr, c);',
			'float ra = dot(rayDir, a);',
			'float rb = dot(rayDir, b);',
			'float rc = dot(rayDir, c);',
			'vec3 tMinus = vec3(',
				'(-aa + cra) / ra,',
				'(-bb + crb) / rb,',
				'(-cc + crc) / rc',
			');',
			'vec3 tPlus = vec3(',
				'(aa + cra) / ra,',
				'(bb + crb) / rb,',
				'(cc + crc) / rc',
			');',
			'vec3 t0 = min(tMinus, tPlus);',
			'vec3 t1 = max(tMinus, tPlus);',
			'float tMinHit = max(t0.x, max(t0.y, t0.z));',
			'float tMaxHit = min(t1.x, min(t1.y, t1.z));',
			'if (tMinHit > tMaxHit) {',
				'return vec2(0);',
			'}',
			'if (tMin <= tMinHit) {',
				'if (tMinHit <= tMax) {',
					'return vec2(1, tMinHit);',
				'}',
				'return vec2(0);',
			'}',
			'if (tMin <= tMaxHit) {',
				'if (tMaxHit <= tMax) {',
					'return vec2(1, tMaxHit);',
				'}',
			'}',
			'return vec2(0);'
		].join(''),
		normal: [
			'vec3 pc = point - center;',
			'float u = dot(pc, a) / dot(a, a);',
			'float v = dot(pc, b) / dot(b, b);',
			'float w = dot(pc, c) / dot(c, c);',
			'if (abs(u) > abs(v)) {',
				'if (abs(u) > abs(w)) {',
					'return normalize(u * a);',
				'} else {',
					'return normalize(w * c);',
				'}',
			'} else {',
				'if (abs(v) > abs(w)) {',
					'return normalize(v * b);',
				'} else {',
					'return normalize(w * c);',
				'}',
			'}'
		].join(''),
		texture: [
			'vec3 pc = point - center;',
			'float u = dot(pc, a) / dot(a, a);',
			'float v = dot(pc, b) / dot(b, b);',
			'float w = dot(pc, c) / dot(c, c);',
			'if (abs(u) > abs(v)) {',
				'if (abs(u) > abs(w)) {',
					'return vec2(v, w);',
				'} else {',
					'return vec2(u, v);',
				'}',
			'} else {',
				'if (abs(v) > abs(w)) {',
					'return vec2(u, w);',
				'} else {',
					'return vec2(u, v);',
				'}',
			'}'
		].join('')
	},
	torus: {
		params: [
			{name: 'center', type: 'vec3', value: [0, 0, 0]},
			{name: 'radius0', type: 'float', value: 1},
			{name: 'radius1', type: 'float', value: 1}
		],
		distance: [
			'point -= center;',
			'return length(vec2(length(point.xz) - radius0, point.y)) - radius1;'
		].join('')
	}
};

SimpleRayTracer.material = {
	diffuse: {
		params: [],
		scatter: 'return normal + randomVector();',
		defaultLightParam: [1, 0.9, 0.1, 10]
	},
	mirror: {
		params: [
			{name: 'fuzz', type: 'float', value: 0}
		],
		scatter: [
			'vec3 reflected = reflect(inDir, normal);',
			'if (bool(fuzz)) {',
				'reflected = normalize(reflected) + fuzz * randomVector();',
				'if (dot(reflected, normal) <= 0.0) {',
					'reflected = vec3(0);',
				'}',
			'}',
			'return reflected;'
		].join(''),
		defaultLightParam: [1, 0.7, 0.3, 40]
	},
	transparent: {
		params: [
			{name: 'ir', type: 'float', value: 1},
			{name: 'schlick', type: 'bool', value: false}
		],
		scatter: [
			'float eta = outside ? (1.0 / ir) : ir;',
			'inDir = normalize(inDir);',
			'if (schlick) {',
				'float r0 = (1.0 - eta) / (1.0 + eta);',
				'r0 = r0 * r0;',
				'if (r0 + (1.0 - r0) * pow(1.0 + dot(inDir, normal), 5.0) > random()) {',
					'return reflect(inDir, normal);',
				'}',
			'}',
			'vec3 refracted = refract(inDir, normal, eta);',
			'if (length(refracted) < 0.01) {',
				'return reflect(inDir, normal);',
			'}',
			'return refracted;'
		].join(''),
		defaultLightParam: [1, 0.8, 0.2, 30]
	}
};

SimpleRayTracer.texture = {
	checkerboard: {
		params: [
			{name: 'color0', type: 'vec3', value: [0, 0, 0]},
			{name: 'color1', type: 'vec3', value: [1, 1, 1]},
			{name: 'size', type: 'vec2', value: [1, 1]}
		],
		color: [
			'bvec2 pos = lessThan(fract(coords / (2.0 * size)), vec2(0.5));',
			'return any(pos) && !all(pos) ? color0 : color1;'
		].join('')
	},
	gradient: {
		params: [
			{name: 'color0', type: 'vec3', value: [0, 0, 0]},
			{name: 'color1', type: 'vec3', value: [1, 1, 1]},
			{name: 'orientation', type: 'vec2', value: [1, 0]}
		],
		color: 'return mix(color0, color1, dot(coords, orientation));'
	},
	image: {
		params: [
			{name: 'sampler', type: 'sampler2D', value: 0}
			//TODO more params for section of image etc.?
		],
		color: 'return texture2D(sampler, vec2(coords.x, 1.0 - coords.y)).rgb;'
	}
};

SimpleRayTracer.light = {
	ambient: {
		params: [],
		dir: 'return vec3(0);'
	},
	directional: {
		params: [
			{name: 'dir', type: 'vec3', value: [0, 1e5, 0]}
		],
		dir: 'return dir;'
	},
	point: {
		params: [
			{name: 'point', type: 'vec3', value: [0, 0, 0]}
		],
		dir: 'return point - pos;'
	},
	sphere: {
		params: [
			{name: 'center', type: 'vec3', value: [0, 0, 0]},
			{name: 'radius', type: 'float', value: 1}
		],
		dir: 'return center + radius * randomVector() - pos;'
	},
	rect: {
		params: [
			{name: 'corner', type: 'vec3', value: [0, 0, 0]},
			{name: 'a', type: 'vec3', value: [1, 0, 0]},
			{name: 'b', type: 'vec3', value: [0, 1, 0]}
		],
		dir: 'return corner + random() * a + random() * b - pos;'
	}
};

function makeFunctionsForDistanceField (distanceField) {
	var eps = 0.001, iterations = 1000;
	return {
		intersect: [
			'float eps = max(float(' + eps + '), (tMax - tMin) / float(' + iterations + '));',
			'rayDir = normalize(rayDir);',
			'float t = tMin;',
			'vec3 pos = rayStart + t * rayDir;',
			'float d = ' + distanceField + 'pos);',
			'if (d == 0.0) {',
				'return vec2(1, t);',
			'}',
			'float sign = d < 0.0 ? -1.0 : 1.0;',
			'for (int i = 0; i < ' + iterations + '; i++) {',
				'd = ' + distanceField + 'rayStart + t * rayDir) * sign;',
				'if (d <= 0.0) {',
					'return vec2(1, t);',
				'}',
				't += max(d, eps);',
				'if (t >= tMax) {',
					'break;',
				'}',
			'}',
			'return vec2(0);'
		].join(''),
		normal: [
			'float eps = float(' + eps + ');',
			'vec3 dx = vec3(eps, 0, 0);',
			'vec3 dy = vec3(0, eps, 0);',
			'vec3 dz = vec3(0, 0, eps);',
			'return normalize(vec3(',
				distanceField + 'point + dx) - ' + distanceField + 'point - dx),',
				distanceField + 'point + dy) - ' + distanceField + 'point - dy),',
				distanceField + 'point + dz) - ' + distanceField + 'point - dz)',
			'));'
		].join(''),
		texture: 'return vec2(0);'
	};
}

function extractParamGroup (data, group) {
	var params;
	if (group === 'texture' && !data.texture) {
		params = [{name: 'color', type: 'vec3', value: [1, 1, 1]}];
	} else {
		params = JSON.parse(JSON.stringify(SimpleRayTracer[group][data[group]].params));
	}
	if (group === 'geometry' || group === 'bound') {
		params.push({name: 'visible', type: 'bool', value: true});
	}
	if (group === 'geometry') {
		params.push({name: 'invTransform', type: 'mat4', value: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]});
	}
	if (group === 'material') {
		params.push({name: 'lightParam', type: 'vec4', value: SimpleRayTracer.material[data.material].defaultLightParam});
	}
	if (group === 'light') {
		params.push({name: 'color', type: 'vec3', value: [1, 1, 1]});
	}
	return params.filter(function (param) {
		return typeof data[param.name] === 'string' || param.type === 'sampler2D';
	});
}

function makeValueString (value, type) {
	if (typeof value === 'string') {
		return 'u_' + value;
	}
	if (type === 'sampler2D') {
		return 'u_sampler_' + value;
	}
	return type + '(' + String(value) + ')';
}

function makeFunctionDeclaration (a, b, c) {
	var params, data = {
		camera: {
			init: ['void', 'vec2 resolution'],
			ray: ['void', 'vec2 pos, out vec3 rayStart, out vec3 rayDir']
		},
		bound: {
			bounds: ['vec2', 'vec3 rayStart, vec3 rayDir']
		},
		geometry: {
			distance: ['float', 'vec3 point'],
			intersect: ['vec2', 'vec3 rayStart, vec3 rayDir, float tMin, float tMax, bool simple'],
			normal: ['vec3', 'vec3 point'],
			texture: ['vec2', 'vec3 point']
		},
		material: {
			scatter: ['vec3', 'vec3 inDir, vec3 normal, bool outside']
		},
		texture: {
			color: ['vec3', 'vec2 coords']
		},
		light: {
			dir: ['vec3', 'vec3 pos']
		}
	};
	data = data[a][c];
	params = SimpleRayTracer[a][b].params.map(function (param) {
		return param.type + ' ' + param.name;
	});
	params.push(data[1]);
	return data[0] + ' ' + a + '_' + b + '_' + c + '(' + params.join(',') + ') {' + SimpleRayTracer[a][b][c] + '}';
}

function makeFunctionCall (a, c, params0, params1) {
	var b = params0[a], params;
	params = SimpleRayTracer[a][b].params.map(function (param) {
		var value = params0[param.name];
		if (value === undefined) {
			value = param.value;
		}
		return makeValueString(value, param.type);
	});
	params.push(params1);
	return a + '_' + b + '_' + c + '(' + params.join(',') + ')';
}

function makeRandomFunctions () {
	return [
		'vec2 randomState;',
		'void initRandom () {',
			'randomState = 1.0 / gl_FragCoord.xy;',
		'}',

		'float random () {',
			'randomState.x = fract(randomState.x + PI);',
			'randomState.y = sin(10.0 * (randomState.x + randomState.y));',
			'return fract(randomState.x + randomState.y);',
		'}',

		'vec3 randomVector () {',
			'float u = random();',
			'float v = random();',
			'float z = 1.0 - 2.0 * u;',
			'float r = sqrt(1.0 - z * z);',
			'float a = 2.0 * PI * v;',
			'return vec3(r * cos(a), r * sin(a), z);',
		'}'
	].join('');
}

function makeHelperFunctions (world) {
	var usedBounds = {},
		usedGeometries = {},
		usedGeometrieTextures = {},
		usedMaterials = {},
		usedTextures = {},
		usedLights = {};
	if (world.background.texture) {
		usedTextures[world.background.texture] = true;
	}
	world.groups.forEach(function (group) {
		if (group.bound) {
			usedBounds[group.bound] = true;
		}
	});
	world.objects.forEach(function (object) {
		usedGeometries[object.geometry] = true;
		if (object.texture) {
			usedGeometrieTextures[object.geometry] = true;
			usedTextures[object.texture] = true;
		}
		usedMaterials[object.material] = true;
	});
	world.lights.forEach(function (light) {
		usedLights[light.light] = true;
	});
	return Object.keys(usedBounds).map(function (name) {
		return makeFunctionDeclaration('bound', name, 'bounds');
	}).join('') + Object.keys(usedGeometries).map(function (name) {
		var params, f = '', fs;
		if (SimpleRayTracer.geometry[name].distance) {
			f = makeFunctionDeclaration('geometry', name, 'distance');
			params = SimpleRayTracer.geometry[name].params.map(function (param) {
				return param.name;
			}).join(',');
			if (params) {
				params = params + ',';
			}
			fs = makeFunctionsForDistanceField('geometry_' + name + '_distance(' + params);
			SimpleRayTracer.geometry[name].intersect = SimpleRayTracer.geometry[name].intersect || fs.intersect;
			SimpleRayTracer.geometry[name].normal = SimpleRayTracer.geometry[name].normal || fs.normal;
			SimpleRayTracer.geometry[name].texture = SimpleRayTracer.geometry[name].texture || fs.texture;
		}
		return f +
			makeFunctionDeclaration('geometry', name, 'intersect') +
			makeFunctionDeclaration('geometry', name, 'normal');
	}).join('') + Object.keys(usedGeometrieTextures).map(function (name) {
		return makeFunctionDeclaration('geometry', name, 'texture');
	}).join('') + Object.keys(usedMaterials).map(function (name) {
		return makeFunctionDeclaration('material', name, 'scatter');
	}).join('') + Object.keys(usedTextures).map(function (name) {
		return makeFunctionDeclaration('texture', name, 'color');
	}).join('') + Object.keys(usedLights).map(function (name) {
		return makeFunctionDeclaration('light', name, 'dir');
	}).join('') + [
		SimpleRayTracer.camera[world.camera.camera].global || '',
		makeFunctionDeclaration('camera', world.camera.camera, 'init'),
		makeFunctionDeclaration('camera', world.camera.camera, 'ray')
	].join('') + [
		'mat3 transp43 (mat4 m) {',
			'return mat3(',
				'm[0][0], m[0][1], m[0][2],',
				'm[1][0], m[1][1], m[1][2],',
				'm[2][0], m[2][1], m[2][2]',
			');',
		'}'
	].join('');
}

function makeGetIntersectionFunction (allObjects, groupId, group) {
	var name = 'getIntersection', boundCheck = '';
	if (groupId) {
		name += 'Group' + groupId;
		if (group.bound) {
			boundCheck = [
				'vec2 bounds = ' + makeFunctionCall('bound', 'bounds', group, 'rayStart, rayDir') + ';',
				'tMin = max(bounds.x, tMin);',
				'tMax = min(bounds.y, tMax);',
				'if (tMax <= tMin) {',
					'return result;',
				'}'
			].join('');
		}
		if (group.visible === false) {
			boundCheck = 'return result;';
		} else if (typeof group.visible === 'string') {
			boundCheck = [
				'if (!' + makeValueString(group.visible) + ') {',
					'return result;',
				'}'
			].join('') + boundCheck;
		}
	}
	return [
		'vec2 ' + name + '(vec3 rayStart, vec3 rayDir, float tMin, float tMax, bool simple, out vec3 localPoint) {',
			'vec2 result = vec2(0);',
			'vec2 current;',
			'vec3 currentLocalPoint;',
			'vec3 resultLocalPoint;',
			'vec3 localRayStart;',
			'vec3 localRayDir;',
			'mat4 invTransform;',
			boundCheck,
			group.ids.map(function (i) {
				var object, visible, pre = '', post = '', transform;
				if (i < 0) {
					return [
						'current = getIntersectionGroup' + (-i) + '(rayStart, rayDir, tMin, tMax, simple, currentLocalPoint);',
						'if (bool(current.x)) {',
							'if (simple) {',
								'return vec2(1, 0);',
							'}',
							'result = current;',
							'resultLocalPoint = currentLocalPoint;',
							'tMax = result.y;',
						'}'
					].join('');
				}
				object = allObjects[i];
				visible = object.visible;
				if (visible === false) {
					return '';
				} else if (typeof visible === 'string') {
					pre = 'if (' + makeValueString(visible) + ') {';
					post = '}';
				}
				if (object.invTransform) {
					transform = [
						'invTransform = ' + makeValueString(object.invTransform, 'mat4') + ';',
						'localRayStart = (invTransform * vec4(rayStart, 1)).xyz;',
						'localRayDir = (invTransform * vec4(rayDir, 0)).xyz;'
					].join('');
				} else {
					transform = 'localRayStart = rayStart; localRayDir = rayDir;';
				}
				return [
					pre,
					transform,
					'current = ' +
						makeFunctionCall('geometry', 'intersect', object,
							'localRayStart, localRayDir, tMin, tMax, simple') + ';',
					'if (bool(current.x)) {',
						'if (simple) {',
							'return vec2(1, 0);',
						'}',
						'result = vec2(' + (i + 1) + ', current.y);',
						'resultLocalPoint = localRayStart + result.y * localRayDir;',
						'tMax = result.y;',
					'}',
					post
				].join('');
			}).join(''),
			'localPoint = resultLocalPoint;',
			'return result;',
		'}'
	].join('');
}

function makeGetIntersectionFunctions (allObjects, allGroups) {
	return allGroups.map(function (group, i) {
		return makeGetIntersectionFunction(allObjects, i ? String(i) : '', group);
	}).reverse().join('');
}

function makeGetNormalFunction (objects) {
	return [
		'vec3 getNormal (int o, vec3 point) {',
			objects.map(function (object, i) {
				var mult = '';
				if (object.invTransform) {
					mult = 'transp43(' + makeValueString(object.invTransform, 'mat4') + ') * ';
				}
				return [
					'if (o == ' + (i + 1) + ') {',
						'return ' + mult + makeFunctionCall('geometry', 'normal', object, 'point') + ';',
					'}'
				].join('');
			}).join(''),
		'}'
	].join('');
}

function makeGetBaseColorFunction (objects) {
	return [
		'vec3 getBaseColor (int o, vec3 point) {',
			objects.map(function (object, i) {
				var color = object.texture ?
					makeFunctionCall('texture', 'color', object,
						makeFunctionCall('geometry', 'texture', object, 'point')
					) :
					makeValueString(object.color || [1, 1, 1], 'vec3');
				return [
					'if (o == ' + (i + 1) + ') {',
						'return ' + color + ';',
					'}'
				].join('');
			}).join(''),
		'}'
	].join('');
}

function makeGetScatterFunction (objects) {
	return [
		'vec3 getScatter (int o, vec3 inDir, vec3 normal, bool outside) {',
			objects.map(function (object, i) {
				return [
					'if (o == ' + (i + 1) + ') {',
						'return ' + makeFunctionCall('material', 'scatter', object, 'inDir, normal, outside') + ';',
					'}'
				].join('');
			}).join(''),
		'}'
	].join('');
}

function makeGetLightParamFunction (objects) {
	return [
		'vec4 getLightParam (int o) {',
			objects.map(function (object, i) {
				var lightParam = object.lightParam || SimpleRayTracer.material[object.material].defaultLightParam;
				return [
					'if (o == ' + (i + 1) + ') {',
						'return ' + makeValueString(lightParam, 'vec4') + ';',
					'}'
				].join('');
			}).join(''),
		'}'
	].join('');
}

function makeGetLightFunction (lights) {
	return [
		'float getSingleLight (vec3 pos, vec3 normal, vec3 reflected, vec3 dir, vec4 lightParam) {',
			'float d = length(dir);',
			'vec3 localPoint;',
			'if (d < 0.01) {',
				'return lightParam.x;',
			'}',
			'dir = dir / d;',
			'if (!bool(getIntersection(pos, dir, 0.01, d, true, localPoint).x)) {',
				'return lightParam.y * max(0.0, dot(dir, normal)) +',
					'lightParam.z * (lightParam.w + 2.0) / (2.0 * PI) * pow(max(0.0, dot(dir, reflected)), lightParam.w);',
			'}',
			'return 0.0;',
		'}',

		'vec3 getLight (vec3 pos, vec3 inDir, vec3 normal, vec4 lightParam) {',
			'vec3 reflected = reflect(normalize(inDir), normal);',
			'vec3 light = vec3(0);',
			lights.map(function (light) {
				return 'light += getSingleLight(pos, normal, reflected,' +
					makeFunctionCall('light', 'dir', light, 'pos') + ', lightParam) * ' +
					makeValueString(light.color || [1, 1, 1], 'vec3') + ';';
			}).join(''),
			'return light;',
		'}'
	].join('');
}

function makeGetBackgroundColorFunction (background) {
	if (!background.texture) {
		return [
			'vec3 getBackgroundColor (vec3 dir) {',
				'return ' + makeValueString(background.color || [1, 1, 1], 'vec3') + ';',
			'}'
		].join('');
	}
	return [
		'vec3 getBackgroundColor (vec3 dir) {',
			'float u = dir.x == 0.0 && dir.z == 0.0 ? 0.0 : atan(dir.x, -dir.z);',
			'u = 0.5 * (u / PI + 1.0);',
			'float v = 0.5 * (normalize(dir).y + 1.0);',
			'return ' + makeFunctionCall('texture', 'color', background, 'vec2(u, v)') + ';',
		'}'
	].join('');
}

function makeRayColorFunction (recursions, hasLights, debug) {
	var noIntersection;
	if (debug === 'normal') {
		return [
			'vec3 rayColor (vec3 rayStart, vec3 rayDir, float maxDist) {',
				'vec3 localPoint;',
				'vec2 intersection = getIntersection(rayStart, rayDir, 0.0, maxDist, false, localPoint);',
				'if (bool(intersection.x)) {',
					'return 0.5 * (getNormal(int(intersection.x), localPoint) + vec3(1));',
				'}',
				'return vec3(0);',
			'}'
		].join('');
	}
	if (debug === 'distance') {
		return [
			'vec3 rayColor (vec3 rayStart, vec3 rayDir, float maxDist) {',
				'vec3 localPoint;',
				'vec2 intersection = getIntersection(rayStart, rayDir, 0.0, maxDist, false, localPoint);',
				'if (bool(intersection.x)) {',
					'return vec3(intersection.y / maxDist);',
				'}',
				'return vec3(0);',
			'}'
		].join('');
	}
	if (!hasLights) {
		noIntersection = [
			'resultColor += colorMask * getBackgroundColor(rayDir);',
			'return resultColor;'
		].join('');
	} else {
		noIntersection = [
			'if (i == 0) {',
				'return getBackgroundColor(rayDir);',
			'} else {',
				'return resultColor;',
			'}'
		].join('');
	}
	return [
		'vec3 rayColor (vec3 rayStart, vec3 rayDir, float maxDist) {',
			'vec3 resultColor = vec3(0);',
			'vec3 colorMask = vec3(1);',
			'vec3 localPoint;',
			'for (int i = 0; i < ' + recursions + '; i++) {',
				'vec2 intersection = getIntersection(rayStart, rayDir, 0.001, maxDist, false, localPoint);',
				'if (!bool(intersection.x)) {',
					noIntersection,
				'}',
				'int o = int(intersection.x);',
				'vec3 point = rayStart + intersection.y * rayDir;',
				'rayStart = point;',
				'vec3 normal = getNormal(o, localPoint);',
				'bool outside = dot(rayDir, normal) < 0.0;',
				'normal = faceforward(normal, rayDir, normal);',
				'colorMask *= getBaseColor(o, localPoint);',
				//TODO vec4 lightParam = getLightParam(o); if (lightParam.x < 0) return resultColor + colorMask;
				hasLights ? 'resultColor += getLight(point, rayDir, normal, getLightParam(o)) * colorMask;' : '',
				'rayDir = getScatter(o, rayDir, normal, outside);',
				'float l = length(rayDir);',
				'if (l < 0.001) {',
					'return resultColor;',
				'}',
			'}',
			'return resultColor;',
		'}'
	].join('');
}

SimpleRayTracer.prototype.getTexture = function (image) {
	var texture = this.gl.createTexture(), index = this.textureCount;
	if (typeof image === 'string') {
		this.loadTexture(index, texture);
		SimpleRayTracer.loadImage(image, function (image) {
			this.loadTexture(index, texture, image);
		}.bind(this));
	} else if (typeof image.then === 'function') {
		this.loadTexture(index, texture);
		image.then(function (image) {
			this.loadTexture(index, texture, image);
		}.bind(this));
	} else {
		this.loadTexture(index, texture, image);
	}
	return index;
};

SimpleRayTracer.prototype.loadTexture = function (index, texture, image) {
	function isPowerOf2 (n) {
		/*jshint bitwise: false*/
		return n & (n - 1) === 0;
	}

	this.gl.activeTexture(this.gl.TEXTURE0 + index);
	this.gl.bindTexture(this.gl.TEXTURE_2D, texture);
	if (image) {
		this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, this.gl.RGBA, this.gl.UNSIGNED_BYTE, image);
		if (isPowerOf2(image.width) && isPowerOf2(image.height)) {
			this.gl.generateMipmap(this.gl.TEXTURE_2D);
		} else {
			this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_S, this.gl.CLAMP_TO_EDGE);
			this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_WRAP_T, this.gl.CLAMP_TO_EDGE);
			this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MIN_FILTER, this.gl.LINEAR);
		}
	} else {
		this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, 1, 1, 0,
			this.gl.RGBA, this.gl.UNSIGNED_BYTE, new Uint8Array([255, 255, 255, 255]));
	}
};

SimpleRayTracer.prototype.addParam = function (name, type, value) {
	if (this.parameters[name]) {
		if (this.parameters[name].type !== type) {
			throw new Error('Parameter already exists with different type');
		}
		return;
	}
	this.parameters[name] = {type: type, value: value};
};

SimpleRayTracer.prototype.addParams = function (data, group) {
	extractParamGroup(data, group).forEach(function (param) {
		if (typeof data[param.name] !== 'string') {
			this.addParam('sampler_' + data[param.name], param.type, data[param.name]);
		} else {
			this.addParam(data[param.name], param.type, param.value);
		}
	}, this);
};

SimpleRayTracer.prototype.setParam = function (name, value) {
	if (!this.parameters[name]) {
		throw new Error('Unknown parameter');
	}
	if (this.parameters[name].location === undefined) {
		this.parameters[name].value = value;
		return;
	}
	switch (this.parameters[name].type) {
	case 'bool':
		this.gl.uniform1i(this.parameters[name].location, value ? 1 : 0);
		break;
	case 'int':
	case 'sampler2D':
		this.gl.uniform1i(this.parameters[name].location, value);
		break;
	case 'float':
		this.gl.uniform1f(this.parameters[name].location, value);
		break;
	case 'vec2':
		this.gl.uniform2fv(this.parameters[name].location, value);
		break;
	case 'vec3':
		this.gl.uniform3fv(this.parameters[name].location, value);
		break;
	case 'vec4':
		this.gl.uniform4fv(this.parameters[name].location, value);
		break;
	case 'mat2':
		this.gl.uniformMatrix2fv(this.parameters[name].location, false, value);
		break;
	case 'mat3':
		this.gl.uniformMatrix3fv(this.parameters[name].location, false, value);
		break;
	case 'mat4':
		this.gl.uniformMatrix4fv(this.parameters[name].location, false, value);
	}
};

SimpleRayTracer.prototype.setCamera = function (camera) {
	if (!camera.camera) {
		camera.camera = 'default';
	}
	this.world.camera = camera;
	this.addParams(camera, 'camera');
};

SimpleRayTracer.prototype.setBackground = function (background) {
	this.world.background = background;
	this.addParams(background, 'texture');
};

SimpleRayTracer.prototype.addGroup = function (bounds, group) {
	bounds.ids = [];
	this.world.groups[group || 0].ids.push(-this.world.groups.length);
	this.world.groups.push(bounds);
	this.addParams(bounds, 'bound');
	return this.world.groups.length - 1;
};

SimpleRayTracer.prototype.addObject = function (object, group) {
	this.world.groups[group || 0].ids.push(this.world.objects.length);
	this.world.objects.push(object);
	this.addParams(object, 'geometry');
	this.addParams(object, 'material');
	this.addParams(object, 'texture');
};

SimpleRayTracer.prototype.addLight = function (light) {
	this.world.lights.push(light);
	this.addParams(light, 'light');
};

SimpleRayTracer.prototype.getFragmentShader = function (options) {
	return [
		'#define PI 3.14159265358979323846\n',
		'precision mediump float;',

		Object.keys(this.parameters).map(function (param) {
			return 'uniform ' + this.parameters[param].type + ' u_' + param + ';';
		}, this).join(''),

		makeRandomFunctions(),
		makeHelperFunctions(this.world),

		makeGetIntersectionFunctions(this.world.objects, this.world.groups),

		makeGetNormalFunction(this.world.objects),
		makeGetBaseColorFunction(this.world.objects),
		makeGetScatterFunction(this.world.objects),
		this.world.lights.length ?
			makeGetLightParamFunction(this.world.objects) + makeGetLightFunction(this.world.lights) :
			'',
		makeGetBackgroundColorFunction(this.world.background),

		makeRayColorFunction(options.iterations, this.world.lights.length, options.debug),

		'vec3 render (vec2 xy, vec2 resolution) {',
			'vec3 rayStart;',
			'vec3 rayDir;',
			'vec2 pos = (xy + vec2(random() - 0.5, random() - 0.5)) / resolution;',
			makeFunctionCall('camera', 'ray', this.world.camera, 'pos, rayStart, rayDir') + ';',
			'return rayColor(rayStart, rayDir, float(' + options.maxDist + '));',
		'}',

		'void main () {',
			'initRandom();',
			makeFunctionCall('camera', 'init', this.world.camera, 'u_resolution') + ';',
			'vec3 color = vec3(0);',
			'for (int i = 0; i < ' + options.sampleCount + '; i++) {',
				'color += render(gl_FragCoord.xy, u_resolution);',
			'}',
			'gl_FragColor = vec4(pow(color / float(' + options.sampleCount + '), vec3(' + options.gamma + ')), 1);',
		'}'
	].join('');
};

SimpleRayTracer.prototype.compile = function (options) {
	var vertexCode, vertexShader, fragmentCode, fragmentShader, program,
		vertexAttrib, vertexBuffer;

	options = options || {};
	options.maxDist = options.maxDist || 1000;
	options.iterations = options.iterations || 50;
	options.sampleCount = options.sampleCount || 100;
	options.gamma = options.gamma || 0.5;

	//vertex shader
	vertexCode = [
		'attribute vec2 vertex;',
		'void main () {',
			'gl_Position = vec4(vertex, 1, 1);',
		'}'
	].join('');
	vertexShader = this.gl.createShader(this.gl.VERTEX_SHADER);
	this.gl.shaderSource(vertexShader, vertexCode);
	this.gl.compileShader(vertexShader);

	//fragment shader
	fragmentCode = this.getFragmentShader(options);
	fragmentShader = this.gl.createShader(this.gl.FRAGMENT_SHADER);
	this.gl.shaderSource(fragmentShader, fragmentCode);
	this.gl.compileShader(fragmentShader);

	//shader program
	program = this.gl.createProgram();
	this.gl.attachShader(program, vertexShader);
	this.gl.attachShader(program, fragmentShader);
	this.gl.linkProgram(program);
	this.gl.useProgram(program);

	//attributes
	vertexAttrib = this.gl.getAttribLocation(program, 'vertex');
	this.gl.enableVertexAttribArray(vertexAttrib);
	vertexBuffer = this.gl.createBuffer();
	this.gl.bindBuffer(this.gl.ARRAY_BUFFER, vertexBuffer);
	this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array([
		1, 1,
		-1, 1,
		1, -1,
		-1, -1
	]), this.gl.STATIC_DRAW);
	this.gl.vertexAttribPointer(vertexAttrib, 2, this.gl.FLOAT, false, 0, 0);

	//uniforms
	Object.keys(this.parameters).forEach(function (param) {
		this.parameters[param].location = this.gl.getUniformLocation(program, 'u_' + param);
		this.setParam(param, this.parameters[param].value);
	}, this);

	return fragmentCode; //for debug
};

SimpleRayTracer.prototype.render = function () {
	if (this.gl.canvas.width !== this.currentSize[0] || this.gl.canvas.height !== this.currentSize[1]) {
		this.currentSize = [this.gl.canvas.width, this.gl.canvas.height];
		this.gl.viewport(0, 0, this.gl.canvas.width, this.gl.canvas.height);
		this.setParam('resolution', this.currentSize);
	}
	this.gl.drawArrays(this.gl.TRIANGLE_STRIP, 0, 4);
};

return SimpleRayTracer;
})();