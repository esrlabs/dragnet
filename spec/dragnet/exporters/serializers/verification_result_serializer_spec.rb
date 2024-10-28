# frozen_string_literal: true

require 'dragnet/exporters/serializers/verification_result_serializer'

RSpec.describe Dragnet::Exporters::Serializers::VerificationResultSerializer do
  subject(:verification_result_serializer) { described_class.new(verification_result) }

  let(:status) { :passed }
  let(:reason) { nil }
  let(:started_at) { Time.new(2024, 2, 28, 14, 11, 36, 'UTC') }
  let(:finished_at) { Time.new(2024, 2, 28, 14, 11, 42, 'UTC') }
  let(:runtime) { finished_at - started_at }

  let(:verification_result) do
    instance_double(
      Dragnet::VerificationResult,
      status: status,
      reason: reason,
      started_at: started_at,
      finished_at: finished_at,
      runtime: runtime
    )
  end

  describe '#serialize' do
    subject(:method_call) { verification_result_serializer.serialize }

    shared_examples_for '#serialize' do
      it 'produces a Hash' do
        expect(method_call).to be_a(Hash)
      end

      it 'includes the status of the Verification Result' do
        expect(method_call).to include(status: status)
      end

      it 'includes the started_at attribute' do
        expect(method_call).to include(started_at: '2024-02-28 14:11:36 +0000')
      end

      it 'includes the finished_at attribute' do
        expect(method_call).to include(finished_at: '2024-02-28 14:11:42 +0000')
      end

      it 'includes the runtime attribute' do
        expect(method_call).to include(runtime: runtime)
      end
    end

    context "when the Verification Result doesn't have a reason" do
      let(:reason) { nil }

      it_behaves_like '#serialize'

      it 'does not include the :reason key' do
        expect(method_call).not_to have_key(:reason)
      end
    end

    context 'when the Verification Result has a reason' do
      let(:status) { :skipped }
      let(:reason) { 'Changes detected in the repository' }

      it_behaves_like '#serialize'

      it 'includes the reason' do
        expect(method_call).to include(reason: reason)
      end
    end
  end
end
