# frozen_string_literal: true

require 'dragnet/validators/fields/sha1_validator'

require_relative 'field_validator_shared.rb'

RSpec.describe Dragnet::Validators::Fields::SHA1Validator do
  subject(:sha1_validator) { described_class.new }

  describe '#valiudate' do
    subject(:method_call) { sha1_validator.validate(key, value) }

    let(:key) { 'sha1' }
    let(:value) { '6c25d4c4e0183136b558ce8cbc67b0f9463c3ad1' }

    context 'with a valid SHA1' do
      it "doesn't raise any errors" do
        expect { method_call }.not_to raise_error
      end
    end

    context "when the data doesn't have a sha1 key", requirements: ['DRAGNET_0006'] do
      let(:value) { nil }
      let(:expected_message) { 'Missing required key: sha1' }

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the SHA1 is not a string', requirements: ['DRAGNET_0006'] do
      let(:value) { 123_456 }

      let(:expected_message) do
        'Incompatible type for key sha1: Expected String got Integer instead'
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the SHA1 is too short', requirements: ['DRAGNET_0006'] do
      let(:value) { 'af27' }

      let(:expected_message) do
        "Invalid value for key sha1: '#{value}'. Expected a string between 7 and 40 characters"
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the SHA1 is too long', requirements: ['DRAGNET_0006'] do
      let(:value) { 'ca3a9455ae12dc3a1939a3152d82250cc9ed001a1f8736b43010a41702b' }

      let(:expected_message) do
        "Invalid value for key sha1: '#{value}'. Expected a string between 7 and 40 characters"
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    context 'when the SHA1 is not a valid hexadecimal string', requirements: ['DRAGNET_0006'] do
      let(:value) { '...jumped over the lazy gray dog' }

      let(:expected_message) do
        "Invalid value for key sha1: '#{value}'. Doesn't seem to be a valid hexadecimal string"
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end
  end
end
