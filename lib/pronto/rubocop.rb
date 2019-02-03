require 'pronto'
require 'rubocop'

module Pronto
  class Rubocop < Runner
    def run
      ruby_patches
        .select { |patch| valid_patch?(patch) }
        .map { |patch| messages(patch) }
        .flatten
        .compact
    end

    def valid_patch?(patch)
      return false if patch.additions < 1

      path = patch.new_file_full_path.to_s
      config = config_store.for(path)

      return false if config.file_to_exclude?(path)
      return true if config.file_to_include?(path)

      true
    end

    def messages(patch)
      processed_source = processed_source_for(patch)
      offences = run_investigation(processed_source)

      offences.map do |offence|
        patch
          .added_lines
          .select { |line| line.new_lineno == offence.line }
          .map { |line| new_message(offence, line) }
      end
    end

    def new_message(offence, line)
      path = line.patch.delta.new_file[:path]
      level = level(offence.severity.name)

      Message.new(path, line, level, offence.message, nil, self.class)
    end

    def config_store
      @config_store ||= begin
        store = ::RuboCop::ConfigStore.new
        store.options_config = ENV['RUBOCOP_CONFIG'] if ENV['RUBOCOP_CONFIG']
        store
      end
    end

    def processed_source_for(patch)
      path = patch.new_file_full_path.to_s
      ruby_version = config_store.for(path).target_ruby_version
      ::RuboCop::ProcessedSource.from_file(path, ruby_version)
    end

    def run_investigation(processed_source)
      config = config_store.for(processed_source.path)
      team = ::RuboCop::Cop::Team.new(registry, config, {})
      offences = team.inspect_file(processed_source)
      offences.sort.reject(&:disabled?)
    end

    def registry
      ::RuboCop::Cop::Registry.new(RuboCop::Cop::Cop.all)
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
