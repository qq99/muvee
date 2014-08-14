class AddImagesToSeries < ActiveRecord::Migration
  def change
    add_column :series, :poster_path, :string
    add_column :series, :banner_path, :string
    add_column :series, :fanart_path, :string
  end
end
