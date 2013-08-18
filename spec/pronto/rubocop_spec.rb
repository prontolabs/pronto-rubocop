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
        let(:path_to_repo) { File.join(File.dirname(__FILE__), '../../') }
        let(:repo) { Rugged::Repository.new(path_to_repo) }

        let(:patches) { repo.diff('f8d5f2c', '504469e') }

        its(:count) { should == 2 }
        its(:'first.level') { should == :info }
        its(:'first.line.new_lineno') { should == 2 }
        its(:'first.msg') {
          should == 'Missing top-level class documentation comment.'
        }
      end
    end
  end
end
