class MoviesDiscoveryWorker
  include Sidekiq::Worker
  sidekiq_options queue: :movies_discovery, retry: false

  def perform
    find_more
  end

  def query(page)
    remote_movies = KickassTorrentsListResult.get(page).results
    return 'error' if remote_movies.blank?

    remote_movies = remote_movies.select{ |r| r[:verified] }
    return 'error' if remote_movies.blank?

    results = []

    remote_movies.each do |m|
      guessed = Guesser::Movie.guess_from_string(m[:title])
      movie = Movie.new(
        title: guessed[:title],
        status: 'remote'
      )
      movie.imdb_id = movie.search_for_imdb_id

      if movie.imdb_id.present?
        movie.save
        results << movie.persisted?
      end
    end

    results.include?(true) ? 'created' : 'none-created'
  end

  def find_more
    (1..1000).each do |i|
      creation_status = query(i)
      break if creation_status == 'created' || creation_status == 'error'
    end
  end

end
