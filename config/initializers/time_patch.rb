#http://stackoverflow.com/questions/449271/how-to-round-a-time-down-to-the-nearest-15-minutes-in-ruby
class Time
  def floor(seconds = 60)
    Time.at((self.to_f / seconds).floor * seconds)
  end
end
