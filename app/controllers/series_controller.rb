class SeriesController < ApplicationController
  before_action :set_series, only: [:show]

  def index
    @series = Series.all
  end

  def show
    render layout: 'fullscreen'
  end

  private
    def set_series
      @series = Series.find(params[:id])
    end
end
