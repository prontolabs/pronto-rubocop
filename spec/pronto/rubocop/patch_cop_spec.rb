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
end
