class Actor < ActiveRecord::Base
  include HasVideo

  has_many :actors_videos
  has_videos(through: :actors_videos)
  has_many :actors_series
  has_many :series, through: :actors_series

  has_many :fanarts, dependent: :destroy
  has_one :profile_picture_fanart

  after_create :extract_metadata

  validates :name, presence: true, uniqueness: {case_sensitive: true}

  def fetch_tmdb_person_id
    search_results = TmdbPersonSearchResult.get(name)
    results = search_results.data["results"]
    return nil if results.blank?

    # TODO: should be sorting by ascending Ldistance, maybe even the popularity stat
    results.select! do |entry|
      Ldistance.compute(entry['name'].downcase, name.downcase) <= 3
    end # filter list to very close matches
    result = results.first
    id = result.try(:[], 'id')
    id
  end

  def generate_profile_url(profile_slug)
    File.join("http://image.tmdb.org/t/p/original/", profile_slug).to_s
  end

  def extract_metadata
    tmdb_id = fetch_tmdb_person_id
    if tmdb_id.present?
      tmdb_result = TmdbPersonResult.get(tmdb_id)

      self.birthday = Date.parse(tmdb_result.data[:birthday]) if tmdb_result[:birthday].present?
      self.deathday = Date.parse(tmdb_result.data[:deathday]) if tmdb_result[:deathday].present?
      self.bio = tmdb_result.data[:biography]
      self.aliases = tmdb_result.data[:also_known_as]
      self.tmdb_person_id = tmdb_id
      self.imdb_id = tmdb_result.data[:imdb_id]
      self.place_of_birth = tmdb_result.data[:place_of_birth]

      profile_path = tmdb_result.data[:profile_path]

      if profile_path.present? && profile_picture_fanart.blank?
        self.fanarts << ProfilePictureFanart.create(
          remote_location: generate_profile_url(profile_path)
        )
      end
      self.save
    end
  end

  def reanalyze
    extract_metadata
  end

end
