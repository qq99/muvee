class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy, :stream]

  # GET /videos
  # GET /videos.json
  def index
    @videos = Video.all
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
    @video.series.last_watched_video = @video
    @video.series.save
    render layout: 'fullscreen'
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
  end

  def generate
    # TODO: make this service create from a user-defined endpoint
    service = VideoCreationService.new({
      tv: ['/media/sf_TV/'],
      movies: []
    })

    @new_tv_shows, @failed_tv_shows, @new_movies, @failed_movies = service.generate()

    respond_to do |format|
      format.json { render json: {
        new_tv_shows: @new_tv_shows,
        failed_tv_shows: @failed_tv_shows,
        new_movies: @new_movies,
        failed_movies: @failed_movies
      }, status: :ok}
    end
  end

  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render :show, status: :created, location: @video }
      else
        format.html { render :new }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { render :show, status: :ok, location: @video }
      else
        format.html { render :edit }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video.destroy
    respond_to do |format|
      format.html { redirect_to videos_url, notice: 'Video was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def stream
    # video_path = @video.raw_file_path
    # video_extension = File.extname(@video.raw_file_path)[1..-1]
    # video_file = File.open(video_path) # TODO: check that it exists
    # video_size = video_file.size
    # video_begin = 0
    # video_end = video_size - 1

    # if request.headers["Range"]
    #   status_code = :partial_content
    #   match = request.headers['Range'].match(/bytes=(\d+)-(\d*)/)

    #   r1 = match[1].to_i if match[1].present?
    #   r2 = match[2].to_i if match[2] && match[2].present?
    #   if r1 && (r1 >= 0) && (r1 < video_end)
    #     video_begin = r1
    #   end
    #   if r2 && (r2 > video_begin) && (r2 <= video_end)
    #     video_end = r2
    #   end

    #   response.headers["Accept-Ranges"] = "bytes"
    #   response.headers['Content-Range'] = "bytes #{video_begin}-#{video_end}/#{video_size}"
    # else
    #   status_code = :ok
    # end

    # response.headers["Content-Length"] = (video_end.to_i - video_begin.to_i + 1).to_s
    # response.headers["Cache-Control"] = "public, must-revalidate, max-age=0"
    # response.headers["Pragma"] = "no-cache"
    # response.headers["Connection"] = "keep-alive" # maybe
    # #response.headers["Last-Modified"] = @video.updated_at.to_s
    # response.headers["Content-Transfer-Encoding"] = "binary"
    # # response.headers['Content-Duration'] = @video.duration.to_s
    # # response.headers['X-Content-Duration'] = @video.duration.to_s

    send_file @video.raw_file_path,
      #filename: "muv-stream.mp4",
      #type: Mime::Type.lookup_by_extension(video_extension),
      type: 'video/mp4',
      #status: status_code,
      disposition: 'inline',
      stream: true,
      buffer_size: 4096
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      params.require(:video).permit(:raw_file_path, :type, :episode, :season, :duration, :left_off_at, :series_id)
    end
end
