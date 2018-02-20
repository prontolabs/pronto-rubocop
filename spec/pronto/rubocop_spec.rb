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
    end

    describe '#inspect' do
      subject { rubocop.inspect(patches) }

      let(:item_patch) { nil }
      let(:item_line) { double(new_lineno: 1) }
      let(:item_offense) { double(disabled?: false, cop_name: "Lint/Syntax", message: "message-text", status: :uncorrected, line: 9) }
      let(:item_line_patch) { nil }
      let(:item_delta_value) { nil }
      let(:item_severity) { double(name: :error) }

      before do
        allow(rubocop).to receive(:patch).and_return(patch)
        allow(rubocop).to receive(:offences).and_return(array_of_offences)
        allow(rubocop).to receive(:patches).and_return(patch)

        allow(item_patch).to receive(:added_lines).and_return(array_of_lines)

        allow(item_line).to receive(:patch).and_return(line_patch)
        allow(item_line).to receive(:commit_sha).and_return("123456789abcdefgh")

        allow(line_patch).to receive(:delta).and_return(delta_value)

        allow(item_delta_value).to receive(:new_file).and_return(file)

        allow(item_offense).to receive(:severity).and_return(severity)

        allow(item_severity).to receive(:name).and_return(:error)
      end

      context 'return offences' do
        let(:patch) { item_patch }
        let(:line_patch) { item_line_patch }
        let(:delta_value) { item_delta_value }
        let(:array_of_offences) { [item_offense] }
        let(:array_of_lines) { [item_line] }
        let(:file) { { :path => "file.rb" } }
        let(:severity) { item_severity }

        it 'syntax error offense' do
          should == [[], Message.new("file.rb", patch.added_lines.last, :error, "message-text", nil, nil)]
        end
      end

      context 'does not return offences' do
        let(:item_offense) { double(disabled?: false, cop_name: "Asd", message: "message-text", status: :uncorrected, line: 1) }
        let(:patch) { item_patch }
        let(:line_patch) { item_line_patch }
        let(:delta_value) { item_delta_value }
        let(:array_of_offences) { [item_offense] }
        let(:array_of_lines) { [item_line] }
        let(:file) { { :path => "file.rb" } }
        let(:severity) { item_severity }

        it 'syntax error offense' do
          should == [[Message.new("file.rb", patch.added_lines.last, :error, "message-text", nil, nil)]]
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
