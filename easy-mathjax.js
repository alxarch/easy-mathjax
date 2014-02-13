/* global document, window */
; (function () {
	var _hasOwn = Object.prototype.hasOwnProperty;

	var $$ = function (selector) {
		[].slice.apply(document.querySelectorAll(selector));
	};

	var remove = function (node) {
		if (typeof node === "string") {
			node = $$(node);
		}
		[].concat(node).forEach(function (n) {
			if (n && n.parentNode) {
				n.parentNode.removeChild(n);
			}
		});
	};

	var extend = function (base) {
		if (typeof base !== "object") {
			return base;
		}
		var extenders = [].slice.call(arguments, 1);
		var ext, key;
		var total = extenders.length;
		for (var i = 0; i < total; i++) {
			ext = extenders[i];
			if (typeof ext !== "object") {
				continue;
			}
			for (key in ext) {
				if (_hasOwn.call(ext, key)) {
					base[key] = ext[key];
				}
			}
		}
		return base;
	};

	var EasyMathJax = function (options) {
		this.options = extend({
			url: "http://cdn.mathjax.org/mathjax/latest/MathJax.js"
		}, options);
	};
	
	var matchFontUrl = /url\s*\(\s*['"]([^\)]+fonts\/HTML\-CSS\/([^\/]+\/(?:woff|otf|eot)\/[^-]+\-(?:Regular|Italic|Bold|Bolditalic)\.(?:woff|eot|otf)))['"]\s*\)/g;

	EasyMathJax.prototype = {
		injected: function () {
			var injected = [];
			var el = this.begin;
			while (el && el.nextElementSibling !== this.end) {
				injected.push(el);
				el = el.nextElementSibling;
			}
			injected.push(this.end);
			return injected;
		},
		clean: function () {
			remove(this.injected());

			remove("#MathJax_Message");
			remove("#MathJax_Font_Test");
			remove(".MathJax_Preview");
			var hidden = document.querySelector("#MathJax_Hidden");
			if (hidden) {
				remove(hidden.parentNode);
			}

			if (!this.options.debug) {
				remove("script[id^=MathJax]");
				$$("[id^='MathJax']").forEach(function (s) {
					s.removeAttribute('id');
				});
			}
			return this;
		},
		css: function () {
			var fonts = {};
			var css = [];
		
			var fixFontUrl = function (line) {
				return line.replace(matchFontUrl, function(ma, url, font) {
					fonts[font] = url;
					return "url('fonts/mathjax/" + font + "')";
				});
			};

			var parseLine = function (line) {
				if (line.match(/@font\-face/)) {
					line = fixFontUrl(line);
				}

				css.push(line);
			};

			this.injected().forEach(function (el) {
				if (el.tagName.toLowerCase() === "style") {
					el.innerHTML.split("\n").forEach(parseLine);
				}
			});

			return {
				contents: css.join("\n"),
				fonts: fonts
			};
		},
		onReady: function (callback) {
			var ready = null;
			var checkReady = function () {
				if (window.MathJax.isReady) {
					clearInterval(ready);
					if (typeof callback === "function") {
						callback();
					}
				}
				return window.MathJax.isReady;
			};

			if (!checkReady()) {
				var hub = null;
				var checkHub = function () {
					if (window.MathJax.Hub != null) {
						clearInterval(hub);
						ready = setInterval(checkReady, 50);
					}
				};

				hub = setInterval(checkHub, 50);
			}
			return this;
		},
		inject: function (callback) {
			window.MathJax = extend({}, window.MathJax, this.options.config, {
				delayStartupUntil: "configured",
				skipStartupTypeset: true
			});
			
			// Inject script tags to head.
			// Pad it with identifiable script tags.
			this.begin = document.createElement('script');
			this.begin.type = "mathjax/begin";
			document.head.appendChild(this.begin);

			this.script = document.createElement('script');
			this.script.src = this.options.url;
			document.head.appendChild(this.script);

			this.end = document.createElement('script');
			this.end.type = "mathjax/end";
			document.head.appendChild(this.end);
			
			this.onReady(function (){
				if (this.options.debug) {
					window.MathJax.Hub.Startup.signal.Interest(function(message) {
						console.log("Startup: " + message);
					});
					window.MathJax.Hub.signal.Interest(function(message) {
						console.log("Hub: " + message);
					});
				}

				window.MathJax.Hub.Configured();

				if (typeof callback === "function") {
					callback();
				}
			});

			return this;
		},
		render: function (selector, callback) {
			$$(selector).forEach(function (el) {
				window.MathJax.Hub.Queue(["Typeset", window.MathJax.Hub, el]);
			});
			if (typeof callback === "function") {
				window.MathJax.Hub.Queue(callback);
			}
			return this;
		}
	};

	this.EasyMathJax = EasyMathJax;

}).call(this);
