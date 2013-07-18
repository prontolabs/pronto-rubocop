require 'rubocop'
require 'pry'

module Pronto
  class Rubocop
    def initialize
      @cli = ::Rubocop::CLI.new
    end

    def run(diffs)
      return [] unless diffs && diffs.any?

      working_dir = diffs.first.repo.working_dir
      diffs.map do |diff|
        full_b_path = File.join(working_dir, diff.b_path)

        @cli.inspect_file(full_b_path)
      end
    end
  end
end
