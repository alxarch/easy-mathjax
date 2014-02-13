module.exports = (grunt) ->
	grunt.initConfig
		jasmine:
			all:
				options:
					specs: "lib/spec/*Spec.js"
					
				src: "lib/*.js"
		coffee:
			options:
				bare: yes

			all:
				expand: yes
				src: "spec/**/*Spec.coffee"
				dest: "lib/"
				ext: ".js"
			compile:
				cwd: "src/"
				expand: yes
				src: "**/*.coffee"
				dest: "lib/"
				ext: ".js"
		clean:
			spec: "lib/spec/**/*"
			compiled: "lib/*.{js,map}"

	grunt.loadNpmTasks "grunt-contrib-jasmine"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-clean"

	grunt.registerTask "test", ["build", "jasmine"]
	grunt.registerTask "build", ["clean", "coffee"]
	grunt.registerTask "default", ["test"]
