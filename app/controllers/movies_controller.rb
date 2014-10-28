class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :find_sources_via_yts, :download, :find_sources_via_pirate_bay]
  before_action :set_existing_copies, only: [:show, :find_sources_via_yts, :find_sources_via_pirate_bay]

  def index
    @movies = Movie.local.all.shuffle
  end

  def show
    if @movie.remote?
      @sources = TorrentManagerService.find_sources(@movie)

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
    @movies = Movie.remote.order(created_at: :desc).limit(50).all
  end

  def genres
    @genres = Genre.all.sort_by(&:name).reject { |genre| genre.videos.length == 0 }
  end

  def genre
    name = Genre.normalized_name(params[:type])
    @genre = Genre.find_by(name: name)
    @movies = @genre.videos.movies.all
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

  def find_sources_via_yts
    @query = params[:q]
    @sources = TorrentManagerService.find_sources(@movie)
    render partial: 'yts_sources', locals: {sources: @sources}
  end

  def find_sources_via_pirate_bay
    @query = params[:q]
    @results = ThePirateBay::Search.new(@query, 0, ThePirateBay::SortBy::Seeders, ThePirateBay::Category::Video).results
    render partial: 'shared/pirate_bay_sources', locals: {sources: @results, video: @movie, download_path: download_movie_path(@movie)}
  end

  def movie_search
    @query = params[:q]
    query = ImdbSearchResult.get(@query)
    results = query.relevant_results(@query)
    @movies = []

    results.each do |result|
      movie = Movie.find_by(imdb_id: result[:imdbID])
      movie ||= Movie.create(
        status: "remote",
        title: result[:Title],
        imdb_id: result[:imdbID],
        imdb_id_is_accurate: true
      )
      @movies << movie
    end
    @movies = @movies.compact.reject{ |m| m.id.blank? }

    render 'remote'
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])
    end

    def set_existing_copies
      @torrents = @movie.torrents.all
      @existing_copies = Movie.local.where(imdb_id: @movie.fetch_imdb_id)
    end
end
