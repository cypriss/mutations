require './lib/mutations/version'

Gem::Specification.new do |s|
  s.name = 'mutations'
  s.version = Mutations::VERSION
  s.author = 'Jonathan Novak'
  s.email = 'jnovak@gmail.com'
  s.homepage = 'http://github.com/cypriss/mutations'
  s.summary = s.description = 'Compose your business logic into commands that sanitize and validate input.'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files test`.split("\n")
  s.require_path = 'lib'

  s.add_dependency "activesupport"
  s.add_development_dependency 'minitest', '~> 4'
  s.add_development_dependency 'rake'
end
