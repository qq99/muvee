class LightsController < ApplicationController

  def set
    rgbs = light_params.values.sample(4).map do |c|
      Color::RGB.new(c["r"].to_i, c["g"].to_i, c["b"].to_i)
    end

    hsls = rgbs.map(&:to_hsl)

    HueManagingService.set_lights(hsls)

    render json: {status: "ok"}
  end

  def brighten
    HueManagingService.brighten_lights

    render json: {status: "ok"}
  end

  def dim
    HueManagingService.dim_lights

    render json: {status: "ok"}
  end

  private

  def light_params
    params.require(:colors)
  end

end
