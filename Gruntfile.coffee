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
			easy:
				cwd: "src/"
				expand: yes
				src: "**/*.coffee"
				dest: "dist/"
				ext: ".js"

	grunt.loadNpmTasks "grunt-contrib-jasmine"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.registerTask "default", ["coffee", "jasmine"]
