# frozen_string_literal: true

require 'dragnet/cli/master'
require 'shared/cli_master'

RSpec.shared_context 'when Dragnet::Validator detects error in the MTR files' do
  let(:errors) do
    [
      {
        file: 'test/manual/ESR_REQ_1030.yaml',
        message: "Missing required key 'sha1'"
      }
    ]
  end
end

RSpec.shared_context 'when Dragnet::Verifier finds a failed MTR' do
  let(:test_records) do
    [
      instance_double(
        Dragnet::TestRecord,
        source_file: 'test/manual/ESR_REQ_5138.yaml',
        result: 'passed',
        verification_result: instance_double(
          Dragnet::VerificationResult,
          status: :passed,
          passed?: true
        )
      ),
      instance_double(
        Dragnet::TestRecord,
        source_file: 'test/manual/ESR_REQ_4570.yaml',
        result: 'passed',
        verification_result: instance_double(
          Dragnet::VerificationResult,
          status: :skipped,
          reason: 'Changes detected in the repository',
          passed?: false
        )
      )
    ]
  end
end

RSpec.shared_examples 'a fatal error is raised inside Dragnet::CLI::Master#check' do
  it 'prints the expected error to the console' do
    message = Regexp.escape("#{expected_message_header}\n       #{expected_message}")
    expect { method_call }.to raise_error(SystemExit)
      .and output(Regexp.new(message)).to_stdout
  end

  it 'exists with the expected error code' do
    expect { method_call }.to output.to_stdout.and(
      raise_error { |error| expect(error.status).to eq(expected_exit_code) }
    )
  end
end

