# frozen_string_literal: true

class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    article = Article.first
    Rails.logger.info "■■■■■■ Async Job Test OK - args: #{args&.join('/')}, Article title: #{article&.title}"
  end
end
