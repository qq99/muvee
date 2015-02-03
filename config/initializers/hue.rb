if Rails.env.test?
  HUE_CLIENT = {}
else
  HUE_CLIENT = Hue::Client.new
end
