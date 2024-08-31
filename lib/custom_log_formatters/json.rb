# frozen_string_literal: true

# rubocop:disable Layout/HashAlignment
module CustomLogFormatters
  class Json < Logger::Formatter
    def call(severity, time, _progname, msg)
      log = format(
        severity:,
        time:,
        hashed_tags:,
        hashed_msg: hashed_msg(msg)
      )

      "#{log.to_json}\n"
    end

    private

    def format(severity:, time:, hashed_tags:, hashed_msg:)
      {
        time:  time.iso8601(6),
        level: severity,
        type:  'application'
      }.merge(hashed_tags).merge(hashed_msg)
    end

    def hashed_tags
      return {} if current_tags.blank?

      Rails.application.config.log_tags.zip(current_tags).to_h
    end

    def hashed_msg(original_msg)
      pure_msg = remove_tags(original_msg)
      { message: pure_msg&.to_s }
    end

    def remove_tags(original_msg)
      return original_msg if current_tags.blank?

      original_msg&.split("[#{current_tags.last}] ")&.last
    end
  end
end
# rubocop:enable Layout/HashAlignment
