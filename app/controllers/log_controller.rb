# frozen_string_literal: true

class LogController < ApplicationController
  def debug
    logger.info '■■■■■■ log debug'
    head :no_content
  end

  def info
    logger.info '■■■■■■ log info'
    head :no_content
  end

  def warn
    logger.info '■■■■■■ log warn'
    head :no_content
  end
  
  def error
    logger.error '■■■■■■ log error'
    head :no_content
  end

  def fatal
    logger.fatal '■■■■■■ log fatal'
    head :no_content
  end

  def unknown
    logger.unknown '■■■■■■ log unknown'
    head :no_content
  end
end
