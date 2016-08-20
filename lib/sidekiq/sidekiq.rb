schedule_file = "config/cron.yml"
if File.exists?(schedule_file) && Sidekiq.server?
  cron_configs = YAML.load_file(schedule_file)
  Sidekiq::Cron::Job.load_from_hash(cron_configs)
  cron_configs.each do |config|
    job_name = config.first
    job = Sidekiq::Cron::Job.find(job_name)
    status = ScheduledWorker.enqueue_if_enabled(job)
    Rails.logger.info("Cron: #{job_name} is #{status == true ? 'enabled' : 'disabled' }")
  end
end


