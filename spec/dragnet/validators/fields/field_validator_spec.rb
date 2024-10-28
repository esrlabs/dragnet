# frozen_string_literal: true

require 'dragnet/validators/fields/field_validator'

RSpec.describe Dragnet::Validators::Fields::FieldValidator do
  subject(:field_validator) { described_class.new }

  describe '#validate' do
    subject(:method_call) { field_validator.validate(key, value) }

    let(:key) { nil }
    let(:value) { nil }

    it 'raises a NotImplementedError' do
      expect { method_call }.to raise_error(
        NotImplementedError,
        '#validate method not implemented in Dragnet::Validators::Fields::FieldValidator'
      )
    end
  end
end
