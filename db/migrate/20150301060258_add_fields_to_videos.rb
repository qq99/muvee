class AddFieldsToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :tagline, :text
    add_column :videos, :vote_count, :integer
    add_column :videos, :vote_average, :decimal
    add_column :videos, :parental_guidance_rating, :string
    add_column :videos, :runtime_minutes, :integer
  end
end
