class ImdbSearchResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(title)
    "http://www.imdb.com/xml/find?json=1&nr=1&tt=on&q=#{title}"
  end

  def best_results(title)
    list = (data[:title_popular] || []) + (data[:title_exact] || []) + (data[:title_substring] || []) + (data[:title_approximate] || [])

    best_results = if list && list.length > 0
      by_ldistance(list, :title, title) if list.any?
    else
      []
    end
  end

  def relevant_result(title)
    full_results = best_results(title).first(10).map do |result|
      OmdbSearchResult.get(result[:id]).data
    end

    # use vote count as a gauge of popularity / correctness of match
    full_results_by_votes = full_results.sort_by do |result|
      -(result[:imdbVotes] || 0).gsub(/\D/, '').to_f
    end

    full_results_by_votes.first.try(:[], :imdbID)
  end

  def by_ldistance(list, field, ideal)
    list.sort_by{|entry| Ldistance.compute(entry[field], ideal)}
  end
end
