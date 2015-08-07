schedule_file = "config/schedule.yml"

unless Rails.env.test? || $rails_rake_task || defined?(Rails::Console)
  puts "Checking for job schedule file"
  if File.exists?(schedule_file)
    puts "Running jobs on schedule"
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end
