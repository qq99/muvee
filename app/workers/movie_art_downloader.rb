class MovieArtDownloader
  include Sidekiq::Worker

  def perform(id)
    movie = Movie.find(id.to_i)
    movie.download_fanart
  end
end
