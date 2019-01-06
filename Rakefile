require "bundler/gem_tasks"
require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.libs << "spec"
  test.pattern = "spec/**/*_spec.rb"
end

task :default => :test
