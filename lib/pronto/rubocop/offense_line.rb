# frozen_string_literal: true

module Pronto
  class Rubocop < Runner
    class OffenseLine
      def initialize(patch_cop, offense, line)
        @patch_cop = patch_cop
        @offense = offense
        @line = line
      end

      def message
        Message.new(path, line, level, message_text, nil, Pronto::Rubocop)
      end

      private

      attr_reader :patch_cop, :offense, :line

      def path
        line.patch.delta.new_file[:path]
      end

      def processed_source
        patch_cop.processed_source
      end

      def message_text
        return "#{indirect_message}#{offense.message}" unless suggestable?

        "#{offense.message}\n\n#{indirect_suggestion}#{suggestion_text}"
      end

      def indirect_offense?
        offense.location.first_line != line.new_lineno
      end

      def indirect_message
        INDIRECT_MESSAGE % offense.location.first_line if indirect_offense?
      end

      def indirect_suggestion
        INDIRECT_SUGGESTION % offense.location.first_line if indirect_offense?
      end

      def suggestable?
        OffenseSuggestion.new(patch_cop, offense, line).suggestable?
      end

      def suggestion_text
        OffenseSuggestion.new(patch_cop, offense, line).suggestion
      end

      def level
        severities.fetch(offense.severity.name)
      end

      def severities
        @severities ||= DEFAULT_SEVERITIES.merge(config_severities)
      end

      def config_severities
        patch_cop
          .runner
          .pronto_rubocop_config
          .fetch('severities', {})
          .map { |k, v| [k.to_sym, v.to_sym] }
          .to_h
      end

      DEFAULT_SEVERITIES = {
        info: :info,
        refactor: :warning,
        convention: :warning,
        warning: :warning,
        error: :error,
        fatal: :fatal
      }.freeze
      SUGGESTION = 'suggestion'
      RUBY = 'ruby'
      INDIRECT_MESSAGE = "Offense generated for line %d:\n\n"
      INDIRECT_SUGGESTION = "Suggestion for line %d:\n\n"

      private_constant :DEFAULT_SEVERITIES
    end
  end
end
