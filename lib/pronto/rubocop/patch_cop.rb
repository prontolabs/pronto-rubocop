module Pronto
  class Rubocop < Runner
    class PatchCop
      def initialize(patch, runner)
        @patch = patch
        @runner = runner
      end

      def messages
        return [] unless valid?

        offences.map do |offence|
          patch
            .added_lines
            .select { |line| line.new_lineno == offence.line }
            .map { |line| new_message(offence, line) }
        end
      end

      private

      attr_reader :patch, :runner

      def valid?
        return false if config.file_to_exclude?(path)
        return true if config.file_to_include?(path)
        true
      end

      def path
        @path ||= patch.new_file_full_path.to_s
      end

      def config
        @config ||= begin
          store = ::RuboCop::ConfigStore.new
          store.for(path)
        end
      end

      def offences
        team
          .inspect_file(processed_source)
          .sort
          .reject(&:disabled?)
      end

      def team
        @team ||= ::RuboCop::Cop::Team.new(registry, config)
      end

      def registry
        @registry ||= ::RuboCop::Cop::Registry.new(RuboCop::Cop::Cop.all)
      end

      def processed_source
        @processed_source ||=
          ::RuboCop::ProcessedSource.from_file(path, config.target_ruby_version)
      end

      def new_message(offence, line)
        path = line.patch.delta.new_file[:path]
        level = level(offence.severity.name)

        Message.new(path, line, level, offence.message, nil, runner.class)
      end

      def config_severities
        @config_severities ||=
          Hash[
            ::Pronto::ConfigFile.new.to_h
              .fetch('rubocop', {})
              .fetch('severities', {})
              .map { |k, v| [k.to_sym, v.to_sym] }
          ]
      end

      def severities
        @severities ||= DEFAULT_SEVERITIES.merge(config_severities)
      end

      def level(severity)
        severities.fetch(severity)
      end

      DEFAULT_SEVERITIES = {
        refactor: :warning,
        convention: :warning,
        warning: :warning,
        error: :error,
        fatal: :fatal
      }.freeze

      private_constant :DEFAULT_SEVERITIES
    end
  end
end
