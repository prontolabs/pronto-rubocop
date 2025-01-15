# frozen_string_literal: true

module Pronto
  class Rubocop < Runner
    class OffenseLine
      DOCS = 'https://docs.rubocop.org/rubocop/cops_%s.html#%s'

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
        return "#{indirect_message}#{offense_message}" unless suggestable?

        "#{offense_message}\n\n#{indirect_suggestion}#{suggestion_text}"
      end

      def offense_message
        offense.message.gsub(
          offense.cop_name, "[#{offense.cop_name}](#{documentation_url})"
        )
      end

      def documentation_url
        format(DOCS, offense.cop_name.split('/').first.downcase, offense.cop_name.downcase.tr('/', ''))
      end

      def indirect_offense?
        offense.location.first_line != line.new_lineno
      end

      def indirect_message
        "Offense generated for line #{offense.location.first_line}:\n\n" if indirect_offense?
      end

      def indirect_suggestion
        "Suggestion for line #{offense.location.first_line}:\n\n" if indirect_offense?
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

      private_constant :DEFAULT_SEVERITIES
    end
  end
end
