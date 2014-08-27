class MoviesController < ApplicationController
  before_action :set_movie, only: [:show]

  def index
    @movies = Movie.local.all
#    render layout: 'fullscreen'
  end

  def remote
    @movies = Movie.remote.all
  end

  private
    def set_movie
      @series = Movie.find(params[:id])
    end
end
