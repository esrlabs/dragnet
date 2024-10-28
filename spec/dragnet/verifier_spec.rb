# frozen_string_literal: true

require 'dragnet/verifier'

RSpec.describe Dragnet::Verifier do
  subject(:verifier) do
    described_class.new(test_records: test_records, repository: repository, logger: logger)
  end

  let(:test_records) do
    [
      instance_double(
        Dragnet::TestRecord,
        source_file: 'Workspace/project/test/manual/security.yml',
        'verification_result=': true
      ),
      instance_double(
        Dragnet::TestRecord,
        source_file: 'Workspace/project/test/manual/crypto.yml',
        'verification_result=': true
      ),
      instance_double(
        Dragnet::TestRecord,
        source_file: 'Workspace/project/test/manual/processes.yml',
        'verification_result=': true
      )
    ]
  end

  let(:repository) do
    instance_double(
      Dragnet::Repository
    )
  end

  let(:logger) do
    instance_double(
      Dragnet::CLI::Logger,
      info: true
    )
  end

  describe '#verify' do
    subject(:method_call) { verifier.verify }

    let(:passed_verification_result) do
      instance_double(
        Dragnet::VerificationResult,
        status: :passed,
        'started_at=': true,
        'finished_at=': true,
        log_message: 'PASSED'
      )
    end

    let(:test_record_verifier) do
      instance_double(
        Dragnet::Verifiers::TestRecordVerifier,
        verify: passed_verification_result
      )
    end

    before do
      allow(Dragnet::Verifiers::TestRecordVerifier).to receive(:new).and_return(test_record_verifier)
    end

    RSpec.shared_examples 'prints nothing to STDOUT' do
      it 'prints nothing to STDOUT', requirements: ['DRAGNET_0031'] do
        expect { method_call }.not_to output.to_stdout
      end
    end

    include_examples 'prints nothing to STDOUT'

    it 'passes all the Test Records through the TestRecordVerifier', requirements: ['DRAGNET_0030'] do
      test_records.each do |test_record|
        expect(Dragnet::Verifiers::TestRecordVerifier).to receive(:new)
          .with(test_record: test_record, repository: repository, test_records: test_records)
      end

      method_call
    end

    shared_examples 'logs the passing of the passing MTRs' do
      # Required variables:
      # :passed_test_records_count: The number of test records that should have passed the verification.

      it 'logs the passing of all MTRs', requirements: %w[DRAGNET_0028] do
        expect(passed_verification_result).to receive(:log_message).exactly(passed_test_records_count).times
        expect(logger).to receive(:info).with('PASSED').exactly(passed_test_records_count).times

        method_call
      end
    end

    shared_examples 'records the timestamp attributes to the VerificationResult objects' do
      # Required variables
      # :verification_result: The VerificationResult double that should receive the messages
      # :number_of_messages: The number of messages that should be received by the VerificationResult double

      it 'records the started_at timestamp', requirements: %w[DRAGNET_0075] do
        expect(verification_result).to receive(:started_at=).with(instance_of(Time)).exactly(number_of_messages).times
        method_call
      end

      it 'records the finished_at timestamp', requirements: %w[DRAGNET_0076] do
        expect(verification_result).to receive(:finished_at=).with(instance_of(Time)).exactly(number_of_messages).times
        method_call
      end
    end

    shared_examples_for 'attaches the passed VerificationResult to the passing MTRs' do
      it 'attaches the passed VerificationResult to the passing MTRs' do
        expect(passed_test_records).to all(
          receive(:verification_result=).with(passed_verification_result)
        )

        method_call
      end
    end

    context 'when the verifications passes for all MTRs' do
      let(:passed_test_records) { test_records }
      let(:passed_test_records_count) { passed_test_records.size }

      include_examples 'prints nothing to STDOUT'
      include_examples 'logs the passing of the passing MTRs'

      describe 'timestamp values for the passing MTRs' do
        let(:verification_result) { passed_verification_result }
        let(:number_of_messages) { passed_test_records_count }

        include_examples 'records the timestamp attributes to the VerificationResult objects'
      end

      include_examples 'attaches the passed VerificationResult to the passing MTRs'
    end

    context 'when the verification fails for one or more of the MTRs' do
      let(:failed_test_records_count) { rand(1..2) }
      let(:failed_test_records) { test_records.sample(failed_test_records_count) }
      let(:passed_test_records) { test_records - failed_test_records }
      let(:passed_test_records_count) { passed_test_records.size }

      let(:reason) { "'result' field has the status 'failed'" }

      let(:failed_verification_result) do
        instance_double(
          Dragnet::VerificationResult,
          status: :failed,
          reason: reason,
          'started_at=': true,
          'finished_at=': true,
          log_message: 'FAILED'
        )
      end

      let(:failing_test_record_verifier) do
        instance_double(
          Dragnet::Verifiers::TestRecordVerifier,
          verify: failed_verification_result
        )
      end

      before do
        failed_test_records.each do |failed_test_record|
          allow(Dragnet::Verifiers::TestRecordVerifier).to receive(:new)
            .with(test_record: failed_test_record, repository: repository, test_records: test_records)
            .and_return(failing_test_record_verifier)
        end
      end

      include_examples 'prints nothing to STDOUT'

      it 'logs the failure of the test record(s)', requirements: %w[DRAGNET_0028] do
        expect(failed_verification_result).to receive(:log_message).exactly(failed_test_records_count).times
        expect(logger).to receive(:info).with('FAILED').exactly(failed_test_records_count).times

        method_call
      end

      describe 'timestamp values for the passing MTRs' do
        let(:verification_result) { passed_verification_result }
        let(:number_of_messages) { passed_test_records_count }

        include_examples 'records the timestamp attributes to the VerificationResult objects'
      end

      describe 'timestamp values for the failing MTRs' do
        let(:verification_result) { failed_verification_result }
        let(:number_of_messages) { failed_test_records_count }

        include_examples 'records the timestamp attributes to the VerificationResult objects'
      end

      it 'attaches the failed VerificationResult to the failed TestRecords' do
        expect(failed_test_records).to all(
          receive(:verification_result=).with(failed_verification_result)
        )

        method_call
      end

      include_examples 'logs the passing of the passing MTRs'
      include_examples 'attaches the passed VerificationResult to the passing MTRs'
    end

    context 'when the verification is skipped for one or more of the MTRs' do
      let(:skipped_test_records_count) { rand(1..2) }
      let(:skipped_test_records) { test_records.sample(skipped_test_records_count) }
      let(:passed_test_records) { test_records - skipped_test_records }
      let(:passed_test_records_count) { passed_test_records.size }

      let(:reason) { 'Changes detected in listed file(s)' }

      let(:skipped_verification_result) do
        instance_double(
          Dragnet::VerificationResult,
          status: :skipped,
          reason: reason,
          'started_at=': true,
          'finished_at=': true,
          log_message: 'SKIPPED'
        )
      end

      let(:skipping_test_record_verifier) do
        instance_double(
          Dragnet::Verifiers::TestRecordVerifier,
          verify: skipped_verification_result
        )
      end

      before do
        skipped_test_records.each do |skipped_test_record|
          allow(Dragnet::Verifiers::TestRecordVerifier).to receive(:new)
            .with(test_record: skipped_test_record, repository: repository, test_records: test_records)
            .and_return(skipping_test_record_verifier)
        end
      end

      include_examples 'prints nothing to STDOUT'

      it 'logs the skipping of the test record(s)', requirements: %w[DRAGNET_0028] do
        expect(skipped_verification_result).to receive(:log_message).exactly(skipped_test_records_count).times
        expect(logger).to receive(:info).with('SKIPPED').exactly(skipped_test_records_count).times

        method_call
      end

      describe 'timestamp values for the passing MTRs' do
        let(:verification_result) { passed_verification_result }
        let(:number_of_messages) { passed_test_records_count }

        include_examples 'records the timestamp attributes to the VerificationResult objects'
      end

      describe 'timestamp values for the skipped MTRs' do
        let(:verification_result) { skipped_verification_result }
        let(:number_of_messages) { skipped_test_records_count }

        include_examples 'records the timestamp attributes to the VerificationResult objects'
      end

      it 'attaches the skipped VerificationResult to the skipped TestRecords' do
        expect(skipped_test_records).to all(
          receive(:verification_result=).with(skipped_verification_result)
        )

        method_call
      end

      include_examples 'logs the passing of the passing MTRs'
      include_examples 'attaches the passed VerificationResult to the passing MTRs'
    end
  end
end
