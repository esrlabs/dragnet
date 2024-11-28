# frozen_string_literal: true

require 'dragnet/verifiers/test_record_verifier'

RSpec.describe Dragnet::Verifiers::TestRecordVerifier do
  subject(:test_record_verifier) do
    described_class.new(test_record: test_record, repository: repository, test_records: test_records)
  end

  let(:files) { nil }
  let(:repos) { nil }

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord,
      files: files,
      repos: repos,
      verification_result: nil,
      'verification_result=': true
    )
  end

  let(:repository) do
    instance_double(
      Dragnet::Repository
    )
  end

  let(:test_records) do
    [
      instance_double(Dragnet::TestRecord),
      instance_double(Dragnet::TestRecord),
      instance_double(Dragnet::TestRecord)
    ]
  end

  describe '#verify' do
    subject(:method_call) { test_record_verifier.verify }

    let(:result_verifier) do
      instance_double(
        Dragnet::Verifiers::ResultVerifier,
        verify: nil
      )
    end

    let(:changes_verifier) do
      instance_double(
        Dragnet::Verifiers::ChangesVerifier,
        verify: nil
      )
    end

    before do
      allow(Dragnet::Verifiers::ResultVerifier).to receive(:new).and_return(result_verifier)
      allow(Dragnet::Verifiers::ChangesVerifier).to receive(:new).and_return(changes_verifier)
    end

    shared_examples '#verify' do
      it "uses the ResultVerifier to verify the TestRecord's result" do
        expect(Dragnet::Verifiers::ResultVerifier).to receive(:new).with(test_record: test_record)
        expect(result_verifier).to receive(:verify)
        method_call
      end
    end

    shared_examples_for '#verify when all verifications pass' do
      let(:passed_verification_result) do
        instance_double(
          Dragnet::VerificationResult
        )
      end

      before do
        allow(Dragnet::VerificationResult).to receive(:new)
          .with(status: :passed).and_return(passed_verification_result)
      end

      it 'creates a passed VerificationResult', requirements: %w[SRS_DRAGNET_0016] do
        expect(Dragnet::VerificationResult).to receive(:new).with(status: :passed)
        method_call
      end

      it 'returns the passed VerificationResult', requirements: %w[SRS_DRAGNET_0016] do
        expect(method_call).to eq(passed_verification_result)
      end
    end

    shared_context 'when the TestRecord fails the verification' do
      # Required variables
      # :test_record: The test record that should to fail the verification
      # :failed_verifier: The instance double of the Verifier class which
      #   triggers the failure

      let(:failed_verification_result) do
        instance_double(
          Dragnet::VerificationResult
        )
      end

      before do
        allow(failed_verifier).to receive(:verify).and_return(failed_verification_result)
      end

      it 'returns the failed VerificationResult' do
        expect(method_call).to eq(failed_verification_result)
      end
    end

    it_behaves_like '#verify'

    context 'when the TestRecord fails the result verification' do
      let(:failed_verifier) { result_verifier }

      include_context 'when the TestRecord fails the verification'

      it 'does not pass the TestRecord to the FilesVerifier' do
        expect(Dragnet::Verifiers::FilesVerifier).not_to receive(:new)
        method_call
      end

      it 'does not pass the TestRecord to the ReposVerifier' do
        expect(Dragnet::Verifiers::ReposVerifier).not_to receive(:new)
        method_call
      end

      it 'does not pass the TestRecord to the ChangesVerifier' do
        expect(Dragnet::Verifiers::ChangesVerifier).not_to receive(:new)
        method_call
      end
    end

    context 'when the TestRecord has files' do
      let(:files) do
        %w[
          modules/dem/src/dem/DEMLocker.cpp
          modules/dem/src/dem/DEMUtils.cpp
          modules/dem/src/dem/DiagJobs/SecondaryErrorMemory/SecAppDummyDTCJob.cpp
        ]
      end

      let(:files_verifier) do
        instance_double(
          Dragnet::Verifiers::FilesVerifier,
          verify: nil
        )
      end

      before do
        allow(Dragnet::Verifiers::FilesVerifier).to receive(:new).and_return(files_verifier)
      end

      it_behaves_like '#verify'

      it 'does not pass the TestRecord to the ReposVerifier' do
        expect(Dragnet::Verifiers::ReposVerifier).not_to receive(:new)
        method_call
      end

      it 'does not pass the TestRecord to the ChangesVerifier' do
        expect(Dragnet::Verifiers::ChangesVerifier).not_to receive(:new)
        method_call
      end

      it 'uses the FilesVerifier to verify the changes to the listed files' do
        expect(Dragnet::Verifiers::FilesVerifier).to receive(:new)
          .with(test_record: test_record, repository: repository)

        expect(files_verifier).to receive(:verify)
        method_call
      end

      context 'when the TestRecord fails the files verification' do
        let(:failed_verifier) { files_verifier }

        include_context 'when the TestRecord fails the verification'
      end

      context 'when the TestRecord passes the files verification' do
        it_behaves_like '#verify when all verifications pass'
      end
    end

    context 'when the TestRecord has repositories' do
      let(:repos) do
        [
          instance_double(Dragnet::Repo),
          instance_double(Dragnet::Repo),
          instance_double(Dragnet::Repo)
        ]
      end

      let(:repos_verifier) do
        instance_double(
          Dragnet::Verifiers::ReposVerifier,
          verify: nil
        )
      end

      before do
        allow(Dragnet::Verifiers::ReposVerifier).to receive(:new).and_return(repos_verifier)
      end

      it_behaves_like '#verify'

      it 'does not pass the TestRecord to the FilesVerifier' do
        expect(Dragnet::Verifiers::FilesVerifier).not_to receive(:new)
        method_call
      end

      it 'does not pass the TestRecord to the ChangesVerifier' do
        expect(Dragnet::Verifiers::ChangesVerifier).not_to receive(:new)
        method_call
      end

      it 'uses the ReposVerifier to verify the changes to the listed repositories',
         requirements: %w[SRS_DRAGNET_0050] do
        expect(Dragnet::Verifiers::ReposVerifier).to receive(:new)
          .with(test_record: test_record, multi_repository: repository)

        expect(repos_verifier).to receive(:verify)
        method_call
      end

      context 'when the TestRecord fails the files verification' do
        let(:failed_verifier) { repos_verifier }

        include_context 'when the TestRecord fails the verification'
      end

      context 'when the TestRecord passes the repos verification' do
        it_behaves_like '#verify when all verifications pass'
      end
    end

    context "when the TestRecord doesn't have files nor repositories" do
      it_behaves_like '#verify'

      it 'does not pass the TestRecord to the FilesVerifier' do
        expect(Dragnet::Verifiers::FilesVerifier).not_to receive(:new)
        method_call
      end

      it 'does not pass the TestRecord to the ReposVerifier' do
        expect(Dragnet::Verifiers::ReposVerifier).not_to receive(:new)
        method_call
      end

      it 'uses the ChangesVerifier to verify the changes in the repository' do
        expect(Dragnet::Verifiers::ChangesVerifier).to receive(:new)
          .with(test_record: test_record, repository: repository, test_records: test_records)

        expect(changes_verifier).to receive(:verify)
        method_call
      end

      context 'when the TestRecord fails the changes verification' do
        let(:failed_verifier) { changes_verifier }

        include_context 'when the TestRecord fails the verification'
      end

      context 'when the TestRecord passes the changes verification' do
        it_behaves_like '#verify when all verifications pass'
      end
    end

    context 'when the TestRecord passes all the verifiers' do
      it_behaves_like '#verify when all verifications pass'
    end
  end
end
