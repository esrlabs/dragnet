# frozen_string_literal: true

require 'dragnet/exporters/id_generator'
require 'dragnet/multi_repository'
require 'dragnet/test_record'

RSpec.describe Dragnet::Exporters::IDGenerator, requirements: %w[DRAGNET_0067] do
  subject(:id_generator) { described_class.new(repository) }

  let(:repository) do
    instance_double(
      Dragnet::MultiRepository,
      path: Pathname.new('/workspace/project')
    )
  end

  describe '#id_for' do
    subject(:method_call) { id_generator.id_for(test_record) }

    let(:test_record) do
      instance_double(
        Dragnet::TestRecord,
        source_file: Pathname.new('/workspace/project/MTR/buffer_overflow.yaml'),
        id: id
      )
    end

    context 'when the Test Record has only one ID' do
      let(:id) { 'ESR_REQ_2370' }

      it 'returns the expected string' do
        # Hashed string: "MTR/buffer_overflow.yamlESR_REQ_2370"
        expect(method_call).to eq('18572e9e32d29aae')
      end
    end

    context 'when the Test Record has multiple IDs' do
      let(:id) { %w[ESR_REQ_9788 ESR_REQ_7249] }

      it 'returns the expected string' do
        # Hashed string: "MTR/buffer_overflow.yaml[\"ESR_REQ_9788\", \"ESR_REQ_7249\"]"
        expect(method_call).to eq('0a142cfc270408a2')
      end
    end
  end
end
