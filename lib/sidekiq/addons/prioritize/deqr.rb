require "celluloid"
require "sidekiq/fetch"

module Sidekiq::Addons::Prioritize
  class Deqr < Sidekiq::BasicFetch

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

    def retrieve_work
      if "queue:asset_processor".in? @queues.uniq
        priority_job = Sidekiq.redis {|con| con.eval(Deqr::ZPOP, ["priority_queue"]) }
      else
        priority_job = nil
      end

      if priority_job.nil?
        return super
      else
        work = JSON.load(priority_job)
        Sidekiq.redis do |con|
          Sidekiq::ClientMiddleware.stat_dequeued(con, work)
        end
        return UnitOfWork.new(work["queue"], priority_job)
      end
    end

    def self.bulk_requeue(inprogress, options)
      return if inprogress.empty?

      jobs_unhandled = []
      inprogress.each do |unit_work|
        unit_work = JSON.load(unit_work)
        priority = Sidekiq::ClientMiddleware.priority_from_unit_work(unit_work)
        if priority
          Sidekiq.redis do |con|
            Sidekiq::ClientMiddleware.enqueue_with_priority(con, priority, unit_work)
          end
        else
          jobs_unhandled << unit_work.to_json
        end
      end

      Sidekiq.logger.info("Pushed #{inprogress.size - jobs_unhandled.size} jobs back to priority_queue in Redis")

      super(jobs_unhandled, options)
    end
  end

end

