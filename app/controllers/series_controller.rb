class SeriesController < ApplicationController
  before_action :set_series, only: [:show]

  def index
    @series = Series.all
  end

  def show
    @sort = params[:sort].try(:to_sym) || :latest
    @videos = @series.tv_shows.send(@sort)
    @seasons = @videos.map{|v| v.season}.uniq.sort
    render layout: 'fullscreen'
  end

  private
    def set_series
      @series = Series.find(params[:id])
    end
end
