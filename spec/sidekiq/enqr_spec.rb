require 'spec_helper'

module Sidekiq::Addons::Prioritize
  describe Enqr do
    before do
      Sidekiq.redis { |c| c.flushdb }
    end

    it 'should enqueue to priority queue when with_priority is > 0' do
      jid = MockWorker.perform_async(100, {:with_priority => 100})
      expect(jid).to eq nil

      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 1
      expect(job.first).to eq expected_q

      job = Sidekiq.redis {|c| c.zrange(expected_q, 0, -1) }
      expect(job.size).to eq 1
      expect(JSON.parse(job.first)["class"]).to eq "MockWorker"
    end

    it 'should add enqueue job which has with_priority' do
      jid = NonDefaultWorker.perform_async(100, {:with_priority => 100})
      expect(jid).to eq nil

      expected_q = 'sidekiq-addons:pq:non_default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 1
      expect(job.first).to eq expected_q

      job = Sidekiq.redis {|c| c.zrange(expected_q, 0, -1) }
      expect(job.size).to eq 1
      expect(JSON.parse(job.first)["class"]).to eq "NonDefaultWorker"
    end

    it 'should work with a combination of default and non_default' do
      jid = MockWorker.perform_async(100, {:with_priority => 100})
      expect(jid).to eq nil

      jid = NonDefaultWorker.perform_async(100, {:with_priority => 100})
      expect(jid).to eq nil

      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 1
      expect(job.first).to eq expected_q

      job = Sidekiq.redis {|c| c.zrange(expected_q, 0, -1) }
      expect(job.size).to eq 1
      expect(JSON.parse(job.first)["class"]).to eq "MockWorker"

      expected_q = 'sidekiq-addons:pq:non_default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 1
      expect(job.first).to eq expected_q

      job = Sidekiq.redis {|c| c.zrange(expected_q, 0, -1) }
      expect(job.size).to eq 1
      expect(JSON.parse(job.first)["class"]).to eq "NonDefaultWorker"
    end

    it 'should not enqueue job if it is in ignore_priority list' do
      Sidekiq.options[:ignore_priority] = ["default"]

      jid = MockWorker.perform_async(100, {:with_priority => 100})
      is_null = !jid
      expect(is_null).to eq false

      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 0

      Sidekiq.options.delete(:ignore_priority)
    end

    it 'should not enqueue job if priority is less than min_priority' do
      Sidekiq.options[:min_priority] = 50

      jid = MockWorker.perform_async(100, {:with_priority => 40})
      is_null = !jid
      expect(is_null).to eq false

      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 0

      Sidekiq.options.delete(:min_priority)
    end

    it 'should enqueue job if priority is greater than min_priority' do
      jid = MinPriorityWorker.perform_async(100, {:with_priority => 40})
      is_null = !jid
      expect(is_null).to eq false

      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 0
    end

    it 'should enqueue job if priority is greater than min_priority' do
      jid = MinPriorityWorker.perform_async(100, {:with_priority => 60})
      expect(jid).to eq nil

      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 1
      expect(job.first).to eq expected_q
    end

    it 'should enqueue job if priority is greater than min_priority' do
      Sidekiq.options[:min_priority] = 50

      jid = MockWorker.perform_async(100, {:with_priority => 60})
      expect(jid).to eq nil

      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 1
      expect(job.first).to eq expected_q

      Sidekiq.options.delete(:min_priority)
    end

    it 'should not enqueue job if it is in ignore_priority list non_default case' do
      Sidekiq.options[:ignore_priority] = ["non_default"]

      jid = NonDefaultWorker.perform_async(100, {:with_priority => 100})
      is_null = !jid
      expect(is_null).to eq false

      jid = MockWorker.perform_async(100, {:with_priority => 100})
      expect(jid).to eq nil

      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 1
      expect(job.first).to eq expected_q

      expected_q = 'sidekiq-addons:pq:non_default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 0

      Sidekiq.options.delete(:ignore_priority)
    end

    it 'should add enqueue job which has with_priority' do
      jid = MockWorker.perform_async(1, {:with_priority => 100})
      expect(jid).to eq nil

      jid = MockWorker.perform_async(2, {:with_priority => 90})
      expect(jid).to eq nil

      jid = MockWorker.perform_async(3, {:with_priority => 90})
      expect(jid).to eq nil

      jid = MockWorker.perform_async(4, {:with_priority => 100})
      expect(jid).to eq nil

      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 1
      expect(job.first).to eq expected_q

      jobs = Sidekiq.redis {|c| c.zrevrange(expected_q, 0, -1) }
      expect(jobs.size).to eq 4

      expectation = { "0" => 1, "1" => 4, "2" => 2, "3" => 3}

      jobs.each_with_index do |job, i|
        expect(JSON.parse(job)["class"]).to eq "MockWorker"
        expect(expectation.values.include?(JSON.parse(job)["args"].first.to_i)).to eq true
      end
    end

    it 'should enqueue based on proc evalution' do
      LazyEvalWorker.perform_async(100)
      expected_q = 'sidekiq-addons:pq:default'
      job = Sidekiq.redis {|c| c.keys(expected_q) }
      expect(job.size).to eq 1
      expect(job.first).to eq expected_q
    end

    it 'should not enqueue based on proc evalution' do
      LazyEvalWorker.perform_async(50)
      expected_q = 'sidekiq-addons:pq:default'
      jid = Sidekiq.redis {|c| c.keys(expected_q) }
      is_null = !jid
      expect(is_null).to eq false
    end
  end
end
