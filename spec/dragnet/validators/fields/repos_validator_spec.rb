# frozen_string_literal: true

require 'dragnet/validators/fields/repos_validator'

require_relative 'field_validator_shared'

RSpec.describe Dragnet::Validators::Fields::ReposValidator do
  subject(:repos_validator) { described_class.new }

  describe '#validate' do
    subject(:method_call) { repos_validator.validate(key, value) }

    let(:key) { 'repos' }
    let(:value) { nil }

    let(:repo) do
      instance_double(Dragnet::Repo, validate: true)
    end

    before { allow(Dragnet::Repo).to receive(:new).and_return(repo) }

    context 'when the value is nil' do
      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context 'when the value is neither a hash nor an array' do
      let(:value) { 'esrlabs/bsw/crypto' }

      let(:expected_message) do
        'Incompatible type for key repos: Expected Hash, Array got String instead'
      end

      it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
    end

    shared_examples_for '#validate with an Array of Hashes' do
      it 'creates a Repo object for each of the Hashes' do
        hashes.each { |hash| expect(Dragnet::Repo).to receive(:new).with(**hash) }
        method_call
      end

      it 'returns an array' do
        expect(method_call).to be_an(Array)
      end

      it 'returns an array of Repo objects' do
        expect(method_call).to all(eq(repo))
      end

      it 'calls validate on each of the Repo objects' do
        expect(repo).to receive(:validate).exactly(hashes.length).times
        method_call
      end
    end

    context 'when the value is an Array', requirements: ['DRAGNET_0037'] do
      context 'when the array is empty' do
        let(:value) { [] }

        it 'returns nil' do
          expect(method_call).to be_nil
        end
      end

      context 'when the array contains something that is not a Hash' do
        let(:value) { [{ some: 'repo' }, { another: 'repo' }, 'bsw/central/tools'] }

        let(:expected_message) do
          'Incompatible type for key repos: Expected a Array<Hash>. Found a(n) String inside the array'
        end

        it_behaves_like 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails'
      end

      context 'when the array contains only hashes' do
        let(:value) { [{ a: 'repo' }, { example_of: 'a repo' }] }
        let(:hashes) { value }

        it_behaves_like '#validate with an Array of Hashes'
      end
    end

    context 'when the value is a Hash' do
      let(:value) do
        {
          path: 'bsw/central/tools/pit_generator',
          sha1: 'c6bb9fe3bd918094a24593fae480cdfa9fde28b3',
          files: 'deconfabulator.c'
        }
      end

      let(:hashes) { [value] }

      it_behaves_like '#validate with an Array of Hashes'
    end
  end
end
