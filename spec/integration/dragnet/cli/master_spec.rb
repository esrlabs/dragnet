# frozen_string_literal: true

require 'dragnet/cli/master'
require 'shared/cli_master'

RSpec.describe Dragnet::CLI::Master do
  describe '--version', requirements: %w[DRAGNET_0017 DRAGNET_0026] do
    subject(:output) { `#{base_command}` }

    let(:base_command) { 'bundle exec exe/dragnet --version' }

    include_context "with the default CLI's --version output"

    it 'prints the current version of the gem' do
      expect(output).to eq(expected_output)
    end

    context 'when the -q switch is used' do
      subject(:output) { `#{base_command} -q` }

      let(:expected_output) { '' }

      it 'prints nothing' do
        expect(output).to eq(expected_output)
      end
    end
  end
end
