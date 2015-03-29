class VideosController < ApplicationController
  before_action :set_video, only: [:show, :show_source, :edit, :update, :destroy, :stream, :stream_source, :left_off_at, :thumbnails, :fanart, :reanalyze_video]
  before_action :set_source, only: [:show_source, :stream_source]

  skip_before_filter :check_if_first_use, only: [:left_off_at]
  respond_to :json, only: [:left_off_at, :thumbnails]

  def index
  end

  def list
    @videos = Video.all
  end

  # GET /videos/1
  # GET /videos/1.json
  def show_source

    if @video.is_tv?
      if @video.series.present?
        @video.series.last_watched_video_id = @video.id
        @video.series.save
      end

      if params[:shuffle].present?
        if params[:series_id].present?
          @next_episode = Series.find(params[:series_id]).tv_shows.local.sample
        else
          @next_episode = TvShow.local.all.sample
        end
      elsif @video.series.present?
        episodic = @video.series.tv_shows.local.release_order
        index_of_current_episode = episodic.to_a.find_index{|vid| vid.id == @video.id}
        @previous_episode = episodic.at(index_of_current_episode - 1) if index_of_current_episode > 0
        @next_episode = episodic.at(index_of_current_episode + 1) if index_of_current_episode < (episodic.length - 1)
      end
    end
    render 'show', layout: 'fullscreen'
  end

  def shuffle
    random_show = TvShow.all.sample
    redirect_to show_source_video_path(random_show, shuffle: true)
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
  end

  # GET /videos/1/stream
  def stream_source
    filepath = @source.raw_file_path

    video_extension = File.extname(filepath)[1..-1]

    send_file filepath,
      filename: File.basename(filepath),
      type: Mime::Type.lookup_by_extension(video_extension),
      disposition: 'inline',
      stream: true,
      buffer_size: 4096
  end

  # GET /videos/1/fanart
  # => [array of absolute paths to the image]
  def fanart
    respond_to do |format|
      format.json { render json: @video.fanarts.map{|f| f.url} }
    end
  end

  # POST /videos/:id/reanalyze
  # re-analyze the metadata of a single video
  def reanalyze_video
    @video.reanalyze
    render json: {status: "ok"}
  end

  # POST /videos/1/left_off_at.json
  def left_off_at
    @video.update_attribute(:left_off_at, params[:left_off_at])
    render json: {status: "ok"}
  end

  # GET /videos/1/thumbnails.json
  def thumbnails
    # builds thumbnails if they don't exist, returns them if they do
    # all videos start with 1 thumbnail
    unless @video.has_set_of_thumbnails?
      @video.thumbnails.destroy_all
      @video.create_n_thumbnails(Thumbnail::IDEAL_NUMBER_OF_THUMBNAILS)
    end

    render json: {thumbnails: @video.thumbnails.map{|t| t.url}}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    def set_source
      if params[:source_id].present?
        @source = Source.find(params[:source_id])
      else
        @source = @video.sources.first
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      params.require(:video).permit(:raw_file_path, :type, :episode, :season, :duration, :left_off_at, :series_id)
    end
end
