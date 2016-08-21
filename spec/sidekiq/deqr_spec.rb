require 'spec_helper'

module Sidekiq::Addons::Prioritize
  describe Deqr do
    before do
      Sidekiq.redis { |c| c.flushdb }
    end

    it 'should dequeue job from priority queue' do
      jid = MockWorker.perform_async("job_identifier", {:with_priority => 100})
      expect(jid).to eq nil

      d = Deqr.new(queues: ['default'])
      job = d.retrieve_work.message
      f_job = JSON.parse(job)

      expect(f_job["class"]).to eq "MockWorker"
      expect(f_job["args"].first).to eq "job_identifier"

      job = d.retrieve_work
      expect(job).to eq nil
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
  end
end
