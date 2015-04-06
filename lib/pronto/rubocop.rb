require 'pronto'
require 'rubocop'

module Pronto
  class Rubocop < Runner
    def initialize
      @config_store = ::RuboCop::ConfigStore.new
      @inspector = ::RuboCop::Runner.new({}, @config_store)
    end

    def run(patches, _)
      return [] unless patches

      valid_patches = patches.select do |patch|
        patch.additions > 0 &&
          ruby_file?(patch.new_file_full_path) &&
          !excluded?(patch)
      end

      valid_patches.map { |patch| inspect(patch) }.flatten.compact
    end

    def inspect(patch)
      processed_source = ::RuboCop::ProcessedSource.from_file(patch.new_file_full_path.to_s)
      offences = @inspector.send(:inspect_file, processed_source).first

      offences.map do |offence|
        patch.added_lines.select { |line| line.new_lineno == offence.line }
                         .map { |line| new_message(offence, line) }
      end
    end

    def new_message(offence, line)
      path = line.patch.delta.new_file[:path]
      level = level(offence.severity.name)

      Message.new(path, line, level, offence.message)
    end

    def excluded?(patch)
      path = patch.new_file_full_path.to_s
      @config_store.for(path).file_to_exclude?(path)
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
