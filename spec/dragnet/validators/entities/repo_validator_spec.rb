# frozen_string_literal: true

require 'dragnet/validators/entities/repo_validator'
require 'dragnet/repo'

RSpec.describe Dragnet::Validators::Entities::RepoValidator do
  subject(:repo_validator) { described_class.new(repo) }

  let(:sha1) { 'de97dcc0dbd57bed7e4a6565ed854197c406a343' }
  let(:path) { 'esrlabs/bsw/crypto' }
  let(:files) { nil }

  let(:repo) do
    instance_double(
      Dragnet::Repo,
      files: files,
      'files=': true,
      path: path,
      sha1: sha1
    )
  end

  describe '#validate' do
    subject(:method_call) { repo_validator.validate }

    let(:sha1_validator) do
      instance_double(Dragnet::Validators::Fields::SHA1Validator, validate: true)
    end

    let(:path_validator) do
      instance_double(Dragnet::Validators::Fields::PathValidator, validate: true)
    end

    let(:processed_files) { nil }

    let(:files_validator) do
      instance_double(Dragnet::Validators::Fields::FilesValidator, validate: processed_files)
    end

    before do
      allow(Dragnet::Validators::Fields::SHA1Validator)
        .to receive(:new).and_return(sha1_validator)

      allow(Dragnet::Validators::Fields::PathValidator)
        .to receive(:new).and_return(path_validator)

      allow(Dragnet::Validators::Fields::FilesValidator)
        .to receive(:new).and_return(files_validator)
    end

    shared_context 'when an individual validator fails' do
      before do
        allow(validator).to receive(:validate).and_raise(
          validation_error, message
        )
      end

      it 'raises the expected error' do
        expect { method_call }.to raise_error(validation_error, message)
      end
    end

    it 'uses the SHA1Validator class to validate the `sha1` attribute', requirements: ['DRAGNET_0043'] do
      expect(sha1_validator).to receive(:validate).with('repos[sha1]', sha1)
      method_call
    end

    context 'when the SHA1Validator fails', requirements: ['DRAGNET_0046'] do
      let(:validator) { sha1_validator }
      let(:validation_error) { Dragnet::Errors::ValidationError }
      let(:message) { 'Missing required key: repos[sha1]' }

      include_context 'when an individual validator fails'
    end

    it 'uses the PathValidator class to validate the `path` attribute', requirements: ['DRAGNET_0039'] do
      expect(path_validator).to receive(:validate).with('repos[path]', path)
      method_call
    end

    context 'when the PathValidator fails', requirements: ['DRAGNET_0042'] do
      let(:validator) { path_validator }
      let(:validation_error) { Dragnet::Errors::ValidationError }

      let(:message) do
        'Incompatible type for key repos[path]: Expected String got Float instead'
      end

      include_context 'when an individual validator fails'
    end

    context 'when the Repo has files', requirements: ['DRAGNET_0041'] do
      let(:files) { 'utils/b2f/password.c' }
      let(:processed_files) { ['utils/b2f/password.c'] }

      it 'uses the FilesValidator class to validate the `files` attribute' do
        expect(files_validator).to receive(:validate).with('repos[files]', files)
        method_call
      end

      context 'when the FilesValidator fails' do
        let(:validator) { files_validator }
        let(:validation_error) { Dragnet::Errors::ValidationError }

        let(:message) do
          'Incompatible type for key repos[files]: Expected a Array<String>. '\
          'Found a(n) Hash inside the array'
        end

        include_context 'when an individual validator fails'
      end

      it 'overwrites the `files` attribute with the files array returned by the validator' do
        expect(repo).to receive(:'files=').with(processed_files)
        method_call
      end
    end
  end
end
