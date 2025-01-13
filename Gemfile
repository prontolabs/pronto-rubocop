# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

local_gemfile = File.expand_path('Gemfile.local', __dir__)
eval_gemfile local_gemfile if File.exist?(local_gemfile)

group :development, :test do
  gem 'rake', '~> 12.0'
  gem 'rspec', '~> 3.4'
  gem 'rspec-its', '~> 1.3'
  gem 'rubocop'
end
