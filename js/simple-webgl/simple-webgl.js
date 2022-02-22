/*global SimpleRenderer: true*/
SimpleRenderer =
(function () {
"use strict";

function SimpleRenderer (gl, options) {
	this.gl = gl;
	this.options = options || {};
	if (this.options.texture) {
		this.initTexture(0, this.options.texture);
	}
	this.canvasDimensions = [0, 0];
	this.projectionData = [30 * Math.PI / 180, 1, 100];
	this.viewMatrix = SimpleRenderer.matrix.identity();
	this.createProgram();
}

SimpleRenderer.animate = function (callback) {
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

SimpleRenderer.initContext = function (canvas, color) {
	var gl, options = {};
	color = color || [0, 0, 0];
	if (color.length === 3 || color[3] === 1) {
		options.alpha = false;
	}
	gl = canvas.getContext('webgl', options) || canvas.getContext('experimental-webgl', options);
	gl.enable(gl.DEPTH_TEST);
	gl.enable(gl.CULL_FACE);
	gl.clearColor(color[0], color[1], color[2], color.length === 3 ? 1 : color[3]);
	return gl;
};

SimpleRenderer.loadImage = function (url, callback) {
	var image = new Image();
	image.onload = function () {
		callback(image);
	};
	image.src = url;
};

SimpleRenderer.matrix = {
	normalize: function (v) {
		var l = Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
		return [v[0] / l, v[1] / l, v[2] / l];
	},
	cross: function (a, b) {
		return [
			a[1] * b[2] - a[2] * b[1],
			a[2] * b[0] - a[0] * b[2],
			a[0] * b[1] - a[1] * b[0]
		];
	},
	vectorMultiply: function (a, b) {
		var a00 = a[0], a01 = a[1], a02 = a[2], a03 = a[3],
			a10 = a[4], a11 = a[5], a12 = a[6], a13 = a[7],
			a20 = a[8], a21 = a[9], a22 = a[10], a23 = a[11],
			a30 = a[12], a31 = a[13], a32 = a[14], a33 = a[15],
			b0 = b[0], b1 = b[1], b2 = b[2], b3 = 1, w;
		w = b0 * a03 + b1 * a13 + b2 * a23 + b3 * a33;
		return [
			(b0 * a00 + b1 * a10 + b2 * a20 + b3 * a30) / w,
			(b0 * a01 + b1 * a11 + b2 * a21 + b3 * a31) / w,
			(b0 * a02 + b1 * a12 + b2 * a22 + b3 * a32) / w
		];
	},
	identity: function () {
		return [
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		];
	},
	multiply: function (a, b) {
		var a00 = a[0], a01 = a[1], a02 = a[2], a03 = a[3],
			a10 = a[4], a11 = a[5], a12 = a[6], a13 = a[7],
			a20 = a[8], a21 = a[9], a22 = a[10], a23 = a[11],
			a30 = a[12], a31 = a[13], a32 = a[14], a33 = a[15],
			b0, b1, b2, b3, ab = [];

		b0 = b[0];
		b1 = b[1];
		b2 = b[2];
		b3 = b[3];
		ab[0] = b0 * a00 + b1 * a10 + b2 * a20 + b3 * a30;
		ab[1] = b0 * a01 + b1 * a11 + b2 * a21 + b3 * a31;
		ab[2] = b0 * a02 + b1 * a12 + b2 * a22 + b3 * a32;
		ab[3] = b0 * a03 + b1 * a13 + b2 * a23 + b3 * a33;

		b0 = b[4];
		b1 = b[5];
		b2 = b[6];
		b3 = b[7];
		ab[4] = b0 * a00 + b1 * a10 + b2 * a20 + b3 * a30;
		ab[5] = b0 * a01 + b1 * a11 + b2 * a21 + b3 * a31;
		ab[6] = b0 * a02 + b1 * a12 + b2 * a22 + b3 * a32;
		ab[7] = b0 * a03 + b1 * a13 + b2 * a23 + b3 * a33;

		b0 = b[8];
		b1 = b[9];
		b2 = b[10];
		b3 = b[11];
		ab[8] = b0 * a00 + b1 * a10 + b2 * a20 + b3 * a30;
		ab[9] = b0 * a01 + b1 * a11 + b2 * a21 + b3 * a31;
		ab[10] = b0 * a02 + b1 * a12 + b2 * a22 + b3 * a32;
		ab[11] = b0 * a03 + b1 * a13 + b2 * a23 + b3 * a33;

		b0 = b[12];
		b1 = b[13];
		b2 = b[14];
		b3 = b[15];
		ab[12] = b0 * a00 + b1 * a10 + b2 * a20 + b3 * a30;
		ab[13] = b0 * a01 + b1 * a11 + b2 * a21 + b3 * a31;
		ab[14] = b0 * a02 + b1 * a12 + b2 * a22 + b3 * a32;
		ab[15] = b0 * a03 + b1 * a13 + b2 * a23 + b3 * a33;
		return ab;
	},
	transformationSequence: function () {
		var i, m = arguments[0];
		for (i = 1; i < arguments.length; i++) {
			m = SimpleRenderer.matrix.multiply(arguments[i], m);
		}
		return m;
	},
	inverse: function (m) {
		var m00 = m[0], m01 = m[1], m02 = m[2], m03 = m[3],
			m10 = m[4], m11 = m[5], m12 = m[6], m13 = m[7],
			m20 = m[8], m21 = m[9], m22 = m[10], m23 = m[11],
			m30 = m[12], m31 = m[13], m32 = m[14], m33 = m[15],

			tmp0 = m22 * m33, tmp1 = m32 * m23, tmp2 = m12 * m33, tmp3 = m32 * m13,
			tmp4 = m12 * m23, tmp5 = m22 * m13, tmp6 = m02 * m33, tmp7 = m32 * m03,
			tmp8 = m02 * m23, tmp9 = m22 * m03, tmp10 = m02 * m13, tmp11 = m12 * m03,
			tmp12 = m20 * m31, tmp13 = m30 * m21, tmp14 = m10 * m31, tmp15 = m30 * m11,
			tmp16 = m10 * m21, tmp17 = m20 * m11, tmp18 = m00 * m31, tmp19 = m30 * m01,
			tmp20 = m00 * m21, tmp21 = m20 * m01, tmp22 = m00 * m11, tmp23 = m10 * m01,

			t0 = (tmp0 * m11 + tmp3 * m21 + tmp4 * m31) - (tmp1 * m11 + tmp2 * m21 + tmp5 * m31),
			t1 = (tmp1 * m01 + tmp6 * m21 + tmp9 * m31) - (tmp0 * m01 + tmp7 * m21 + tmp8 * m31),
			t2 = (tmp2 * m01 + tmp7 * m11 + tmp10 * m31) - (tmp3 * m01 + tmp6 * m11 + tmp11 * m31),
			t3 = (tmp5 * m01 + tmp8 * m11 + tmp11 * m21) - (tmp4 * m01 + tmp9 * m11 + tmp10 * m21),
			d = 1 / (m00 * t0 + m10 * t1 + m20 * t2 + m30 * t3);

		return [
			d * t0, d * t1, d * t2, d * t3,

			d * ((tmp1 * m10 + tmp2 * m20 + tmp5 * m30) - (tmp0 * m10 + tmp3 * m20 + tmp4 * m30)),
			d * ((tmp0 * m00 + tmp7 * m20 + tmp8 * m30) - (tmp1 * m00 + tmp6 * m20 + tmp9 * m30)),
			d * ((tmp3 * m00 + tmp6 * m10 + tmp11 * m30) - (tmp2 * m00 + tmp7 * m10 + tmp10 * m30)),
			d * ((tmp4 * m00 + tmp9 * m10 + tmp10 * m20) - (tmp5 * m00 + tmp8 * m10 + tmp11 * m20)),

			d * ((tmp12 * m13 + tmp15 * m23 + tmp16 * m33) - (tmp13 * m13 + tmp14 * m23 + tmp17 * m33)),
			d * ((tmp13 * m03 + tmp18 * m23 + tmp21 * m33) - (tmp12 * m03 + tmp19 * m23 + tmp20 * m33)),
			d * ((tmp14 * m03 + tmp19 * m13 + tmp22 * m33) - (tmp15 * m03 + tmp18 * m13 + tmp23 * m33)),
			d * ((tmp17 * m03 + tmp20 * m13 + tmp23 * m23) - (tmp16 * m03 + tmp21 * m13 + tmp22 * m23)),

			d * ((tmp14 * m22 + tmp17 * m32 + tmp13 * m12) - (tmp16 * m32 + tmp12 * m12 + tmp15 * m22)),
			d * ((tmp20 * m32 + tmp12 * m02 + tmp19 * m22) - (tmp18 * m22 + tmp21 * m32 + tmp13 * m02)),
			d * ((tmp18 * m12 + tmp23 * m32 + tmp15 * m02) - (tmp22 * m32 + tmp14 * m02 + tmp19 * m12)),
			d * ((tmp22 * m22 + tmp16 * m02 + tmp21 * m12) - (tmp20 * m12 + tmp23 * m22 + tmp17 * m02))
		];
	},
	transpose: function (m) {
		return [
			m[0], m[4], m[8], m[12],
			m[1], m[5], m[9], m[13],
			m[2], m[6], m[10], m[14],
			m[3], m[7], m[11], m[15]
		];
	},
	rotateX: function (a) {
		var c = Math.cos(a), s = Math.sin(a);
		return [
			1,  0, 0, 0,
			0,  c, s, 0,
			0, -s, c, 0,
			0,  0, 0, 1
		];
	},
	rotateY: function (a) {
		var c = Math.cos(a), s = Math.sin(a);
		return [
			c, 0, -s, 0,
			0, 1,  0, 0,
			s, 0,  c, 0,
			0, 0,  0, 1
		];
	},
	rotateZ: function (a) {
		var c = Math.cos(a), s = Math.sin(a);
		return [
			c, s, 0, 0,
			-s, c, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		];
	},
	translate: function (x, y, z) {
		return [
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			x, y, z, 1
		];
	},
	scale: function (x, y, z) {
		return [
			x, 0, 0, 0,
			0, y, 0, 0,
			0, 0, z, 0,
			0, 0, 0, 1
		];
	},
	perspective: function (angle, a, zMin, zMax) {
		var t = 1 / Math.tan(angle * 0.5);
		return [
			t / a, 0, 0, 0,
			0, t, 0, 0,
			0, 0, (zMax + zMin) / (zMin - zMax), -1,
			0, 0, 2 * zMax * zMin / (zMin - zMax), 0
		];
	},
	lookAt: function (cameraPosition, target, up) {
		up = up || [0, 1, 0];
		var diff = [cameraPosition[0] - target[0], cameraPosition[1] - target[1], cameraPosition[2] - target[2]],
			zAxis = SimpleRenderer.matrix.normalize(diff),
			xAxis = SimpleRenderer.matrix.normalize(SimpleRenderer.matrix.cross(up, zAxis)),
			yAxis = SimpleRenderer.matrix.normalize(SimpleRenderer.matrix.cross(zAxis, xAxis));

		return [
			xAxis[0], xAxis[1], xAxis[2], 0,
			yAxis[0], yAxis[1], yAxis[2], 0,
			zAxis[0], zAxis[1], zAxis[2], 0,
			cameraPosition[0], cameraPosition[1], cameraPosition[2], 1
		];
	}
};

SimpleRenderer.prototype.initTexture = function (index, image) {
	var texture = this.gl.createTexture();
	if (typeof image === 'string') {
		this.loadTexture(index, texture);
		SimpleRenderer.loadImage(image, function (image) {
			this.loadTexture(index, texture, image);
		}.bind(this));
		return;
	}
	if (typeof image.then === 'function') {
		this.loadTexture(index, texture);
		image.then(function (image) {
			this.loadTexture(index, texture, image);
		}.bind(this));
		return;
	}
	this.loadTexture(index, texture, image);
};

SimpleRenderer.prototype.loadTexture = function (index, texture, image) {
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
		this.gl.texImage2D(
			this.gl.TEXTURE_2D, 0, this.gl.RGBA, 1, 1, 0, this.gl.RGBA, this.gl.UNSIGNED_BYTE,
			new Uint8Array([255, 255, 255, 255])
		);
	}
};

SimpleRenderer.prototype.createProgram = function () {
	var vertexCode, vertexShader, fragmentCode, fragmentShader,
		normal = this.options.directionalLight || this.options.pointLight;
	//TODO point -> shiny, spot?
	vertexCode = [
		'attribute vec4 a_color;',
		this.options.texture ? 'attribute vec2 a_texture;' : '',
		normal ? 'attribute vec3 a_normal;' : '',
		'attribute vec4 a_position;',
		'uniform mat4 u_mvp;',
		normal ? 'uniform mat4 u_inverseTransp;' : '',
		this.options.pointLight ? 'uniform mat4 u_model;' : '',
		'uniform vec3 u_ambientColor;',
		this.options.directionalLight ? 'uniform vec3 u_directionalColor;' : '',
		this.options.directionalLight ? 'uniform vec3 u_directionalDir;' : '',
		'varying vec4 v_color;',
		this.options.texture ? 'varying vec2 v_texture;' : '',
		'varying vec3 v_light;',
		this.options.pointLight ? 'varying vec3 v_position;' : '',
		this.options.pointLight ? 'varying vec3 v_normal;' : '',
		'void main() {',
			'gl_Position = u_mvp * a_position;',
			normal ? 'vec3 normal = normalize(mat3(u_inverseTransp) * a_normal);' : '',
			'v_color = a_color;',
			this.options.texture ? 'v_texture = a_texture;' : '',
			this.options.directionalLight ?
				'v_light = u_ambientColor + max(dot(normal, u_directionalDir), 0.) * u_directionalColor;' :
				'v_light = u_ambientColor;',
			this.options.pointLight ? 'v_position = vec3(u_model * a_position);' : '',
			this.options.pointLight ? 'v_normal = normal;' : '',
		'}'
	].join('');
	fragmentCode = [
		'precision mediump float;',
		'varying vec4 v_color;',
		this.options.texture ? 'varying vec2 v_texture;' : '',
		'varying vec3 v_light;',
		this.options.pointLight ? 'varying vec3 v_position;' : '',
		this.options.pointLight ? 'varying vec3 v_normal;' : '',
		this.options.texture ? 'uniform sampler2D u_texture;' : '',
		this.options.pointLight ? 'uniform vec3 u_pointColor;' : '',
		this.options.pointLight ? 'uniform vec3 u_pointPos;' : '',
		this.options.fog ? 'uniform vec3 u_fogColor;' : '',
		this.options.fog ? 'uniform float u_fogNear;' : '',
		this.options.fog ? 'uniform float u_fogFar;' : '',
		'void main() {',
			this.options.pointLight ? 'vec3 light = v_light +' +
				'max(dot(normalize(u_pointPos - v_position), normalize(v_normal)), 0.) * u_pointColor;' :
				'vec3 light = v_light;',
			this.options.texture ? 'vec4 color = v_color * texture2D(u_texture, v_texture);' : 'vec4 color = v_color;',
			this.options.fog ? 'color = mix(color, vec4(u_fogColor, 1.),' +
				'smoothstep(u_fogNear, u_fogFar, gl_FragCoord.z));' : '',
			'gl_FragColor = color * vec4(light, 1.);',
		'}'
	].join('');

	vertexShader = this.gl.createShader(this.gl.VERTEX_SHADER);
	this.gl.shaderSource(vertexShader, vertexCode);
	this.gl.compileShader(vertexShader);

	fragmentShader = this.gl.createShader(this.gl.FRAGMENT_SHADER);
	this.gl.shaderSource(fragmentShader, fragmentCode);
	this.gl.compileShader(fragmentShader);

	this.program = this.gl.createProgram();
	this.gl.attachShader(this.program, vertexShader);
	this.gl.attachShader(this.program, fragmentShader);
	this.gl.linkProgram(this.program);

	this.attributes = {};
	this.attributeNames = [];
	this.uniforms = {};

	this.gl.useProgram(this.program);
	this.initAttribute('color');
	if (this.options.texture) {
		this.initAttribute('texture');
	}
	if (normal) {
		this.initAttribute('normal');
	}
	this.initAttribute('position');
	this.initUniform('mvp');
	this.initUniform('ambientColor', [1, 1, 1]);
	if (this.options.texture) {
		this.initUniform('texture', 0);
	}
	if (normal) {
		this.initUniform('inverseTransp', SimpleRenderer.matrix.identity());
	}
	if (this.options.directionalLight) {
		this.initUniform('directionalColor', [0, 0, 0]);
		this.initUniform('directionalDir', [0, 1, 0]);
	}
	if (this.options.pointLight) {
		this.initUniform('model', SimpleRenderer.matrix.identity());
		this.initUniform('pointColor', [0, 0, 0]);
		this.initUniform('pointPos', [0, 10, 0]);
	}
	if (this.options.fog) {
		this.initUniform('fogColor', [0, 0, 0]);
		this.initUniform('fogNear', [0]);
		this.initUniform('fogFar', [1]);
	}
};

SimpleRenderer.prototype.initAttribute = function (name) {
	this.attributes[name] = this.gl.getAttribLocation(this.program, 'a_' + name);
	this.gl.enableVertexAttribArray(this.attributes[name]);
	this.attributeNames.push(name);
};

SimpleRenderer.prototype.initUniform = function (name, value) {
	this.uniforms[name] = this.gl.getUniformLocation(this.program, 'u_' + name);
	if (value !== undefined) {
		this.updateUniform(name, value);
	}
};

SimpleRenderer.prototype.updateUniform = function (name, value) {
	var type = '3', param = [this.uniforms[name]];
	if (name === 'texture') {
		this.gl.uniform1i(this.uniforms[name], value);
		return;
	}
	if (['mvp', 'inverseTransp', 'model'].indexOf(name) > -1) {
		type = 'Matrix4';
		param.push(false);
	}
	if (['fogNear', 'fogFar'].indexOf(name) > -1) {
		type = '1';
	}
	param.push(value);
	this.gl['uniform' + type + 'fv'].apply(this.gl, param);
};

SimpleRenderer.prototype.setProjectionData = function (data) {
	this.projectionData = data;
	this.viewProjection = false;
};

SimpleRenderer.prototype.setViewMatrix = function (matrix) {
	this.viewMatrix = matrix;
	this.viewProjection = false;
};

SimpleRenderer.prototype.setAmbientLight = function (color) {
	this.updateUniform('ambientColor', color);
};

SimpleRenderer.prototype.setDirectionalLight = function (color) {
	if (!this.options.directionalLight) {
		throw new Error('Directional light not enabled!');
	}
	this.updateUniform('directionalColor', color);
};

SimpleRenderer.prototype.setDirectionalDir = function (dir) {
	if (!this.options.directionalLight) {
		throw new Error('Directional light not enabled!');
	}
	this.updateUniform('directionalDir', SimpleRenderer.matrix.normalize(dir));
};

SimpleRenderer.prototype.setPointLight = function (color) {
	if (!this.options.pointLight) {
		throw new Error('Point light not enabled!');
	}
	this.updateUniform('pointColor', color);
};

SimpleRenderer.prototype.setPointPos = function (pos) {
	if (!this.options.pointLight) {
		throw new Error('Point light not enabled!');
	}
	this.updateUniform('pointPos', pos);
};

SimpleRenderer.prototype.setFogColor = function (color) {
	if (!this.options.fog) {
		throw new Error('Fog not enabled!');
	}
	this.updateUniform('fogColor', color);
};

SimpleRenderer.prototype.setFogNearFar = function (limit) {
	if (!this.options.fog) {
		throw new Error('Fog not enabled!');
	}
	if (limit[0] < 0 || limit[0] > limit[1] || limit[1] > 1) {
		throw new Error('Wrong values for limit!');
	}
	this.updateUniform('fogNear', [limit[0]]);
	this.updateUniform('fogFar', [limit[1]]);
};

SimpleRenderer.prototype.getViewProjectionMatrix = function () {
	if (!this.viewProjection) {
		this.viewProjection = SimpleRenderer.matrix.multiply(
			SimpleRenderer.matrix.perspective(
				this.projectionData[0],
				this.canvasDimensions[0] / this.canvasDimensions[1],
				this.projectionData[1],
				this.projectionData[2]
			),
			this.viewMatrix
		);
	}
	return this.viewProjection;
};

SimpleRenderer.prototype.updateData = function (model) {
	var w = this.gl.canvas.width, h = this.gl.canvas.height;
	if (this.canvasDimensions[0] !== w || this.canvasDimensions[1] !== h) {
		this.gl.viewport(0, 0, w, h);
		this.canvasDimensions = [w, h];
		this.viewProjection = false;
	}
	this.updateUniform('mvp', SimpleRenderer.matrix.multiply(this.getViewProjectionMatrix(), model.getMatrix()));
	if (this.options.directionalLight || this.options.pointLight) {
		this.updateUniform(
			'inverseTransp',
			SimpleRenderer.matrix.transpose(SimpleRenderer.matrix.inverse(model.getMatrix()))
		);
	}
	if (this.options.pointLight) {
		this.updateUniform('model', model.getMatrix());
	}
	model.bindBuffers(this.attributes, this.currentModel !== model);
	this.currentModel = model;
};

SimpleRenderer.prototype.createModel = function () {
	return new SimpleModel(this.gl, this.attributeNames);
};

SimpleRenderer.prototype.render = function (model, noClear) {
	/*jshint bitwise: false*/
	if (!noClear) {
		this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
	}
	this.gl.useProgram(this.program);
	this.updateData(model);
	this.gl.drawArrays(this.gl.TRIANGLES, 0, model.getCount());
};

function SimpleModel (gl, names) {
	this.gl = gl;
	this.matrix = SimpleRenderer.matrix.identity();
	this.names = names;
	this.buffers = {};
	this.data = {};
	this.names.forEach(function (name) {
		this.buffers[name] = this.gl.createBuffer();
		this.data[name] = [];
	}.bind(this));
}

SimpleModel.prototype.createSubModel = function (anchor) {
	var model = new SimpleModel(this.gl, this.names);
	model.parent = this;
	if (anchor) {
		model.anchor = SimpleRenderer.matrix.translate(anchor[0], anchor[1], anchor[2]);
	}
	return model;
};

SimpleModel.prototype.bindBuffers = function (pointers, force) {
	if (!this.needsUpdate && !force) {
		return;
	}
	this.names.forEach(function (name) {
		var count = 3;
		if (name === 'texture') {
			count = 2;
		}
		this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.buffers[name]);
		if (this.needsUpdate) {
			this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(this.data[name]), this.gl.STATIC_DRAW);
		}
		this.gl.vertexAttribPointer(pointers[name], count, this.gl.FLOAT, false, 0, 0);
	}.bind(this));
	this.needsUpdate = false;
};

