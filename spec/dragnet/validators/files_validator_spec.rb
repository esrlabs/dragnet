# frozen_string_literal: true

require 'dragnet/validators/files_validator'

RSpec.describe Dragnet::Validators::FilesValidator do
  subject(:files_validator) { described_class.new(test_record, path) }

  let(:files) do
    %w[
      test/manual/ESR_REQ_5745.yaml
      test/manual/ESR_REQ_6845.yaml
      test/manual/security/ESR_REQ_*.yaml
    ]
  end

  let(:expected_result) do
    %w[
      /Workspace/source/test/manual/ESR_REQ_5745.yaml
      /Workspace/source/test/manual/ESR_REQ_6845.yaml
      /Workspace/source/test/manual/security/ESR_REQ_2005.yaml
      /Workspace/source/test/manual/security/ESR_REQ_1721.yaml
    ]
  end

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord,
      files: files,
      'files=': true
    )
  end

  let(:path) { Pathname.new('/Workspace/source') }

  before do
    allow(path).to receive(:glob)
      .with('test/manual/ESR_REQ_5745.yaml')
      .and_return(expected_result.slice(0, 1))

    allow(path).to receive(:glob)
      .with('test/manual/ESR_REQ_6845.yaml')
      .and_return(expected_result.slice(1, 1))

    allow(path).to receive(:glob)
      .with('test/manual/security/ESR_REQ_*.yaml')
      .and_return(expected_result.slice(2, 2))
  end

  describe '#validate' do
    subject(:method_call) { files_validator.validate }

    context 'when the files key is not present or has no value', requirements: ['DRAGNET_0004'] do
      let(:files) { nil }

      it 'does nothing' do
        expect(test_record).not_to receive(:files=)
        method_call
      end
    end

    context "when one of the given files doesn't match a file in the repository", requirements: ['DRAGNET_0005'] do
      let(:file) { 'test/manual/ESR_REQ_5745.yaml' }

      before do
        allow(path).to receive(:glob).with(file).and_return([])
      end

      it 'raises a Dragnet::Errors::FileNotFoundError' do
        expect { method_call }.to raise_error(
          Dragnet::Errors::FileNotFoundError,
          "Could not find any files matching #{file} in #{path}")
      end
    end

    context 'when a glob pattern is given', requirements: %w[DRAGNET_0013 DRAGNET_0014] do
      let(:files) { ['test/manual/security/ESR_REQ_*.yaml'] }

      let(:expected_files) do
        %w[
          /Workspace/source/test/manual/security/ESR_REQ_2005.yaml
          /Workspace/source/test/manual/security/ESR_REQ_1721.yaml
        ]
      end

      it 'returns all files matching the pattern' do
        expect(method_call).to eq(expected_files)
      end
    end

    context 'when the files have windows-style paths' do
      let(:files) do
        %w[
          test\manual\ESR_REQ_5745.yaml
          test/manual\ESR_REQ_6845.yaml
          test/manual/security/ESR_REQ_*.yaml
        ]
      end

      it 'translates the paths to linux-like paths' do
        expect(method_call).to eq(expected_result)
      end
    end

    context 'when the listed files or glob patterns have a / at the beginning',
            requirements: %w[DRAGNET_0072 DRAGNET_0073] do
      let(:files) do
        %w[
          /test/manual/safety/ESR_REQ_*.yaml
          /test/manual/external/SRS_5452.yaml
          /test/manual/external/SRS_6951.yaml
        ]
      end

      let(:expected_result) do
        %w[
          /Workspace/source/test/manual/safety/ESR_REQ_5333.yaml
          /Workspace/source/test/manual/safety/ESR_REQ_5069.yaml
          /Workspace/source/test/manual/external/SRS_5452.yaml
          /Workspace/source/test/manual/external/SRS_6951.yaml
        ]
      end

      before do
        allow(path).to receive(:glob)
          .with('test/manual/safety/ESR_REQ_*.yaml')
          .and_return(expected_result.slice(0, 2))

        allow(path).to receive(:glob)
          .with('test/manual/external/SRS_5452.yaml')
          .and_return(expected_result.slice(2, 1))

        allow(path).to receive(:glob)
          .with('test/manual/external/SRS_6951.yaml')
          .and_return(expected_result.slice(3, 1))
      end

      it 'coerces the paths into relative paths' do
        expect(method_call).to eq(expected_result)
      end
    end

    it 'resolves the files in the files key (including glob patterns)' do
      expect(test_record).to receive(:files=).with(expected_result)
      method_call
    end
  end
end
