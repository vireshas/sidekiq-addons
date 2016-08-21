module Sidekiq::Addons::Prioritize
  class Enqr

    def compute_priority(queue, msg)
      to_ignore_qs = Sidekiq.options[:ignore_priority] || []
      min_priority = msg["min_priority"] || Sidekiq.options[:min_priority] || 0
      ignore_priority = msg["ignore_priority"]
      lazy_eval = msg["lazy_eval"]

      priority = min_priority
      if ignore_priority or (to_ignore_qs.include?(queue))
        priority = 0

      elsif lazy_eval
        priority = lazy_eval.call(msg["args"])
        unless priority.is_a?(Integer)
          priority = priority ? (min_priority + 1) : (min_priority - 1)
        end

      else
        priority = self.class.get_priority_from_msg(msg)
      end

      return (priority > min_priority) ? priority : nil
    end

    def call(worker_class, msg, queue, redis_pool)
      priority = compute_priority(queue, msg)
      if priority
        msg["queue"] = "queue:#{queue}"
        msg["queue"] = "queue:#{queue}"
        redis_pool.with {|con| self.class.enqueue_with_priority(con, queue, priority, msg) }
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
