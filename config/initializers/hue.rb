HUE_CLIENT = if is_server_or_sidekiq_context?
  puts '=> initializers/hue: Initializing Hue client'
  begin
    Hue::Client.new
  rescue Hue::NoBridgeFound => e
    puts '=> initializers/hue: Hue bridge not found'
    nil
  end
else
  {}
end
