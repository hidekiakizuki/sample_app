# frozen_string_literal: true

class MonitoringController < ApplicationController
  def healthy
    head :ok
  end

  def synthetic
    Article.first
    head :ok
  end
end
