class SeriesController < ApplicationController
  before_action :set_series, only: [:show, :find_episode, :download, :reanalyze]
  before_action :set_episode, only: [:show_episode_details, :download]

  RESULTS_PER_PAGE = 18

  def index
    paged
    @section = :series
    @series = Series.with_episodes.paginated(cur_page, RESULTS_PER_PAGE).order(title: :asc).all
  end

  def search
    paged
    query = "%#{params[:query]}%".downcase
    @section = :series
    @series = Series.paginated(cur_page, RESULTS_PER_PAGE).where('lower(title) like :q', q: query).to_a

    if cur_page == 0 && @series.size == 1
      response.headers['X-Next-Redirect'] = series_path(@series.first)
      head :found
      return
    end
    response.headers['X-XHR-Redirected-To'] = request.env['REQUEST_URI']
    render 'index'
  end

  def discover
    paged
    @section = :discover
    @series = Series.without_episodes.paginated(cur_page, RESULTS_PER_PAGE).all
    render 'remote'
  end

  def newest_episodes
    @section = :newest
    @shows = TvShow.local.newest.limit(50) # newest first
    render 'nonepisodic'
  end

  def newest_unwatched
    @section = :newest_unwatched
    @shows = TvShow.local.newest.unwatched.limit(50)
    render 'nonepisodic'
  end

  def nonepisodic
    @section = :nonepisodic
    @shows = TvShow.where(series_id: nil).all
  end

  def show
    @section = :series
    season = params[:season].presence || @series.last_season_filter.presence

    @season = if season == 'all'
      nil
    elsif season.present?
      season.to_i
    else
      nil
    end

    @sort = params[:sort].try(:to_sym) || @series.last_sort_value.try(:to_sym) || :release_order

    @series.update_attributes(last_sort_value: @sort.to_s, last_season_filter: @season.to_s)

    @all_episodes = @series.tv_shows.send(@sort)
    if @season
      @videos = @all_episodes.where(season: @season)
    else
      @videos = @all_episodes
    end

    @seasons = @all_episodes.map{|v| v.season}.uniq.sort
  end

  def show_episode_details
    @episode = TvShow.find(params[:episode_id])

    if @episode.local?
      render partial: 'episode', locals: {video: @episode, detailed: true}
    else
      if params[:query].present?
        @torrent_sources = EztvSearchResult.search(params[:query])
        @torrent_sources.reject! do |src|
          Torrent.exists?(source: src[:magnet_link]).present?
        end
      end
      render partial: 'remote_episode', locals: {video: @episode, detailed: true}
    end
  end

  def download
    service = TorrentManagerService.new
    service.download_tv_show(params[:download_url], @episode)

    show_episode_details
  end

  def reanalyze
    @series.reanalyze
    render json: {status: "ok"}
  end

  def discover_more
    SeriesDiscoveryWorker.perform_async
    redirect_to discover_series_index_path
  end

  private
    def paged
      @_is_paged = true
    end

    def cur_page
      page = params[:page].to_i || 0
    end

    def set_series
      @series = Series.find(params[:id])
    end

    def set_episode
      @episode = TvShow.find(params[:episode_id])
    end
end
