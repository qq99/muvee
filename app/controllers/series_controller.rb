class SeriesController < ApplicationController
  before_action :set_series, only: [:show, :find_episode, :download]

  def index
    @series = Series.all.sort_by{|item| -item.updated_at.to_i} # newest updated first
  end

  def newest_episodes
    @shows = TvShow.all.limit(50).sort_by{|item| -item.created_at.to_i} # newest first
    render 'nonepisodic'
  end

  def newest_unwatched
    @shows = TvShow.all.limit(50).sort_by{|item| -item.created_at.to_i}.reject{|item| item.left_off_at != nil}.take(6*6)
    render 'nonepisodic'
  end

  def nonepisodic
    @shows = TvShow.where(series_id: nil).all
  end

  def show
    @season = params[:season].present? ? params[:season].to_i : nil
    @sort = params[:sort].try(:to_sym) || :latest
    @all_episodes = @series.tv_shows.send(@sort)
    if @season
      @videos = @all_episodes.where(season: @season)
    else
      @videos = @all_episodes
    end

    by_season_and_episode = @all_episodes.sort_by{ |e| e.season * 1000 + e.episode }
    latest = by_season_and_episode.last
    @next_episode = TvShow.format_season_and_episode(latest.season, latest.episode + 1)
    @next_episode_of_next_season = TvShow.format_season_and_episode(latest.season + 1, 1)

    @seasons = @all_episodes.map{|v| v.season}.uniq.sort
    render layout: 'fullscreen'
  end

  def find_episode
    series_episode = params[:series_episode]
    @query = @series.title + " " + series_episode
    @results = EztvSearchResult.search(@query).first(20)
    render partial: 'find_episode', locals: {sources: @results, download_path: download_series_path(@series) }
  end

  def download
    service = TorrentManagerService.new
    service.download_tv_show(params[:download_url])
    redirect_to series_path(@series)
  end

  private
    def set_series
      @series = Series.find(params[:id])
    end
end
