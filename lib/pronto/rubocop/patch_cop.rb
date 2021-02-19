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
          patch
            .added_lines
            .select { |line| line.new_lineno == offense.line }
            .map { |line| OffenseLine.new(self, offense, line).message }
        end
      end

      def processed_source
        @processed_source ||= ::RuboCop::ProcessedSource.from_file(
          path,
          rubocop_config.target_ruby_version
        )
      end

      def registry
        @registry ||= ::RuboCop::Cop::Registry.new(RuboCop::Cop::Cop.all)
      end

      def rubocop_config
        @rubocop_config ||= begin
          store = ::RuboCop::ConfigStore.new
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
