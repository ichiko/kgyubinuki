require 'bundler'
Bundler.require
require './app'
require './static_file_maker'
require 'rspec/core/rake_task'

task :default => [:spec]

desc 'test modules'
RSpec::Core::RakeTask.new(:spec) do |spec|
	spec.pattern = 'spec/**/*_spec.rb'
	spec.rspec_opts = ['-cfs -I .']
end

desc 'Make static file (html, css, js, etc...) from site.json'
task 'make_static_file' do
  StaticFileMaker.new(App).run
end
