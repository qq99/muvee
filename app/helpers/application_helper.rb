module ApplicationHelper
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
    "http://www.imdb.com/title/#{imdb_id}/"
  end

  def released_on_human(released_on)
    if released_on
      released_on.strftime("%Y %b %-d")
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

  def expected_release_from_now(future_time)
    ChronicDuration.output(future_time - Time.now, days: true, units: 2, joiner: ', ')
  end
end