SimpleModel.prototype.addRaw = function (position, data, matrix) {
	var i, vector;
	data = data || {};

	if (matrix) {
		for (i = 0; i < position.length / 3; i++) {
			vector = [position[3 * i], position[3 * i + 1], position[3 * i + 2]];
			vector = SimpleRenderer.matrix.vectorMultiply(matrix, vector);
			position[3 * i] = vector[0];
			position[3 * i + 1] = vector[1];
			position[3 * i + 2] = vector[2];
		}
	}
	this.data.position = this.data.position.concat(position);

	if (!data.color) {
		data.color = position.map(function () {
			return 1;
		});
	} else if (data.color.length < position.length) {
		data.color = position.map(function (p, i) {
			return data.color[i % data.color.length];
		});
	}
	this.data.color = this.data.color.concat(data.color);

	if (this.names.indexOf('normal') > -1) {
		if (!data.normal) {
			data.normal = [];
			for (i = 0; i < position.length / 9; i++) {
				vector = SimpleRenderer.matrix.cross(
					[
						position[9 * i + 3] - position[9 * i],
						position[9 * i + 4] - position[9 * i + 1],
						position[9 * i + 5] - position[9 * i + 2]
					],
					[
						position[9 * i + 6] - position[9 * i],
						position[9 * i + 7] - position[9 * i + 1],
						position[9 * i + 8] - position[9 * i + 2]
					]
				);
				data.normal = data.normal.concat(vector, vector, vector);
			}
		} else if (matrix) {
			matrix = SimpleRenderer.matrix.transpose(SimpleRenderer.matrix.inverse(matrix));
			for (i = 0; i < data.normal.length / 3; i++) {
				vector = [data.normal[3 * i], data.normal[3 * i + 1], data.normal[3 * i + 2]];
				vector = SimpleRenderer.matrix.vectorMultiply(matrix, vector);
				data.normal[3 * i] = vector[0];
				data.normal[3 * i + 1] = vector[1];
				data.normal[3 * i + 2] = vector[2];
			}
		}
		this.data.normal = this.data.normal.concat(data.normal);
	}

	function getZeroArray (len) {
		var i, array = [];
		for (i = 0; i < len; i++) {
			array.push(0);
		}
		return array;
	}

	if (this.names.indexOf('texture') > -1) {
		if (!data.texture) {
			data.texture = getZeroArray(position.length * 2 / 3);
		} else if (data.texture.length < position.length * 2 / 3) {
			data.texture = getZeroArray(position.length * 2 / 3).map(function (z, i) {
				return data.texture[i % data.texture.length];
			});
		}
		this.data.texture = this.data.texture.concat(data.texture);
	}

	this.needsUpdate = true;
};

