require 'spec_helper'

describe Pronto::Rubocop::PatchCop do
  let(:patch_cop) { described_class.new(patch, runner) }
  let(:patch) { double :patch }
  let(:runner) { double :runner }

  describe '#level' do
    subject { patch_cop.send(:level, severity) }

    ::RuboCop::Cop::Severity::NAMES.each do |severity|
      let(:severity) { severity }
      context "severity '#{severity}' conversion to Pronto level" do
        it { should_not be_nil }
      end
    end
  end

  describe '#default_levels' do
    expected_hash = {
      refactor: :warning,
      convention: :warning,
      warning: :warning,
      error: :error,
      fatal: :fatal
    }
    expected_hash.each do |severity, expected_level|
      context "Checking level for severity: #{severity} => #{expected_level}" do
        it { expect(patch_cop.send(:level, severity)).to eq(expected_level) }
      end
    end
  end

  describe '#override_severity_levels_all_fatal' do
    before do
      fatal_hash = {
        refactor: :fatal,
        convention: :fatal,
        warning: :fatal,
        error: :fatal,
        fatal: :fatal
      }
      allow(File).to receive(:exist?).and_return(true)
      allow(YAML).to receive(:load_file).and_return('rubocop' => { 'severities' => fatal_hash })
    end

    ::RuboCop::Cop::Severity::NAMES.each do |severity|
      it { expect(patch_cop.send(:level, severity)).to eq(:fatal) }
    end
  end

  describe '#override_severity_levels_all_refactor' do
    before do
      refactor_hash = {
        refactor: :refactor,
        convention: :refactor,
        warning: :refactor,
        error: :refactor,
        fatal: :refactor
      }
      allow(File).to receive(:exist?).and_return(true)
      allow(YAML).to receive(:load_file).and_return('rubocop' => { 'severities' => refactor_hash })
    end

    ::RuboCop::Cop::Severity::NAMES.each do |severity|
      it { expect(patch_cop.send(:level, severity)).to eq(:refactor) }
    end
  end
end
