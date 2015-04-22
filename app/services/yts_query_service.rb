class YtsQueryService
  def self.query(page)
    query = YtsListResult.get(page).data
    remote_movies = query[:data][:movies]
    return ["error"] if remote_movies.blank?

    results = []
    remote_movies.each do |m|
      if Movie.exists?(imdb_id: m[:imdb_code])
        results << false
      else
        movie = Movie.create(
          status: "remote",
          title: m[:title],
          imdb_id: m[:imdb_code]
        )
        results << movie.persisted?
      end
    end

    results
  end

  def self.find_more
    (0..1000).each do |i|
      creation_status = YtsQueryService.query(i)
      break if creation_status.include?(true) || creation_status.include?("error")
    end
  end
end
