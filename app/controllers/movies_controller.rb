class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :find_sources_via_yts, :destroy, :download, :find_sources_via_pirate_bay, :override_imdb_id, :reanalyze]
  before_action :set_existing_copies, only: [:show, :find_sources_via_yts, :find_sources_via_pirate_bay]

  RESULTS_PER_PAGE = 24

  def index
    newest
  end

  def all
    @section = :all
    @movies = Movie.local_and_downloading.shuffle.to_a
    render 'index2'
  end

  def show

  end

  def three_d
    @section = :threed
    @movies = Movie.local.where(is_3d: true).all
    render 'index'
  end

  def two_d
    @section = :twod
    @movies = Movie.local.where(is_3d: false).all
    render 'index'
  end

  def newest
    @section = :newest
    @movies = paginated_movies.local_and_downloading.order(created_at: :desc).all.to_a

    if @movies.size > 0
      render 'index2'
    else
      head :not_found
    end
  end

  def remote
    @section = :discover
    #@genres = Genre.all.sort_by(&:name).reject { |genre| genre.videos.length == 0 }
    @movies = paginated_movies.remote.order(created_at: :desc).to_a

    if @movies.size > 0
      render 'remote'
    else
      head :not_found
    end
  end

  def genres
    @section = :genres
    @genres = Genre.all.sort_by(&:name).select { |genre| genre.has_local_movies? }
  end

  def genre
    @section = :genres
    name = Genre.normalized_name(params[:type])
    @genre = Genre.find_by(name: name)
    @movies = @genre.videos.movies.all.to_a
    render 'index2'
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

  def destroy
    @movie.delete_file!
    @movie.destroy
    redirect_to movies_path
  end

  def reanalyze
    @movie.reanalyze

    render 'show'
  end

  def override_imdb_id
    @movie.update_attributes(imdb_id: params[:movie][:imdb_id], imdb_id_is_accurate: true)
    @movie.reanalyze
    @movie.redownload

    render 'show'
  end

  private
    def paginated_movies
      page = params[:page].to_i || 0
      Movie.limit(RESULTS_PER_PAGE).offset(page * RESULTS_PER_PAGE)
    end

    def set_movie
      @movie = Movie.find(params[:id])
    end

    def set_existing_copies
      @torrents = @movie.torrents.all
      @existing_copies = Movie.local.where(imdb_id: @movie.fetch_imdb_id)
    end
end
