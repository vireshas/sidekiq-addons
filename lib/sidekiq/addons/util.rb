module Sidekiq
  module Addons
    module Util

      def self.priority_job_queue_name(q)
        return "sidekiq-addons:pq:#{q}"
      end

    end
  end
end
