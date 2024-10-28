# frozen_string_literal: true

require 'dragnet/exporters/serializers/repo_serializer'

RSpec.describe Dragnet::Exporters::Serializers::RepoSerializer do
  subject(:repo_serializer) { described_class.new(repo) }

  let(:path) { 'path/to/repo' }
  let(:sha1) { '1a3425a' }
  let(:files) { nil }

  let(:repo) do
    instance_double(
      Dragnet::Repo,
      path: path,
      sha1: sha1,
      files: files
    )
  end

  describe '#serialize' do
    subject(:method_call) { repo_serializer.serialize }

    it 'produces a Hash' do
      expect(method_call).to be_a(Hash)
    end

    it 'includes the path to the repo' do
      expect(method_call).to include(path: path)
    end

    it 'includes the SHA1 of the repo' do
      expect(method_call).to include(sha1: sha1)
    end

    shared_examples_for '#serialize when the Repo has no listed files' do
      it 'does not include the :files key' do
        expect(method_call).not_to have_key(:files)
      end
    end

    context 'when the repo has no listed files' do
      let(:files) { nil }

      it_behaves_like '#serialize when the Repo has no listed files'
    end

    context 'when the list of files is empty' do
      let(:files) { [] }

      it_behaves_like '#serialize when the Repo has no listed files'
    end

    context 'when there are listed files' do
      let(:files) do
        [
          'path/to/repo/some/directory/file.cpp',                        # Has the path to the repo in it
          Pathname.new('path/to/repo/another/directory/other-file.cpp'), # Pathname and path to the repo
          'just/a/simple-file.h',                                        # A simple file, without the repo's path
          Pathname.new('another/simple/file/in/a/directory.c')           # Pathname, without the path to the repo
        ]
      end

      let(:expected_files) do
        %w[
          some/directory/file.cpp
          another/directory/other-file.cpp
          just/a/simple-file.h
          another/simple/file/in/a/directory.c
        ]
      end

      it 'includes the expected list of files' do
        expect(method_call).to include(files: expected_files)
      end
    end
  end
end
