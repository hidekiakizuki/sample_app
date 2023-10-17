# frozen_string_literal: true

class MonitoringController < ApplicationController
  def healthy
    head :no_content
  end

  def synthetic
    Article.first
    head :no_content
  end
end
