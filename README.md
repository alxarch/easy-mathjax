easy-mathjax
============

Faclitate MathJax usage.

Usage:

```js
// Configure MathJax prior to loading.
// All mathjax-config blocks will also be merged after injection.

window.MathJax = {
	tex2jax: {
		inlineMath: [["$","$"]],
		processEscapes: true
	}
};
var easy = new EasyMathJax({
	url: "path/to/mathjax.js"
});

easy.inject(function() {
	easy.render(".mathjax-block", function () {
		console.log("All items with class 'mathjax-block' have been rendered");
	});
});
```
