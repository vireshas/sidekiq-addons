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

    it 'should prioritize job with higher priority' do
      MockWorker.perform_async(1, {:with_priority => 90})
      MockWorker.perform_async(2, {:with_priority => 90})
      MockWorker.perform_async(3, {:with_priority => 90})
      MockWorker.perform_async(4, {:with_priority => 100})

      d = Deqr.new(queues: ['default'])
      job = d.retrieve_work.message
      f_job = JSON.parse(job)

      expect(f_job["args"].first).to eq 4
      expect(f_job["class"]).to eq "MockWorker"
    end

    it 'should prioritize job with higher priority' do
      MockWorker.perform_async(11, {:with_priority => 90})
      MockWorker.perform_async(12, {:with_priority => 90})
      MockWorker.perform_async(14, {:with_priority => 100})

      IgnoreWorker.perform_async(21, {:with_priority => 90})
      IgnoreWorker.perform_async(22, {:with_priority => 90})
      IgnoreWorker.perform_async(24, {:with_priority => 100})

      d = Deqr.new(queues: ['default'])
      job = d.retrieve_work.message
      f_job = JSON.parse(job)
      expect(f_job["args"].first).to eq 14
      expect(f_job["class"]).to eq "MockWorker"

      2.times {
        d = Deqr.new(queues: ['default'])
        job = d.retrieve_work.message
        f_job = JSON.parse(job)
        expect(f_job["class"]).to eq "MockWorker"
      }
    end
  end
end
