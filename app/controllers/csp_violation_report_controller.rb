# frozen_string_literal: true

class CspViolationReportController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    logger.debug(request.body.to_json)
    head :no_content
  end
end
