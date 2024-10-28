# frozen_string_literal: true

require 'dragnet/helpers/repository_helper'

RSpec.describe Dragnet::Helpers::RepositoryHelper do
  subject(:test_class) do
    Class.new do
      include Dragnet::Helpers::RepositoryHelper
    end.new
  end

  describe '#shorten_sha1' do
    subject(:method_call) { test_class.shorten_sha1(sha1) }

    let(:sha1) { '96731e7330180ac41f168c5707628eaffa718c4a' }

    it 'returns only the first 10 characters of the given string' do
      expect(method_call).to eq('96731e7330')
    end
  end
end
