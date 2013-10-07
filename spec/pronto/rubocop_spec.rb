require 'spec_helper'

module Pronto
  describe Rubocop do
    let(:rubocop) { Rubocop.new }

    describe '#run' do
      subject { rubocop.run(patches) }

      context 'patches are nil' do
        let(:patches) { nil }
        it { should == [] }
      end

      context 'no patches' do
        let(:patches) { [] }
        it { should == [] }
      end

      context 'pronto-rubocop repo itself' do
        let(:repo) { Rugged::Repository.init_at('.') }

        let(:patches) { repo.diff('86b7f05', '86b7f05~10') }

        its(:count) { should == 1 }
        its(:'first.level') { should == :info }
        its(:'first.msg') { should =~ /snake_case.*symbols./ }
      end
    end

    describe '#level' do
      subject { rubocop.level(severity) }

      ::Rubocop::Cop::Offence::SEVERITIES.each do |severity|
        let(:severity) { severity }
        context "severity '#{severity}' conversion to Pronto level" do
          it { should_not be_nil }
        end
      end
    end
  end
end
