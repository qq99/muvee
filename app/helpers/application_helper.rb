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
end
