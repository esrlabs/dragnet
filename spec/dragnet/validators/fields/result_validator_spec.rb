# frozen_string_literal: true

require 'dragnet/validators/fields/result_validator'

require_relative 'field_validator_shared'

RSpec.describe Dragnet::Validators::Fields::ResultValidator do
  subject(:result_validator) { described_class.new }

  describe '#validate' do
    subject(:method_call) { result_validator.validate(key, value) }

    let(:key) { 'result' }
    let(:value) { 'passed' }

    context 'with a valid result' do
      it 'does not raise any errors' do
        expect { method_call }.not_to raise_error
      end

      context 'when the given value has odd capitalization' do
        let(:value) { 'PaSsEd' }

        it 'returns the downcase version of the value' do
          expect(method_call).to eq('passed')
        end
      end
    end

    context "when the data doesn't have a result key", requirements: ['SRS_DRAGNET_0008'] do
      let(:value) { nil }
      let(:expected_message) { 'Missing required key: result' }

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the result key contains something that is not a string', requirements: ['SRS_DRAGNET_0008'] do
      let(:value) { /missed/ }

      let(:expected_message) do
        'Incompatible type for key result: Expected String got Regexp instead'
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the value of the result field is not valid', requirements: ['SRS_DRAGNET_0008'] do
      let(:value) { 'missed' }

      let(:expected_message) do
        "Invalid value for key result: '#{value}'. Valid values are passed, failed"
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end
  end
end
