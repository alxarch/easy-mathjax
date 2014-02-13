describe "EasyMathJax suite", ->
	div = null
	e = null
	beforeEach ->
		div?.parentNode?.removeChild div
		div = document.createElement "div"
		div.className = "EasyMathJax-Test"
		document.body.appendChild div

	it "Exports constructor globally.", ->
		expect(typeof EasyMathJax).toBe "function"

	it "Respects user-provided options.", ->
		e = new EasyMathJax
			url: "MathJax.js"

		expect(e.options.url).toBe("MathJax.js")

	it "Injects MathJax properly.", (done) ->
		e = new EasyMathJax
			config:
				tex2jax:
					inlineMath: [["~", "~"]]
					displayMath: [["~~~", "~~~"]]

		e.inject -> done()

		expect(e.script).toBeDefined()

	it "Renders math correctly.", (done) ->
		div.textContent = "Testing some math ~ A^3 ~ inlined"
		e.render ".EasyMathJax-Test", ->
			script = div.querySelector("script[type='math/tex']")
			expect(script).not.toBe(null)
			expect(script.textContent).toBe(" A^3 ")
			done()


	it "Exports css data after render.", (done) ->
		div.textContent = "Testing some math ~ A^3 ~ inlined"
		e.render ".EasyMathJax-Test", ->
			css = e.css()
			expect(css.contents.replace(/\s\n/g, "")).not.toBe("")
			expect(typeof css.fonts).toBe("object")
			expect(Object.keys(css.fonts).length).not.toBe(0)
			done()
	
	it "Cleans up the document.", (done) ->
		div.textContent = "Testing some math ~ A^3 ~ inlined"
		e.render ".EasyMathJax-Test", ->
			e.clean()
			expect(document.querySelector("script[type='math/tex']")).toBe(null)
			expect(document.querySelector(".MathJax_Preview")).toBe(null)
			expect(document.querySelector("#MathJax_Font_Test")).toBe(null)
			expect(e.script.parentNode).toBe(null)
			done()

