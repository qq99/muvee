class VideosController < ApplicationController
  before_action :set_video, only: [:show, :show_source, :edit, :update, :destroy, :stream, :stream_source, :thumbnails, :fanart, :reanalyze_video]
  before_action :set_source, only: [:show_source, :stream_source]

  respond_to :json, only: [:thumbnails]

  def list
    @videos = Video.all
  end

  # GET /videos/1
  # GET /videos/1.json
  def show_source

    if @video.is_tv?
      @video.series.update_attribute(:last_watched_video_id, @video.id) if @video.series.present?

      if params[:shuffle].present?
        if (series_id = params[:series_id]).present?
          @next_episode = Series.find(series_id).tv_shows.local.sample
        else
          @next_episode = TvShow.local.all.sample
        end
      elsif @video.series.present?
        episodic_scope = @video.series.tv_shows.local.release_order
        episodic_ids = episodic_scope.pluck(:id)
        index_of_current_episode = episodic_ids.find_index{|id| id == @video.id}
        @previous_episode = episodic_scope[index_of_current_episode - 1] if index_of_current_episode > 0
        @next_episode = episodic_scope[index_of_current_episode + 1] if index_of_current_episode < (episodic_ids.size - 1)
      end
    end
    render 'show', layout: 'fullscreen'
  end

  def shuffle
    random_show = TvShow.local.sample
    redirect_to show_source_video_path(random_show, shuffle: true, t: 0)
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
    send_file @source.raw_file_path,
      filename: @source.filename,
      type: Mime::Type.lookup_by_extension(@source.extension),
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

    def video_params
      params.require(:video).permit(:raw_file_path, :type, :episode, :season, :duration, :left_off_at, :series_id)
    end
end
