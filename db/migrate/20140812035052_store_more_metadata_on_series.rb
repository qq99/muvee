class StoreMoreMetadataOnSeries < ActiveRecord::Migration
  def change
    add_column :series, :overview, :string
    add_column :series, :tvdb_rating, :decimal
    add_column :series, :tvdb_rating_count, :integer
    add_column :series, :status, :string
  end
end
