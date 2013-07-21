require 'pronto'
require 'rubocop'

module Pronto
  class Rubocop < Runner
    def initialize
      @cli = ::Rubocop::CLI.new
    end

    def run(diffs)
      return [] unless diffs

      diffs.map do |diff|
        offences = inspect(diff)
        messages_from(offences, diff)
      end
    end

    def inspect(diff)
      @cli.inspect_file(diff.full_b_path)
    end

    def messages_from(offences, diff)
      offences.map do |offence|
        line = diff.added.select do |added_line|
          added_line.line_number == offence.line
        end.first

        message_from(offence, line) if line
      end.compact
    end

    def message_from(offence, diff_line)
      Pronto::Message.new(diff_line,
                          level(offence.severity),
                          offence.message)
    end

    def level(severity)
      case severity
      when :refactor, :convention
        :info
      when :warning
        :warning
      when :error
        :error
      when :fatal
        :fatal
      end
    end
  end
end
