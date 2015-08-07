HUE_CLIENT = if is_server_or_sidekiq_context?
  puts '=> initializers/hue: Initializing Hue client'
  Hue::Client.new
else
  {}
end
