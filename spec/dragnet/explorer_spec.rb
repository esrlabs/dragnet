# frozen_string_literal: true

require 'dragnet/explorer'

RSpec.describe Dragnet::Explorer do
  subject(:explorer) { described_class.new(path: path, glob_patterns: glob_patterns, logger: logger) }

  let(:path) { Pathname.new('/Workspace/source') }
  let(:glob_patterns) { 'tests/manual/*.yaml' }

  let(:logger) do
    instance_double(
      Dragnet::CLI::Logger,
      info: true
    )
  end

  describe '#initialize', requirements: %w[SRS_DRAGNET_0001 SRS_DRAGNET_0002] do
    subject(:method_call) { explorer }

    describe 'parameter checks', requirements: ['SRS_DRAGNET_0034'] do
      context 'when the path is missing' do
        let(:path) { nil }

        it 'raises an ArgumentError' do
          expect { method_call }.to raise_error(
            ArgumentError, 'Missing required parameter path'
          )
        end
      end

      context 'when the path has an invalid type' do
        let(:path) { [] }

        it 'raises an ArgumentError' do
          expect { method_call }.to raise_error(
            ArgumentError,
            'Incompatible parameter type path. Expected: Pathname, given: Array'
          )
        end
      end

      context 'when the glob_patterns are missing' do
        let(:glob_patterns) { nil }

        it 'raises an ArgumentError' do
          expect { method_call }.to raise_error(
            ArgumentError, 'Missing required parameter glob_patterns'
          )
        end
      end

      context 'when the glob patterns have an invalid type' do
        let(:glob_patterns) { {} }

        it 'raises an ArgumentError' do
          expect { method_call }.to raise_error(
            ArgumentError, 'Incompatible parameter type glob_patterns. Expected: String or Array<String>, given: Hash'
          )
        end
      end

      context 'when one of the glob patterns is not a string' do
        let(:glob_patterns) { ['requirements/*.yaml', 2] }

        it 'raises an ArgumentError' do
          expect { method_call }.to raise_error(
            ArgumentError, 'Incompatible parameter type glob_patterns. Expected: String or Array<String>, given: Array'
          )
        end
      end
    end

    context 'when glob_patterns is not an array' do
      let(:glob_patterns) { 'src/main/reqs/*.yaml' }

      it 'turns it into an array' do
        expect(explorer.glob_patterns).to eq([glob_patterns])
      end
    end
  end

  describe '#files' do
    subject(:method_call) { explorer.files }

    context 'when no files are found on the given path', requirements: ['SRS_DRAGNET_0033'] do
      before do
        allow(path).to receive(:glob).with('tests/manual/*.yaml').and_return([])
      end

      it 'raises a Dragnet::Errors::NoMTRFilesFoundError' do
        expect { method_call }.to raise_error(
          Dragnet::Errors::NoMTRFilesFoundError,
          'No MTR Files found in /Workspace/source with the following glob patterns: tests/manual/*.yaml'
        )
      end
    end

    context 'when the explorer finds files' do
      let(:files) do
        %w[
          /Workspace/source/tests/manual/ESR_9473.yaml
          /Workspace/source/tests/manual/ESR_1532.yaml
        ]
      end

      before do
        allow(path).to receive(:glob).with('tests/manual/*.yaml').and_return(files)
      end

      shared_examples_for '#files when the explorer finds files' do
        it 'logs the found MTR files', requirements: %w[SRS_DRAGNET_0032] do
          expect(logger).to receive(:info).with('Found MTR file: /Workspace/source/tests/manual/ESR_9473.yaml')
          expect(logger).to receive(:info).with('Found MTR file: /Workspace/source/tests/manual/ESR_1532.yaml')
          method_call
        end
      end

      include_examples '#files when the explorer finds files'

      it 'returns the list of found files' do
        expect(method_call).to eq(files)
      end

      context 'when two or more glob patterns are given' do
        let(:glob_patterns) { %w[tests/manual/*.yaml req/manual/*.yml] }

        let(:other_files) do
          %w[
            /Workspace/source/req/manual/ESR_6348.yml
          ]
        end

        before do
          allow(path).to receive(:glob).with('req/manual/*.yml').and_return(other_files)
        end

        it 'searches for files using both patterns' do
          expect(path).to receive(:glob).with('tests/manual/*.yaml')
          expect(path).to receive(:glob).with('req/manual/*.yml')
          method_call
        end

        it_behaves_like '#files when the explorer finds files'

        it 'logs the MTR found in the second glob pattern', requirements: %w[SRS_DRAGNET_0032] do
          expect(logger).to receive(:info).with('Found MTR file: /Workspace/source/req/manual/ESR_6348.yml')
          method_call
        end

        it 'returns the files returned from both patterns' do
          expect(method_call).to eq(files + other_files)
        end
      end
    end
  end
end
