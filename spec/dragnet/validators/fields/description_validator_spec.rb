# frozen_string_literal: true

require 'dragnet/validators/fields/description_validator'

RSpec.describe Dragnet::Validators::Fields::DescriptionValidator do
  subject(:description_validator) { described_class.new }

  describe '#validate' do
    subject(:method_call) { description_validator.validate(key, value) }

    let(:key) { 'description' }

    context 'when the value is nil' do
      let(:value) { nil }

      it 'does not raise any errors' do
        expect { method_call }.not_to raise_error
      end
    end

    context 'when the values is a string' do
      let(:value) { 'Subway tile woke 3 wolf moon occupy bicycle rights, anim ennui unicorn gluten-free roof party.' }

      it 'does not raise any errors' do
        expect { method_call }.not_to raise_error
      end
    end

    shared_examples_for '#validate with an invalid type' do
      it 'raises the expected error' do
        expect { method_call }.to raise_error(
          Dragnet::Errors::ValidationError,
          "Incompatible type for key description: Expected String got #{type} instead"
        )
      end
    end

    context 'when the value is an Array' do
      let(:value) do
        [
          'Dreamcatcher nisi reprehenderit edison bulb, dolore in direct trade do dolore.',
          'Minim photo booth stumptown, kogi cardigan banjo post-ironic try-hard migas biodiesel.'
        ]
      end

      let(:type) { 'Array' }

      it_behaves_like '#validate with an invalid type'
    end

    context 'when the value is a Hash' do
      let(:value) do
        {
          'Text 1' => 'Test fails during CPU0 boot',
          'Text 2' => 'Test fails during PMIC execution'
        }
      end

      let(:type) { 'Hash' }

      it_behaves_like '#validate with an invalid type'
    end

    context 'when the value is a Float' do
      let(:value) { 11.35 }
      let(:type) { 'Float' }

      it_behaves_like '#validate with an invalid type'
    end

    context 'when the value is a FalseClass' do
      let(:value) { false }
      let(:type) { 'FalseClass' }

      it_behaves_like '#validate with an invalid type'
    end
  end
end
