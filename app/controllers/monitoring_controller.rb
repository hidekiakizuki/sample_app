# frozen_string_literal: true

class MonitoringController < ApplicationController
  skip_before_action :verify_authenticity_token

  def healthy
    head :no_content
  end

  def synthetic
    Article.first
    head :no_content
  end
end
