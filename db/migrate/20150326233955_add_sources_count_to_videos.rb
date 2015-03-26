class AddSourcesCountToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :sources_count, :integer, default: 0

    Video.reset_column_information
    Video.all.each do |v|
      Video.reset_counters(v.id, :sources)
    end
  end

  def self.down
    remove_column :videos, :sources_count
  end
end
