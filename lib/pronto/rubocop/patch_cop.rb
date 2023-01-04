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

        offenses.flat_map do |offense|
          offending_line = patch
            .added_lines
            .detect { |line| offense_includes?(offense, line.new_lineno) }

          if offending_line
            [OffenseLine.new(self, offense, offending_line).message]
          else
            []
          end
        end
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

        true
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
        offense_range = (offense.location.first_line..offense.location.last_line)
        offense_range.include?(line_number)
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
    end
  end
end
