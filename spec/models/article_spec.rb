# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article do
  it 'テスト' do
    article = create(:article)
    expect(article).not_to be_nil
  end
end
