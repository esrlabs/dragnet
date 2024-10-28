# frozen_string_literal: true

require 'dragnet/exporters/json_exporter'

RSpec.describe Dragnet::Exporters::JSONExporter, requirements: %w[DRAGNET_0060] do
  subject(:json_exporter) do
    described_class.new(test_records: test_records, errors: errors, repository: repository, logger: logger)
  end

  let(:test_records) do
    [
      instance_double(Dragnet::TestRecord),
      instance_double(Dragnet::TestRecord),
      instance_double(Dragnet::TestRecord)
    ]
  end

  let(:errors) { [] }

  let(:repository) do
    instance_double(
      Dragnet::Repository
    )
  end

  let(:logger) do
    instance_double(
      Logger,
      info: true
    )
  end

  describe '#export' do
    subject(:method_call) { json_exporter.export }

    let(:test_record_serializer) do
      instance_double(
        Dragnet::Exporters::Serializers::TestRecordSerializer
      )
    end

    let(:serialized_test_records) do
      [
        {
          refs: %w[ESR_REQ_1559],
          result: 'passed',
          sha1: 'b226f108ff1b83d911264fa224f4f56435a7742f'
        },
        {
          refs: %w[ESR_REQ_6860],
          result: 'passed',
          sha1: '889b64e1b363fd25b0e49da41c5c717c04b37f47'
        },
        {
          refs: %w[ESR_REQ_8988],
          result: 'failed',
          sha1: 'af91433d43978a356c19f3b18ffd52dbd9f5c136'
        }
      ]
    end

    let(:expected_json) do
      '[' \
        '{' \
          '"refs":["ESR_REQ_1559"],' \
          '"result":"passed",' \
          '"sha1":"b226f108ff1b83d911264fa224f4f56435a7742f",' \
          '"id":"f8f653fd1d2fc7af"'\
        '},' \
        '{' \
          '"refs":["ESR_REQ_6860"],' \
          '"result":"passed",' \
          '"sha1":"889b64e1b363fd25b0e49da41c5c717c04b37f47",' \
          '"id":"e3145e30a4468b60"' \
        '},' \
        '{' \
            '"refs":["ESR_REQ_8988"],' \
            '"result":"failed",' \
            '"sha1":"af91433d43978a356c19f3b18ffd52dbd9f5c136",' \
            '"id":"e0454575ffa3d94f"' \
        '}' \
      ']'
    end

    let(:ids) do
      %w[
        f8f653fd1d2fc7af
        e3145e30a4468b60
        e0454575ffa3d94f
      ]
    end

    let(:id_generator) do
      instance_double(
        Dragnet::Exporters::IDGenerator
      )
    end

    before do
      allow(Dragnet::Exporters::Serializers::TestRecordSerializer)
        .to receive(:new).and_return(test_record_serializer)

      allow(test_record_serializer).to receive(:serialize).and_return(*serialized_test_records)

      allow(Dragnet::Exporters::IDGenerator).to receive(:new).and_return(id_generator)
      allow(id_generator).to receive(:id_for).and_return(*ids)
    end

    it 'passes each of the given Test Records to the Serializer' do
      test_records.each do |test_record|
        expect(Dragnet::Exporters::Serializers::TestRecordSerializer)
          .to receive(:new).with(test_record, repository)
      end

      method_call
    end

    it 'creates a single instance of the IDGenerator class', requirements: %w[DRAGNET_0066] do
      expect(Dragnet::Exporters::IDGenerator).to receive(:new).with(repository).once
      method_call
    end

    it 'generates IDs for each of the Test Records', requirements: %w[DRAGNET_0066] do
      test_records.each do |test_record|
        expect(id_generator).to receive(:id_for).with(test_record)
      end

      method_call
    end

    it 'calls serialize as many times as there are Test Records' do
      expect(test_record_serializer).to receive(:serialize)
        .exactly(test_records.size).times

      method_call
    end

    it 'returns the expected JSON string' do
      expect(method_call).to eq(expected_json)
    end

    describe 'Generated JSON string' do
      subject(:generated_json) { method_call }

      context 'when parsed' do
        subject(:parsed_json) { JSON.parse(generated_json) }

        it 'produces an Array' do
          expect(parsed_json).to be_an(Array)
        end

        it 'produces an Array of Hashes', requirements: %w[DRAGNET_0061] do
          expect(parsed_json).to all(be_a(Hash))
        end

        it 'produces an array with the same number of elements as Test Records there are',
           requirements: %w[DRAGNET_0061] do
          expect(parsed_json.size).to eq(test_records.size)
        end
      end
    end
  end
end
