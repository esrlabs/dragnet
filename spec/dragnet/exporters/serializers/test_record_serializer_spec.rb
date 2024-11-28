# frozen_string_literal: true

require 'dragnet/exporters/serializers/test_record_serializer'

RSpec.describe Dragnet::Exporters::Serializers::TestRecordSerializer do
  subject(:test_record_serializer) { described_class.new(test_record, repository) }

  let(:id) { 'ESR_REQ_7630' }
  let(:result) { 'passed' }
  let(:sha1) { nil }
  let(:name) { nil }
  let(:description) { nil }
  let(:test_method) { nil }
  let(:tc_derivation_method) { nil }
  let(:reviewed) { false }
  let(:review_comments) { nil }
  let(:has_findings) { false }
  let(:findings) { nil }
  let(:files) { nil }
  let(:repos) { nil }

  let(:verification_result) do
    instance_double(
      Dragnet::VerificationResult
    )
  end

  let(:test_record) do
    instance_double(
      Dragnet::TestRecord,
      id: id,
      result: result,
      reviewed?: reviewed,
      review_comments: review_comments,
      sha1: sha1,
      name: name,
      description: description,
      test_method: test_method,
      tc_derivation_method: tc_derivation_method,
      findings?: has_findings,
      findings: findings,
      verification_result: verification_result,
      files: files,
      repos: repos
    )
  end

  let(:repository) do
    instance_double(
      Dragnet::Repository,
      path: Pathname.new('/workspace/path/to/repo')
    )
  end

  describe '#serialize' do
    subject(:method_call) { test_record_serializer.serialize }

    let(:serialized_verification_result) do
      {
        status: :passed,
        started_at: Time.new(2024, 2, 28, 15, 36, 48),
        finished_at: Time.new(2024, 2, 28, 15, 36, 50)
      }
    end

    let(:verification_result_serializer) do
      instance_double(
        Dragnet::Exporters::Serializers::VerificationResultSerializer,
        serialize: serialized_verification_result
      )
    end

    before do
      allow(Dragnet::Exporters::Serializers::VerificationResultSerializer)
        .to receive(:new).and_return(verification_result_serializer)
    end

    it 'returns a Hash' do
      expect(method_call).to be_a(Hash)
    end

    context 'when the ID of the Test Record is a String' do
      let(:id) { 'ESR_REQ_7630' }

      it 'includes the expected Array of "refs"', requirements: %w[SRS_DRAGNET_0064] do
        expect(method_call).to include(refs: [id])
      end
    end

    context 'when the ID of the Test Record is an Array' do
      let(:id) { %w[ESR_REQ_1008 ESR_REQ_1065] }

      it 'includes the expected Array of "refs"', requirements: %w[SRS_DRAGNET_0064] do
        expect(method_call).to include(refs: id)
      end
    end

    it 'includes the result of the Test Record' do
      expect(method_call).to include(result: result)
    end

    context "when the Test Record doesn't have a SHA1" do
      let(:sha1) { nil }

      it 'does not include the :sha1 key' do
        expect(method_call).not_to have_key(:sha1)
      end
    end

    context 'when the TestRecord has a SHA1' do
      let(:sha1) { '76e440d0d12763baaf0f825ad4eee9a1b28afa5c' }

      it "includes the Test Record's SHA1" do
        expect(method_call).to include(sha1: sha1)
      end
    end

    context "when the TestRecord doesn't have the tester's name" do
      let(:name) { nil }

      it 'does not include the :owner key', requirements: %w[SRS_DRAGNET_0071] do
        expect(method_call).not_to have_key(:owner)
      end
    end

    context "when the TestRecord has the tester's name" do
      context 'when there is a single tester' do
        let(:name) { ['Freddy Mercury'] }

        it "includes the tester's name (as 'owner')", requirements: %w[SRS_DRAGNET_0065] do
          expect(method_call).to include(owner: 'Freddy Mercury')
        end
      end

      context 'when there are multiple testers' do
        let(:name) { ['Freddy Mercury', 'Brian May', 'John Deacon', 'Roger Taylor'] }

        it "includes all the testers' names as a single string", requirements: %w[SRS_DRAGNET_0071] do
          expect(method_call).to include(owner: 'Freddy Mercury, Brian May, John Deacon, Roger Taylor')
        end
      end
    end

    context "when the TestRecord doesn't have a description" do
      it 'does not include the :description key' do
        expect(method_call).not_to have_key(:description)
      end
    end

    context 'when the TestRecord has a description' do
      let(:description) do
        <<~TEXT
          Perform a factory reset of the ECU and checks that:
            * The ROM wasn't deleted and the checksum of the ROM image is still valid.
            * The VKMS keys have not been lost.
            * All the DTC has been cleared.
            * The system can still boot to the application.
        TEXT
      end

      it "includes the Manual Test Record's description" do
        expect(method_call).to include(description: description)
      end
    end

    context "when the TestRecord doesn't have a test method" do
      let(:test_method) { nil }

      it 'does not include the :test_method key', requirements: %w[SRS_DRAGNET_0070] do
        expect(method_call).not_to have_key(:test_method)
      end
    end

    context 'when the TestRecord has a test method', requirements: %w[SRS_DRAGNET_0070] do
      context 'when there is a single method' do
        let(:test_method) { 'Failure injection' }

        it "includes the Manual Test Record's test method(s)" do
          expect(method_call).to include(test_method: ['Failure injection'])
        end
      end

      context 'when there are multiple methods' do
        let(:test_method) { ['Main-path checking', 'Tampering'] }

        it "includes the Manual Test Record's test method(s)" do
          expect(method_call).to include(test_method: test_method)
        end
      end
    end

    context "when the TestRecord doesn't have a derivation method" do
      let(:tc_derivation_method) { nil }

      it 'does not include the :tc_derivation_method key', requirements: %w[SRS_DRAGNET_0070] do
        expect(method_call).not_to have_key(:tc_derivation_method)
      end
    end

    context 'when the TestRecord has a derivation method', requirements: %w[SRS_DRAGNET_0070] do
      context 'when there is a single method' do
        let(:tc_derivation_method) { 'Decision tree' }

        it "includes the Manual Test Record's test case derivation method" do
          expect(method_call).to include(tc_derivation_method: ['Decision tree'])
        end
      end

      context 'when there are multiple methods' do
        let(:tc_derivation_method) { ['BVA', 'Error guessing'] }

        it "includes the Manual Test Record's test case derivation method" do
          expect(method_call).to include(tc_derivation_method: tc_derivation_method)
        end
      end
    end

    context 'when the TestRecord has not been reviewed' do
      let(:reviewed) { false }

      it 'includes the expected review_status field' do
        expect(method_call).to include(review_status: 'not_reviewed')
      end
    end

    context 'when the TestRecord has been reviewed' do
      let(:reviewed) { true }

      it 'includes the expected review_status field' do
        expect(method_call).to include(review_status: 'reviewed')
      end
    end

    context 'when the TestRecord has no review comments' do
      let(:review_comments) { nil }

      it 'does not include the :review_comments key' do
        expect(method_call).not_to have_key(:review_comments)
      end
    end

    context 'when the TestRecord has review comments' do
      let(:review_comments) do
        <<~TEXT
          Reviewed by John Wix on 23th February 2023
           * The MTR should include the checksum of the ROM image
             and the expected VKMS keys.
        TEXT
      end

      it 'includes the expected review comments' do
        expect(method_call).to include(review_comments: review_comments)
      end
    end

    context 'when the TestRecord has no findings' do
      let(:has_findings) { false }

      it 'does not include the :findings keys' do
        expect(method_call).not_to have_key(:findings)
      end
    end

    context 'when the TestRecord has findings' do
      let(:has_findings) { true }

      let(:findings) do
        <<~TEXT
          After performing the reset the ECU had to be power cycled twice for
          it to boot to the application.
        TEXT
      end

      it 'includes the findings' do
        expect(method_call).to include(findings: findings)
      end
    end

    it "includes the TestRecord's serialized VerificationResult" do
      expect(method_call).to include(verification_result: serialized_verification_result)
    end

    it "includes the 'started_at' attribute from the TestRecord's VerificationResult" do
      expect(method_call).to include(started_at: serialized_verification_result[:started_at])
    end

    it "includes the 'finished_at' attribute from the TestRecord's VerificationResult" do
      expect(method_call).to include(finished_at: serialized_verification_result[:finished_at])
    end

    shared_examples_for '#serialize when the TestRecord has no files' do
      it 'does not include the :files key' do
        expect(method_call).not_to have_key(:files)
      end
    end

    context 'when the TestRecord has no files' do
      let(:files) { nil }

      it_behaves_like '#serialize when the TestRecord has no files'
    end

    context "when the TestRecord's files attribute is an empty Array" do
      let(:files) { [] }

      it_behaves_like '#serialize when the TestRecord has no files'
    end

    context 'when the TestRecord has listed files' do
      let(:files) do
        [
          Pathname.new('/workspace/path/to/repo/some/directory/module.cpp'),
          Pathname.new('/workspace/path/to/repo/other/folder/new_module.h'),
          Pathname.new('/workspace/path/to/repo/Makefile')
        ]
      end

      let(:expected_files) do
        %w[
          some/directory/module.cpp
          other/folder/new_module.h
          Makefile
        ]
      end

      it 'includes the expected array of files' do
        expect(method_call).to include(files: expected_files)
      end
    end

    shared_examples_for '#serialize when the TestRecord has no Repos' do
      it 'does not include the :repos key' do
        expect(method_call).not_to have_key(:repos)
      end
    end

    context 'when the TestRecord has no Repos' do
      let(:repos) { nil }

      it_behaves_like '#serialize when the TestRecord has no Repos'
    end

    context "when the TestRecord's repos attribute is an empty array" do
      let(:repos) { [] }

      it_behaves_like '#serialize when the TestRecord has no Repos'
    end

    context 'when the TestRecord has Repos' do
      let(:repository) do
        instance_double(
          Dragnet::MultiRepository,
          path: Pathname.new('/workspace/source/pd')
        )
      end

      let(:repos) do
        [
          instance_double(Dragnet::Repo),
          instance_double(Dragnet::Repo),
          instance_double(Dragnet::Repo)
        ]
      end

      let(:serialized_repos) do
        [
          {
            path: 'esrlabs/crypto/aes256',
            sha1: 'd33c6e2bd8e37bc5d93dcabbfee2ee55469f428e'
          },
          {
            path: 'esrlabs/bsw/can',
            sha1: '24987d89b32a979f39900499bde1ed713e1cd610',
            files: %w[
              driver/base.h
              driver/base.cpp
              driver/checksum.cpp
            ]
          },
          {
            path: 'platform/system/iot/attestation',
            sha1: 'b72d3e6d4a91eb282927f29f8a2508a2a2e3711c',
            files: %w[Makefile]
          }
        ]
      end

      let(:repo_serializer) do
        instance_double(
          Dragnet::Exporters::Serializers::RepoSerializer
        )
      end

      before do
        allow(Dragnet::Exporters::Serializers::RepoSerializer)
          .to receive(:new).and_return(repo_serializer)

        allow(repo_serializer).to receive(:serialize).and_return(*serialized_repos)
      end

      it 'includes the serialized version of the attached Repo objects' do
        expect(method_call).to include(repos: serialized_repos)
      end
    end
  end
end
