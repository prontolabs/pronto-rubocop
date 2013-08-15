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

      context 'pronto-rubocop repo itself' do
        let(:path_to_repo) { File.join(File.dirname(__FILE__), '../../') }
        let(:repo) { Rugged::Repository.new(path_to_repo) }

        let(:diffs) { repo.diff('f8d5f2c', '504469e') }

        its(:count) { should == 3 }
        its(:'first.count') { should == 1 }
        its(:'first.first.level') { should == :info }
        its(:'first.first.line.new_lineno') { should == 2 }
        its(:'first.first.msg') {
          should == 'Missing top-level class documentation comment.'
        }
      end
    end
  end
end
