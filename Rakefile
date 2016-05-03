require "bundler/gem_tasks"
require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.libs << "spec"
  # test.warning = true # Wow that outputs a lot of shit
  test.pattern = "spec/**/*_spec.rb"
end

task :default => :test
