class SettingsController < ApplicationController

  skip_before_filter :check_if_first_use

  def index
    @config = muvee_configuration
    render layout: 'application'
  end

  def welcome
    if ApplicationConfiguration.count > 0
      redirect_to settings_path
    end
    @config = muvee_configuration || ApplicationConfiguration.new
    render layout: 'fullscreen'
  end

  def create
    if ApplicationConfiguration.count > 0
      throw "ApplicationConfiguration already exists; we should never create another one"
    end

    @config = ApplicationConfiguration.new(config_params)
    if success = @config.save
      render 'welcome'
    else
      render 'welcome', layout: 'fullscreen'
    end
  end

  def update
    @config = ApplicationConfiguration.find(params[:id])
    if @config.update(config_params)
      render 'welcome'
    end
  end

  def reorganize_movies_show
    @config = APP_CONFIG
    @folders = @config.movie_sources
    @sources = MovieSource.all
  end

  def reorganize_movies_perform
    to_rename = reorganize_movies_params.select do |m|
      m["rename"].present?
    end
    to_rename.each do |to_rename|
      source = MovieSource.find(to_rename["from"])
      new_path = to_rename["to_folder"] + to_rename["to_filename"]
      source.move_to(new_path)
    end
    flash[:notice] = "Renamed #{to_rename.size} sources."
    redirect_to reorganize_movies_settings_path
  end

  def find_dead_files
    @dead_files = DeadFileFindingService.new.list_unsourced_files(source_folders)
  end

  def destroy_files
    to_destroy = destroy_files_params
    to_destroy.each do |record|
      filename = record['file']
      File.delete(filename) if filename.start_with?(*source_folders)
    end
    redirect_to status_index_path, notice: "Deleted #{to_destroy.size} files."
  end

  def find_dead_sources
    @dead_sources = DeadFileFindingService.new.list_dead_sources
  end

  def destroy_sources
    to_destroy = destroy_sources_params
    to_destroy.each do |record|
      Source.destroy(record['source_id'])
    end
    redirect_to find_dead_sources_settings_path, notice: "Destroyed #{to_destroy.size} sources.  Re-analyzing your library in the background now."
  end

  private

  def muvee_configuration
    ApplicationConfiguration.first
  end

  def source_folders
    @source_folders ||= muvee_configuration.movie_sources + muvee_configuration.tv_sources
  end

  def destroy_files_params
    to_destroy = params[:destroy].values.first.values
    to_destroy.select do |record|
      record["should_destroy"].present? &&
      record["file"].start_with?(*source_folders)
    end
  end

  def destroy_sources_params
    to_destroy = params[:destroy].values
    to_destroy.select do |record|
      record["should_destroy"].present?
    end
  end

  def reorganize_movies_params
    params[:reorg].values
  end

  def config_params
    config = params.require(:application_configuration).permit(:tv_sources, :movie_sources, :transcode_media, :transcode_folder, :torrent_start_path)
    config[:transcode_media] = false if config[:transcode_media].blank?
    config[:movie_sources] = arrayify(config[:movie_sources])
    config[:tv_sources] = arrayify(config[:tv_sources])
    config
  end

  def arrayify(item)
    if item.is_a?(Array)
      return item
    elsif item.is_a?(String)
      item.gsub(/\r/, '').split(/,|\n/).uniq.compact
    end
  end

end
