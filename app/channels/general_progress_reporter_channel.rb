class GeneralProgressReporterChannel < ApplicationCable::Channel
  def subscribed
    stream_from "progress_reports"
  end
end
