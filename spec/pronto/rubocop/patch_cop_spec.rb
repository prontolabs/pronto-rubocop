# frozen_string_literal: true

require 'spec_helper'

describe Pronto::Rubocop::PatchCop do
  let(:patch_cop) { described_class.new(patch, runner) }
  let(:patch) do
    double :patch, new_file_full_path: 'example.rb', added_lines: [line]
  end
  let(:line) { double :line, new_lineno: 42 }
  let(:runner) { double :runner }
  let(:processed_source) { double :processed_source }
  let(:team) { double :team, inspect_file: [offense] }
  let(:offense) { double :offense, disabled?: false, line: 42 }
  let(:offense_line) { double :offense_line, message: 'Err' }

  before do
    allow(RuboCop::ProcessedSource).to receive(:from_file) { processed_source }
    allow(RuboCop::Cop::Team).to receive(:new) { team }
    allow(Pronto::Rubocop::OffenseLine).to receive(:new) { offense_line }
  end

  describe '#processed_source' do
    it do
      expect(patch_cop.processed_source).to eq(processed_source)
    end
  end

  describe '#messages' do
    it do
      expect(patch_cop.messages).to eq(['Err'])
    end
  end
end
