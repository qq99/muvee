class ImdbSearchResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(title)
    "http://www.imdb.com/xml/find?json=1&nr=1&tt=on&q=#{title}"
  end

  def relevant_result(title)
    list = self.data[:title_popular] || self.data[:title_exact] || self.data[:title_substring] || self.data[:title_approximate]

    best_results = if list.any?
      by_ldistance(list, :title, title) if list.any?
    else
      []
    end

    best_results.first
  end

  def by_ldistance(list, field, ideal)
    list.sort_by{|entry| Ldistance.compute(entry[field], ideal)}
  end
end
