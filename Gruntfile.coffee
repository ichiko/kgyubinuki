module.exports = (grunt) ->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		watch:
			coffee:
				files: ['src/coffee/**/*.coffee']
				tasks: ['browserify:app']
			jasmine:
				files: ['src/coffee/**/*.coffee', 'spec/coffee/**/*.coffee']
				tasks: ['browserify:spec', 'jasmine']
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
			app:
				files: 'public/script/main.js': ['src/coffee/main.coffee']
				options:
					transform: ['coffeeify']
					browserifyOptions:
						extensions: ['.coffee']
			spec:
				files: 'spec/js/spec.js': ['spec/coffee/**/*.coffee']
				options: '<%= browserify.app.options %>'
		jasmine:
			model:
				src: 'spec/dummy.js'
				options:
					specs: 'spec/js/*.js'
					helpers: 'lib/jquery/jquery.js'


	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-bower-task'
	grunt.loadNpmTasks 'grunt-browserify'
	grunt.loadNpmTasks 'grunt-contrib-jasmine'
	grunt.registerTask 'default', ['watch']
	grunt.registerTask 'build', ['browserify:app']
	grunt.registerTask 'spec', ['browserify:spec', 'jasmine']
	return
