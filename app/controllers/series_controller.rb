class SeriesController < ApplicationController
  before_action :set_series, only: [:show, :find_episode, :download, :reanalyze]
  before_action :set_episode, only: [:show_episode_details, :download]

  def index
    @section = :series
    @series = Series.with_episodes.all.sort_by{|item| -item.updated_at.to_i} # newest updated first
  end

  def discover
    @section = :discover
    @series = Series.without_episodes.all
    render 'index'
  end

  def discover_series
    SeriesDiscoveryWorker.perform_async
  end

  def newest_episodes
    @section = :newest
    @shows = TvShow.newest.limit(50) # newest first
    render 'nonepisodic'
  end

  def newest_unwatched
    @section = :newest_unwatched
    @shows = TvShow.newest.unwatched.limit(50)
    render 'nonepisodic'
  end

  def nonepisodic
    @section = :nonepisodic
    @shows = TvShow.where(series_id: nil).all
  end

  def show
    @season = params[:season].present? ? params[:season].to_i : nil
    @sort = params[:sort].try(:to_sym) || :release_order
    @all_episodes = @series.tv_shows.send(@sort)
    if @season
      @videos = @all_episodes.where(season: @season)
    else
      @videos = @all_episodes
    end

    if @all_episodes.present?
      by_season_and_episode = @videos.sort_by{ |e| e.season * 1000 + e.episode }
      latest = by_season_and_episode.last
      @next_episode = TvShow.format_season_and_episode(latest.season, latest.episode + 1)
      @next_episode_of_next_season = TvShow.format_season_and_episode(latest.season + 1, 1)
    else
      @next_episode = "S1 E1"
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

  private
    def set_series
      @series = Series.find(params[:id])
    end

    def set_episode
      @episode = TvShow.find(params[:episode_id])
    end
end
