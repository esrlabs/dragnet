# frozen_string_literal: true

require 'dragnet/validators/fields/path_validator'

require_relative 'field_validator_shared'

RSpec.describe Dragnet::Validators::Fields::PathValidator do
  subject(:path_validator) { described_class.new }

  describe '#validate' do
    subject(:method_call) { path_validator.validate(key, value) }

    let(:key) { 'path' }
    let(:value) { 'esrlabs/bsw/crypto' }

    context 'when the value is nil' do
      let(:value) { nil }
      let(:expected_message) { 'Missing required key: path' }

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the value is not a String' do
      let(:value) { 45 }

      let(:expected_message) do
        'Incompatible type for key path: Expected String got Integer instead'
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'with a valid value' do
      it 'does not raise any errors' do
        expect { method_call }.not_to raise_error
      end
    end
  end
end
