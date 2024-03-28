# frozen_string_literal: true

require 'spec_helper'

describe Pronto::Rubocop::PatchCop do
  let(:patch_cop) { described_class.new(patch, runner) }
  let(:patch) { instance_double Pronto::Git::Patch, new_file_full_path: 'example.rb', added_lines: [line] }
  let(:line) { double :line, new_lineno: 42 }
  let(:runner) { instance_double Pronto::Rubocop, pronto_rubocop_config: config }
  let(:config) { {} }
  let(:ast) { double :ast, each_node: nil }
  let(:rubocop_processed_source) { instance_double RuboCop::ProcessedSource, ast: ast }
  let(:team) { instance_double RuboCop::Cop::Team, inspect_file: [offense] }
  let(:offense_location) { double :location, first_line: 42, last_line: 43 }
  let(:offense) { instance_double RuboCop::Cop::Offense, disabled?: false, location: offense_location }
  let(:offense_line) { instance_double Pronto::Rubocop::OffenseLine, message: 'Err' }

  before do
    allow(RuboCop::ProcessedSource).to receive(:from_file) { rubocop_processed_source }
    allow(RuboCop::Cop::Team).to receive(:new) { team }
    allow(Pronto::Rubocop::OffenseLine).to receive(:new) { offense_line }
  end

  describe '#processed_source' do
    subject(:processed_source) { patch_cop.processed_source }

    it { expect(processed_source).to eq(rubocop_processed_source) }
  end

  describe '#messages' do
    subject(:messages) { patch_cop.messages }

    it { expect(messages).to eq(['Err']) }

    context 'when there is an error only on the patch line' do
      let(:offense_location) { double :location, first_line: 42, last_line: 42 }

      it { expect(messages).to eq(['Err']) }
    end

    context 'when there is an error including the patch, but not starting inside it' do
      let(:offense_location) { double :location, first_line: 40, last_line: 43 }

      it { expect(messages).to eq(['Err']) }
    end

    context 'when there is an error excluding the patch' do
      let(:offense_location) { double :location, first_line: 40, last_line: 41 }

      it { expect(messages).to eq([]) }
    end

    context 'when rubocop config for only_patched_lines is false' do
      let(:config) { { 'only_patched_lines' => false } }

      it { expect(messages).to eq(['Err']) }

      context 'when there is an error only on the patch line' do
        let(:offense_location) { double :location, first_line: 42, last_line: 42 }

        it { expect(messages).to eq(['Err']) }
      end

      context 'when there is an error including the patch, but not starting inside it' do
        let(:offense_location) { double :location, first_line: 40, last_line: 43 }

        it { expect(messages).to eq(['Err']) }
      end

      context 'when there is an error excluding the patch' do
        let(:offense_location) { double :location, first_line: 40, last_line: 41 }

        it { expect(messages).to eq([]) }
      end
    end

    context 'when rubocop config for only_patched_lines is true' do
      let(:config) { { 'only_patched_lines' => true } }

      it { expect(messages).to eq(['Err']) }

      context 'when there is an error only on the patch line' do
        let(:offense_location) { double :location, first_line: 42, last_line: 42 }

        it { expect(messages).to eq(['Err']) }
      end

      context 'when there is an error including the patch, but not starting inside it' do
        let(:offense_location) { double :location, first_line: 40, last_line: 43 }

        it { expect(messages).to eq([]) }
      end

      context 'when there is an error excluding the patch' do
        let(:offense_location) { double :location, first_line: 40, last_line: 41 }

        it { expect(messages).to eq([]) }
      end
    end
  end
end
