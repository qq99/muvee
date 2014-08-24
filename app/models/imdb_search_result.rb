class ImdbSearchResult < ExternalMetadata

  def result_format
    :json
  end

  def self.endpoint_url(title)
    "http://www.imdb.com/xml/find?json=1&nr=1&tt=on&q=#{title}"
  end

  def relevant_result(title)
    best_results = nil

    if popular_titles = self.data[:title_popular]
      best_results = by_ldistance(popular_titles, :title, title)
    else
      if approximate_titles = self.data[:title_approx]
        best_results = by_ldistance(approximate_titles, :title, title)
      end
    end

    if best_results.blank?
      nil
    else
      best_results.first
    end
  end

  def by_ldistance(list, field, ideal)
    list.sort_by{|entry| Ldistance.compute(entry[field], ideal)}
  end
end
