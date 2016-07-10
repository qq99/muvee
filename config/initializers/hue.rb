HUE_CLIENT = if Rails.configuration.control_hue_lights
  puts '=> initializers/hue: Initializing Hue client'
  begin
    Hue::Client.new
  rescue Hue::NoBridgeFound => e
    puts '=> initializers/hue: Hue bridge not found'
    nil
  end
else
  puts '=> initializers/hue: Opting not to control Hue lights'
  {}
end
