class AddUriToExternalMetadata < ActiveRecord::Migration
  def change
    add_column :external_metadata, :uri, :string
  end
end
