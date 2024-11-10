# frozen_string_literal: true

class AsyncTestJobController < ApplicationController
  def enqueue
    TestJob.perform_later('param1', 2, { param3: '3' })
    head :ok
  end
end
