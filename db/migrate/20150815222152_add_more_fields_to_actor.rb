class AddMoreFieldsToActor < ActiveRecord::Migration
  def change
    add_column :actors, :deathday, :date
    add_column :actors, :homepage, :string
    add_column :actors, :aliases, :text, array: true, default: []
  end
end
