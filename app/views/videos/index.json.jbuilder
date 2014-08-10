json.array!(@videos) do |video|
  json.extract! video, :id, :raw_file_path, :type, :episode, :season, :duration, :left_off_at, :series_id
  json.url video_url(video, format: :json)
end
