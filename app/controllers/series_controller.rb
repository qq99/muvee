class SeriesController < ApplicationController
  before_action :set_series, only: [:show]

  def index
    @series = Series.all.sort_by{|item| -item.updated_at.to_i} # newest updated first
  end

  def newest_episodes
    @shows = TvShow.all.sort_by{|item| -item.created_at.to_i} # newest first
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
    @seasons = @all_episodes.map{|v| v.season}.uniq.sort
    render layout: 'fullscreen'
  end

  private
    def set_series
      @series = Series.find(params[:id])
    end
end
