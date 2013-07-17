# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'pronto/rubocop/version'

Gem::Specification.new do |s|
  s.name        = 'pronto-rubocop'
  s.version     = Pronto::RubocopVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Mindaugas Mozūras']
  s.email       = ['mindaugas.mozuras@gmail.com']
  s.homepage    = 'http://github.org/mmozuras/pronto-rubocop'
  s.summary     = 'pronto-rubocop'
  s.description = 'pronto-rubocop'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'pronto-rubocop'
  s.license = 'MIT'

  s.files         = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'rubocop', '~> 0.9.0'
  s.add_dependency 'pronto', '~> 0.0.6'
  s.add_development_dependency 'rake', '~> 10.1.0'
  s.add_development_dependency 'rspec', '~> 2.13.0'
end