SimpleModel.prototype.addCube = function (data, matrix) {
	this.addRaw([
		-1, -1, -1,
		-1, 1, -1,
		1, -1, -1,
		-1, 1, -1,
		1, 1, -1,
		1, -1, -1,

		-1, -1, 1,
		1, -1, 1,
		-1, 1, 1,
		-1, 1, 1,
		1, -1, 1,
		1, 1, 1,

		-1, 1, -1,
		-1, 1, 1,
		1, 1, -1,
		-1, 1, 1,
		1, 1, 1,
		1, 1, -1,

		-1, -1, -1,
		1, -1, -1,
		-1, -1, 1,
		-1, -1, 1,
		1, -1, -1,
		1, -1, 1,

		-1, -1, -1,
		-1, -1, 1,
		-1, 1, -1,
		-1, -1, 1,
		-1, 1, 1,
		-1, 1, -1,

		1, -1, -1,
		1, 1, -1,
		1, -1, 1,
		1, -1, 1,
		1, 1, -1,
		1, 1, 1
	], data, matrix);
};

SimpleModel.prototype.canUseCachedMatrix = function () {
	if (!this.cachedMatrix) {
		return false;
	}
	if (!this.parent) {
		return true;
	}
	return this.parent.canUseCachedMatrix();
};

SimpleModel.prototype.setMatrix = function (matrix) {
	this.matrix = this.anchor ? SimpleRenderer.matrix.multiply(this.anchor, matrix) : matrix;
	this.cachedMatrix = false;
};

SimpleModel.prototype.getMatrix = function () {
	if (!this.canUseCachedMatrix()) {
		this.cachedMatrix = this.parent ? SimpleRenderer.matrix.multiply(this.parent.getMatrix(), this.matrix) : this.matrix;
	}
	return this.cachedMatrix;
};

SimpleModel.prototype.getCount = function () {
	return this.data.position.length / 3;
};

return SimpleRenderer;
})();