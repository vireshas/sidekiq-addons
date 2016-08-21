module Sidekiq
  module Addons
    module Util

      ZPOP = %q(
        local resp = redis.call('zrevrange', KEYS[1], '0', '0')
        if (resp[1] ~= nil) then
          local val = resp[# resp]
          redis.call('zrem', KEYS[1], val)
          return val
        else
          return false
        end
      )

      def self.priority_job_queue_name(q)
        return "sidekiq-addons:pq:#{q}"
      end

    end
  end
end
