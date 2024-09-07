# frozen_string_literal: true

# rubocop:disable Layout/HashAlignment
module CustomLogFormatters
  class Lograge
    def call(payload)
      log = format(payload)
      log.to_json
    end

    private

    def format(payload)
      {
        time:       Time.zone.now.iso8601(3),
        level:      level(payload[:status]),
        type:       'access',
        status:     payload[:status],
        method:     payload[:method],
        path:       payload[:path],
        format:     payload[:format],
        controller: [payload[:controller], payload[:action]].join('#'),
        duration:   payload[:duration],
        user_id:    payload[:user_id],
        request_id: payload[:request_id],
        remote_ip:  payload[:remote_ip],
        host:       payload[:host],
        url:        payload[:url],
        user_agent: payload[:user_agent]
      }
    end

    def level(status)
      status < 500 ? 'INFO' : 'ERROR'
    end
  end
end
# rubocop:enable Layout/HashAlignment
