# frozen_string_literal: true

require 'dragnet/validators/data_validator'

RSpec.shared_examples 'Dragnet::Validators::DataValidator#validate raises a Dragnet::Errors::YAMLFormatError' do
  it 'raises a Dragnet::Errors::YAMLFormatError' do
    expect { method_call }
      .to raise_error(Dragnet::Errors::YAMLFormatError, expected_message)
  end
end

RSpec.describe Dragnet::Validators::DataValidator do
  subject(:data_validator) { described_class.new(data, source_file) }

  let(:sha1) { 'e65af096e3104190e004fe0dc2f9b4cb29ea553e' }
  let(:id) { 'ESR_REQ_5723' }
  let(:result) { 'Passed' }

  let(:description) do
    <<~TEXT
      Makes sure that that pin 34 of the device is high whenever the watchdog
      triggers a reset and that it stays high for at least 2.34 seconds after
      the reset happens.
    TEXT
  end

  let(:data) do
    {
      'sha1' => sha1,
      'id' => id,
      'result' => result,
      'description' => description
    }
  end

  let(:transformed_data) do
    {
      sha1: sha1,
      id: id,
      result: result,
      description: description.chomp
    }
  end

  let(:source_file) { '/Workspace/project/source/module/source_file.cpp' }

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord,
      'source_file=': true,
      validate: true
    )
  end

  before do
    allow(Dragnet::TestRecord).to receive(:new).and_return(test_record)
  end

  describe '#validate' do
    subject(:method_call) { data_validator.validate }

    context 'when the data is not a hash', requirements: %w[SRS_DRAGNET_0006 SRS_DRAGNET_0007 SRS_DRAGNET_0008] do
      let(:data) { 'The quick brown fox...' }

      let(:expected_message) do
        'Incompatible data structure. Expecting a Hash, got a String'
      end

      include_examples 'Dragnet::Validators::DataValidator#validate raises a Dragnet::Errors::YAMLFormatError'
    end

    it "symbolizes the data's keys" do
      expect { method_call }.to change(data, :keys)
        .from(%w[sha1 id result description]).to(transformed_data.keys)
    end

    it 'removes newlines at the end of the strings' do
      expect { method_call }.to change { data[:description] }.to(transformed_data[:description])
    end

    it 'creates the Test Record with the expected data' do
      expect(Dragnet::TestRecord).to receive(:new).with(transformed_data)
      method_call
    end

    it 'assigns the source file to the newly created Test Record' do
      expect(test_record).to receive(:source_file=).with(source_file)
      method_call
    end

    it 'validates the newly created Test Record' do
      expect(test_record).to receive(:validate)
      method_call
    end

    context 'when the Test Record validation fails' do
      let(:expected_message) do
        'Incompatible type for key sha1: Expected String got Integer instead'
      end

      before do
        allow(test_record).to receive(:validate).and_raise(
          Dragnet::Errors::ValidationError,
          expected_message
        )
      end

      include_examples 'Dragnet::Validators::DataValidator#validate raises a Dragnet::Errors::YAMLFormatError'
    end

    it 'returns the newly created Test Record' do
      expect(method_call).to eq(test_record)
    end
  end
end
