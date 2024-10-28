# frozen_string_literal: true

require 'dragnet/multi_repository'
require 'dragnet/repository'

RSpec.shared_examples_for 'Dragnet::BaseRepository#incompatible_repository' do
  let(:message) do
    "Failed to perform the action '#{method_name}' on '#{path}'. There isn't a git"\
      ' repository there. If you are running with the --multi-repo command line'\
      " switch make sure that all of your MTRs contain a valid 'repos' attribute."
  end

  it 'raises a Dragnet::Errors::IncompatibleRepositoryError' do
    expect { method_call }.to raise_error(
      Dragnet::Errors::IncompatibleRepositoryError,
      message
    )
  end
end

RSpec.describe Dragnet::MultiRepository do
  subject(:multi_repository) { described_class.new(path: path) }

  let(:path) { '/workspace/project' }

  describe 'contract' do
    let(:repository) { Dragnet::Repository.new(path: path) }

    let(:git) do
      instance_double(Git::Base)
    end

    before do
      allow(Git).to receive(:open).and_return(git)
    end

    it 'responds to the same methods as Dragnet::Repository' do
      expect(repository.methods).to all(
        satisfy { |method| multi_repository.respond_to?(method) }
      )
    end
  end

  describe '#initialize' do
    it 'initializes an empty repositories list' do
      expect(multi_repository.repositories).to be_a(Hash).and be_empty
    end
  end

  describe '#multi?' do
    it 'returns true' do
      expect(multi_repository.multi?).to eq(true)
    end
  end

  describe '#git' do
    subject(:method_call) { multi_repository.git }

    let(:method_name) { :git }

    it_behaves_like 'Dragnet::BaseRepository#incompatible_repository'
  end

  describe '#branch' do
    subject(:method_call) { multi_repository.branch }

    let(:method_name) { :branch }

    it_behaves_like 'Dragnet::BaseRepository#incompatible_repository'
  end

  describe '#branches' do
    subject(:method_call) { multi_repository.branches }

    let(:method_name) { :branches }

    it_behaves_like 'Dragnet::BaseRepository#incompatible_repository'
  end

  describe '#diff' do
    subject(:method_call) { multi_repository.diff }

    let(:method_name) { :diff }

    it_behaves_like 'Dragnet::BaseRepository#incompatible_repository'
  end

  describe '#head' do
    subject(:method_call) { multi_repository.head }

    let(:method_name) { :head }

    it_behaves_like 'Dragnet::BaseRepository#incompatible_repository'
  end

  describe '#remote_uri_path' do
    subject(:method_call) { multi_repository.remote_uri_path }

    let(:method_name) { :remote_uri_path }

    it_behaves_like 'Dragnet::BaseRepository#incompatible_repository'
  end

  describe '#branches_with' do
    subject(:method_call) { multi_repository.branches_with(commit) }

    let(:commit) { 'e1675e7bf1' }
    let(:method_name) { :branches_with }

    it_behaves_like 'Dragnet::BaseRepository#incompatible_repository'
  end

  describe '#branches_with_head' do
    subject(:method_call) { multi_repository.branches_with_head }

    let(:method_name) { :branches_with_head }

    it_behaves_like 'Dragnet::BaseRepository#incompatible_repository'
  end
end

