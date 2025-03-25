# frozen_string_literal: true

require 'dragnet/cli/master'
require 'shared/cli_master'

RSpec.describe Dragnet::CLI::Master do
  describe '--version', requirements: %w[SRS_DRAGNET_0017 SRS_DRAGNET_0026] do
    subject(:output) { `#{command}` }

    let(:command) { 'bundle exec exe/dragnet --version' }

    include_context "with the default CLI's --version output"

    shared_examples_for '--version when the quiet option is given' do
      let(:command) { "#{super()} -q" }
      let(:expected_output) { '' }

      it 'prints nothing' do
        expect(output).to eq(expected_output)
      end
    end

    it 'prints the current version of the gem' do
      expect(output).to eq(expected_output)
    end

    context 'when the --number-only version is given' do
      let(:command) { "#{super()} -n" }

      include_context "with the number-only CLI's --version output"

      it 'prints only the version number' do
        expect(output).to eq(expected_output)
      end

      context 'when the -q switch is used' do
        it_behaves_like '--version when the quiet option is given'
      end
    end

    context 'when the -q switch is used' do
      it_behaves_like '--version when the quiet option is given'
    end
  end
end
