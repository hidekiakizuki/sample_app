Aws::Rails::SqsActiveJob.configure do |config|
  config.queues = {
    default: ENV['SQS_QUEUE_DEFAULT']
  }
end
