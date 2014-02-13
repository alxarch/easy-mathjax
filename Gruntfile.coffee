module.exports = (grunt) ->
	grunt.initConfig
		jasmine:
			all:
				options:
					specs: "dist/spec/*Spec.js"
					"web-security": no
					
				src: "dist/*.js"
		coffee:
			options:
				bare: yes

			spec:
				expand: yes
				src: "spec/**/*Spec.coffee"
				dest: "dist/"
				ext: ".js"
			compile:
				cwd: "src/"
				expand: yes
				src: "**/*.coffee"
				dest: "dist/"
				ext: ".js"
		clean:
			spec: "dist/spec/**/*"
			compiled: "dist/*.js"

	grunt.loadNpmTasks "grunt-contrib-jasmine"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-clean"

	grunt.registerTask "default", ["clean", "coffee", "jasmine"]
