# frozen_string_literal: true

class CspViolationReportController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    raw_body = request.body.read
    json_body = JSON.parse(raw_body)
    formatted_json = JSON.pretty_generate(json_body)
    logger.error("CSP Violation Detected: #{formatted_json}")
    head :no_content
  rescue JSON::ParserError => e
    logger.error("Failed to Record CSP Violation: Error parsing JSON - #{e.message}. Original content: #{raw_body}")
    head :bad_request
  ensure
    request.body.rewind
  end
end
