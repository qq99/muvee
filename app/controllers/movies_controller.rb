class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :find_sources]

  def index
    @movies = Movie.local.all
#    render layout: 'fullscreen'
  end

  def remote
    @movies = Movie.remote.all
  end

  def find_sources
    @sources = TorrentManagerService.find_sources(@movie)
    render partial: 'source_options', locals: {sources: @sources}
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])
    end
end
