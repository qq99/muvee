class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :find_sources_via_yts, :destroy, :download, :find_sources_via_pirate_bay, :override_imdb_id, :reanalyze]

  RESULTS_PER_PAGE = 24

  def index
    all
  end

  def search
    query = "%#{params[:query]}%".downcase
    @movies = Movie.paginated(cur_page, RESULTS_PER_PAGE).where('lower(title) like :q', q: query).to_a

    if cur_page == 0 && @movies.size == 1
      response.headers['X-Next-Redirect'] = movie_path(@movies.first)
      head :found
      return
    end
    response.headers['X-XHR-Redirected-To'] = request.env['REQUEST_URI']
    render 'index2'
  end

  def all
    @section = :all

    scope = Movie.paginated(cur_page, RESULTS_PER_PAGE).order('random()')

    @prev_movie, @movies, @next_movie = paged(scope)

    if @movies.size > 0
      render 'index2', locals: {paginator_path: self.method(:all_movies_path)}
    else
      head :not_found
    end
  end

  def newest
    @section = :newest
    scope = Movie.local_and_downloading.order(created_at: :desc)

    @prev_movie, @movies, @next_movie = paged(scope)

    if @movies.size > 0
      render 'index2', locals: {paginator_path: self.method(:newest_movies_path)}
    else
      head :not_found
    end
  end

  def remote
    @section = :discover
    scope = Movie.remote.order(created_at: :desc)

    @prev_movie, @movies, @next_movie = paged(scope)

    if @movies.size > 0
      render 'remote', locals: {paginator_path: self.method(:remote_movies_path)}
    else
      head :not_found
    end
  end

  def genres
    @section = :genres
    @genres = Genre.order(name: :asc).select { |genre| genre.has_local_movies? }
  end

  def genre
    @section = :genres
    name = Genre.normalized_name(params[:type])
    @genre = Genre.find_by(name: name)
    @movies = @genre.movies.all.to_a # TODO: figure out pagination here
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
    @torrents = Torrent.all
    render partial: 'yts_sources', locals: {sources: @sources}
  end

  def find_sources_via_pirate_bay
    @query = params[:q]
    @results = ThePirateBay::Search.new(@query, 0, ThePirateBay::SortBy::Seeders, ThePirateBay::Category::Video).results
    @results.reject! do |result|
      result[:seeders] == 0
    end
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
        imdb_id: result[:imdbID]
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

    render 'show'
  end

  private

    def paged(scope)
      @_is_paged = true
      @current_page = cur_page
      @next_page = cur_page + 1
      @prev_page = cur_page - 1

      prev_offset = (@current_page * RESULTS_PER_PAGE) - 1
      next_offset = (@current_page * RESULTS_PER_PAGE) + RESULTS_PER_PAGE

      prev_resource = scope.limit(1).offset(prev_offset).first if prev_offset > 0
      next_resource = scope.limit(1).offset(next_offset).first if next_offset > 0
      current_resources = scope.paginated(@current_page, RESULTS_PER_PAGE).to_a

      [prev_resource, current_resources, next_resource]
    end

    def cur_page
      page = params[:page].to_i || 0
    end

    def set_movie
      @movie = Movie.find(params[:id])
    end
end
