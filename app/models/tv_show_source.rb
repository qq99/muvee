class TvShowSource < Source
  def reanalyze
    source_exists = super
    return unless source_exists
    if self.video.present? && self.video.title.blank?
      self.video.title = effective_tv_show_title
      self.video.save
    end
    self.quality = guessed[:quality]
    self.is_3d = guessed[:three_d]
    self.save
  end
end
