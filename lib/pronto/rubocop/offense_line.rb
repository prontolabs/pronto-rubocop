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
        return "#{indirect_message}#{offense_message}" unless suggestable?

        "#{offense_message}\n\n#{indirect_suggestion}#{suggestion_text}"
      end

      def suggestion_text
        return unless suggestable?

        "```#{code_type}\n#{corrected_lines[offense.line - 1]}```"
      end

      def suggestable?
        # `corrector.nil?`` possible after optimisation in https://github.com/rubocop/rubocop/pull/11264
        patch_cop.runner.pronto_rubocop_config.fetch('suggestions', false) &&
          (!corrections_count.zero? && !corrector.nil? && differing_lines_count == corrections_count)
      end

      def code_type
        indirect_offense? ? 'ruby' : 'suggestion'
      end

      def offense_message
        if documentation_url
          offense.message.gsub(
            offense.cop_name, "[#{offense.cop_name}](#{documentation_url})"
          )
        else
          offense.message
        end
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

      def corrected_lines
        @corrected_lines ||= corrector.rewrite.lines
      end

      def differing_lines_count
        original_lines.each_with_index.count { |line, index| line != corrected_lines[index] }
      end

      def original_lines
        processed_source.lines.join("\n").lines
      end

      # rubocop 1.30.0 renamed from auto_correct to autocorrect
      AUTOCORRECT =
        if Gem::Version.new(::RuboCop::Version::STRING) >= Gem::Version.new('1.30.0')
          :autocorrect
        else
          :auto_correct
        end

      # rubocop >= 0.87.0 has investigate as a public method
      def report
        @report ||= autocorrect_team.investigate(processed_source).cop_reports.first
      end

      def corrector
        report.corrector
      end

      def corrections_count
        # Some lines may contain more than one offense
        report.offenses.map(&:line).uniq.size
      end

      # rubocop >= 0.87.0 has mobilize as a public method
      def autocorrect_team
        @autocorrect_team ||= ::RuboCop::Cop::Team.mobilize(
          ::RuboCop::Cop::Registry.new([cop_class]),
          patch_cop.rubocop_config,
          **{ AUTOCORRECT => true, stdin: true }
        )
      end

      def cop_class
        patch_cop.registry.find_by_cop_name(offense.cop_name)
      end

      def documentation_url
        cop_class&.documentation_url
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
