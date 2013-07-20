require 'spec_helper'
require 'grit-ext'

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

      context 'pronto-rubocop repo itself' do
        let(:path_to_repo) { File.join(File.dirname(__FILE__), '../../') }
        let(:repo) { Grit::Repo.new(path_to_repo) }
        let(:diffs) { repo.diff('f8d5f2c', '504469e') }

        its(:count) { should == 3 }
        its(:'first.count') { should == 1 }
      end
    end
  end
end
