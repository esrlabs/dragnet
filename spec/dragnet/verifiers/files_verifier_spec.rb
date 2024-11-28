# frozen_string_literal: true

require 'dragnet/verifiers/files_verifier'

RSpec.describe Dragnet::Verifiers::FilesVerifier do
  subject(:files_verifier) do
    described_class.new(test_record: test_record, repository: repository)
  end

  let(:path) { Pathname.new('/Workspace/project') }

  let(:files) do
    [
      path / 'src/master/module.cpp',
      path / 'src/master/module.h',
      path / 'src/master/constants.h'
    ]
  end

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord,
      sha1: 'a981468aedddc0b6b19a00949591561985f8b956',
      files: files
    )
  end

  let(:commit) do
    instance_double(
      Git::Object::Commit,
      sha: '83674b8a8168c21de46547f62b606e6ec981c9c7'
    )
  end

  let(:repository) do
    instance_double(
      Dragnet::Repository,
      diff: diff,
      head: commit,
      path: path
    )
  end

  let(:diff) do
    instance_double(
      Git::Diff,
      size: 0
    )
  end

  before do
    allow(diff).to receive(:path).and_return(diff)
  end

  describe '#verify' do
    subject(:method_call) { files_verifier.verify }

    context 'when the MTR has not files' do
      let(:files) { [] }

      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context 'when there are no changes in the listed files', requirements: ['SRS_DRAGNET_0016'] do
      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context 'when one or more of the files have changes', requirements: %w[SRS_DRAGNET_0012 SRS_DRAGNET_0014] do
      let(:changed_diff) do
        instance_double(
          Git::Diff,
          size: 1
        )
      end

      let(:verification_result) do
        instance_double(
          Dragnet::VerificationResult
        )
      end

      let(:expected_parameters) do
        {
          status: :skipped,
          reason: 'Changes detected in listed file(s): a981468aed..83674b8a81'\
                  ' -- src/master/module.cpp src/master/constants.h'
        }
      end

      before do
        allow(diff).to receive(:path)
          .with('src/master/module.cpp').and_return(changed_diff)

        allow(diff).to receive(:path)
          .with('src/master/constants.h').and_return(changed_diff)

        allow(Dragnet::VerificationResult).to receive(:new)
          .and_return(verification_result)
      end

      it 'creates a VerificationResult object with the expected parameters' do
        expect(Dragnet::VerificationResult).to receive(:new).with(expected_parameters)
        method_call
      end

      it 'returns the expected VerificationResult' do
        expect(method_call).to eq(verification_result)
      end
    end
  end
end