RSpec.describe Dragnet::CLI::Master do
  subject(:master) { described_class.new }

  describe '#version', requirements: %w[DRAGNET_0017 DRAGNET_0026] do
    subject(:method_call) { master.version }

    include_context "with the default CLI's --version output"

    it 'prints the current version of the Gem' do
      expect { method_call }.to output(expected_output).to_stdout
    end

    context 'when the quit options is given' do
      before do
        master.options = { quiet: true }
      end

      it "doesn't print anything to the output" do
        expect { method_call }.not_to output.to_stdout
      end
    end
  end

  describe '#check', requirements: ['DRAGNET_0018'] do
    subject(:method_call) { master.check(path) }

    let(:path) { nil }

    let(:files) do
      %w[
        test/manual/ESR_REQ_5138.yaml
        test/manual/ESR_REQ_1030.yaml
        test/manual/ESR_REQ_4570.yaml
      ]
    end

    let(:explorer) do
      instance_double(
        Dragnet::Explorer,
        files: files
      )
    end

    let(:test_records) { [] }
    let(:errors) { [] }

    let(:repository) do
      instance_double(
        Dragnet::Repository
      )
    end

    let(:multi_repository) do
      instance_double(
        Dragnet::MultiRepository
      )
    end

    let(:validator) do
      instance_double(
        Dragnet::Validator,
        validate: test_records,
        errors: errors
      )
    end

    let(:verifier) do
      instance_double(
        Dragnet::Verifier,
        verify: true
      )
    end

    let(:config_yaml) do
      <<~YAML
        glob_patterns:
          - tests/manual/*.yaml
      YAML
    end

    let(:logger) do
      instance_double(
        Dragnet::CLI::Logger,
        info: true
      )
    end

    before do
      allow(File).to receive(:read).with('.dragnet.yaml').and_return(config_yaml)
      allow(Dragnet::CLI::Logger).to receive(:new).and_return(logger)
      allow(Dragnet::Explorer).to receive(:new).and_return(explorer)
      allow(Dragnet::Validator).to receive(:new).and_return(validator)
      allow(Dragnet::Verifier).to receive(:new).and_return(verifier)
      allow(Dragnet::Repository).to receive(:new).and_return(repository)
      allow(Dragnet::MultiRepository).to receive(:new).and_return(multi_repository)
    end

    context 'when no configuration file is specified' do
      it 'loads the default configuration file', requirements: ['DRAGNET_0019'] do
        expect(File).to receive(:read).with('.dragnet.yaml')
        method_call
      end
    end

    context 'when a configuration file is specified', requirements: ['DRAGNET_0020'] do
      before do
        master.options = { configuration: 'my_config.yaml' }
        allow(File).to receive(:read).with('my_config.yaml').and_return(config_yaml)
      end

      it 'loads the specified configuration file' do
        expect(File).to receive(:read).with('my_config.yaml')
        method_call
      end
    end

    context 'when the specified configuration file cannot be loaded', requirements: ['DRAGNET_0034'] do
      before do
        allow(File).to receive(:read).with('.dragnet.yaml').and_raise(
          Errno::ENOENT, 'File not found .dragnet.yaml'
        )
      end

      it 'prints the expected error to the console' do
        expect { method_call }.to raise_error(SystemExit).and output(
          /Error: .*Unable to load the given configuration file: '\.dragnet\.yaml'/
        ).to_stdout
      end

      it 'prints the exception message to the console' do
        expect { method_call }.to raise_error(SystemExit).and output(
          /File not found \.dragnet\.yaml/
        ).to_stdout
      end

      it 'exists with the expected error code' do
        expect { method_call }.to output.to_stdout.and(
          raise_error { |error| expect(error.status).to eq(described_class::E_CONFIG_LOAD_ERROR) }
        )
      end
    end

    context 'when no path is specified', requirements: %w[DRAGNET_0001 DRAGNET_0002] do
      context 'when none is configured in the configuration file' do
        let(:pwd) { Pathname.pwd }

        it 'uses the current working directory as path for the Explorer' do
          expect(Dragnet::Explorer).to receive(:new)
            .with(path: pwd, glob_patterns: ['tests/manual/*.yaml'], logger: logger)

          method_call
        end

        it 'uses the current working directory as path for the Validator' do
          expect(Dragnet::Validator).to receive(:new)
            .with(files: files, path: pwd, logger: logger)

          method_call
        end

        shared_examples 'creates a repository and a verifier' do
          it 'creates a repository pointing to the current working directory' do
            expect(repository_class).to receive(:new).with(path: pwd)
            method_call
          end

          it 'passes down the created repository object to the Verifier' do
            expect(Dragnet::Verifier).to receive(:new)
              .with(test_records: test_records, repository: repository_instance, logger: logger)

            method_call
          end
        end

        context 'when multi-repo compatibility is disabled' do
          let(:repository_class) { Dragnet::Repository }
          let(:repository_instance) { repository }

          include_examples 'creates a repository and a verifier'
        end

        context 'when multi-repo compatibility is enabled' do
          let(:repository_class) { Dragnet::MultiRepository }
          let(:repository_instance) { multi_repository }

          before { master.options = master.options.merge('multi-repo': true) }

          include_examples 'creates a repository and a verifier'
        end
      end

      context 'when the configuration file contains a path' do
        let(:config_yaml) do
          <<~YAML
            path: /Workspace/source
            glob_patterns:
              - tests/manual/*.yaml
          YAML
        end

        let(:expected_path) { Pathname.new('/Workspace/source') }

        it 'uses the path from the configuration file for the Explorer' do
          expect(Dragnet::Explorer).to receive(:new)
            .with(path: expected_path, glob_patterns: ['tests/manual/*.yaml'], logger: logger)

          method_call
        end

        it 'uses the path from the configuration file for the Validator' do
          expect(Dragnet::Validator).to receive(:new)
            .with(files: files, path: expected_path, logger: logger)

          method_call
        end

        shared_examples 'creates a repository and a verifier' do
          it 'creates a repository using the path from the configuration file' do
            expect(repository_class).to receive(:new).with(path: expected_path)
            method_call
          end

          it 'passes down the created repository to the Verifier' do
            expect(Dragnet::Verifier).to receive(:new)
              .with(test_records: test_records, repository: repository_instance, logger: logger)

            method_call
          end
        end

        context 'when multi-repo compatibility is disabled' do
          let(:repository_class) { Dragnet::Repository }
          let(:repository_instance) { repository }

          include_examples 'creates a repository and a verifier'
        end

        context 'when multi-repo compatibility is enabled' do
          let(:repository_class) { Dragnet::MultiRepository }
          let(:repository_instance) { multi_repository }

          before { master.options = master.options.merge('multi-repo': true) }

          include_examples 'creates a repository and a verifier'
        end
      end
    end

    context 'when a path is specified', requirements: %w[DRAGNET_0001 DRAGNET_0002] do
      let(:path) { '/tmp/repository' }
      let(:pathname) { Pathname.new('/tmp/repository') }

      it 'uses a Pathname created from the specified path for the Explorer' do
        expect(Dragnet::Explorer).to receive(:new)
          .with(path: pathname, glob_patterns: ['tests/manual/*.yaml'], logger: logger)

        method_call
      end

      it 'uses a Pathname created from the specified path for the Validator' do
        expect(Dragnet::Validator).to receive(:new)
          .with(files: files, path: pathname, logger: logger)

        method_call
      end

      shared_examples 'creates a Repository and a Verifier' do
        it 'creates a Repository object using a Pathname created with the given path' do
          expect(repository_class).to receive(:new).with(path: pathname)
          method_call
        end

        it 'passed down the created repository object to the Verifier' do
          expect(Dragnet::Verifier).to receive(:new)
            .with(test_records: test_records, repository: repository_instance, logger: logger)

          method_call
        end
      end

      context 'when multi-repo compatibility is disabled' do
        let(:repository_class) { Dragnet::Repository }
        let(:repository_instance) { repository }

        include_examples 'creates a Repository and a Verifier'
      end

      context 'when multi-repo compatibility is enabled' do
        let(:repository_class) { Dragnet::MultiRepository }
        let(:repository_instance) { multi_repository }

        before { master.options = master.options.merge('multi-repo': true) }

        include_examples 'creates a Repository and a Verifier'
      end
    end

    it 'creates an instance of the Explorer class' do
      expect(Dragnet::Explorer).to receive(:new)
      method_call
    end

    it 'uses the instance of the Explorer class to get the list of MTR files' do
      expect(explorer).to receive(:files)
      method_call
    end

    context 'when the Explorer class raises an ArgumentError', requirements: ['DRAGNET_0034'] do
      before do
        allow(Dragnet::Explorer).to receive(:new).and_raise(
          ArgumentError, 'Missing required parameter glob_patterns'
        )
      end

      it 'prints the expected error to the console' do
        expect { method_call }.to raise_error(SystemExit).and output(
          /Initialization error. Missing or malformed parameter\./
        ).to_stdout
      end

      it 'prints the exception message to the console' do
        expect { method_call }.to raise_error(SystemExit).and output(
          /Missing required parameter glob_patterns/
        ).to_stdout
      end

      it 'exists with the expected error code' do
        expect { method_call }.to output.to_stdout.and(
          raise_error { |error| expect(error.status).to eq(described_class::E_MISSING_PARAMETER_ERROR) }
        )
      end
    end

    context 'when the Explorer raises a Dragnet::Errors::NoMTRFilesFoundError', requirements: ['DRAGNET_0033'] do
      before do
        allow(explorer).to receive(:files).and_raise(
          Dragnet::Errors::NoMTRFilesFoundError,
          'No MTR Files found in /Workspace/source with the following glob patterns: tests/manual/*.yaml'
        )
      end

      it 'prints the expected error to the console' do
        expect { method_call }.to raise_error(SystemExit).and output(
          /No MTR Files found\./
        ).to_stdout
      end

      it 'prints the exception message to the console' do
        expect { method_call }.to raise_error(SystemExit).and output(
          %r{No MTR Files found in /Workspace/source with the following glob patterns: tests/manual/\*\.yaml}
        ).to_stdout
      end

      it 'exists with the expected error code' do
        expect { method_call }.to output.to_stdout.and(
          raise_error { |error| expect(error.status).to eq(described_class::E_NO_MTR_FILES_FOUND) }
        )
      end
    end

    it 'creates an instance of the Validator class' do
      expect(Dragnet::Validator).to receive(:new)
      method_call
    end

    it 'calls #validate on the validator' do
      expect(validator).to receive(:validate)
      method_call
    end

    it 'creates an instance of the Verifier class' do
      expect(Dragnet::Verifier).to receive(:new)
      method_call
    end

    context 'when the repository cannot be created' do
      before do
        allow(Dragnet::Repository).to receive(:new).and_raise(
          ArgumentError, 'path does not exist from /Workspace/project'
        )
      end

      it 'prints the expected error to the console' do
        message = Regexp.escape("Could not open the specified path: #{Dir.pwd} as a Git Repository")
        expect { method_call }.to raise_error(SystemExit)
          .and output(Regexp.new(message)).to_stdout
      end

      it 'prints the exception message to the console' do
        message = Regexp.escape('path does not exist from /Workspace/project')
        expect { method_call }.to raise_error(SystemExit)
          .and output(Regexp.new(message)).to_stdout
      end

      it 'exists with the expected error code' do
        expect { method_call }.to output.to_stdout.and(
          raise_error { |error| expect(error.status).to eq(described_class::E_GIT_ERROR) }
        )
      end
    end

    it 'calls #verify on the verifier' do
      expect(verifier).to receive(:verify)
      method_call
    end

    context 'when the Verifier raises a Dragnet::Errors::IncompatibleRepositoryError' do
      let(:expected_message_header) { 'Incompatible git operation:' }
      let(:expected_message) { 'Incompatible git operation performed over a multi-repository' }
      let(:expected_exit_code) { described_class::E_INCOMPATIBLE_REPOSITORY }

      before do
        allow(verifier).to receive(:verify).and_raise(
          Dragnet::Errors::IncompatibleRepositoryError,
          expected_message
        )
      end

      include_examples 'a fatal error is raised inside Dragnet::CLI::Master#check'
    end

    context 'when no errors nor issues on the MTRs are found' do
      let(:test_records) do
        [
          instance_double(
            Dragnet::TestRecord,
            source_file: 'test/manual/ESR_REQ_5138.yaml',
            result: 'passed',
            verification_result: instance_double(
              Dragnet::VerificationResult,
              status: :passed,
              passed?: true
            )
          ),
          instance_double(
            Dragnet::TestRecord,
            source_file: 'test/manual/ESR_REQ_4570.yaml',
            result: 'passed',
            verification_result: instance_double(
              Dragnet::VerificationResult,
              status: :passed,
              passed?: true
            )
          )
        ]
      end

      it 'does not raise an error' do
        expect { method_call }.not_to raise_error
      end
    end

    context 'when errors are detected in the MTR files' do
      include_context 'when Dragnet::Validator detects error in the MTR files'

      it 'exits with the expected exit code' do
        expect { method_call }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(described_class::E_ERRORS_DETECTED)
        end
      end
    end

    context 'when the verification fails for any of the MTR files' do
      include_context 'when Dragnet::Verifier finds a failed MTR'

      it 'exists with the expected exit code' do
        expect { method_call }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(described_class::E_FAILED_TESTS)
        end
      end
    end

    context 'when there are errors in the MTRs and the verification fails' do
      include_context 'when Dragnet::Validator detects error in the MTR files'
      include_context 'when Dragnet::Verifier finds a failed MTR'

      let(:expected_exit_code) do
        described_class::E_ERRORS_DETECTED | described_class::E_FAILED_TESTS
      end

      it 'exists with the expected exit code' do
        expect { method_call }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(expected_exit_code)
        end
      end
    end

    context 'when export targets are given' do
      let(:export_files) do
        %w[
          output/report.html
          output/report.tex
        ]
      end

      let(:exporter) do
        instance_double(
          Dragnet::Exporter,
          export: true
        )
      end

      before do
        master.options = master.options.merge(export: export_files)
        allow(Dragnet::Exporter).to receive(:new).and_return(exporter)
      end

      shared_examples 'create an exporter with the expected parameters' do
        it 'creates an exporter with the expected parameters (including the target files)' do
          expect(Dragnet::Exporter).to receive(:new).with(
            test_records: test_records, errors: errors, repository: repository_instance, targets: export_files, logger: logger
          )

          method_call
        end
      end

      context 'when the multi-repo compatibility is disabled' do
        let(:repository_instance) { repository }

        include_examples 'create an exporter with the expected parameters'
      end

      context 'when the multi-repo compatibility is enabled' do
        let(:repository_instance) { multi_repository }

        before { master.options = master.options.merge('multi-repo': true) }

        include_examples 'create an exporter with the expected parameters'
      end

      it 'executes the export procedure' do
        expect(exporter).to receive(:export)
        method_call
      end

      shared_context 'when the Exporter raises a known error' do
        before do
          allow(exporter).to receive(:export).and_raise(
            expected_error, expected_message
          )
        end
      end

      context 'when the Exporter raises a UnknownExportFormatError' do
        let(:expected_error) { Dragnet::Errors::UnknownExportFormatError }
        let(:expected_message_header) { 'Export failed' }

        let(:expected_message) do
          "Unknown export format: '.tex'. Valid export formats are: .html, .htm"
        end

        let(:expected_exit_code) { described_class::E_EXPORT_ERROR }

        include_context 'when the Exporter raises a known error'
        include_examples 'a fatal error is raised inside Dragnet::CLI::Master#check'
      end

      context 'when the Exporter raises an UnableToWriteReportError' do
        let(:expected_error) { Dragnet::Errors::UnableToWriteReportError }
        let(:expected_message_header) { 'Export failed' }

        let(:expected_message) do
          'Unable to write report output to output/report.html: Permission Denied'
        end

        let(:expected_exit_code) { described_class::E_EXPORT_ERROR }

        include_context 'when the Exporter raises a known error'
        include_examples 'a fatal error is raised inside Dragnet::CLI::Master#check'
      end

      context 'when the Exporter raises a Dragnet::Errors::IncompatibleRepositoryError' do
        let(:expected_error) { Dragnet::Errors::IncompatibleRepositoryError }
        let(:expected_message_header) { 'Incompatible git operation:' }
        let(:expected_message) { 'Incompatible git operation performed over a multi-repository' }
        let(:expected_exit_code) { described_class::E_INCOMPATIBLE_REPOSITORY }

        include_context 'when the Exporter raises a known error'
        include_examples 'a fatal error is raised inside Dragnet::CLI::Master#check'
      end
    end
  end
end
