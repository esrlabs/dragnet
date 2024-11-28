# frozen_string_literal: true

require 'dragnet/validators/fields/meta_data_field_validator'

RSpec.describe Dragnet::Validators::Fields::MetaDataFieldValidator, requirements: %w[SRS_DRAGNET_0068] do
  subject(:meta_data_field_validator) { described_class.new }

  describe '#validate' do
    subject(:method_call) { meta_data_field_validator.validate(key, value) }

    let(:key) { 'name' }

    context 'when value is nil' do
      let(:value) { nil }

      it 'does not raise any error' do
        expect { method_call }.not_to raise_error
      end

      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context 'when the value is neither a String nor an Array' do
      let(:value) { { the: 'best name' } }

      it 'raises a Dragnet::Errors::ValidationError' do
        expect { method_call }.to raise_error(
          Dragnet::Errors::ValidationError,
          'Incompatible type for key name: Expected String, Array got Hash instead'
        )
      end
    end

    context 'when the value is a String' do
      let(:value) { 'Some name' }

      it 'does not raise any errors' do
        expect { method_call }.not_to raise_error
      end

      it 'returns an array with the given string' do
        expect(method_call).to eq([value])
      end
    end

    context 'when the value is an Array' do
      context 'when the Array is empty' do
        let(:value) { [] }

        it 'does not raise any errors' do
          expect { method_call }.not_to raise_error
        end

        it 'returns nil' do
          expect(method_call).to be_nil
        end
      end

      context 'when the array has only strings' do
        let(:value) { %w[a beautiful name right?] }

        it 'does not raise any errors' do
          expect { method_call }.not_to raise_error
        end

        it 'returns the same array' do
          expect(method_call).to be(value)
        end
      end

      context 'when the array has something besides strings' do
        let(:value) { ['some', 'name', 47] }

        it 'raises a Dragnet::Errors::ValidationError' do
          expect { method_call }.to raise_error(
            Dragnet::Errors::ValidationError,
            'Incompatible type for key name: Expected a Array<String>. Found a(n) Integer inside the array'
          )
        end
      end
    end
  end
end
