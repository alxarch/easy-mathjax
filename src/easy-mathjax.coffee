
$$ = (selector) ->
	(el for el in document.querySelectorAll selector)

remove = (node) ->
	if typeof node is "string"
		node = $$ node
	node = [].concat node
	for n in [].concat node
		if n and n.parentNode?
			n.parentNode.removeChild n

extend = (base, extenders...) ->
	if typeof base is "object"
		for ext in extenders when typeof ext is "object"
			for own key, value of ext
				base[key] = value
	base

class EasyMathJax
	matchFontUrl = ///
		url \s*	\(
			\s*
			['"]
			( # url
			[^\)]+
			fonts/HTML\-CSS/
			( #font
			[^/]+/
			(?:woff|otf|eot)/
			[^-]+
			\-
			(?:Regular|Italic|Bold|Bolditalic)
			\.
			(?:woff|eot|otf)
			) # end font
			) # end url
			['"]
			\s*
			\)
		///g
	@defaults = defaults =
		url: "http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"

	constructor: (options) ->
		@options = extend {}, EasyMathJax.defaults, options

	injected: ->
		el = @script
		injected = []
		while el
			injected.push el
			el = el.nextElementSibling
		injected

	clean: ->
		remove @injected()

		remove "#MathJax_Message"
		remove "#MathJax_Font_Test"
		remove ".MathJax_Preview"
		remove document.getElementById("MathJax_Hidden")?.parentNode

		unless @options.debug
			remove "script[id^=MathJax]"
			for s in $$ "[id^='MathJax']"
				s.removeAttribute 'id'
		@
	css: ->
		fonts = {}
		css = []
	
		fixFontUrl = (line) ->
			line.replace matchFontUrl, (ma, url, font) ->
				fonts[font] = url
				"url('fonts/mathjax/#{font}')"

		parseLine = (line) ->
			if line.match /@font\-face/
				line = fixFontUrl line
			css.push line

		for el in @injected() when el?.tagName.toLowerCase() is "style"
			parseLine(line) for line in el.innerHTML.split "\n"

		contents: css.join("\n")
		fonts: fonts

	inject: (callback) ->
		window.MathJax = extend {}, window.MathJax, @options.config,
			delayStartupUntil: "configured"
			skipStartupTypeset: yes
		
		@script = document.createElement 'script'
		@script.addEventListener "load", =>
			if @options.debug
				window.MathJax.Hub.Startup.signal.Interest (message) ->
					console.log "Startup: #{message}"
				window.MathJax.Hub.signal.Interest (message) ->
					console.log "Hub: #{message}"

			window.MathJax.Hub.Register.StartupHook "End", ->
				callback() unless typeof callback isnt "function"

			window.MathJax.Hub.Configured()
		@script.src = @options.url;

		document.head.appendChild @script
		@

	render: (selector, callback) ->
		for el in $$ selector
			window.MathJax.Hub.Queue ["Typeset", window.MathJax.Hub, el]

		if typeof callback is "function"
			window.MathJax.Hub.Queue(callback)
		@

@EasyMathJax = EasyMathJax
