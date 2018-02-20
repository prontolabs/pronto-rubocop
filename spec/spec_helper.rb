require 'rspec'
require 'rspec/its'
require 'pronto/rubocop'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
end
