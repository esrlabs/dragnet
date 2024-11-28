# frozen_string_literal: true

require 'dragnet/test_record'

RSpec.describe Dragnet::TestRecord do
  subject(:test_record) { described_class.new(args) }

  let(:sha1) { '6c25d4c4e0183136b558ce8cbc67b0f9463c3ad1' }
  let(:id) { 'ESR_REQ_5435' }
  let(:result) { 'passed' }
  let(:files) { 'source/tests/manual/safeio.yaml' }

  let(:review_status) { 'reviewed' }
  let(:findings) { 'no findings' }

  let(:args) do
    {
      sha1: sha1,
      id: id,
      result: result,
      files: files,
      review_status: review_status,
      findings: findings
    }
  end

  describe '#initialize' do
    subject(:method_call) { test_record }

    let(:review_status) { 'notReviewed' }
    let(:review_comments) { '2021-06-21 Bobillier, S. No findings' }

    context 'with review_status' do
      let(:args) { { review_status: review_status } }

      it 'accepts the given review status' do
        expect(method_call.review_status).to eq(review_status)
      end
    end

    context 'with reviewstatus' do
      let(:args) { { reviewstatus: review_status } }

      it 'accepts the given review status' do
        expect(method_call.review_status).to eq(review_status)
      end
    end

    context 'with review_status and reviewstatus' do
      let(:args) do
        { review_status: review_status, reviewstatus: 'something else'}
      end

      it 'takes review_status and not reviewstatus' do
        expect(method_call.review_status).to eq(review_status)
      end
    end

    context 'with review_comments' do
      let(:args) { { review_comments: review_comments } }

      it 'accepts the given review comments' do
        expect(method_call.review_comments).to eq(review_comments)
      end
    end

    context 'with reviewcomments' do
      let(:args) { { reviewcomments: review_comments } }

      it 'accepts the given review comments' do
        expect(method_call.review_comments).to eq(review_comments)
      end
    end

    context 'with review_comments and reviewcomments' do
      let(:args) do
        { review_comments: review_comments, reviewcomments: '-'}
      end

      it 'takes review_comments and not reviewcomments' do
        expect(method_call.review_comments).to eq(review_comments)
      end
    end

    describe 'Meta-data', requirements: %w[SRS_DRAGNET_0068] do
      shared_examples_for 'a meta-data attribute' do
        # Required variables:
        #   :attribute_value: The value attribute being tested
        #   :arg_key: The key used to set the value of the attribute in the +args+ hash.

        context 'when the argument is not present' do
          it 'leaves the attribute as nil' do
            expect(attribute_value).to be_nil
          end
        end

        context 'when nil is given as argument' do
          before { args[arg_key] = nil }

          it 'sets the attribute to nil' do
            expect(attribute_value).to be_nil
          end
        end

        context 'when a String is given as argument' do
          before { args[arg_key] = 'Single String' }

          it 'sets the attribute to the given value' do
            expect(attribute_value).to eq('Single String')
          end
        end

        context 'when an Array of Strings is given as argument' do
          before { args[arg_key] = %w[Array of Strings] }

          it 'sets the attribute to the given value' do
            expect(attribute_value).to eq(%w[Array of Strings])
          end
        end
      end

      describe 'name' do
        subject(:attribute_value) { test_record.name }

        let(:arg_key) { :name }

        it_behaves_like 'a meta-data attribute'
      end

      describe 'test_method' do
        subject(:attribute_value) { test_record.test_method }

        let(:arg_key) { :test_method }

        it_behaves_like 'a meta-data attribute'
      end

      describe 'tc_derivation_method' do
        subject(:attribute_value) { test_record.tc_derivation_method }

        let(:arg_key) { :tc_derivation_method }

        it_behaves_like 'a meta-data attribute'
      end
    end
  end

  describe '#validate' do
    subject(:method_call) { test_record.validate }

    let(:test_record_validator) do
      instance_double(
        Dragnet::Validators::Entities::TestRecordValidator,
        validate: true
      )
    end

    before do
      allow(Dragnet::Validators::Entities::TestRecordValidator).to receive(:new)
        .and_return(test_record_validator)
    end

    it 'Creates a TestRecordValidator object and calls validate on it' do
      expect(Dragnet::Validators::Entities::TestRecordValidator)
        .to receive(:new).with(test_record)

      expect(test_record_validator).to receive(:validate)
      method_call
    end

    context 'when the validation fails' do
      let(:exception) { Dragnet::Errors::ValidationError }
      let(:message) { 'missing key id' }

      before do
        allow(test_record_validator).to receive(:validate)
          .and_raise(exception, message)
      end

      it 'raises the ValidationError' do
        expect { method_call }.to raise_error(exception, message)
      end
    end
  end

  describe '#passed' do
    subject(:method_call) { test_record.passed? }

    context 'when the result is passed' do
      it 'returns true' do
        expect(method_call).to eq(true)
      end
    end

    context 'when the result is something else' do
      let(:result) { 'something' }

      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end
  end

  describe '#reviewed?' do
    subject(:method_call) { test_record.reviewed? }

    context "when the review_status is 'reviewed'" do
      it 'returns true' do
        expect(method_call).to eq(true)
      end
    end

    context 'when the review_status is something else' do
      let(:review_status) { 'review in progress' }

      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end
  end

  describe '#findings?' do
    subject(:method_call) { test_record.findings? }

    context "when 'findings' is nil" do
      let(:findings) { nil }

      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end

    context "when 'findings' is en empty string" do
      let(:findings) { '' }

      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end

    context "when 'findings' has only spaces" do
      let(:findings) { '       ' }

      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end

    context "when 'findings' is equal to 'no findings'" do
      context "when 'no findings' is lowercase" do
        let(:findings) { 'no findings' }

        it 'returns false' do
          expect(method_call).to eq(false)
        end
      end

      context "when 'no findings' has different capitalization" do
        let(:findings) { 'No Findings' }

        it 'returns false' do
          expect(method_call).to eq(false)
        end
      end
    end

    context "when 'findings' is something else" do
      let(:findings) { 'Possible instability detected when testing output signal' }

      it 'returns true' do
        expect(method_call).to eq(true)
      end
    end
  end
end
