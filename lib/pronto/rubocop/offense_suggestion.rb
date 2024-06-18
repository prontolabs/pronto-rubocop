# frozen_string_literal: true

module Pronto
  class Rubocop < Runner
    class OffenseSuggestion
      def initialize(patch_cop, offense, line)
        @patch_cop = patch_cop
        @offense = offense
        @line = line
      end

      def suggestion
        return unless suggestable?

        "```#{code_type}\n#{suggestion_text}```"
      end

      def suggestable?
        # `corrector.nil?`` possible after optimisation in https://github.com/rubocop/rubocop/pull/11264
        patch_cop.runner.pronto_rubocop_config.fetch('suggestions', false) &&
          (!corrections_count.zero? && !corrector.nil? && differing_lines_count == corrections_count)
      end

      private

      attr_reader :patch_cop, :offense, :line

      def processed_source
        patch_cop.processed_source
      end

      def code_type
        indirect_offense? ? RUBY : SUGGESTION
      end

      def indirect_offense?
        offense.location.first_line != line.new_lineno
      end

      def suggestion_text
        return unless patch_cop.runner.pronto_rubocop_config['suggestions']
        # `corrector.nil?`` possible after optimisation in https://github.com/rubocop/rubocop/pull/11264
        return if corrections_count.zero? || corrector.nil? || differing_lines_count != corrections_count

        @suggestion_text ||= corrected_lines[offense.line - 1]
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

      if ::RuboCop::Cop::Team.respond_to?(:mobilize) && ::RuboCop::Cop::Team.public_method_defined?(:investigate)
        # rubocop >= 0.87.0 has both mobilize and public investigate method
        MOBILIZE = :mobilize
        # rubocop 1.30.0 renamed from auto_correct to autocorrect
        AUTOCORRECT =
          if Gem::Version.new(::RuboCop::Version::STRING) >= Gem::Version.new('1.30.0')
            :autocorrect
          else
            :auto_correct
          end

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
      else
        # rubocop 0.85.x and 0.86.0 have mobilize, older versions don't
        MOBILIZE = ::RuboCop::Cop::Team.respond_to?(:mobilize) ? :mobilize : :new
        AUTOCORRECT = :auto_correct

        def corrector
          @corrector ||= begin
            autocorrect_team.inspect_file(processed_source)
            corrector = RuboCop::Cop::Corrector.new(processed_source.buffer)
            corrector.corrections.concat(autocorrect_team.cops.first.corrections)
            corrector
          end
        end

        def corrections_count
          @corrections_count ||= corrector.corrections.count
        end
      end

      def autocorrect_team
        @autocorrect_team ||=
          ::RuboCop::Cop::Team.send(MOBILIZE,
                                    ::RuboCop::Cop::Registry.new([cop_class]),
                                    patch_cop.rubocop_config,
                                    **{ AUTOCORRECT => true, stdin: true })
      end

      def cop_class
        patch_cop.registry.find_by_cop_name(offense.cop_name)
      end
      SUGGESTION = 'suggestion'
      RUBY = 'ruby'
    end
  end
end
