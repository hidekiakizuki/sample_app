# frozen_string_literal: true

class MonitoringController < ApplicationController
  def healthy
    render plain: 'OK test', status: :ok
  end

  def synthetic
    Article.first
    render plain: 'OK', status: :ok
  end
end
