# frozen_string_literal: true

require 'dragnet/repository'

RSpec.describe Dragnet::Repository do
  subject(:repository) { described_class.new(path: path) }

  let(:path) { '/Workspace/project/source' }

  let(:branches) { [] }

  let(:git) do
    instance_double(
      Git::Base,
      branches: branches
    )
  end

  before do
    allow(Git).to receive(:open).with(path).and_return(git)
  end

  describe 'contract' do
    let(:multi_repository) { Dragnet::MultiRepository.new(path: path) }

    it 'responds to the same methods as Dragnet::MultiRepository' do
      expect(multi_repository.methods).to all(
        satisfy { |method| repository.respond_to?(method) }
      )
    end
  end

  it 'delegates #branch to the git object' do
    expect(repository.git).to receive(:branch)
    repository.branch
  end

  it 'delegates #branches to the git object' do
    expect(repository.git).to receive(:branches)
    repository.branches
  end

  it 'delegates #diff to the git object' do
    expect(repository.git).to receive(:diff)
    repository.diff
  end

  describe '#initialize' do
    subject(:method_call) { repository }

    context 'when the given path cannot be opened as a git repository' do
      let(:expected_message) { "path does not exist\nfrom #{path}" }

      before do
        allow(Git).to receive(:open).with(path).and_raise(
          ArgumentError, expected_message
        )
      end

      it 'raises an ArgumentError' do
        expect { method_call }.to raise_error(ArgumentError, expected_message)
      end
    end
  end

  describe '#head' do
    subject(:method_call) { repository.head }

    let(:head) do
      instance_double(
        Git::Object::Commit
      )
    end

    before do
      allow(git).to receive(:object).with('HEAD').and_return(head)
    end

    it 'returns the commit at the head of the repository' do
      expect(method_call).to eq(head)
    end
  end

  describe '#remote_uri_path' do
    subject(:method_call) { repository.remote_uri_path }

    let(:remote_url) { 'ssh://focal.fossa@gerrit.local:29418/projects/central/bsw' }

    let(:remote) do
      instance_double(
        Git::Remote,
        url: remote_url
      )
    end

    let(:remotes) do
      [
        remote,
        instance_double(
          Git::Remote
        )
      ]
    end

    before do
      allow(git).to receive(:remotes).and_return(remotes)
    end

    it 'fetches the URL from the first remote' do
      expect(remotes).to receive(:first).and_call_original
      method_call
    end

    context 'when the URL is a standard SSH url' do
      it "returns only the path of the remote's URL" do
        expect(method_call).to eq('/projects/central/bsw')
      end
    end

    context 'when the URL is a Git URL' do
      let(:remote_url) { 'git://git@git.local/esrlabs/dox.git' }

      it "returns only the path of the remote's URL" do
        expect(method_call).to eq('/esrlabs/dox.git')
      end
    end

    context 'when the URL is a GitHub URL' do
      let(:remote_url) { 'git@github.com:esrlabs/dox.git' }

      it "returns only the path of the remote's URL" do
        expect(method_call).to eq('/esrlabs/dox.git')
      end
    end

    context 'when the URL is an HTTPS URL' do
      let(:remote_url) { 'https://github.com/esrlabs/dox.git' }

      it "returns only the path of the remote's URL" do
        expect(method_call).to eq('/esrlabs/dox.git')
      end
    end

    context 'when the URL is a file URL' do
      let(:remote_url) { '~/Projects/esrlabs/dox' }

      it "returns only the path of the remote's URL" do
        expect(method_call).to eq('~/Projects/esrlabs/dox')
      end
    end

    context 'when the URL is a JOSH URL' do
      let(:remote_url) { 'https://focal.fossa@josh.local/bsw.git:/libs.git' }

      it "returns only the path of the remote's URL" do
        expect(method_call).to eq('/bsw.git:/libs.git')
      end
    end
  end

  describe '#multi?' do
    subject(:method_call) { repository.multi? }

    it 'returns false' do
      expect(method_call).to eq(false)
    end
  end

  describe '#repositories' do
    subject(:method_call) { repository.repositories }

    let(:message) do
      "Failed to perform the action 'repositories' on '#{path}'."\
      ' The path was not set-up as a multi-repo path. If you are running'\
      ' without the --multi-repo command line switch make sure that none of'\
      " your MTRs have a 'repos' attribute or run with the --multi-repo switch"
    end

    it 'raises a Dragnet::Errors::IncompatibleRepositoryError' do
      expect { method_call }.to raise_error(
        Dragnet::Errors::IncompatibleRepositoryError,
        message
      )
    end
  end

  shared_examples_for '#branches_with' do
    context 'when there are no branches' do
      it 'returns an empty array' do
        expect(method_call).to be_an(Array).and be_empty
      end
    end

    context 'when no branch contains the given commit' do
      let(:branches) do
        [
          instance_double(Git::Branch, contains?: false),
          instance_double(Git::Branch, contains?: false),
          instance_double(Git::Branch, contains?: false)
        ]
      end

      it 'returns an empty array' do
        expect(method_call).to be_an(Array).and be_empty
      end
    end

    context 'when some of the branches contain the given commit' do
      let(:containing_branches) do
        [
          instance_double(Git::Branch, contains?: true),
          instance_double(Git::Branch, contains?: true)
        ]
      end

      let(:branches) do
        containing_branches + [
          instance_double(Git::Branch, contains?: false)
        ]
      end

      it 'returns the expected array of branches' do
        expect(method_call).to eq(containing_branches)
      end
    end
  end

  describe '#branches_with' do
    subject(:method_call) { repository.branches_with(commit) }

    let(:commit) { '13002236e4' }

    it_behaves_like '#branches_with'
  end

  describe '#branches_with_head' do
    subject(:method_call) { repository.branches_with_head }

    let(:head_sha1) { '6d71da084791ddadc54f4acb25b739c9b240a552' }

    let(:head) do
      instance_double(
        Git::Object::Commit,
        sha: head_sha1
      )
    end

    before do
      allow(git).to receive(:object).with('HEAD').and_return(head)
    end

    it_behaves_like '#branches_with'
  end
end
