require 'spec_helper'

module Pronto
  describe Rubocop do
    let(:rubocop) { Rubocop.new(patches) }
    let(:patches) { nil }

    describe '#run' do
      subject { rubocop.run }

      context 'patches are nil' do
        it { should == [] }
      end

      context 'no patches' do
        let(:patches) { [] }
        it { should == [] }
      end

      context 'patches with an offense' do
        include_context 'test repo'

        let(:patches) { repo.diff('ac7e278') }

        its(:count) { should == 1 }
        its(:'first.msg') do
          should =~ /Prefer single-quoted strings/
        end
      end
    end

    describe '#level' do
      subject { rubocop.level(severity) }

      ::RuboCop::Cop::Severity::NAMES.each do |severity|
        let(:severity) { severity }
        context "severity '#{severity}' conversion to Pronto level" do
          it { should_not be_nil }
        end
      end
    end
  end
end
