class YtsQueryService
  def self.query(page)
    query = YtsListResult.get(page).data
    remote_movies = query[:MovieList]

    results = []
    remote_movies.each do |m|
      results << Movie.create(
        status: "remote",
        title: m[:MovieTitleClean],
        imdb_id: m[:ImdbCode]
      )
    end

    results
  end
end
