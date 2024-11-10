if Rails.env.production?
  require Rails.root.join('lib/custom_log_formatters/json')
  require Rails.root.join('lib/custom_log_formatters/lograge')
  
  aws_logger = ActiveSupport::Logger.new($stdout)
  aws_logger.level = Logger::WARN
  aws_logger.formatter = CustomLogFormatters::Json.new
  
  Aws.config.update(
    logger: ActiveSupport::TaggedLogging.new(aws_logger)
  )
end
