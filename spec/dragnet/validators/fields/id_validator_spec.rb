# frozen_string_literal: true

require 'dragnet/validators/fields/id_validator'

require_relative 'field_validator_shared'

RSpec.describe Dragnet::Validators::Fields::IDValidator do
  subject(:id_validator) { described_class.new }

  describe '#validate' do
    subject(:method_call) { id_validator.validate(key, value) }

    let(:key) { 'id' }
    let(:value) { 'ESR_REQ_5435' }

    context 'with a valid ID' do
      it "doesn't raise any errors" do
        expect { method_call }.not_to raise_error
      end
    end

    context "when the data doesn't have an id key", requirements: ['SRS_DRAGNET_0007'] do
      let(:value) { nil }
      let(:expected_message) { 'Missing required key: id' }

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the id key has an invalid data type', requirements: ['SRS_DRAGNET_0007'] do
      let(:value) { 6754.54 }

      let(:expected_message) do
        'Incompatible type for key id: Expected String, Array got Float instead'
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the id key has multiple IDs in a string', requirements: ['SRS_DRAGNET_0007'] do
      let(:value) { 'ERS_REQ_6845, ESR_REQ_9459' }

      let(:expected_message) do
        "Disallowed character ',' found in the value for key id. "\
        'To use multiple requirement IDs please put them into an array'
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the array of IDs has something that is not a string', requirements: ['SRS_DRAGNET_0007'] do
      let(:value) { ['ESR_REQ_3175', 2 + 3i, 'ESR_REQ_8518'] }

      let(:expected_message) do
        'Incompatible type for key id: Expected a Array<String>. '\
        'Found a(n) Complex inside the array'
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end
  end
end
