# frozen_string_literal: true

require 'dragnet/verifiers/changes_verifier'

RSpec.describe Dragnet::Verifiers::ChangesVerifier do
  subject(:changes_verifier) do
    described_class.new(test_record: test_record, repository: repository, test_records: test_records)
  end

  let(:path) { Pathname.new('/Workspace/project/') }

  let(:commit) do
    instance_double(
      Git::Object::Commit,
      sha: '83674b8a8168c21de46547f62b606e6ec981c9c7'
    )
  end

  let(:repository) do
    instance_double(
      Dragnet::Repository,
      path: path,
      head: commit
    )
  end

  let(:test_records) do
    [
      instance_double(
        Dragnet::TestRecord,
        source_file: path / 'tests/manual/security.yml',
        sha1: 'ed981b34eed'
      ),
      instance_double(
        Dragnet::TestRecord,
        source_file: path / 'tests/manual/processes.yml',
        sha1: '05f961d151e'
      )
    ]
  end

  let(:test_record) { test_records.first }

  before do
    allow(repository).to receive(:diff).with('ed981b34eed', 'HEAD').and_return(diff)
  end

  describe '#verify' do
    subject(:method_call) { changes_verifier.verify }

    let(:verification_result) do
      instance_double(
        Dragnet::VerificationResult
      )
    end

    before do
      allow(Dragnet::VerificationResult).to receive(:new)
        .and_return(verification_result)
    end

    context 'when there are no changes in the repository', requirements: ['SRS_DRAGNET_0016'] do
      let(:diff) do
        instance_double(
          Git::Diff,
          size: 0
        )
      end

      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context 'when there are changes in the repository', requirements: ['SRS_DRAGNET_0016'] do
      let(:diff) do
        instance_double(
          Git::Diff,
          size: 2,
          stats: stats
        )
      end

      context 'when the changes are only in MTR files', requirements: ['SRS_DRAGNET_0015'] do
        let(:stats) do
          {
            files: {
              'tests/manual/processes.yml' => { insertions: 2, deletions: 6 }
            }
          }
        end

        it 'returns nil' do
          expect(method_call).to be_nil
        end
      end

      context 'when the change include other files', requirements: ['SRS_DRAGNET_0015'] do
        let(:stats) do
          {
            files: {
              'tests/manual/security.yml' => { insertions: 1, deletions: 1 },
              'src/startup/entry.cpp' => { insertions: 14, deletions: 6 }
            }
          }
        end

        let(:expected_parameters) do
          {
            status: :skipped,
            reason: 'Changes detected in the repository: ed981b34ee..83674b8a81 # -- src/startup/entry.cpp'
          }
        end

        it 'creates a VerificationResult object with the expected parameters' do
          expect(Dragnet::VerificationResult).to receive(:new).with(expected_parameters)
          method_call
        end

        it 'returns the failed VerificationResult' do
          expect(method_call).to eq(verification_result)
        end
      end
    end

    context 'when the difference between the two revisions cannot be determined', requirements: %w[SRS_DRAGNET_0082] do
      let(:diff) { instance_double(Git::Diff) }

      let(:result) do
        instance_double(
          Git::CommandLineResult,
          git_cmd: "git '--git-dir=/Workspace/project/.git' '-c' 'diff' '--numstat' " \
                   "'ed981b34eed' 'HEAD' 2>&1",
          status: instance_double(Process::Status),
          stdout: 'fatal: bad object ed981b34eed',
          stderr: ''
        )
      end

      let(:expected_parameters) do
        {
          status: :failed,
          reason: 'Unable to diff the revisions: ed981b34ee..83674b8a81: ' \
                  'fatal: bad object ed981b34eed'
        }
      end

      before do
        allow(diff).to receive(:size).and_raise(Git::FailedError, result)
      end

      it 'creates a VerificationResult object with the expected parameters' do
        expect(Dragnet::VerificationResult).to receive(:new).with(expected_parameters)
        method_call
      end

      it 'returns the failed VerificationResult' do
        expect(method_call).to eq(verification_result)
      end
    end
  end
end
