# frozen_string_literal: true

require 'dragnet/validators/repos_validator'

RSpec.describe Dragnet::Validators::ReposValidator do
  subject(:repos_validator) { described_class.new(test_record, path) }

  let(:repos) { nil }

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord,
      repos: repos
    )
  end

  let(:path) do
    instance_double(
      Pathname,
      to_s: '/workspace/source'
    )
  end

  describe '#validate' do
    subject(:method_call) { repos_validator.validate }

    context "when the Test Record has no 'repos'" do
      it 'does not raise any errors' do
        expect { method_call }.not_to raise_error
      end
    end

    context "when the Test Record have 'repos'" do
      let(:absolute_path_string) { '/workspace/some/other/repo' }
      let(:relative_path_string) { 'path/to/repo' }
      let(:another_path_string) { 'another/path' }

      let(:files) { %w[some/random/file.cpp a/glob/pattern*.cpp] }

      let(:another_repo) do
        instance_double(
          Dragnet::Repo,
          files: files,
          path: another_path_string,
          'path=': true
        )
      end

      let(:repos) do
        [
          instance_double(
            Dragnet::Repo,
            files: nil,
            path: absolute_path_string,
            'path=': true
          ),
          instance_double(
            Dragnet::Repo,
            files: nil,
            path: relative_path_string,
            'path=': true
          ),
          another_repo
        ]
      end

      let(:complete_exists) { true }
      let(:complete_path) { instance_double(Pathname, exist?: complete_exists) }

      let(:absolute_exists) { true }

      let(:absolute_path) do
        instance_double(
          Pathname,
          absolute?: true,
          relative?: false,
          exist?: absolute_exists,
          to_s: absolute_path_string
        )
      end

      let(:relative_path) { instance_double(Pathname, absolute?: false, relative?: true, to_s: relative_path_string) }
      let(:another_path) { instance_double(Pathname, absolute?: false) }

      let(:files_validator) do
        instance_double(
          Dragnet::Validators::FilesValidator,
          validate: true
        )
      end

      before do
        allow(Pathname).to receive(:new).with(relative_path_string).and_return(relative_path)
        allow(Pathname).to receive(:new).with(absolute_path_string).and_return(absolute_path)
        allow(Pathname).to receive(:new).with(another_path_string).and_return(another_path)

        allow(path).to receive(:/).with(relative_path).and_return(complete_path)
        allow(path).to receive(:/).with(another_path).and_return(complete_path)

        allow(Dragnet::Validators::FilesValidator).to receive(:new).and_return(files_validator)
      end

      context 'when the path has backslashes and not slashes' do
        let(:transformed_path) { 'another/path' }

        it 'transform the slashes and replaces the path string' do
          expect(another_repo).to receive(:path=).with(transformed_path)
          method_call
        end

        it 'uses the transformed path to do the checking' do
          expect(Pathname).to receive(:new).with(transformed_path)
          method_call
        end
      end

      context 'when the repo has a relative path', requirements: %w[DRAGNET_0039] do
        let(:complete_path) { instance_double(Pathname, exist?: complete_exists) }

        it 'creates a path by joining the workspace path with the path of the repo' do
          expect(path).to receive(:/).with(relative_path)
          method_call
        end

        it 'verifies the existence of the generated path' do
          expect(complete_path).to receive(:exist?)
          method_call
        end

        context "when the repo path doesn't exist" do
          let(:complete_exists) { false }

          it 'raises a Dragnet::Errors::RepoPathNotFoundError', requirements: %w[DRAGNET_0058] do
            expect { method_call }.to raise_error(
              Dragnet::Errors::RepoPathNotFoundError,
              'Cannot find the repository path path/to/repo inside /workspace/source'
            )
          end
        end
      end

      context 'when the repo has an absolute path', requirements: %w[DRAGNET_0039] do
        it 'verifies the existence of the given path directly' do
          expect(absolute_path).to receive(:exist?)
          method_call
        end

        context "when the repo path doesn't exist" do
          let(:absolute_exists) { false }

          it 'raises a Dragnet::Errors::RepoPathNotFoundError', requirements: %w[DRAGNET_0058] do
            expect { method_call }.to raise_error(
              Dragnet::Errors::RepoPathNotFoundError,
              'Cannot find the repository path /workspace/some/other/repo'
            )
          end
        end
      end

      context 'when the repos have no files', requirements: %w[DRAGNET_0049] do
        let(:files) { nil }

        it 'does not perform any validation over files' do
          expect(Dragnet::Validators::FilesValidator).not_to receive(:new)
          method_call
        end

        it 'does not raise any errors' do
          expect { method_call }.not_to raise_error
        end
      end

      context "when one of the files listed in a 'repo' doesn't exist" do
        let(:expected_error) do
          [
            Dragnet::Errors::FileNotFoundError,
            'Could not find any files matching a/glob/pattern*.cpp in /workspace/source/another/path'
          ]
        end

        before do
          allow(files_validator).to receive(:validate).and_raise(*expected_error)
        end

        it 'raises a Dragnet::Errors::FileNotFoundError', requirements: %w[DRAGNET_0044 DRAGNET_0047 DRAGNET_0048] do
          expect { method_call }.to raise_error(*expected_error)
        end
      end
    end
  end
end
