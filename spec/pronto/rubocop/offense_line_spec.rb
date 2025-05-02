# frozen_string_literal: true

require 'spec_helper'

describe Pronto::Rubocop::OffenseLine do
  let(:offense_line) { described_class.new(patch_cop, offense, line) }
  let(:patch_cop) { instance_double Pronto::Rubocop::PatchCop, runner: runner, registry: registry }
  let(:registry) do
    RuboCop::Cop::Registry.new(
      if RuboCop::Cop.const_defined?(:Registry) && RuboCop::Cop::Registry.respond_to?(:all)
        RuboCop::Cop::Registry.all
      else
        RuboCop::Cop::Cop.all
      end
    )
  end
  let(:runner) do
    instance_double Pronto::Rubocop, pronto_rubocop_config: config
  end
  let(:offense) do
    instance_double RuboCop::Cop::Offense,
                    severity: severity,
                    message: 'Layout/IndentationConsistency: Fake message',
                    location: offense_location,
                    cop_name: 'Layout/IndentationConsistency'
  end
  let(:offense_location) { double :location, first_line: 42, last_line: 43 }
  let(:line) do
    instance_double Pronto::Git::Line, patch: patch, commit_sha: 'af42', new_lineno: 42
  end
  let(:patch) { instance_double Pronto::Git::Patch, delta: delta }
  let(:delta) { instance_double Rugged::Diff::Delta, new_file: new_file }
  let(:new_file) { { path: 'example.rb' } }
  let(:severity) { instance_double RuboCop::Cop::Severity, name: severity_name }
  let(:severity_name) { :refactor }
  let(:config) { {} }

  describe '#message' do
    subject(:message) { offense_line.message }

    its(:path) { is_expected.to eq('example.rb') }
    its(:line) { is_expected.to eq(line) }
    its(:msg) { is_expected.to eq('[Layout/IndentationConsistency](https://docs.rubocop.org/rubocop/cops_layout.html#layoutindentationconsistency): Fake message') }

    context 'when the documentation URL is not available' do
      let(:offense) do
        instance_double RuboCop::Cop::Offense,
                        severity: severity,
                        message: 'Fake/FakeOffense: Fake message',
                        location: offense_location,
                        cop_name: 'Fake/FakeOffense'
      end

      its(:msg) { is_expected.to eq('Fake/FakeOffense: Fake message') }
    end

    context 'with default severity levels' do
      default_level_hash = {
        refactor: :warning,
        convention: :warning,
        warning: :warning,
        error: :error,
        fatal: :fatal
      }
      default_level_hash.each do |given_severity, expected_level|
        context "when severity is #{given_severity}" do
          let(:severity_name) { given_severity }

          its(:level) { is_expected.to eq(expected_level) }
        end
      end
    end

    context 'with overridden severity levels to "fatal"' do
      let(:config) do
        {
          'severities' =>
            RuboCop::Cop::Severity::NAMES.map { |name| [name, 'fatal'] }.to_h
        }
      end

      RuboCop::Cop::Severity::NAMES.each do |given_severity|
        context "when severity is #{given_severity.inspect}" do
          let(:severity_name) { given_severity }

          its(:level) { is_expected.to eq(:fatal) }
        end
      end
    end

    context 'when the offense is indirectly related to the new code' do
      let(:offense_location) { double :location, first_line: 40, last_line: 41 }

      its(:msg) { is_expected.to include('Offense generated for line 40:') }
    end
  end
end
