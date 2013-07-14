require 'spec_helper'

module Pronto
  describe Rubocop do
    let(:rubocop) { Rubocop.new }

    describe '#run' do
      subject { rubocop.run(diffs) }

      context 'diffs are nil' do
        let(:diffs) { nil }
        it { should == [] }
      end

      context 'no diffs' do
        let(:diffs) { [] }
        it { should == [] }
      end
    end
  end
end
