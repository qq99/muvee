namespace :sidekiq do
  task :clear do
    Sidekiq::RetrySet.new.clear
    Sidekiq::Queue.new.clear
    queues = %w(series_discovery scan movies_discovery analyze default transcode)
    queues.each do |queue|
      Sidekiq::Queue.new(queue).clear
    end
    Sidekiq::ScheduledSet.new.clear
  end
end
