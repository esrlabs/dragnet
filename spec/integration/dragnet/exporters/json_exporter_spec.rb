# frozen_string_literal: true

require 'dragnet/exporters/json_exporter'

RSpec.describe Dragnet::Exporters::JSONExporter do
  subject(:json_exporter) do
    described_class.new(test_records: test_records, errors: errors, repository: repository, logger: logger)
  end

  let(:test_records) { [] }
  let(:errors) { [] }

  let(:workspace) { Pathname.new(Dir.pwd) }

  let(:repository) do
    Dragnet::MultiRepository.new(path: workspace)
  end

  let(:log_output) { StringIO.new }
  let(:logger) { Logger.new(log_output) }

  describe '#export' do
    subject(:method_call) { json_exporter.export }

    let(:re_parsed_json) { JSON.parse(method_call) }

    shared_context 'with errors' do
      let(:errors) do
        [
          {
            file: 'manual_verification/crypto/checksum_checker.yaml',
            message: 'Referenced repository not found',
            error: Errno::ENOENT.new('lib/crypto/difi')
          }
        ]
      end
    end

    shared_examples_for '#export' do
      it 'returns a String' do
        expect(method_call).to be_a(String)
      end

      it 'produces parseable JSON', requirements: %w[SRS_DRAGNET_0060] do
        expect { re_parsed_json }.not_to raise_error
      end
    end

    context 'when no TestRecords are given' do
      let(:test_records) { [] }

      it_behaves_like '#export'

      shared_examples_for '#export when no TestRecords are given' do
        it 'produces an empty array' do
          expect(re_parsed_json).to be_an(Array).and be_empty
        end
      end

      context 'when errors are present', requirements: %w[SRS_DRAGNET_0063] do
        include_context 'with errors'

        it_behaves_like '#export when no TestRecords are given'

        it 'does not include the validation errors' do
          expect(method_call).not_to include('manual_verification/crypto/checksum_checker.yaml')
        end
      end
    end

    context 'when test records are given' do
      let(:test_records) do
        [
          Dragnet::TestRecord.new(
            id: 'ESR_REQ_9126',
            result: 'passed',
            sha1: 'c99204563e5337e48ab7b3689d8ec1b1a0f45cb7',
            description: <<~TEXT
              Use an oscilloscope to verify that pin 3 on the PD-3234 chip is high
              when the cycle starts, goes low during the first 250ms of the cycle
              and then switches between high and low every 333ms for the rest of
              the cycle.
            TEXT
          ).tap do |test_record|
            test_record.source_file = workspace / 'MTR' / 'PD_3234_voltage.yaml'
            test_record.verification_result = Dragnet::VerificationResult.new(
              status: :skipped,
              reason: 'Changes detected in the repository: c99204563e..fc5aaddf52'
            ).tap do |verification_result|
              verification_result.started_at = Time.new(2024, 2, 27, 14, 36, 7, 'UTC')
              verification_result.finished_at = Time.new(2024, 2, 27, 14, 36, 9, 'UTC')
            end
          end,
          Dragnet::TestRecord.new(
            id: %w[ESR_REQ_7817 ESR_REQ_3636],
            sha1: '354aa24ffcc9c8baae28fec14eabd469169d87b2',
            result: 'passed',
            files: [
              workspace / 'lib' / 'cli' / 'master.cpp',
              workspace / 'validators' / 'sha1_validator.cpp',
              workspace / 'validators' / 'id_validator.cpp'
            ],
            name: 'Carl Sagan',
            review_status: 'reviewed',
            review_comments: 'Reviewed on 1970-01-01. No findings.'
          ).tap do |test_record|
            test_record.source_file = workspace / 'MTR' / 'validators.yaml'
            test_record.verification_result = Dragnet::VerificationResult.new(
              status: :passed
            ).tap do |verification_result|
              verification_result.started_at = Time.new(2024, 2, 27, 14, 21, 16, 'UTC')
              verification_result.finished_at = Time.new(2024, 2, 27, 14, 22, 4, 'UTC')
            end
          end,
          Dragnet::TestRecord.new(
            id: 'ESR_REQ_7661',
            name: 'Ada Lovelace',
            result: 'failed',
            repos: [
              Dragnet::Repo.new(
                path: 'lib/crypto/diffie',
                sha1: '5606bc61ab2560ecbc54ae1fe5272cdd8ad8a083',
                files: %w[
                  key_scheduling/key_scheduler.cpp
                  key_scheduling/key_scheduler.h
                  key_generator/generator.cpp
                ]
              )
            ],
            findings: 'The key scheduler repeats a key when both cycles match (++p == pe)',
            review_status: 'in-review'
          ).tap do |test_record|
            test_record.source_file = workspace / 'MTR' / 'crypto' / 'diffie.yaml'
            test_record.verification_result = Dragnet::VerificationResult.new(
              status: :failed,
              reason: "'result' field has the status 'failed'"
            ).tap do |verification_result|
              verification_result.started_at = Time.new(2024, 2, 27, 14, 22, 4, 'UTC')
              verification_result.finished_at = Time.new(2024, 2, 27, 14, 22, 11, 'UTC')
            end
          end
        ]
      end

      let(:expected_json) do
        '['\
          '{' \
            '"refs":["ESR_REQ_9126"],' \
            '"result":"passed",' \
            '"review_status":"not_reviewed",' \
            '"verification_result":{' \
              '"status":"skipped",' \
              '"started_at":"2024-02-27 14:36:07 +0000",' \
              '"finished_at":"2024-02-27 14:36:09 +0000",' \
              '"runtime":2.0,' \
              '"reason":"Changes detected in the repository: c99204563e..fc5aaddf52"' \
            '},' \
            '"started_at":"2024-02-27 14:36:07 +0000",' \
            '"finished_at":"2024-02-27 14:36:09 +0000",' \
            '"sha1":"c99204563e5337e48ab7b3689d8ec1b1a0f45cb7",' \
            '"description":"Use an oscilloscope to verify that pin 3 on the PD-3234 chip is high\n'\
              'when the cycle starts, goes low during the first 250ms of the cycle\n'\
              'and then switches between high and low every 333ms for the rest of\n'\
              'the cycle.\n",' \
            '"id":"2de4fadc0e37faff"' \
          '},'\
          '{' \
            '"refs":["ESR_REQ_7817","ESR_REQ_3636"],' \
            '"result":"passed",' \
            '"review_status":"reviewed",' \
            '"verification_result":{' \
              '"status":"passed",' \
              '"started_at":"2024-02-27 14:21:16 +0000",' \
              '"finished_at":"2024-02-27 14:22:04 +0000",' \
              '"runtime":48.0' \
            '},' \
            '"started_at":"2024-02-27 14:21:16 +0000",' \
            '"finished_at":"2024-02-27 14:22:04 +0000",' \
            '"sha1":"354aa24ffcc9c8baae28fec14eabd469169d87b2",' \
            '"owner":"Carl Sagan",' \
            '"review_comments":"Reviewed on 1970-01-01. No findings.",' \
            '"files":['\
              '"lib/cli/master.cpp",'\
              '"validators/sha1_validator.cpp",'\
              '"validators/id_validator.cpp"' \
            '],' \
            '"id":"02c3a37bb344f280"' \
          '},' \
          '{' \
            '"refs":["ESR_REQ_7661"],' \
            '"result":"failed",' \
            '"review_status":"not_reviewed",' \
            '"verification_result":{' \
              '"status":"failed",' \
              '"started_at":"2024-02-27 14:22:04 +0000",' \
              '"finished_at":"2024-02-27 14:22:11 +0000",' \
              '"runtime":7.0,' \
              '"reason":"\'result\' field has the status \'failed\'"' \
            '},' \
            '"started_at":"2024-02-27 14:22:04 +0000",' \
            '"finished_at":"2024-02-27 14:22:11 +0000",' \
            '"owner":"Ada Lovelace",' \
            '"findings":"The key scheduler repeats a key when both cycles match (++p == pe)",' \
            '"repos":[' \
              '{' \
                '"path":"lib/crypto/diffie",' \
                '"sha1":"5606bc61ab2560ecbc54ae1fe5272cdd8ad8a083",' \
                '"files":[' \
                  '"key_scheduling/key_scheduler.cpp",' \
                  '"key_scheduling/key_scheduler.h",' \
                  '"key_generator/generator.cpp"' \
                ']' \
              '}' \
            '],' \
            '"id":"77ac686a8f4b46dd"' \
          '}' \
        ']'
      end

      it_behaves_like '#export'

      shared_examples_for '#export when test records are given' do
        let(:verification_results) do
          re_parsed_json.map { |object| object['verification_result'] }
        end

        it 'produces an array with an element for each Test Record object', requirements: %w[SRS_DRAGNET_0061] do
          expect(re_parsed_json.size).to eq(test_records.size)
        end

        it 'produces an array of Hashes', requirements: %w[SRS_DRAGNET_0061] do
          expect(re_parsed_json).to all(be_a(Hash))
        end

        it 'produces the expected JSON' do
          expect(method_call).to eq(expected_json)
        end

        it 'includes all the MTRs', requirements: %w[SRS_DRAGNET_0061] do
          ids = re_parsed_json.flat_map { |object| object['id'] }
          expect(ids).to eq(%w[2de4fadc0e37faff 02c3a37bb344f280 77ac686a8f4b46dd])
        end

        it 'includes the Verification Result for each MTR', requirements: %w[SRS_DRAGNET_0062] do
          expect(verification_results).to all(be_a(Hash))
        end

        it 'includes the start_at attribute in each Verification Result', requirements: %w[SRS_DRAGNET_0078] do
          expect(verification_results).to all(have_key('started_at'))
        end

        it 'includes the finished_at attribute in each Verification Result', requirements: %w[SRS_DRAGNET_0078] do
          expect(verification_results).to all(have_key('finished_at'))
        end

        it 'includes the runtime attribute in each Verification Result', requirements: %w[SRS_DRAGNET_0078] do
          expect(verification_results).to all(have_key('runtime'))
        end
      end

      it_behaves_like '#export when test records are given'

      context 'when errors are present', requirements: %w[SRS_DRAGNET_0063] do
        include_context 'with errors'

        it_behaves_like '#export when test records are given'

        it 'does not include the validation errors' do
          expect(method_call).not_to include('Referenced repository not found')
        end
      end
    end
  end
end
