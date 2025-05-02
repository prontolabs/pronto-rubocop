# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'pronto/rubocop/version'
require 'English'

Gem::Specification.new do |s|
  s.name = 'pronto-rubocop'
  s.version = Pronto::RubocopVersion::VERSION
  s.platform = Gem::Platform::RUBY
  s.author = 'Mindaugas Mozūras'
  s.email = 'mindaugas.mozuras@gmail.com'
  s.homepage = 'https://github.com/prontolabs/pronto-rubocop'
  s.summary = 'Pronto runner for Rubocop, ruby code analyzer'

  s.licenses = ['MIT']
  s.required_ruby_version = '>= 2.4.0'

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ %r{^(?:
    spec/.*
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$}x
  end
  s.test_files = []
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.require_paths = ['lib']

  s.add_runtime_dependency('pronto', '~> 0.11.0')
  s.add_runtime_dependency('rubocop', '>= 0.90.0', '< 2.0')
  s.add_development_dependency('base64', '~> 0.1.2')
  s.add_development_dependency('rake', '~> 12.0')
  s.add_development_dependency('rspec', '~> 3.4')
  s.add_development_dependency('rspec-its', '~> 1.2')
end
