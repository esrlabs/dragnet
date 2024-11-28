# frozen_string_literal: true

require 'dragnet/repo'

RSpec.describe Dragnet::Repo do
  subject(:repo) { described_class.new(**params) }

  let(:path) { 'esrlabs/bsw/crypto' }
  let(:sha1) { 'a7e08c441d61cec17a007c25712b86f5b0db56bc' }
  let(:files) { %w[utils/bam2f_keys.cpp utils/blowfish_algo.cpp utils/headers/blowfish.h] }

  let(:params) { { path: path, sha1: sha1, files: files } }

  describe '#initialize' do
    context 'without files' do
      let(:params) { { path: path, sha1: sha1 } }

      it 'does not raise any errors', requirements: ['SRS_DRAGNET_0049'] do
        expect { repo }.not_to raise_error
      end
    end

    context 'when files is nil' do
      let(:files) { nil }

      it 'does not rise any errors', requirements: ['SRS_DRAGNET_0049'] do
        expect { repo }.not_to raise_error
      end
    end
  end

  describe '#validate' do
    subject(:method_call) { repo.validate }

    let(:repo_validator) do
      instance_double(
        Dragnet::Validators::Entities::RepoValidator,
        validate: nil
      )
    end

    before do
      allow(Dragnet::Validators::Entities::RepoValidator)
        .to receive(:new).and_return(repo_validator)
    end

    context 'when the validation passes' do
      it 'does not raise any errors' do
        expect { method_call }.not_to raise_error
      end
    end

    context 'when the validation fails' do
      let(:validation_error) do
        [
          Dragnet::Errors::ValidationError,
          'Validation has failed'
        ]
      end

      before do
        allow(repo_validator).to receive(:validate).and_raise(*validation_error)
      end

      it 'raises a Dragnet::Errors::ValidationError' do
        expect { method_call }.to raise_error(*validation_error)
      end
    end
  end
end
