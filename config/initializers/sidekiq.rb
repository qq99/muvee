# schedule_file = "config/schedule.yml"
#
# if is_server_or_sidekiq_context?
#   puts "=> initializers/sidekiq: Checking for job schedule file"
#   if File.exists?(schedule_file)
#     puts "=> initializers/sidekiq: Running jobs on schedule"
#     Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
#   end
# end
