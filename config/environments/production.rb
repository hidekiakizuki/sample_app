# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

# 追加
require Rails.root.join('lib/custom_log_formatters/json')
require Rails.root.join('lib/custom_log_formatters/lograge')

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path =~ %r{^/healthy|^/synthetic} } } }

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store
  config.cache_store = :redis_cache_store, {
    url: "rediss://#{ENV['ELASTICACHE_USER']}:#{ENV['ELASTICACHE_PASSWORD']}@#{ENV['ELASTICACHE_HOST']}:6379/0",
    namespace: 'rails_cache_store',
    expires_in: 30.days
  }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "src_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  # 下部でロガーの設定をしているのでここはコメントアウトします。
  # if ENV['RAILS_LOG_TO_STDOUT'].present?
  #   logger           = ActiveSupport::Logger.new($stdout)
  #   logger.formatter = config.log_formatter
  #   config.logger    = ActiveSupport::TaggedLogging.new(logger)
  # end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # 追加
  config.colorize_logging = false

  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = CustomLogFormatters::Json.new
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  config.lograge.enabled = true
  config.lograge.formatter = CustomLogFormatters::Lograge.new
  config.lograge.custom_payload do |controller|
    request = controller.request
    {
      user_id:    controller.try(:current_user)&.id,
      request_id: request.request_id,
      remote_ip:  request.remote_ip,
      host:       request.host,
      url:        request.original_url,
      user_agent: request.user_agent
    }
  end
end
