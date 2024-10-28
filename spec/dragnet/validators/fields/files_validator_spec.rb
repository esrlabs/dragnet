# frozen_string_literal: true

require 'dragnet/validators/fields/files_validator'

require_relative 'field_validator_shared'

RSpec.describe Dragnet::Validators::Fields::FilesValidator do
  subject(:files_validator) { described_class.new }

  describe '#validate' do
    subject(:method_call) { files_validator.validate(key, value) }

    let(:key) { 'files' }
    let(:value) do
      %w[
        source/tests/manual/safeio.yaml
        source/tests/manual/safety.yaml
        source/tests/manual/signals.yaml
      ]
    end

    context 'with an array of files' do
      it "doesn't raise any errors" do
        expect { method_call }.not_to raise_error
      end
    end

    context 'with a single string' do
      let(:value) { 'test/manual/ESR_REQ_5745.yaml' }
      let(:expected_result) { [value] }

      it 'turns it into an array' do
        expect(method_call).to eq(expected_result)
      end
    end

    context 'when the files key has an invalid type' do
      let(:value) { -5 }

      let(:expected_message) do
        'Incompatible type for key files: Expected String, Array got Integer instead'
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the array on the files key contains something that is not a string' do
      let(:value) { ['test/manual/ESR_REQ_3003.yaml', 23] }

      let(:expected_message) do
        'Incompatible type for key files: Expected a Array<String>. '\
        'Found a(n) Integer inside the array'
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end
  end
end

