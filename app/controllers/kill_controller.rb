# frozen_string_literal: true

class KillController < ApplicationController
  def index
    Process.kill('TERM', Process.pid)
  end
end
