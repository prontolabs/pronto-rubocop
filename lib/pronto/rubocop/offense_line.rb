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
        return offense.message unless suggestion_text

        "#{offense.message}\n\n```suggestion\n#{suggestion_text}```"
      end

      def suggestion_text
        return unless patch_cop.runner.pronto_rubocop_config['suggestions']
        return if corrections_count.zero?
        return if differing_lines_count != corrections_count

        @suggestion_text ||= corrected_lines[offense.line - 1]
      end

      def corrected_lines
        @corrected_lines ||= corrector.rewrite.lines
      end

      def differing_lines_count
        original_lines.each_with_index.count do |line, index|
          line != corrected_lines[index]
        end
      end

      def original_lines
        processed_source.lines.join("\n").lines
      end

      if ::RuboCop::Cop::Team.respond_to?(:mobilize) && ::RuboCop::Cop::Team.public_method_defined?(:investigate)
        # rubocop >= 0.87.0 has both mobilize and public investigate method
        MOBILIZE = :mobilize

        def report
          @report ||= autocorrect_team.investigate(processed_source).cop_reports.first
        end

        def corrector
          report.corrector
        end

        def corrections_count
          report.offenses.size
        end
      else
        # rubocop 0.85.x and 0.86.0 have mobilize, older versions don't
        MOBILIZE = ::RuboCop::Cop::Team.respond_to?(:mobilize) ? :mobilize : :new

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
                                    auto_correct: true,
                                    stdin: true)
      end

      def cop_class
        patch_cop.registry.find_by_cop_name(offense.cop_name)
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
