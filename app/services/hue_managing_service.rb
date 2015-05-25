class HueManagingService

  def self.dim_lights
    HUE_CLIENT.groups.first.brightness = 0
  end

  def self.brighten_lights
    HUE_CLIENT.groups.first.brightness = 255
  end

  def self.set_lights(hsls)
    HUE_CLIENT.lights.each do |light|
      hsl = hsls.pop
      break if hsl.blank?
      result = light.set_state({
        hue: ((hsl.hue / 360.0) * Hue::Light::HUE_RANGE.last).to_i,
        saturation: ((hsl.saturation / 100.0) * Hue::Light::SATURATION_RANGE.last).to_i,
        brightness: ((hsl.brightness / 100.0) * Hue::Light::BRIGHTNESS_RANGE.last).to_i
      }, 30)
    end
  end

end
