class Actor < ActiveRecord::Base
  has_many :actors_videos
  has_many :videos, through: :actors_videos
  has_many :movies, -> { where(videos: {type: 'Movie'}) }, through: :actors_videos, source: :video
  has_many :tv_shows, -> { where(videos: {type: 'TvShow'}) }, through: :actors_videos, source: :video

  has_many :fanarts, dependent: :destroy
  has_one :profile_picture_fanart

  after_create :extract_metadata

  # before_validation :sanitize_name
  validates :name, presence: true, uniqueness: {case_sensitive: true}

  def has_movies?
    movies.count > 0
  end

  def has_local_movies?
    movies.local.count > 0
  end

  def has_tv_shows?
    tv_shows.count > 0
  end

  def fetch_tmdb_person_id
    search_results = TmdbPersonSearchResult.get(name)
    results = search_results.data["results"]

    results.select!{|entry| entry['name'] == name} # filter list to exact matches
    result = results.first
    profile = result.try(:[], 'profile_path')
    id = result.try(:[], 'id')
    @profile_pic = "http://image.tmdb.org/t/p/original/#{profile}" if profile.present?
    id
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
      if @profile_pic.present? && profile_picture_fanart.blank?
        self.fanarts << ProfilePictureFanart.create(remote_location: @profile_pic)
      end
      self.save
    end
  end

  def reanalyze
    extract_metadata
  end

  def query_tmdb_images
    # return [] if fetch_imdb_id.blank?

    # images_result = TmdbImageResult.get(fetch_imdb_id).data
    # posters = images_result[:posters]
    # posters = posters.map do |poster|
    #   path = poster.try(:[], :file_path)
    #   if path
    #     path.gsub!(/^\//, '') # trim beginning slash
    #     "http://image.tmdb.org/t/p/original/#{path}"
    #   else
    #     nil
    #   end
    # end
    # posters
  end

  # def self.normalized_name(name)
  #   name = name.strip.titleize
  #   SAME_THINGS.each do |key, val|
  #     name = val if name.downcase == key
  #   end
  #   name
  # end
  #
  # def sanitize_name
  #   self.name = Genre.normalized_name(name)
  # end
end
