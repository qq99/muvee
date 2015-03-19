schedule_file = "config/schedule.yml"

unless Rails.env.test?
  if File.exists?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end
