# frozen_string_literal: true

require 'dragnet/validators/entities/test_record_validator'

RSpec.describe Dragnet::Validators::Entities::TestRecordValidator do
  subject(:test_record_validator) do
    described_class.new(test_record)
  end

  let(:sha1) { '6c25d4c4e0183136b558ce8cbc67b0f9463c3ad1' }
  let(:id) { 'ESR_REQ_5435' }
  let(:description) { 'Check the functionality of the SafeIO feature' }
  let(:name) { nil }
  let(:test_method) { nil }
  let(:tc_derivation_method) { nil }
  let(:result) { 'passed' }
  let(:files) { 'source/tests/manual/safeio.yaml' }
  let(:repos) { nil }

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord,
      sha1: sha1,
      id: id,
      description: description,
      name: name,
      'name=': true,
      test_method: test_method,
      'test_method=': true,
      tc_derivation_method: tc_derivation_method,
      'tc_derivation_method=': true,
      result: result,
      files: files,
      'files=': true,
      repos: repos,
      'repos=': true,
      'result=': true
    )
  end

  describe '#validate' do
    subject(:method_call) { test_record_validator.validate }

    let(:sha1_validator) do
      instance_double(
        Dragnet::Validators::Fields::SHA1Validator,
        validate: true
      )
    end

    let(:id_validator) do
      instance_double(
        Dragnet::Validators::Fields::IDValidator,
        validate: true
      )
    end

    let(:validated_files) { ['source/tests/manual/safeio.yaml'] }

    let(:files_validator) do
      instance_double(
        Dragnet::Validators::Fields::FilesValidator,
        validate: validated_files
      )
    end

    let(:validated_repos) { nil }

    let(:repos_validator) do
      instance_double(
        Dragnet::Validators::Fields::ReposValidator,
        validate: validated_repos
      )
    end

    let(:validated_result) { 'failed' }

    let(:result_validator) do
      instance_double(
        Dragnet::Validators::Fields::ResultValidator,
        validate: validated_result
      )
    end

    let(:description_validator) do
      instance_double(
        Dragnet::Validators::Fields::DescriptionValidator,
        validate: true
      )
    end

    let(:meta_data_field_validator) do
      instance_double(
        Dragnet::Validators::Fields::MetaDataFieldValidator,
        validate: true
      )
    end

    before do
      allow(Dragnet::Validators::Fields::SHA1Validator).to receive(:new).and_return(sha1_validator)
      allow(Dragnet::Validators::Fields::IDValidator).to receive(:new).and_return(id_validator)
      allow(Dragnet::Validators::Fields::FilesValidator).to receive(:new).and_return(files_validator)
      allow(Dragnet::Validators::Fields::ReposValidator).to receive(:new).and_return(repos_validator)
      allow(Dragnet::Validators::Fields::ResultValidator).to receive(:new).and_return(result_validator)
      allow(Dragnet::Validators::Fields::DescriptionValidator).to receive(:new).and_return(description_validator)
      allow(Dragnet::Validators::Fields::MetaDataFieldValidator).to receive(:new).and_return(meta_data_field_validator)
    end

    shared_context 'when an individual validator fails' do
      before do
        allow(validator).to receive(:validate).and_raise(exception, message)
      end

      it 'Raises the validation error' do
        expect { method_call }.to raise_error(exception, message)
      end
    end

    context 'when the MTR has neither a `files` nor a `repos` attribute' do
      let(:files) { nil }

      it 'passes the validation', requirements: %w[DRAGNET_0055 DRAGNET_0056] do
        expect { method_call }.not_to raise_error
      end
    end

    context 'when the MTR has a `files` attribute but no `repos` attribute' do
      it 'passes the validation', requirements: %w[DRAGNET_0004] do
        expect { method_call }.not_to raise_error
      end
    end

    context 'when the MTR has a `repos` attribute but no `files` attribute' do
      it 'passes the validation', requirements: %w[DRAGNET_0035] do
        expect { method_call }.not_to raise_error
      end
    end

    context 'when the MTR has a `files` and a `repos` attribute' do
      let(:repos) do
        [
          { some: 'repo' },
          { another: 'repo' }
        ]
      end

      it 'fails the validation', requirements: %w[DRAGNET_0036] do
        expect { method_call }.to raise_error(
          Dragnet::Errors::ValidationError,
          "Invalid MTR: ESR_REQ_5435. Either 'files' or 'repos' should be provided, not both"
        )
      end
    end

    context 'when the MTR has a SHA1 but not a list of repositories' do
      it 'uses the SHA1 Validator to validate', requirements: ['DRAGNET_0006'] do
        expect(sha1_validator).to receive(:validate).with('sha1', sha1)
        method_call
      end

      context 'when the SHA1 validation fails', requirements: ['DRAGNET_0006'] do
        let(:exception) { Dragnet::Errors::ValidationError }
        let(:message) { 'missing key sha1' }
        let(:validator) { sha1_validator }

        include_context 'when an individual validator fails'
      end
    end

    context 'when the Description validation fails' do
      let(:exception) { Dragnet::Errors::ValidationError }
      let(:message) { 'Incompatible type for key description: Expected String got Array instead' }
      let(:validator) { description_validator }

      include_context 'when an individual validator fails'
    end

    context 'when the MTR has both a SHA1 and a list of repositories' do
      let(:files) { nil }
      let(:repos) { [{ a: 'repo' }, { b: 'repo' }, { c: 'repo' }] }

      it 'raises a Dragnet::Errors::ValidationError', requirements: %w[DRAGNET_0057] do
        expect { method_call }.to raise_error(
          Dragnet::Errors::ValidationError,
          "Invalid MTR: ESR_REQ_5435. Either 'repos' or 'sha1' should be provided, not both"
        )
      end
    end

    it 'uses the ID Validator to validate' do
      expect(id_validator).to receive(:validate).with('id', id)
      method_call
    end

    it 'uses the Description Validator to validate' do
      expect(description_validator).to receive(:validate).with('description', description)
      method_call
    end

    context 'when the ID validation fails' do
      let(:exception) { Dragnet::Errors::ValidationError }
      let(:message) { 'missing key id' }
      let(:validator) { id_validator }

      include_context 'when an individual validator fails'
    end

    it 'uses the Files Validator to validate' do
      expect(files_validator).to receive(:validate).with('files', files)
      method_call
    end

    it "updates the files field with the Files Validator's return value" do
      expect(test_record).to receive(:files=).with(validated_files)
      method_call
    end

    context 'when the Files validation fails' do
      let(:exception) { Dragnet::Errors::ValidationError }
      let(:message) { 'unsupported type Integer' }
      let(:validator) { files_validator }

      include_context 'when an individual validator fails'
    end

    context 'when the MTR has a list of repositories' do
      let(:files) { nil } # Cannot have files and repos at the same time
      let(:sha1) { nil } # Cannot have repos and sha1 at the same time

      let(:repos) do
        [
          { path: 'esrlabs/crypto', sha1: '19544d4ecd6f577c0742a01f71e139ab75935ea9', files: 'utilities/b2f/*.cpp' },
          { path: 'esrlabs/bsw/safeRng', sha1: '75430dc90b1e82ef8a688c7bf036eb48f6941b8a', files: '**/**/*.cpp'}
        ]
      end

      let(:validated_repos) do
        [instance_double(Dragnet::Repo), instance_double(Dragnet::Repo)]
      end

      it 'does not validate the SHA1 attribute', requirements: ['DRAGNET_0057'] do
        expect(Dragnet::Validators::Fields::SHA1Validator).not_to receive(:new)
        expect(sha1_validator).not_to receive(:validate)
        method_call
      end

      it 'uses the ReposValidator to validate the repos', requirements: ['DRAGNET_0037'] do
        expect(repos_validator).to receive(:validate).with('repos', repos)
        method_call
      end

      context 'when the ReposValidator validation fails' do
        let(:validator) { repos_validator }
        let(:exception) { Dragnet::Errors::ValidationError }

        let(:message) do
          'Incompatible type for key repos: Expected Array, Hash got String instead'
        end

        include_context 'when an individual validator fails'
      end

      it 'overwrites the `repos` attribute with the array of repos returned by the validator' do
        expect(test_record).to receive(:'repos=').with(validated_repos)
        method_call
      end
    end

    it 'uses the Result Validator to validate' do
      expect(result_validator).to receive(:validate).with('result', result)
      method_call
    end

    it "updates the result field with the Result Validator's return value" do
      expect(test_record).to receive(:result=).with(validated_result)
      method_call
    end

    context 'when the Result validation fails' do
      let(:exception) { Dragnet::Errors::ValidationError }
      let(:message) { 'unknown result missed' }
      let(:validator) { result_validator }

      include_context 'when an individual validator fails'
    end

    describe 'meta-data validation', requirements: %w[DRAGNET_0068] do
      let(:name) { 'Bruce Willis' }
      let(:test_method) { 'Nuclear explosion' }
      let(:tc_derivation_method) { 'BVA' }

      before do
        allow(meta_data_field_validator).to receive(:validate)
          .with('name', 'Bruce Willis').and_return(['Bruce Willis'])

        allow(meta_data_field_validator).to receive(:validate)
          .with('test_method', 'Nuclear explosion').and_return(['Nuclear explosion'])

        allow(meta_data_field_validator).to receive(:validate)
          .with('tc_derivation_method', 'BVA').and_return(['BVA'])
      end

      it "validates the 'name' attribute" do
        expect(meta_data_field_validator).to receive(:validate).with('name', 'Bruce Willis')
        method_call
      end

      it "assigns the value returned by the validator to the 'name' attribute" do
        expect(test_record).to receive(:name=).with(['Bruce Willis'])
        method_call
      end

      it "validates the 'test_method' attribute" do
        expect(meta_data_field_validator).to receive(:validate).with('test_method', 'Nuclear explosion')
        method_call
      end

      it "assigns the value returned by the validator to the 'test_method' attribute" do
        expect(test_record).to receive(:test_method=).with(['Nuclear explosion'])
        method_call
      end

      it "validates the 'tc_derivation_method' attribute" do
        expect(meta_data_field_validator).to receive(:validate).with('tc_derivation_method', 'BVA')
        method_call
      end

      it "assigns the value returned by the validator to the 'tc_derivation_method' attribute" do
        expect(test_record).to receive(:tc_derivation_method=).with(['BVA'])
        method_call
      end

      context 'when the meta-data validation fails' do
        let(:test_method) { 1994 }

        let(:expected_error) do
          [
            Dragnet::Errors::ValidationError,
            'Incompatible type for key test_method: Expected a String, Array got Integer instead'
          ]
        end

        before do
          allow(meta_data_field_validator).to receive(:validate).and_raise(*expected_error)
        end

        it 'raises the validation error' do
          expect { method_call }.to raise_error(*expected_error)
        end
      end
    end
  end
end
