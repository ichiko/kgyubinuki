module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		watch:
			coffee:
				files: ['src/coffee/**/*.coffee']
				tasks: ['coffee:compile', 'browserify:dist']
			jasmine:
				files: ['src/coffee/**/*.coffee', 'spec/coffee/**/*.coffee']
				tasks: ['coffee:spec', 'browserify:spec', 'jasmine']
		coffee:
			compile:
				files: [
					expand: true
					cwd: 'src/coffee/'
					src: ['**/*.coffee']
					dest: 'src/js/'
					ext: '.js'
				]
			spec:
				files: [
					expand: true
					cwd: 'spec/coffee'
					src: ['**/*.coffee']
					dest: 'spec/obj/'
					ext: '.js'
				]
		bower:
			install:
				options:
					targetDir: './public/lib',
					layout: 'byComponent',
					install: true,
					verbose: false,
					cleanTargetDir: true,
					cleanBowerDir: false
		browserify:
			dist:
				src: 'src/js/main.js',
				dest: 'public/script/main.js'
			spec:
				src: 'spec/obj/*.js'
				dest: 'spec/js/spec.js'
		jasmine:
			model:
				src: 'spec/dummy.js'
				options:
					specs: 'spec/js/*.js'
					helpers: 'lib/jquery/jquery.js'


	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-bower-task'
	grunt.loadNpmTasks 'grunt-browserify'
	grunt.loadNpmTasks 'grunt-contrib-jasmine'
	grunt.registerTask 'default', ['watch']
	grunt.registerTask 'spec', ['coffee:compile', 'coffee:spec', 'browserify:spec', 'jasmine']
	return
