module Sidekiq::Addons::Prioritize
  class Enqr

    def call(worker_class, msg, queue, redis_pool)
      to_ignore_qs = Sidekiq.options[:ignore_prioritize] || []

      priority = 0
      unless to_ignore_qs.include? queue
        priority = self.class.get_priority_from_msg(msg)
      end

      if ( priority > 0 )
        msg["queue"] = "queue:#{queue}"
        redis_pool.with do |con|
          self.class.enqueue_with_priority(con, queue, priority, msg)
        end
        return false
      else
        yield
      end
    end

    class << self

      def get_priority_from_msg(msg)
        priority = nil

        if msg["args"].is_a?(Array)
          msg["args"].each do |param|
            if param.is_a?(Hash) and ( param.has_key?(:with_priority) \
               or param.has_key?("with_priority") )

              priority = param[:with_priority]
              priority = param["with_priority"] unless priority
              break
            end
          end
        end

        return priority.to_i
      end

      def enqueue_with_priority(con, queue, priority, msg)
        q_name = Sidekiq::Addons::Util.priority_job_queue_name(queue)
        return con.zadd(q_name, priority, msg.to_json)
      end

    end

  end
end
