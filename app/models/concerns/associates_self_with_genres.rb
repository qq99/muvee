module AssociatesSelfWithGenres

  def associate_self_with_genres(genre_names)
    return unless genre_names.size > 0

    genres = genre_names
      .compact
      .map(&:strip)
      .map(&:titleize)
      .uniq
      .reject(&:blank?)
      .map{|g| Genre.normalized_name(g) }

    self.genres = []

    genres.each do |genre_name|
      existing_genre = Genre.where(name: genre_name).first
      new_genre = Genre.new(name: genre_name) unless existing_genre.present?
      genre = existing_genre || new_genre

      self.genres << genre if genre.present?
    end

    self.save
  end
end
