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
    ChronicDuration.output(future_time - Time.now, days: true, units: 2, joiner: ', ', format: :long)
  end

  def days_from_now(future_time)
    ChronicDuration.output(future_time - Time.now, days: true, units: 1, format: :long)
  end

  def effective_video_path(video)
    if video.left_off_at_percent > 90
      show_source_video_path(video, t: 0)
    else
      show_source_video_path(video)
    end
  end

  def days_ago(past_time)
    ChronicDuration.output(Time.now - past_time, days: true, units: 1, format: :long)
  end

  def year_month_day(time)
    time.try(:strftime, '%Y-%m-%d')
  end
end
