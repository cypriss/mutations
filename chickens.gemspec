require './lib/chickens/version'

Gem::Specification.new do |s|
  s.name = 'chickens'
  s.version = Chickens::VERSION
  s.author = 'Jonathan Novak'
  s.email = 'jnovak@gmail.com'
  s.homepage = 'http://github.com/cypriss/chickens'
  s.summary = s.description = 'Compose your business logic into commands that sanitize and validate input.'
  s.licenses = %w[MIT]

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files test`.split("\n")
  s.require_path = 'lib'

  s.add_dependency "activesupport"
  s.add_development_dependency 'minitest', '~> 4'
  s.add_development_dependency 'rake'
end
