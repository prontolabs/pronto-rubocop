# frozen_string_literal: true

require 'spec_helper'

module Pronto
  describe Rubocop do
    let(:rubocop) { Rubocop.new(patches) }
    let(:patches) { nil }
    let(:pronto_config) do
      instance_double Pronto::ConfigFile, to_h: config_hash
    end
    let(:config_hash) { {} }

    before do
      allow(Pronto::ConfigFile).to receive(:new) { pronto_config }
    end

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

        let(:patches) { repo.show_commit('c3536be') }

        its(:count) { should == 1 }

        it 'includes the offense message' do
          expect(subject.first.msg).to include('Prefer single-quoted strings')
        end

        context 'with suggestions disabled' do
          it 'does not add a suggestion to the message' do
            expect(subject.first.msg).not_to include('```suggestion')
          end
        end

        context 'with suggestions enabled' do
          let(:config_hash) { { 'rubocop' => { 'suggestions' => true } } }

          it 'adds a suggestion to the message' do
            expect(subject.first.msg).to include("```suggestion\n  'bar'\n```")
          end
        end
      end

      context 'patches with multiple offenses' do
        include_context 'test repo'

        let(:patches) { repo.show_commit('a1095e7') }

        its(:count) { should == 4 }

        it 'returns messages' do
          expect(subject.map(&:msg))
            .to match(
              [
                a_string_matching('Inconsistent indentation detected'),
                a_string_matching('Prefer single-quoted strings'),
                a_string_matching('Inconsistent indentation detected'),
                a_string_matching('Prefer single-quoted strings')
              ]
            )
        end

        context 'with suggestions enabled' do
          let(:config_hash) { { 'rubocop' => { 'suggestions' => true } } }

          it 'includes suggestions for suggestionable cops' do
            expect(subject.map(&:msg))
              .to match(
                [
                  String,
                  a_string_matching("```suggestion\n    'zar'\n```"),
                  String,
                  a_string_matching("```suggestion\n    'gar'\n```")
                ]
              )
          end

          it 'does not include suggestions for multiline cops' do
            expect(subject.map(&:msg))
              .not_to match(
                [
                  a_string_matching('```suggestion'),
                  String,
                  a_string_matching('```suggestion'),
                  String
                ]
              )
          end
        end
      end
    end
  end
end
