# frozen_string_literal: true

class ErrorsController < ApplicationController
  def index
    Process.kill('TERM', Process.pid)
  end
end
