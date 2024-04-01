# frozen_string_literal: true

module Pronto
  class Rubocop < Runner
    class PatchCop
      attr_reader :runner

      def initialize(patch, runner)
        @patch = patch
        @runner = runner
      end

      def messages
        return [] unless valid?

        offenses
          .map { |offense| first_relevant_message(patch, offense) }
          .compact
      end

      def processed_source
        @processed_source ||= begin
          processed_source = ::RuboCop::ProcessedSource.from_file(
            path,
            rubocop_config.target_ruby_version
          )
          processed_source.registry = registry if processed_source.respond_to?(:registry=)
          processed_source.config = rubocop_config if processed_source.respond_to?(:config=)
          processed_source
        end
      end

      def registry
        @registry ||= ::RuboCop::Cop::Registry.new(RuboCop::Cop::Cop.all)
      end

      def rubocop_config
        @rubocop_config ||= begin
          store = ::RuboCop::ConfigStore.new
          store.options_config = ENV['RUBOCOP_CONFIG'] if ENV['RUBOCOP_CONFIG']
          store.for(path)
        end
      end

      private

      attr_reader :patch

      def valid?
        return false if rubocop_config.file_to_exclude?(path)
        return true if rubocop_config.file_to_include?(path)

        runner.ruby_file?(path)
      end

      def path
        @path ||= patch.new_file_full_path.to_s
      end

      def offenses
        team
          .inspect_file(processed_source)
          .sort
          .reject(&:disabled?)
      end

      def offense_includes?(offense, line_number)
        if only_patched_lines?
          (offense.location.first_line..offense.location.first_line + only_patched_lines_range).include?(line_number)
        else
          (offense.location.first_line..offense.location.last_line).include?(line_number)
        end
      end

      def team
        @team ||=
          if ::RuboCop::Cop::Team.respond_to?(:mobilize)
            # rubocop v0.85.0 and later
            ::RuboCop::Cop::Team.mobilize(registry, rubocop_config)
          else
            ::RuboCop::Cop::Team.new(registry, rubocop_config)
          end
      end

      def first_relevant_line(patch, offense)
        patch.added_lines.detect do |line|
          offense_includes?(offense, line.new_lineno)
        end
      end

      def first_relevant_message(patch, offense)
        offending_line = first_relevant_line(patch, offense)
        return nil unless offending_line

        OffenseLine.new(self, offense, offending_line).message
      end

      def only_patched_lines
        runner.pronto_rubocop_config.fetch('only_patched_lines', {})
      end

      def only_patched_lines?
        @only_patched_lines ||= only_patched_lines.fetch('enabled', false)
      end

      def only_patched_lines_range
        @only_patched_lines_range ||= only_patched_lines.fetch('range', 0)
      end
    end
  end
end
