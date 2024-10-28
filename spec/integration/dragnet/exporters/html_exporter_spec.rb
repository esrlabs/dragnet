# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/array/access'
require 'fileutils'
require 'logger'
require 'tmpdir'

require 'dragnet/exporters/html_exporter'

RSpec.shared_context 'with a mocked template for Dragnet::Exporters::HTMLExporter' do
  before do
    # This has to be mocked because there is no way to pass a different template
    # to the class, so the only way to be able to change the content is by
    # mocking the file read.
    allow(File).to receive(:read)
      .with(described_class::TEMPLATE).and_return(template)
  end
end

RSpec.shared_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output' do
  it 'returns the expected output' do
    expect(output).to eq(expected_output)
  end
end

RSpec.shared_context 'with a test repository for Dragnet::Exporters::HTMLExporter' do
  let(:temp_dir) { Pathname.new(Dir.mktmpdir) }
  let(:repository) { Dragnet::Repository.new(path: temp_dir) }
  let(:git_bundle) { Pathname.new(__dir__) / 'test_files' / 'repo.git' }
  let(:git) { Git.clone(git_bundle, '', path: temp_dir) }

  before { git.checkout('master') }

  after do
    FileUtils.rm_rf(temp_dir)
  end
end

RSpec.describe Dragnet::Exporters::HTMLExporter, requirements: ['DRAGNET_0022'] do
  subject(:output) { html_exporter.export }

  let(:html_exporter) do
    described_class.new(
      test_records: test_records, errors: errors, repository: repository, logger: logger
    )
  end

  let(:test_records) { [] }
  let(:errors) { [] }

  # We only use a real repository for certain methods, it takes time to clone
  # and prepare the repository, therefore unless it is needed we just use an
  # empty double. (If anything tries to use the "repo" an error will be raised)
  let(:repository) { double }

  let(:log_output) do
    StringIO.new
  end

  let(:logger) do
    Logger.new(log_output)
  end

  let(:template) { '' }

  describe '#percentage' do
    include_context 'with a mocked template for Dragnet::Exporters::HTMLExporter'

    let(:template) do
      <<~ERB
        <%= percentage(0, 0) %>
        <%= percentage(10, 0) %>
        <%= percentage(0, 20) %>
        <%= percentage(20, 100) %>
        <%= percentage(9, 16) %>
        <%= percentage(42, 26) %>
        <%= percentage(6.555, 15) %>
      ERB
    end

    let(:expected_output) do
      <<~TEXT
        0.0
        0.0
        0.0
        20.0
        56.25
        161.54
        43.7
      TEXT
    end

    include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
  end

  describe '#software_branches' do
    include_context 'with a mocked template for Dragnet::Exporters::HTMLExporter'

    let(:template) do
      <<~ERB
        <%= software_branches(repository).sort.join(', ') %>
      ERB
    end

    include_context 'with a test repository for Dragnet::Exporters::HTMLExporter'

    context 'when the current head is only in one branch' do
      let(:expected_output) do
        <<~TEXT
          master
        TEXT
      end

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end

    context 'when the current head is in multiple branches' do
      include_context 'with a mocked template for Dragnet::Exporters::HTMLExporter'

      let(:expected_output) do
        <<~TEXT
          basics, master
        TEXT
      end

      before { git.checkout('basics') }

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end
  end

  describe '#test_records_by_requirement' do
    include_context 'with a mocked template for Dragnet::Exporters::HTMLExporter'

    let(:test_records) do
      [
        Dragnet::TestRecord.new(
          id: 'ERS_REQ_4028',
          name: 'John S.'
        ),
        Dragnet::TestRecord.new(
          id: 'ERS_REQ_4488',
          name: 'Alice P.'
        ),
        Dragnet::TestRecord.new(
          id: 'ERS_REQ_4488',
          name: 'Gregor J.'
        ),
        Dragnet::TestRecord.new(
          id: 'ERS_REQ_2508',
          name: 'Rick L.'
        ),
        Dragnet::TestRecord.new(
          id: %w[ERS_REQ_4968 ESR_REQ_8481],
          name: 'Natalie E.'
        ),
        Dragnet::TestRecord.new(
          id: %w[ESR_REQ_2430 ERS_REQ_2508],
          name: 'Andrea F.'
        )
      ]
    end

    let(:template) do
      <<~ERB
        <% test_records_by_requirement.sort.each do |req_id, test_records| %>
        <%= req_id %> => <%= test_records.map(&:name).sort.join(' ') %>
        <% end %>
      ERB
    end

    let(:expected_output) do
      <<~TEXT

        ERS_REQ_2508 => Andrea F. Rick L.

        ERS_REQ_4028 => John S.

        ERS_REQ_4488 => Alice P. Gregor J.

        ERS_REQ_4968 => Natalie E.

        ESR_REQ_2430 => Andrea F.

        ESR_REQ_8481 => Natalie E.

      TEXT
    end

    include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
  end

  describe '#review_status_badge' do
    include_context 'with a mocked template for Dragnet::Exporters::HTMLExporter'

    let(:template) do
      <<~ERB
        <%= review_status_badge(test_records.first) %>
      ERB
    end

    context 'when the test record has no review status' do
      let(:test_records) { [Dragnet::TestRecord.new({})] }

      let(:expected_output) do
        <<~HTML
          <span class=\"badge bg-gray\">(unknown)</span>
        HTML
      end

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end

    context 'when the test record has been reviewed' do
      let(:test_records) do
        [
          Dragnet::TestRecord.new(
            reviewstatus: 'reviewed'
          )
        ]
      end

      let(:expected_output) do
        <<~HTML
          <span class=\"badge bg-green\">Reviewed</span>
        HTML
      end

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end

    context "when the test record hasn't been reviewed" do
      let(:test_records) do
        [
          Dragnet::TestRecord.new(
            reviewstatus: 'inReview'
          )
        ]
      end

      let(:expected_output) do
        <<~HTML
          <span class=\"badge bg-red\">Inreview</span>
        HTML
      end

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end
  end

  describe 'colors from verification results', requirements: ['DRAGNET_0024'] do
    include_context 'with a mocked template for Dragnet::Exporters::HTMLExporter'

    let(:test_record) do
      Dragnet::TestRecord.new({}).tap do |record|
        record.verification_result = Dragnet::VerificationResult.new(status: status)
      end
    end

    let(:test_records) { [test_record] }

    describe '#verification_result_badge' do
      let(:template) do
        <<~ERB
          <%= verification_result_badge(test_records.first.verification_result) %>
        ERB
      end

      context 'when the verification result is passed' do
        let(:status) { :passed }

        let(:expected_output) do
          <<~HTML
            <span class=\"badge bg-green\">Passed</span>
          HTML
        end

        include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
      end

      context 'when the verification result is skipped' do
        let(:status) { :skipped }

        let(:expected_output) do
          <<~HTML
            <span class=\"badge bg-yellow\">Skipped</span>
          HTML
        end

        include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
      end

      context 'when the verification result is failed' do
        let(:status) { :failed }

        let(:expected_output) do
          <<~HTML
            <span class=\"badge bg-red\">Failed</span>
          HTML
        end

        include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
      end
    end

    describe '#card_color' do
      let(:template) do
        <<~ERB
          <%= card_color(test_records.first.verification_result) %>
        ERB
      end

      context 'when the verification result is passed' do
        let(:status) { :passed }

        let(:expected_output) do
          <<~TEXT
            green
          TEXT
        end

        include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
      end

      context 'when the verification result is skipped' do
        let(:status) { :skipped }

        let(:expected_output) do
          <<~TEXT
            yellow
          TEXT
        end

        include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
      end

      context 'when the verification result is failed' do
        let(:status) { :failed }

        let(:expected_output) do
          <<~TEXT
            red
          TEXT
        end

        include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
      end
    end
  end

  describe '#relative_to_repo' do
    include_context 'with a mocked template for Dragnet::Exporters::HTMLExporter'
    include_context 'with a test repository for Dragnet::Exporters::HTMLExporter'

    context "when the repository's path is absolute" do
      let(:full_path) { temp_dir / 'hello_world.rb' }

      let(:template) do
        <<~ERB
          <%= relative_to_repo(Pathname.new('#{full_path}')) %>
        ERB
      end

      let(:expected_output) do
        <<~TEXT
          hello_world.rb
        TEXT
      end

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end

    context "when the repository's path is the current working directory" do
      let(:repository) { Dragnet::Repository.new(path: Pathname.new('.')) }
      let(:full_path) { './Test/Manual/cryptographic_functions.yaml' }

      let(:template) do
        <<~ERB
          <%= relative_to_repo(Pathname.new('#{full_path}')) %>
        ERB
      end

      let(:expected_output) do
        <<~TEXT
          Test/Manual/cryptographic_functions.yaml
        TEXT
      end

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end
  end

  describe '#test_record_id_to_string' do
    include_context 'with a mocked template for Dragnet::Exporters::HTMLExporter'

    let(:test_records) do
      [
        Dragnet::TestRecord.new(
          id: 'ERS_REQ_6583'
        ),
        Dragnet::TestRecord.new(
          id: %w[ESR_REQ_1785 ERS_REQ_9846]
        ),
        Dragnet::TestRecord.new(
          id: %w[ESR_REQ_7925]
        )
      ]
    end

    context 'when the ID of the TestRecord object is a String' do
      let(:template) do
        <<~ERB
          <%= test_record_id_to_string(test_records.first) %>
        ERB
      end

      let(:expected_output) do
        <<~TEXT
          ERS_REQ_6583
        TEXT
      end

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end

    context 'when the ID of the TestRecord object is an Array' do
      let(:template) do
        <<~ERB
          <%= test_record_id_to_string(test_records.second) %>
        ERB
      end

      let(:expected_output) do
        <<~TEXT
          ESR_REQ_1785, ERS_REQ_9846
        TEXT
      end

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end

    context 'when the ID of the TestRecord object is an single-element Array' do
      let(:template) do
        <<~ERB
          <%= test_record_id_to_string(test_records.third) %>
        ERB
      end

      let(:expected_output) do
        <<~TEXT
          ESR_REQ_7925
        TEXT
      end

      include_examples 'Dragnet::Exporters::HTMLExporter#export returns the expected output'
    end
  end

  describe 'report contents' do
    include_context 'with a test repository for Dragnet::Exporters::HTMLExporter'

    let(:test_records) do
      [
        Dragnet::TestRecord.new(sha1: '04aec23' ).tap do |test_record|
          test_record.source_file = temp_dir / 'source' / 'tests' / 'manual' / 'safe_e2e.yaml'
          test_record.verification_result = Dragnet::VerificationResult.new(status: :passed)
        end,
        Dragnet::TestRecord.new(sha1: 'f13dbbc' ).tap do |test_record|
          test_record.source_file = temp_dir / 'source' / 'tests' / 'manual/io_vectors.yaml'
          test_record.verification_result = Dragnet::VerificationResult.new(
            status: :skipped,
            reason: 'changes detected in the repository f13dbbc..6e94407'
          )
        end,
        Dragnet::TestRecord.new(sha1: '6e94407').tap do |test_record|
          test_record.source_file = temp_dir / 'source' / 'tests' / 'manual' / 'signals.yaml'
          test_record.verification_result = Dragnet::VerificationResult.new(
            status: :failed,
            reason: "result key has the value 'failed'"
          )
        end
      ]
    end

    let(:errors) do
      [
        {
          file: temp_dir / 'source' / 'tests' / 'manual' / 'entry_points.yaml',
          message: 'YAML Parsing Error',
          exception: Exception.new('Unknown character on line 7')
        },
        {
          file: temp_dir / 'source' / 'tests' / 'manual' / 'watchdog.yaml',
          message: 'Unable to read file',
          exception: Exception.new('Permission Denied')
        }
      ]
    end

    it 'does not include the full repository path' do
      expect(output).not_to include(temp_dir.to_s)
    end

    describe 'list of MTR files', requirements: ['DRAGNET_0023'] do
      it 'lists the MTR files that were successfully loaded' do
        expect(output).to include('source/tests/manual/safe_e2e.yaml')
          .and include('source/tests/manual/io_vectors.yaml')
          .and include('source/tests/manual/signals.yaml')
      end

      it "lists the MTR files that couldn't be loaded" do
        expect(output).to include('source/tests/manual/entry_points.yaml')
          .and include('source/tests/manual/watchdog.yaml')
      end
    end

    it 'lists the reasons for the failure/skipping of the test records', requirements: ['DRAGNET_0025'] do
      expect(output).to include('changes detected in the repository f13dbbc..6e94407')
        .and include("result key has the value 'failed'")
    end
  end
end

