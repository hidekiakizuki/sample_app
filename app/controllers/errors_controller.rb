class ErrorsController < ApplicationController
  def crash
    Process.kill('TERM', Process.pid)
  end
end