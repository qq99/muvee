class SettingsController < ApplicationController

  skip_before_filter :check_if_first_use

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

  def reorganize_movies_show
    @config = ApplicationConfiguration.first
    @folders = @config.movie_sources
    @movies = Movie.local.all
  end

  def reorganize_movies_perform
    to_rename = reorganize_movies_params.select do |m|
      m["rename"].present?
    end
    to_rename.each do |to_rename|
      movie = Movie.find(to_rename["from"])
      new_path = to_rename["to_folder"] + to_rename["to_filename"]
      movie.move_raw_file(new_path)
    end
    redirect_to reorganize_movies_settings_path
  end

  def scan_for_new_media
    if existing_jobs.include? "MediaScannerWorker"
      already_working
    else
      MediaScannerWorker.perform_async
      redirect_to settings_path, notice: 'Now scanning for new media'
    end
  end

  def reanalyze_media
    if existing_jobs.include? "AnalyzerWorker"
      already_working
    else
      AnalyzerWorker.perform_async({method: :reanalyze})
      redirect_to settings_path, notice: 'Now re-analyzing your media'
    end
  end

  def redownload_all_arts
    if existing_jobs.include? "AnalyzerWorker"
      already_working
    else
      AnalyzerWorker.perform_async({method: :redownload})
      redirect_to settings_path, notice: 'Now re-downloading all art'
    end
  end

  def redownload_missing_arts
    if existing_jobs.include? "AnalyzerWorker"
      already_working
    else
      AnalyzerWorker.perform_async({method: :redownload_missing})
      redirect_to settings_path, notice: 'Now re-downloading missing art'
    end
  end

  private

  def already_working
    render json: {status: "Please wait; this task is already running."}, status: 409
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

  def existing_jobs
    jobs = [Sidekiq::ScheduledSet.new.to_a, Sidekiq::RetrySet.new.to_a, Sidekiq::Queue.new("default").to_a, Sidekiq::Queue.new("analyze").to_a, Sidekiq::Queue.new("transcode").to_a]
    jobs = jobs.inject([]) {|set, el| set.concat el}
    existing_jobs = jobs.map do |job|
      job.display_class
    end
  end

end
