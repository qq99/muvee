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
    best_results(title).first
  end

  def by_ldistance(list, field, ideal)
    list.sort_by{|entry| Ldistance.compute(entry[field], ideal)}
  end
end
