# frozen_string_literal: true

RSpec.shared_examples_for 'Dragnet::Validators::Fields::FieldValidator#validate when the validation fails' do
  it 'raises a Dragnet::Errors::ValidationError' do
    expect { method_call }
      .to raise_error(Dragnet::Errors::ValidationError, expected_message)
  end
end
