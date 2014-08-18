class MoviesController < ApplicationController
  before_action :set_movie, only: [:show]

  def index
    @movies = Movie.all
  end

  private
    def set_movie
      @series = Movie.find(params[:id])
    end
end
