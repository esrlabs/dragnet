# frozen_string_literal: true

require 'dragnet/verifiers/result_verifier'

RSpec.shared_examples 'Dragnet::Verifiers::ResultVerifier#verify creates and assign the VerificationResult object' do
  it 'creates the Verification Result with the expected parameters' do
    expect(Dragnet::VerificationResult).to receive(:new).with(expected_parameters)
    method_call
  end

  it 'returns the failed VerificationResult' do
    expect(method_call).to eq(verification_result)
  end
end

RSpec.describe Dragnet::Verifiers::ResultVerifier do
  subject(:result_verifier) { described_class.new(test_record: test_record) }

  let(:passed) { false }

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord,
      result: result,
      passed?: passed
    )
  end

  let(:verification_result) do
    instance_double(
      Dragnet::VerificationResult
    )
  end

  before do
    allow(Dragnet::VerificationResult).to receive(:new)
      .and_return(verification_result)
  end

  describe '#verify' do
    subject(:method_call) { result_verifier.verify }

    context 'when the result is "passed"', requirements: ['DRAGNET_0016'] do
      let(:result) { 'passed' }
      let(:passed) { true }

      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context 'when the result is "failed"', requirements: ['DRAGNET_0011'] do
      let(:result) { 'failed' }

      let(:expected_parameters) do
        {
          status: :failed,
          reason: "'result' field has the status 'failed'"
        }
      end

      include_examples 'Dragnet::Verifiers::ResultVerifier#verify creates and assign the VerificationResult object'
    end

    context 'when the result is something else' do
      let(:result) { 'unknown' }

      let(:expected_parameters) do
        {
          status: :failed,
          reason: "'result' field has the status 'unknown'"
        }
      end

      include_examples 'Dragnet::Verifiers::ResultVerifier#verify creates and assign the VerificationResult object'
    end
  end
end
