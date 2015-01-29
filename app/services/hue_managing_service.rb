class HueManagingService

  def self.dim_lights
    HUE_CLIENT.groups.first.brightness = 0
  end

  def self.brighten_lights
    HUE_CLIENT.groups.first.brightness = 255
  end

end
