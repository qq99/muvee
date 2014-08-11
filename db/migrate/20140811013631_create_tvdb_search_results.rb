class CreateTvdbSearchResults < ActiveRecord::Migration
  def change
    create_table :tvdb_search_results do |t|

      t.timestamps
    end
  end
end
