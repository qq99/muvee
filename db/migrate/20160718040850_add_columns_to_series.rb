class AddColumnsToSeries < ActiveRecord::Migration[5.0]
  def change

    add_column :series, :imdb_id, :string
    add_column :series, :freebase_id, :string
    add_column :series, :freebase_mid, :string
    add_column :series, :tvrage_id, :string
    add_column :series, :website, :string
    add_column :series, :popularity, :float
    add_column :series, :country, :string
    add_column :series, :language, :string
    add_column :series, :first_air_date, :date
    add_column :series, :last_air_date, :date
    add_column :series, :ended, :boolean
    add_column :series, :content_rating, :string
  end
end
