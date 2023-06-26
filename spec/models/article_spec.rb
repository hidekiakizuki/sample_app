# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article do
  # rubocop:disable RSpec/IdenticalEqualityAssertion, RSpec/ExpectActual
  it 'trueであるとき、trueになること' do
    expect(true).to be true
  end
  # rubocop:enable RSpec/IdenticalEqualityAssertion, RSpec/ExpectActual
end
