class AddFieldsToActor < ActiveRecord::Migration
  def change
    add_column :actors, :tmdb_person_id, :string
    add_column :actors, :imdb_id, :string
    add_column :actors, :bio, :text
    add_column :actors, :place_of_birth, :string
    add_column :actors, :birthday, :date
  end
end
