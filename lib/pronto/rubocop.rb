require 'rubocop'
require 'pry'

module Pronto
  class Rubocop
    def initialize
      @cli = ::Rubocop::CLI.new
    end

    def run(diffs)
      return [] unless diffs && diffs.any?

      diffs.map do |diff|
        @cli.inspect_file(diff.full_b_path)
      end
    end
  end
end
