# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'pronto/rubocop'

RSpec.shared_context 'test repo' do
  # To make changes to the fixture repository, you can rename the `git` folder
  # to `.git`, commit, and rename it back to `git`.
  let(:repo_path_git) { 'spec/fixtures/test.git/git' }
  let(:repo_path_dot_git) { 'spec/fixtures/test.git/.git' }
  let(:repo) { Pronto::Git::Repository.new('spec/fixtures/test.git') }

  before do
    FileUtils.mv(repo_path_git, repo_path_dot_git)
  end

  after do
    FileUtils.mv(repo_path_dot_git, repo_path_git)
  end
end
