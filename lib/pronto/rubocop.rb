require 'pronto'
require 'rubocop'

module Pronto
  class Rubocop < Runner
    def initialize
      @cli = ::Rubocop::CLI.new
    end

    def run(patches)
      return [] unless patches

      patches.select { |patch| patch.additions > 0 }
             .map { |patch| inspect(patch) }
             .flatten.compact
    end

    def inspect(patch)
      path = patch.delta.new_file_full_path

      if File.extname(path) == '.rb'
        offences = @cli.inspect_file(path)
        messages_from(offences, patch)
      end
    end

    def added_lines(patch)
      patch.map do |hunk|
        hunk.lines.select(&:addition?)
      end.flatten.compact
    end

    def messages_from(offences, patch)
      offences.map do |offence|
        line = added_lines(patch).select do |added_line|
          added_line.new_lineno == offence.line
        end.first

        path = patch.delta.new_file[:path]
        message_from(path, offence, line) if line
      end.compact
    end

    def message_from(path, offence, line)
      Pronto::Message.new(path,
                          line,
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
