class AddTvShowsCounterCacheToSeries < ActiveRecord::Migration
  def self.up
    add_column :series, :tv_shows_count, :integer, default: 0

    Series.reset_column_information
    Series.all.each do |s|
      s.update_attribute :tv_shows_count, s.tv_shows.count
    end
  end

  def self.down
    remove_column :series, :tv_shows_count
  end
end
