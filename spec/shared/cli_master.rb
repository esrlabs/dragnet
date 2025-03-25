# frozen_string_literal: true

RSpec.shared_context "with the default CLI's --version output" do
  let(:expected_output) do
    <<~TEXT
      Dragnet #{Dragnet::VERSION}
      Copyright (c) #{Time.now.year} ESR Labs GmbH esrlabs.com
    TEXT
  end
end

RSpec.shared_context "with the number-only CLI's --version output" do
  let(:expected_output) do
    <<~TEXT
      #{Dragnet::VERSION}
    TEXT
  end
end
