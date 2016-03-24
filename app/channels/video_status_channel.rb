class VideoStatusChannel < ApplicationCable::Channel
  def set_left_off_at(data)
    Video.where(id: data["video_id"])
      .update_all(left_off_at: data["left_off_at"])
  end
end
