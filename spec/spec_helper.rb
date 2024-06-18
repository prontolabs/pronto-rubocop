# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'pronto/rubocop'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.filter_run focus: true
  config.order = 'random'
  config.run_all_when_everything_filtered = true
end
