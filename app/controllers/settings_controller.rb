class SettingsController < ApplicationController

  skip_before_filter :check_if_first_use

  layout 'settings'

  def index
    @config = ApplicationConfiguration.first
    render layout: 'application'
  end

  def welcome
    if ApplicationConfiguration.count > 0
      redirect_to settings_path
    end
    @config = ApplicationConfiguration.first || ApplicationConfiguration.new
  end

  def create
    if ApplicationConfiguration.count > 0
      throw "ApplicationConfiguration already exists; we should never create another one"
    end

    @config = ApplicationConfiguration.new(config_params)
    if success = @config.save
      redirect_to videos_path
    else
      render 'welcome'
    end
  end

  def update
    @config = ApplicationConfiguration.find(params[:id])
    if @config.update(config_params)
      redirect_to videos_path
    else
      render 'welcome'
    end
  end

  def config_params
    config = params.require(:application_configuration).permit(:tv_sources, :movie_sources, :transcode_media, :transcode_folder)
    config[:transcode_media] = false if config[:transcode_media].blank?
    config[:movie_sources] = arrayify(config[:movie_sources])
    config[:tv_sources] = arrayify(config[:tv_sources])
    config
  end

  def arrayify(item)
    if item.is_a?(Array)
      return item
    elsif item.is_a?(String)
      item.split(",").uniq.compact
    end
  end

end
