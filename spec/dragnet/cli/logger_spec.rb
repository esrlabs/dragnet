# frozen_string_literal: true

require 'dragnet/cli/logger'

RSpec.describe Dragnet::CLI::Logger do
  subject(:logger) { described_class.new(shell, log_level) }

  let(:shell) do
    instance_double(
      Thor::Shell::Basic
    )
  end

  let(:default_log_level) { described_class::LEVELS[described_class::DEFAULT_LOG_LEVEL] }
  let(:message) { 'hello world!' }

  describe '#initialize' do
    context 'when no log level is given' do
      subject(:logger) { described_class.new(shell) }

      it 'sets the log level to the default' do
        expect(logger.log_level).to eq(default_log_level)
      end
    end

    context 'when the log level is not valid' do
      let(:log_level) { :happy }

      it 'raises an ArgumentError' do
        expect { logger }.to raise_error(ArgumentError, 'Unknown logger level: happy')
      end
    end
  end

  describe '#debug' do
    subject(:method_call) { logger.debug(message) }

    context 'when the log level is debug' do
      let(:log_level) { :debug }

      it 'outputs the message' do
        expect(shell).to receive(:say).with(/#{message}/)
        method_call
      end

      it 'colors the level with the expected color' do
        expect(shell).to receive(:say).with(/\e\[0;32;49mDebug: \e\[0m/)
        method_call
      end
    end

    context 'when the log level is greater than debug' do
      let(:log_level) { %i[info warn error].sample }

      it "doesn't output the message" do
        expect(shell).not_to receive(:say)
        method_call
      end
    end
  end

  describe '#info' do
    subject(:method_call) { logger.info(message) }

    context 'when the log level is info or lower' do
      let(:log_level) { %i[debug info].sample }

      it 'outputs the message' do
        expect(shell).to receive(:say).with(/#{message}/)
        method_call
      end

      it 'colors the level with the expected color' do
        expect(shell).to receive(:say).with(/\e\[0;34;49mInfo:  \e\[0m/)
        method_call
      end
    end

    context 'when the log level is greater than info' do
      let(:log_level) { %i[warn error].sample }

      it "doesn't output the message" do
        expect(shell).not_to receive(:say)
        method_call
      end
    end
  end

  describe '#warn' do
    subject(:method_call) { logger.warn(message) }

    context 'when the log level is warn or lower' do
      let(:log_level) { %i[debug info warn].sample }

      it 'outputs the message' do
        expect(shell).to receive(:say).with(/#{message}/)
        method_call
      end

      it 'colors the level with the expected color' do
        expect(shell).to receive(:say).with(/\e\[0;33;49mWarn:  \e\[0m/)
        method_call
      end
    end

    context 'when the log level is greater than warn' do
      let(:log_level) { %i[error].sample }

      it "doesn't output the message" do
        expect(shell).not_to receive(:say)
        method_call
      end
    end
  end

  describe '#error' do
    subject(:method_call) { logger.error(message) }

    let(:log_level) { %i[debug info warn error].sample }

    it 'always outputs the message' do
      expect(shell).to receive(:say).with(/Error: .*#{message}/)
      method_call
    end

    it 'colors the level with the expected color' do
      expect(shell).to receive(:say).with(/\e\[0;31;49mError: \e\[0m/)
      method_call
    end
  end
end
