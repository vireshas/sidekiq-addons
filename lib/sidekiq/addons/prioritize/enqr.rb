module Sidekiq::Addons::Prioritize
  class Enqr

    #pass 'with_priority' to bypass regular queue
    #and stop the client middleware
    #else default to original implementation
    def call(worker_class, msg, queue, redis_pool)
      priority = self.class.priority_from_unit_work(msg)
      if priority and queue == "asset_processor"
        msg["queue"] = "queue:#{queue}"
        redis_pool.with do |con|
          self.class.enqueue_with_priority(con, priority, msg)
        end
        return false
      else
        yield
      end
    end

    def self.priority_from_unit_work(msg)
      priority = nil
      if msg["args"].last and msg["args"].last.is_a?(Hash)
        priority = msg["args"].last[:priority]
        priority = msg["args"].last["priority"] unless priority
      end
      return priority
    end

    def self.stat_queued(con, msg)
      con.rpush("queue:dummy_priority_queue", msg["jid"])
    end

    def self.stat_dequeued(con, msg)
      con.lpop("queue:dummy_priority_queue")
    end

    def self.enqueue_with_priority(con, priority, msg)
      con.zadd("priority_queue", priority, msg.to_json)
      self.stat_queued(con, msg)
    end

  end
end
