class TvShowSource < Source
  def reanalyze
    super
    guessed = Guesser::TvShow.guess_from_filepath(raw_file_path)
    self.quality = guessed[:quality]
    self.is_3d = guessed[:three_d]
    self.save
  end
end
