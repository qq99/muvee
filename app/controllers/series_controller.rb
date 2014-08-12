class SeriesController < ApplicationController
  def index
    @series = Series.all
  end
end
