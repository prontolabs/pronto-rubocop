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

      if ruby_file?(path)
        offences = @cli.inspect_file(path)
        messages_from(offences, patch)
      end
    end

    def messages_from(offences, patch)
      offences.map do |offence|
        patch.added_lines.select { |line| line.new_lineno == offence.line }
                         .map { |line| new_message(patch, offence, line) }
      end.flatten.compact
    end

    def new_message(patch, offence, line)
      path = patch.delta.new_file[:path]
      level = level(offence.severity)

      Message.new(path, line, level, offence.message)
    end

    def level(severity)
      case severity
      when :refactor, :convention
        :info
      when :warning, :error, :fatal
        severity
      end
    end
  end
end
