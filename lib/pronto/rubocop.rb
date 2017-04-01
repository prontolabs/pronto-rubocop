require 'pronto'
require 'rubocop'

module Pronto
  class Rubocop < Runner
    def initialize(_, _ = nil)
      super

      @config_store = ::RuboCop::ConfigStore.new
      @config_store.options_config = ENV['RUBOCOP_CONFIG'] if ENV['RUBOCOP_CONFIG']
      @inspector = ::RuboCop::Runner.new({}, @config_store)
    end

    def run
      return [] unless @patches

      @patches.select { |patch| valid_patch?(patch) }
        .map { |patch| inspect(patch) }
        .flatten.compact
    end

    def valid_patch?(patch)
      return false if patch.additions < 1

      config_store = config_store_for(patch)
      path = patch.new_file_full_path

      return false if config_store.file_to_exclude?(path.to_s)
      return true if config_store.file_to_include?(path.to_s)

      ruby_file?(path)
    end

    def inspect(patch)
      processed_source = processed_source_for(patch)
      offences = @inspector.send(:inspect_file, processed_source).first

      offences.sort.reject(&:disabled?).map do |offence|
        patch.added_lines
          .select { |line| line.new_lineno == offence.line }
          .map { |line| new_message(offence, line) }
      end
    end

    def new_message(offence, line)
      path = line.patch.delta.new_file[:path]
      level = level(offence.severity.name)

      Message.new(path, line, level, offence.message, nil, self.class)
    end

    def config_store_for(patch)
      path = patch.new_file_full_path.to_s
      @config_store.for(path)
    end

    def processed_source_for(patch)
      path = patch.new_file_full_path.to_s
      ::RuboCop::ProcessedSource.from_file(path, RUBY_VERSION[0..2].to_f)
    end

    def level(severity)
      case severity
      when :refactor, :convention
        :warning
      when :warning, :error, :fatal
        severity
      end
    end
  end
end
