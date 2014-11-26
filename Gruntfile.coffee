module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		watch:
			coffee:
				files: ['src/coffee/**/*.coffee']
				tasks: 'coffee'
			browserify:
				files: ['src/js/**/*.js']
				tasks: 'browserify'
		coffee:
			compile:
				files: [
					expand: true
					cwd: 'src/coffee/'
					src: ['**/*.coffee']
					dest: 'src/js/'
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


	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-bower-task'
	grunt.loadNpmTasks 'grunt-browserify'
	grunt.registerTask 'default', ['watch']
	return
