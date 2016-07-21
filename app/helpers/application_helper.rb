module ApplicationHelper

  def app_name
    "μv"
  end

  def human_duration(seconds)
    ChronicDuration.output(seconds, format: :chrono)
  end

  def of_N_stars(rating, rating_max, new_scale)
    rating = rating.to_f
    ratio = rating / rating_max.to_f
    of_five = ratio * new_scale
    full_stars = of_five.floor
    half_stars = (of_five - full_stars) >= 0.5 ? 1 : 0
    empty_stars = new_scale - full_stars - half_stars
    [full_stars, half_stars, empty_stars]
  end

  def imdb_link(imdb_id)
    "http://www.imdb.com/title/#{imdb_id}"
  end

  def tmdb_link(tmdb_id)
    "https://www.themoviedb.org/movie/#{tmdb_id}"
  end

  def released_on_human(released_on)
    if released_on
      released_on.strftime("%Y-%m-%d")
    else
      ''
    end
  end

  def runtime_human(duration = nil, minutes = nil)
    if duration.blank? && minutes.blank?
      "Unknown"
    else
      ChronicDuration.output(duration || (minutes * 60), format: :chrono)
    end
  end

  def airs_on_time(release_date)
    if release_date == release_date.beginning_of_day
      release_date = release_date.end_of_day # data marks released_on as start of day, but that's not great for comparisons to now
    end

    if Time.now.to_date == release_date.to_date
      "today"
    elsif release_date < Time.current + 1.week
      "next #{release_date.strftime('%A')}"
    else
      "in #{distance_of_time_in_words(release_date, Time.now)}"
    end
  end

  def airs_on_summary(release_date)
    if release_date == release_date.beginning_of_day
      release_date = release_date.end_of_day # data marks released_on as start of day, but that's not great for comparisons to now
    end

    if release_date < Time.now
      "Aired #{year_month_day(release_date)} (#{distance_of_time_in_words(release_date, Time.now)} ago)."
    else
      "Airs #{year_month_day(release_date)} (in #{distance_of_time_in_words(release_date, Time.now)})."
    end
  end

  def number_of_released_episodes_unacquired(series)
    most_recently_sourced = series.tv_shows.local.latest.first

    return nil unless most_recently_sourced
    unacquired = series.tv_shows.remote
      .where('(season = ? AND episode > ?) OR (season > ?)', most_recently_sourced.season, most_recently_sourced.episode, most_recently_sourced.season)
      .where('(released_on > ?)', most_recently_sourced.released_on)
      .where('released_on < ?', Time.now.utc).count
  end

  def effective_video_path(video)
    if video.left_off_at_percent > 90
      show_source_video_path(video, t: 0)
    else
      show_source_video_path(video)
    end
  end

  def year_month_day(time)
    time.try(:strftime, '%Y-%m-%d')
  end

  def control_hue_lights?
    Rails.configuration.control_hue_lights
  end

  def control_transmission?
    Rails.configuration.control_transmission
  end
end
