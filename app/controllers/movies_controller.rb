class MoviesController < ApplicationController
  before_action :set_movie, only: [
    :show,
    :find_sources,
    :destroy,
    :download,
    :override_imdb_id,
    :reanalyze,
    :favorite,
    :unfavorite
  ]

  RESULTS_PER_PAGE = 24

  def index
    @section = :all

    scope = Movie.order('random()')
    scope = alpha_filter_scope(scope)

    @prev_movie, @movies, @next_movie = paged(scope)
  end

  def show
    render 'show'
  end

  def search
    query = "%#{params[:query]}%".downcase
    scope = Movie.where('lower(title) like :q', q: query)

    @prev_movie, @movies, @next_movie = paged(scope)

    if @current_page == 0 && @movies.size == 1
      response.headers['X-Next-Redirect'] = movie_path(@movies.first)
      head :found
      return
    end
    response.headers['X-XHR-Redirected-To'] = request.env['REQUEST_URI']
  end

  def newest_unwatched
    @section = :newest_unwatched
    scope = Movie.local.newest.unwatched
    scope = alpha_filter_scope(scope)

    @prev_movie, @movies, @next_movie = paged(scope)
  end

  def newest
    @section = :newest
    scope = Movie.local_and_downloading.order(created_at: :desc)
    scope = alpha_filter_scope(scope)

    @prev_movie, @movies, @next_movie = paged(scope)
  end

  def discover
    @section = :discover
    scope = Movie.remote.order(created_at: :desc)
    scope = alpha_filter_scope(scope)

    @prev_movie, @movies, @next_movie = paged(scope)
    render 'discover'
  end

  def genres
    @section = :genres
    @genres = Genre.order(name: :asc).select { |genre| genre.has_local_movies? }
  end

  def genre
    @section = :genres
    @genre = Genre.find(params[:id])
    @movies = @genre.movies.all.to_a # TODO: figure out pagination here
  end

  def discover_more
    MoviesDiscoveryWorker.perform_async
    flash.now[:notice] = "Finding you more movies in the background"
    discover
  end

  def download
    service = TorrentManagerService.new
    service.download_movie(params[:download_url], @movie)
    redirect_to movie_path(@movie)
  end

  def find_sources
    @torrent_sources = TorrentFinderService.new(params[:query]).find
    @torrent_sources.reject! { |src| Torrent.exists?(source: src[:magnet_link]).present? }
    render partial: 'sources', locals: {sources: @torrent_sources}
  end

  def movie_search
    @query = params[:q]

    service = TmdbMovieSearchingService.new(@query)
    service.search_and_create

    redirect_to search_movies_path(query: @query)
  end

  def destroy
    @movie.delete_file!
    @movie.destroy
    redirect_to movies_path
  end

  def reanalyze
    @movie.reanalyze(true)
    if @movie.persisted? # it may have been deleted as a duplicate
      @movie.reload
    else
      existing_movie = Movie.find_by(tmdb_id: @movie.tmdb_id)
      response.headers['X-Next-Redirect'] = movie_path(existing_movie)
      head :ok
      return
    end

    flash.now[:notice] = "Movie reanalyzing, please check back for updates"
    show
  end

  def override_imdb_id
    unless @movie.update_attributes(imdb_id: params[:movie][:imdb_id]) # movie already exists, find it, and swap sources
      existing_movie = Movie.find_by(imdb_id: params[:movie][:imdb_id])
      @movie.sources.each do |source|
        source.update_attribute(:video_id, existing_movie.id)
      end

      existing_movie.reanalyze
      existing_movie.redownload

      response.headers['X-Next-Redirect'] = movie_path(existing_movie)
      head :ok
      return
    end

    @movie.reanalyze
    @movie.redownload

    show
  end

  def favorites
    @section = :favorites
    scope = Movie.favorites.order(title: :asc)
    scope = alpha_filter_scope(scope)

    @prev_movie, @movies, @next_movie = paged(scope)
  end

  def favorite
    @movie.update_attribute(:is_favorite, true)
    flash.now[:notice] = "This movie is now marked as a favorite!"
    show
  end

  def unfavorite
    @movie.update_attribute(:is_favorite, false)
    flash.now[:notice] = "This movie is no longer marked as a favorite."
    show
  end

  private

    def set_movie
      @movie = Movie.find(params[:id])
    end
end
