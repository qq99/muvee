class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :find_sources, :download]

  def index
    @movies = Movie.local.all.shuffle
  end

  def show
    if @movie.remote?
      @sources = TorrentManagerService.find_sources(@movie)
      @torrents = @movie.torrents.all
      @existing_copies = Movie.local.where(imdb_id: @movie.fetch_imdb_id)
    end
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
    @movies = Movie.remote.order(created_at: :desc).limit(50).all
  end

  def genres
    @genres = Genre.all.sort_by(&:name).reject { |genre| genre.videos.local.length == 0 }
  end

  def genre
    name = Genre.normalized_name(params[:type])
    @genre = Genre.find_by(name: name)
    @movies = @genre.videos.movies.local.all
    render 'index'
  end

  def discover_more
    YtsQueryService.find_more
    redirect_to remote_movies_path
  end

  def download
    service = TorrentManagerService.new
    service.download_movie(params[:download_url], @movie)
    redirect_to movie_path(@movie)
  end

  def find_sources
    @sources = TorrentManagerService.find_sources(@movie)
    render partial: 'source_options', locals: {sources: @sources}
  end

  def movie_search
    @query = params[:q]
    query = ImdbSearchResult.get(@query)
    results = query.best_results(@query)
    @movies = []

    results.each do |result|
      movie = Movie.find_by_imdb_id(result[:id]) || Movie.create(
        status: "remote",
        title: result[:title],
        imdb_id: result[:id]
      )
      @movies << movie
    end
    @movies.compact!

    render 'remote'
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])
    end
end
