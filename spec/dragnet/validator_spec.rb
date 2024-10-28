# frozen_string_literal: true

require 'dragnet/cli/logger'
require 'dragnet/validator'

RSpec.shared_examples 'Dragnet::Validator#validate logs the error' do
  it 'logs the error' do
    expect(logger).to receive(:error).with(
      Regexp.new(Regexp.escape(log_message))
    )

    method_call
  end
end

RSpec.shared_examples 'Dragnet::Validator#validate adds the file data to the errors array' do
  it 'adds the file data to the errors array' do
    method_call

    expect(validator.errors).to include(
      file: file, message: error_message, exception: exception
    )
  end
end

RSpec.describe Dragnet::Validator do
  subject(:validator) do
    described_class.new(files: files, path: path, logger: logger)
  end

  let(:files) do
    %w[
      /Workspace/source/test/manual/ESR_REQ_6897.yaml
      /Workspace/source/test/manual/ESR_REQ_9813.yaml
      /Workspace/source/test/manual/ESR_REQ_1175.yaml
    ]
  end

  let(:path) { '/Workspace/source' }

  let(:logger) do
    instance_double(
      Dragnet::CLI::Logger,
      info: true,
      error: true
    )
  end

  let(:yaml) do
    <<~YAML
      id: ESR_REQ_6897
      result: passed
    YAML
  end

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord
    )
  end

  let(:data_validator) do
    instance_double(
      Dragnet::Validators::DataValidator,
      validate: test_record
    )
  end

  let(:files_validator) do
    instance_double(
      Dragnet::Validators::FilesValidator,
      validate: true
    )
  end

  let(:repos_validator) do
    instance_double(
      Dragnet::Validators::ReposValidator,
      validate: true
    )
  end

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(%r{test/manual/}).and_return(yaml)
    allow(YAML).to receive(:safe_load).and_call_original

    allow(Dragnet::Validators::DataValidator).to receive(:new).and_return(data_validator)
    allow(Dragnet::Validators::FilesValidator).to receive(:new).and_return(files_validator)
    allow(Dragnet::Validators::ReposValidator).to receive(:new).and_return(repos_validator)
  end

  describe '#validate' do
    subject(:method_call) { validator.validate }

    context 'when no files are given' do
      let(:files) { [] }

      it 'returns an empty array' do
        expect(method_call).to eq([])
      end
    end

    it 'Logs the files as they are checked', requirements: %w[DRAGNET_0027] do
      files.each do |file|
        expect(logger).to receive(:info).with("Validating #{file}...")
      end

      method_call
    end

    context 'when one of the given files cannot be read' do
      let(:file) { '/Workspace/source/test/manual/ESR_REQ_6897.yaml' }

      let(:message) { 'Access denied' }
      let(:exception) { Errno::EACCES.new(message) }
      let(:error_message) { 'IO Error: Cannot read the specified file' }
      let(:log_message) { "#{file} Failed: #{error_message} - Permission denied - #{message}" }

      before do
        allow(File).to receive(:read)
          .with(file).and_raise(exception)
      end

      include_examples 'Dragnet::Validator#validate logs the error'
      include_examples 'Dragnet::Validator#validate adds the file data to the errors array'
    end

    context 'when one of the files is not a valid YAML file', requirements: ['DRAGNET_0003'] do
      let(:file) { '/Workspace/source/test/manual/ESR_REQ_9813.yaml' }

      let(:malformed_yaml) do
        <<~YAML
          id: ESR_REQ_9813
            files:
              - main/module1/entry.cpp
        YAML
      end

      let(:line) { 2 }
      let(:column) { 8 }
      let(:problem) { 'mapping values are not allowed in this context' }

      let(:exception) do
        Psych::SyntaxError.new(file, line, column, nil, problem, nil)
      end

      let(:exception_message) { "(#{file}): #{problem} at line #{line} column #{column}" }
      let(:error_message) { 'YAML Parsing Error' }

      let(:log_message) do
        "#{file} Failed: #{error_message} - #{exception_message}"
      end

      before do
        allow(File).to receive(:read).with(file).and_return(malformed_yaml)
        allow(YAML).to receive(:safe_load).with(malformed_yaml).and_raise(exception)
      end

      include_examples 'Dragnet::Validator#validate logs the error'
      include_examples 'Dragnet::Validator#validate adds the file data to the errors array'
    end

    context 'when there is a format error' do
      let(:file) { '/Workspace/source/test/manual/ESR_REQ_1175.yaml' }

      let(:other_yaml) do
        <<~YAML
          id: ESR_REQ_1175
          result: passed
          sha1: -1
        YAML
      end

      let(:exception_message) { 'Invalid value for key sha1' }
      let(:exception) { Dragnet::Errors::YAMLFormatError.new(exception_message) }
      let(:error_message) { 'YAML Formatting Error' }
      let(:log_message) { "#{file} Failed: #{error_message} - #{exception_message}" }

      let(:data) do
        {
          id: 'ESR_REQ_1175',
          result: 'passed',
          sha1: -1
        }
      end

      before do
        allow(File).to receive(:read).with(file).and_return(other_yaml)
        allow(YAML).to receive(:safe_load).with(other_yaml).and_return(data)
        allow(data_validator).to receive(:validate).and_raise(exception)
      end

      include_examples 'Dragnet::Validator#validate logs the error'
      include_examples 'Dragnet::Validator#validate adds the file data to the errors array'
    end

    context 'when one of the referenced files is not found' do
      let(:file) { '/Workspace/source/test/manual/ESR_REQ_6897.yaml' }

      let(:other_yaml) do
        <<~YAML
          id: ESR_REQ_6897
          result: passed
          sha1: 364c2cea75d9328a446a515814c36464d8f62052
          files:
            - main/module1/security.cpp
            - main/module1/assertions.cpp
        YAML
      end

      let(:exception_message) do
        'Could not find any files matching main/module1/assertions.cpp in /Workspace/source'
      end

      let(:exception) { Dragnet::Errors::FileNotFoundError.new(exception_message) }
      let(:error_message) { 'Referenced file not found in repository' }
      let(:log_message) { "#{file} Failed: #{error_message} - #{exception_message}" }

      let(:data) do
        {
          id: 'ESR_REQ_6897',
          result: 'passed',
          sha1: '364c2cea75d9328a446a515814c36464d8f62052',
          files: %w[
            main/module1/security.cpp
            main/module1/assertions.c
          ]
        }
      end

      before do
        allow(File).to receive(:read).with(file).and_return(other_yaml)
        allow(YAML).to receive(:safe_load).with(other_yaml).and_return(data)
        allow(files_validator).to receive(:validate).and_raise(exception)
      end

      include_examples 'Dragnet::Validator#validate logs the error'
      include_examples 'Dragnet::Validator#validate adds the file data to the errors array'
    end

    context 'when one of the MTRs has repos' do
      let(:file) { '/Workspace/source/test/manual/ESR_REQ_1175.yaml' }

      let(:other_yaml) do
        <<~YAML
          id: ESR_REQ_1175
          result: passed
          repos:
            -
              sha1: eb8b4f9cd67c90b527962a51a488c0f80f9ea599
              path: path/to/the/repo
              files:
                - lib/security/crypto/rsa*.cpp
                - lib/security/crypto/rsa*.h
        YAML
      end

      let(:data) do
        {
          id: 'ESR_REQ_1175',
          result: 'passed',
          repos: [
            {
              sha1: 'eb8b4f9cd67c90b527962a51a488c0f80f9ea599',
              path: 'path/to/the/repo',
              files: %w[
                lib/security/crypto/rsa*.cpp
                lib/security/crypto/rsa*.h
              ]
            }
          ]
        }
      end

      before do
        allow(File).to receive(:read).with(file).and_return(other_yaml)
        allow(YAML).to receive(:safe_load).with(other_yaml).and_return(data)
      end

      it 'creates an instance of the ReposValidator' do
        expect(Dragnet::Validators::ReposValidator).to receive(:new).with(test_record, path)
        method_call
      end

      it 'calls validate on the ReposValidator' do
        expect(repos_validator).to receive(:validate)
        method_call
      end

      it 'does not raise any errors' do
        expect { method_call }.not_to raise_error
      end

      context "when one of the Repos' path doesn't exist", requirements: %w[DRAGNET_0058] do
        let(:exception_message) do
          'Cannot find the repository path path/to/the/repo inside /Workspace/source'
        end

        let(:exception) { Dragnet::Errors::RepoPathNotFoundError.new(exception_message) }
        let(:error_message) { 'Referenced repository not found' }
        let(:log_message) { "#{file} Failed: #{error_message} - #{exception_message}" }

        before do
          allow(repos_validator).to receive(:validate).and_raise(exception)
        end

        it 'does not raise any errors' do
          expect { method_call }.not_to raise_error
        end

        include_examples 'Dragnet::Validator#validate logs the error'
        include_examples 'Dragnet::Validator#validate adds the file data to the errors array'
      end

      context "when one or more of the files listed in the Repo doesn't exist",
              requirements: %w[DRAGNET_0047 DRAGNET_0048] do

        let(:exception_message) do
          'Could not find any files matching lib/security/crypto/rsa*.h in path/to/the/repo'
        end

        let(:exception) { Dragnet::Errors::FileNotFoundError.new(exception_message) }
        let(:error_message) { 'Referenced file not found in repository' }
        let(:log_message) { "#{file} Failed: #{error_message} - #{exception_message}" }

        before do
          allow(repos_validator).to receive(:validate).and_raise(exception)
        end

        it 'does not raise any errors' do
          expect { method_call }.not_to raise_error
        end

        include_examples 'Dragnet::Validator#validate logs the error'
        include_examples 'Dragnet::Validator#validate adds the file data to the errors array'
      end
    end
  end
end
