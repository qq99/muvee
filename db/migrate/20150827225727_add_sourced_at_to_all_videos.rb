class AddSourcedAtToAllVideos < ActiveRecord::Migration
  def up
    Video.all.each do |video|
      if video.sources.present?
        video.sourced_at = video.sources.first.created_at
        video.save
      end
    end
  end

  def down; end
end
