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
  s.required_ruby_version = '>= 2.3.0'

  s.files = `git ls-files`.split($RS).grep_v(%r{^(?:
    spec/.*
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$}x)
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.require_paths = ['lib']

  s.add_runtime_dependency('pronto', '~> 0.11.0')
  s.add_runtime_dependency('rubocop', '>= 0.63.1', '< 2.0')
end
