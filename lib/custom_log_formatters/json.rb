# frozen_string_literal: true

# rubocop:disable Layout/HashAlignment
module CustomLogFormatters
  class Json < Logger::Formatter
    def call(severity, time, _progname, msg)
      log = format(
        severity:,
        time:,
        hashed_tags:,
        hashed_message: hashed_message(msg)
      )

      "#{log.to_json}\n"
    end

    private

    def format(severity:, time:, hashed_tags:, hashed_message:)
      {
        time:  time.in_time_zone.iso8601(3),
        level: severity,
        type:  'application'
      }.merge(hashed_tags).merge(hashed_message)
    end

    def hashed_tags
      return {} if current_tags.blank?

      Rails.application.config.log_tags.zip(current_tags).to_h
    end

    def hashed_message(original_message)
      pure_message = extract_pure_message(original_message)
      parse_message(pure_message)
    end

    def extract_pure_message(original_message)
      return original_message if current_tags.blank?

      original_message&.split("[#{current_tags.last}] ", 2)&.last.presence || original_message
    end

    def parse_message(message)
      JSON.parse(message, symbolize_names: true)
    rescue JSON::ParserError
      { message: message&.to_s }
    end
  end
end
# rubocop:enable Layout/HashAlignment
