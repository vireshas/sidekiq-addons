require "celluloid"
require "sidekiq/fetch"

module Sidekiq::Addons::Prioritize
  class Deqr < Sidekiq::BasicFetch

    attr_accessor :script_sha

    def zpop(queue)
      Sidekiq.redis do |con|
        #TODO: for some reason pipeline and multi didnt work; revisit
        if ( self.script_sha.nil? ) or !con.script(:exists, self.script_sha)
          self.script_sha = con.script(:load, Sidekiq::Addons::Util::ZPOP)
        end

        con.evalsha(self.script_sha, [queue])
      end
    end

    def retrieve_work
      priority_job = nil
      @queues.uniq.each do |q|
        q_name = Sidekiq::Addons::Util.priority_job_queue_name(q.split("queue:").last)
        priority_job = zpop(q_name)
        break if priority_job
      end

      if priority_job.nil?
        return super
      else
        work = JSON.load(priority_job)
        return UnitOfWork.new(work["queue"], priority_job)
      end
    end

    def self.bulk_requeue(inprogress, options)
      return if inprogress.empty?

      jobs_unhandled = []
      inprogress.each do |unit_work|
        unit_work = JSON.load(unit_work)
        priority = Sidekiq::Addons::Prioritize::Enqr.get_priority_from_msg(unit_work)
        if ( priority > 0 )
          Sidekiq.redis do |con|
            Sidekiq::Addons::Prioritize::Enqr.enqueue_with_priority(con, unit_work["queue"], priority, unit_work)
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

