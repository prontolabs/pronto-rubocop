# frozen_string_literal: true

RSpec.shared_examples 'it include a documentation url' do |cop_name, cop_section, anchor|
  it "includes a documentation url for #{cop_name}" do
    expect(subject.map(&:msg)).to include(
      a_string_matching(
        %r{\[#{cop_name}\]\(https://docs.rubocop.org/rubocop/cops_#{cop_section}.html##{anchor}\)}
      )
    )
  end
end
