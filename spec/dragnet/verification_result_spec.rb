# frozen_string_literal: true

require 'date'
require 'dragnet/verification_result'

RSpec.shared_examples_for 'Dragnet::VerificationResult#status= with an invalid status' do
  it 'raises an ArgumentError' do
    expect { method_call }.to raise_error(
      ArgumentError, "Invalid status #{new_status}."\
                     ' Valid statuses are: passed, skipped, failed'
    )
  end
end

RSpec.shared_examples_for 'Dragnet::VerificationResult#status=' do
  it 'assigns the given status' do
    method_call
    expect(verification_result.status).to eq(new_status)
  end
end

RSpec.describe Dragnet::VerificationResult do
  subject(:verification_result) { described_class.new(status: status) }

  let(:status) { :passed }
  let(:new_status) { status }

  describe '#initialize' do
    subject(:method_call) { verification_result }

    context 'with an invalid status' do
      let(:status) { :deleted }

      it_behaves_like 'Dragnet::VerificationResult#status= with an invalid status'
    end

    it_behaves_like 'Dragnet::VerificationResult#status='
  end

  describe '#status=' do
    subject(:method_call) { verification_result.status = new_status }

    let(:new_status) { :skipped }

    context 'with an invalid status' do
      let(:new_status) { 'passed' }

      it_behaves_like 'Dragnet::VerificationResult#status= with an invalid status'
    end

    it_behaves_like 'Dragnet::VerificationResult#status='
  end

  describe '#passed?' do
    subject(:method_call) { verification_result.passed? }

    context 'when status is :passed' do
      it 'returns true' do
        expect(method_call).to eq(true)
      end
    end

    context 'when status is not :passed' do
      let(:status) { :failed }

      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end
  end

  describe '#skipped?' do
    subject(:method_call) { verification_result.skipped? }

    context 'when status is not :skipped' do
      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end

    context 'when status is skipped' do
      let(:status) { :skipped }

      it 'returns true' do
        expect(method_call).to eq(true)
      end
    end
  end

  describe 'failed?' do
    subject(:method_call) { verification_result.failed? }

    context 'when status is not :failed' do
      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end

    context 'when status is failed' do
      let(:status) { :failed }

      it 'returns true' do
        expect(method_call).to eq(true)
      end
    end
  end

  shared_examples 'runtime update after timestamp change' do
    describe 'runtime update', requirements: %w[DRAGNET_0077] do
      before do
        verification_result.started_at = Time.new(2028, 2, 6, 22, 40, 24)
        verification_result.finished_at = Time.new(2032, 9, 17, 6, 3, 18)
      end

      it 'updates the runtime' do
        expect { method_call }.to change(verification_result, :runtime)
      end
    end
  end

  shared_examples_for '#started_at' do
    # Required variables:
    # :attribute: The attribute whose value should change after the assignment

    it 'does not raise any errors' do
      expect { method_call }.not_to raise_error
    end

    it 'sets the given time' do
      expect { method_call }.to change(verification_result, attribute).to(time)
    end

    include_examples 'runtime update after timestamp change'
  end

  shared_examples_for '#started_at with an object which is not a Time' do
    it 'raises an ArgumentError' do
      expect { method_call }.to raise_error(
        ArgumentError,
        "Expected a Time object, got #{time.class}"
      )
    end
  end

  describe '#started_at=', requirements: %w[DRAGNET_0075] do
    subject(:method_call) { verification_result.started_at = time }

    let(:time) { Time.new(2024, 1, 31, 11, 20, 12) }
    let(:attribute) { :started_at }

    context 'when the given time is not a Time object' do
      let(:time) { ['2024/01/31 11:20:12', 1_706_696_412, nil, Date.new(2024, 1, 31)].sample }

      it_behaves_like '#started_at with an object which is not a Time'
    end

    context "when finished_at hasn't been set" do
      it_behaves_like '#started_at'
    end

    context 'when finished_at is already set' do
      before do
        verification_result.finished_at = Time.new(2048, 2, 1, 22, 40, 24)
      end

      context 'when the given time is bigger than finished_at' do
        let(:time) { Time.new(2096, 4, 2, 20, 20, 48) }

        it 'raises an ArgumentError' do
          expect { method_call }.to raise_error(
            ArgumentError, 'started_at must be smaller than finished_at'
          )
        end
      end

      context 'when the given time is bigger than started_at' do
        it_behaves_like '#started_at'
      end
    end
  end

  describe '#finished_at=', requirements: %w[DRAGNET_0076] do
    subject(:method_call) { verification_result.finished_at = time }

    let(:time) { Time.new(2031, 1, 24, 12, 20, 11) }
    let(:attribute) { :finished_at }

    context 'when the given time is not a Time object' do
      let(:time) { ['2031/01/24 12:20:11', 1_706_696_412, nil, Date.new(2031, 1, 24)].sample }

      it_behaves_like '#started_at with an object which is not a Time'
    end

    context "when started_at hasn't been set" do
      it_behaves_like '#started_at'
    end

    context 'when started_at is already set' do
      before do
        verification_result.started_at = Time.new(2024, 1, 31, 11, 20, 12)
      end

      context 'when the given time is smaller than started_at' do
        let(:time) { Time.new(2016, 6, 12, 6, 10, 5) }

        it 'raises an ArgumentError' do
          expect { method_call }.to raise_error(
            ArgumentError, 'finished_at must be greater than started_at'
          )
        end
      end

      context 'when the given time is bigger than started_at' do
        it_behaves_like '#started_at'
      end
    end
  end

  shared_examples_for '#runtime! when both started_at and finished_at are set' do
    before do
      verification_result.started_at = Time.new(2024, 1, 31, 15, 34, 8)
      verification_result.finished_at = Time.new(2024, 1, 31, 15, 35, 42)
    end

    it 'returns the expected runtime' do
      expect(method_call).to be_within(0.01).of(94)
    end
  end

  describe '#runtime!', requirements: %w[DRAGNET_0077] do
    subject(:method_call) { verification_result.runtime! }

    shared_examples_for '#runtime! when started_at or finished_at are nil' do
      it 'raises a MissingTimestampAttributeError' do
        expect { method_call }.to raise_error(
          Dragnet::Errors::MissingTimestampAttributeError,
          'Both started_at and finished_at must be set in order to calculate the runtime'
        )
      end
    end

    context 'when both started_at and finished_at are nil' do
      it_behaves_like '#runtime! when started_at or finished_at are nil'
    end

    context 'when started_at is set but finished_at is nil' do
      before { verification_result.started_at = Time.new(2024, 1, 31, 15, 34, 8) }

      it_behaves_like '#runtime! when started_at or finished_at are nil'
    end

    context 'when finished_at is set but started_at is nil' do
      before { verification_result.finished_at = Time.new(2024, 1, 31, 15, 34, 8) }

      it_behaves_like '#runtime! when started_at or finished_at are nil'
    end

    context 'when both started_at and finished_at are set' do
      it_behaves_like '#runtime! when both started_at and finished_at are set'
    end
  end

  describe '#runtime', requirements: %w[DRAGNET_0077] do
    subject(:method_call) { verification_result.runtime }

    context 'when both started_at and finished_at are nil' do
      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context 'when started_at is set but finished_at is nil' do
      before { verification_result.started_at = Time.new(2024, 1, 31, 15, 34, 8) }

      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context 'when finished_at is set but started_at is nil' do
      before { verification_result.finished_at = Time.new(2024, 1, 31, 15, 34, 8) }

      it 'returns nil' do
        expect(method_call).to be_nil
      end
    end

    context 'when both started_at and finished_at are set' do
      it_behaves_like '#runtime! when both started_at and finished_at are set'
    end
  end

  describe '#log_message' do
    subject(:method_call) { verification_result.log_message }

    context 'when the VerificationResult is passed' do
      it 'returns the expected log message' do
        expect(method_call).to eq("\e[0;92;49m✔ PASSED \e[0m")
      end
    end

    context 'when the VerificationResult is skipped' do
      let(:verification_result) do
        described_class.new(
          status: :skipped,
          reason: 'Changes detected in listed file(s): df0a857bc9..b00826b104 -- src/crypto/rsa.rs'
        )
      end

      it 'returns the expected log message', requirements: %w[DRAGNET_0029] do
        expect(method_call).to eq(
          "\e[0;93;49m⚠ SKIPPED\e[0m Changes detected in listed file(s): df0a857bc9..b00826b104 -- src/crypto/rsa.rs"
        )
      end
    end

    context 'when the VerificationResult is failed' do
      context 'with a reason' do
        let(:verification_result) do
          described_class.new(
            status: :failed,
            reason: "The path 'esrlabs/bsw/crypto' does not contain a valid git repository."
          )
        end

        it 'returns the expected log message', requirements: %w[DRAGNET_0029] do
          expect(method_call).to eq(
            "\e[0;91;49m✘ FAILED \e[0m The path 'esrlabs/bsw/crypto' does not contain a valid git repository."
          )
        end
      end

      context 'without a reason' do
        let(:verification_result) { described_class.new(status: :failed) }

        it 'returns the expected log message' do
          expect(method_call).to eq("\e[0;91;49m✘ FAILED \e[0m Unknown reason")
        end
      end
    end
  end
end
