class SeriesController < ApplicationController
  before_action :set_series, only: [:show, :shuffle, :download, :reanalyze, :favorite, :unfavorite]
  before_action :set_episode, only: [:show_episode_details, :download]

  RESULTS_PER_PAGE = 48

  def index
    @section = :series
    scope = Series.local.order(title: :asc)
    scope = alpha_filter_scope(scope)

    @prev_series, @series, @next_series = paged(scope)
  end

  def search
    @section = :series
    query = "%#{params[:query]}%".downcase
    scope = Series.where('lower(title) like :q', q: query)
    scope = alpha_filter_scope(scope)
    @prev_series, @series, @next_series = paged(scope)

    if cur_page == 0 && @series.size == 1
      response.headers['X-Next-Redirect'] = series_path(@series.first)
      head :found
      return
    end
    response.headers['X-XHR-Redirected-To'] = request.env['REQUEST_URI']
    render 'search'
  end

  def discover
    @section = :discover
    scope = Series.alphabetical.without_episodes
    scope = alpha_filter_scope(scope)

    @prev_series, @series, @next_series = paged(scope)

    render 'discover'
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

  def favorites
    @section = :favorites
    scope = Series.favorites.order(title: :asc)
    scope = alpha_filter_scope(scope)

    @prev_series, @series, @next_series = paged(scope)
  end

  def genres
    @section = :genres
    @genres = Genre.order(name: :asc).select { |genre| genre.has_series? }
  end

  def genre
    @section = :genres
    name = Genre.normalized_name(params[:type])
    @genre = Genre.find_by(name: name)
    @series = @genre.series.all.to_a # TODO: figure out pagination here
  end

  def actor
    @section = :actor
    @actor = Actor.find(params[:actor])
    @series = @actor.series.all.to_a # TODO: figure out pagination here
  end

  def nonepisodic
    @section = :nonepisodic
    @shows = TvShow.where(series_id: nil).all
  end

  def show
    @section = if @series.is_favorite then :favorites else :series end
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

    @seasons = @all_episodes.map{|v| v.season}.uniq.compact.sort

    render 'show'
  end

  def shuffle
    random_episode_id = @series.tv_shows.local.try(:sample).try(:id)

    if random_episode_id.present?
      redirect_to show_source_video_path(random_episode_id, shuffle: true, series_id: @series.id)
    else
      redirect_to series_path(@series)
    end
  end

  def show_episode_details
    @episode = TvShow.find(params[:episode_id])

    if @episode.local?
      render partial: 'episode', locals: {video: @episode, detailed: true}
    else
      if params[:query].present?

        @torrent_sources = TorrentFinderService.new(params[:query]).find
        @torrent_sources.reject! do |src|
          Torrent.exists?(source: src[:magnet_link]).present?
        end
      end
      render partial: 'episode', locals: {video: @episode, detailed: true}
    end
  end

  def download
    service = TorrentManagerService.new
    service.download_tv_show(params[:download_url], @episode)

    show_episode_details
  end

  def favorite
    @series.update_attribute(:is_favorite, true)
    flash.now[:notice] = "This series is now marked as a favorite!"
    show
  end

  def unfavorite
    @series.update_attribute(:is_favorite, false)
    flash.now[:notice] = "This series is no longer marked as a favorite."
    show
  end

  def reanalyze
    SeriesAnalyzerWorker.perform_async(@series.id)
    flash.now[:notice] = "Re-analyzing series in the background"
    show
  end

  def discover_more
    SeriesDiscoveryWorker.perform_async
    flash.now[:notice] = "Finding you more series in the background"
    discover
  end

  private

    def paged(scope)
      @_is_paged = true
      @current_page = cur_page
      @next_page = cur_page + 1
      @prev_page = cur_page - 1

      prev_offset = (@current_page * RESULTS_PER_PAGE) - 1
      next_offset = (@current_page * RESULTS_PER_PAGE) + RESULTS_PER_PAGE

      prev_resource = scope.limit(1).offset(prev_offset).first if prev_offset > 0
      next_resource = scope.limit(1).offset(next_offset).first if next_offset > 0
      current_resources = scope.paginated(@current_page, RESULTS_PER_PAGE).to_a

      [prev_resource, current_resources, next_resource]
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
