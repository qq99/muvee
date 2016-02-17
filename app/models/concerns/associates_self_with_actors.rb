module AssociatesSelfWithActors

  def associate_self_with_actors(actor_names)
    return unless actor_names.size > 0

    names = actor_names
      .compact
      .map(&:strip)
      .map(&:titleize)
      .uniq
      .reject(&:blank?)

    self.actors = []

    names.each do |actor_name|
      existing_actor = Actor.where(name: actor_name).first
      new_actor = unless existing_actor.present?
        actor = Actor.new(name: actor_name)
        tmdb_id = actor.fetch_tmdb_person_id
        tmdb_id.present? ? actor : nil
      end # NB: this rejects actors we can't find!
      actor = existing_actor || new_actor

      self.actors << actor if actor.present?
    end

    self.save
  end
end
