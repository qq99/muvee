module ApplicationHelper
  def human_duration(seconds)
    ChronicDuration.output(seconds, format: :chrono)
  end
end
