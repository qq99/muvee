class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :find_sources]

  def index
    @movies = Movie.local.all.shuffle
  end

  def three_d
    @movies = Movie.local.where(is_3d: true).all
    render 'index'
  end

  def two_d
    @movies = Movie.local.where(is_3d: false).all
    render 'index'
  end

  def newest
    @movies = Movie.local.order(created_at: :desc).all
    render 'index'
  end

  def remote
    @query = params[:page].try(:to_i) || 0
    @movies = Movie.remote.order(created_at: :desc).all
  end

  def discover_more
    YtsQueryService.find_more
    redirect_to remote_movies_path
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
