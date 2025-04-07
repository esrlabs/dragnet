# frozen_string_literal: true

require 'dragnet/verifiers/repos_verifier'

RSpec.describe Dragnet::Verifiers::ReposVerifier do
  subject(:repos_verifier) { described_class.new(test_record: test_record, multi_repository: multi_repository) }

  let(:repos) { nil }

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord,
      repos: repos
    )
  end

  let(:existing_repositories) { {} }

  let(:multi_repository) do
    instance_double(
      Dragnet::MultiRepository,
      path: Pathname('/Workspace/project/source'),
      repositories: existing_repositories
    )
  end

  describe '#verify' do
    subject(:method_call) { repos_verifier.verify }

    context "when the Test Record has no 'repos'" do
      it 'does not raise any errors' do
        expect { method_call }.not_to raise_error
      end

      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context "when the Test Record has 'repos'" do
      let(:repo_files) do
        %w[
          /Workspace/project/source/esrlabs/bsw/crypto/safe_rng.cpp
          /Workspace/project/source/esrlabs/bsw/crypto/safe_rng.h
        ]
      end

      let(:repo_with_files) do
        instance_double(
          Dragnet::Repo,
          path: 'esrlabs/bsw/crypto',
          files: repo_files,
          sha1: '6fd07835de'
        )
      end

      let(:repo_without_files) do
        instance_double(
          Dragnet::Repo,
          path: 'esrlabs/libs/security',
          files: nil,
          sha1: '5ac903b80e'
        )
      end

      let(:repos) do
        [
          repo_with_files,
          repo_without_files
        ]
      end

      let(:repository_with_files) do
        instance_double(
          Dragnet::Repository
        )
      end

      let(:repository_without_files) do
        instance_double(
          Dragnet::Repository
        )
      end

      let(:files_verifier) do
        instance_double(
          Dragnet::Verifiers::FilesVerifier,
          verify: nil
        )
      end

      let(:changes_verifier) do
        instance_double(
          Dragnet::Verifiers::ChangesVerifier,
          verify: nil
        )
      end

      let(:proxy_test_record_with_files) do
        instance_double(
          Dragnet::TestRecord
        )
      end

      let(:proxy_test_record_without_files) do
        instance_double(
          Dragnet::TestRecord
        )
      end

      before do
        allow(Dragnet::Repository).to receive(:new)
          .with(path: Pathname.new('/Workspace/project/source/esrlabs/bsw/crypto'))
          .and_return(repository_with_files)

        allow(Dragnet::Repository).to receive(:new)
          .with(path: Pathname.new('/Workspace/project/source/esrlabs/libs/security'))
          .and_return(repository_without_files)

        allow(Dragnet::Verifiers::FilesVerifier).to receive(:new).and_return(files_verifier)
        allow(Dragnet::Verifiers::ChangesVerifier).to receive(:new).and_return(changes_verifier)

        allow(Dragnet::TestRecord).to receive(:new)
          .with(files: repo_files, sha1: '6fd07835de').and_return(proxy_test_record_with_files)

        allow(Dragnet::TestRecord).to receive(:new)
          .with(files: nil, sha1: '5ac903b80e').and_return(proxy_test_record_without_files)
      end

      describe 'Repositories', requirements: %w[SRS_DRAGNET_0050] do
        it 'creates a Repository object for the Repo with files with the expected path' do
          expect(Dragnet::Repository).to receive(:new)
            .with(path: Pathname.new('/Workspace/project/source/esrlabs/bsw/crypto'))

          method_call
        end

        it 'creates a Repository object for the Repo without files with the expected path' do
          expect(Dragnet::Repository).to receive(:new)
            .with(path: Pathname.new('/Workspace/project/source/esrlabs/libs/security'))

          method_call
        end

        context 'when a Repository for the path already exists' do
          let(:existing_repositories) do
            { 'esrlabs/bsw/crypto' => repository_with_files }
          end

          it 'does not create a new Repository for that path' do
            expect(Dragnet::Repository).not_to receive(:new)
              .with(path: '/Workspace/project/source/esrlabs/bsw/crypto')

            method_call
          end
        end

        context 'when the creation of a repository fails', requirements: %w[SRS_DRAGNET_0045] do
          let(:failed_verification_result) do
            instance_double(
              Dragnet::VerificationResult
            )
          end

          before do
            allow(Dragnet::Repository).to receive(:new)
              .and_raise(ArgumentError, 'Path not found .git')

            allow(Dragnet::VerificationResult).to receive(:new)
              .and_return(failed_verification_result)
          end

          it 'does not raise any errors' do
            expect { method_call }.not_to raise_error
          end

          it 'creates a failed VerificationResult object with the expected status and reason' do
            expect(Dragnet::VerificationResult).to receive(:new)
              .with(status: :failed, reason: "The path 'esrlabs/bsw/crypto' does not contain a valid git repository.")

            method_call
          end

          it 'returns the expected VerificationResult object' do
            expect(method_call).to eq(failed_verification_result)
          end
        end
      end

      describe 'Proxy TestRecords', requirements: %w[SRS_DRAGNET_0050] do
        it 'creates a proxy TestRecord for the first Repo with the expected parameters' do
          expect(Dragnet::TestRecord).to receive(:new).with(files: repo_files, sha1: '6fd07835de')
          method_call
        end

        it 'creates a proxy TestRecord for the second Repo with the expected parameters' do
          expect(Dragnet::TestRecord).to receive(:new).with(files: nil, sha1: '5ac903b80e')
          method_call
        end
      end

      describe 'Verification' do
        it 'verifies the Repo that has files with the FilesVerifier', requirements: %w[SRS_DRAGNET_0051] do
          expect(Dragnet::Verifiers::FilesVerifier).to receive(:new)
            .with(test_record: proxy_test_record_with_files, repository: repository_with_files)

          expect(files_verifier).to receive(:verify)
          method_call
        end

        it 'verifies the Repo that has no files with the ChangesVerifier', requirements: %w[SRS_DRAGNET_0053] do
          expect(Dragnet::Verifiers::ChangesVerifier).to receive(:new)
            .with(test_record: proxy_test_record_without_files, repository: repository_without_files, test_records: [])

          expect(changes_verifier).to receive(:verify)
          method_call
        end
      end

      context 'when none of the inner verifiers fail' do
        it 'returns nil' do
          expect(method_call).to be_nil
        end
      end

      describe 'Inner verifier failures' do
        shared_examples_for '#verify when one of the inner verifiers fails' do
          before do
            allow(files_verifier).to receive(:verify).and_return(failed_verification_result)
          end

          it 'returns the VerificationResult returned by the inner verifier' do
            expect(method_call).to eq(failed_verification_result)
          end

          it 'does not raise any errors' do
            expect { method_call }.not_to raise_error
          end
        end

        context 'when the FilesVerifier fails', requirements: %w[SRS_DRAGNET_0052 SRS_DRAGNET_0059] do
          let(:failed_verification_result) do
            instance_double(
              Dragnet::VerificationResult,
              status: :failed,
              reason: 'Changes detected in listed file(s): 6fd07835de..b8fce26205 ' \
                      '-- /Workspace/project/source/esrlabs/bsw/crypto/safe_rng.cpp'
            )
          end

          it_behaves_like '#verify when one of the inner verifiers fails'
        end

        context 'when the ChangesVerifier fails', requirements: %w[SRS_DRAGNET_0054 SRS_DRAGNET_0059] do
          let(:failed_verification_result) do
            instance_double(
              Dragnet::VerificationResult,
              status: :failed,
              reason: 'Changes detected in the repository: 5ac903b80e..eeb9101593 '\
                      '# -- include/securenvm/AsyncSecureNvm.h'
            )
          end

          it_behaves_like '#verify when one of the inner verifiers fails'
        end
      end
    end
  end
end
