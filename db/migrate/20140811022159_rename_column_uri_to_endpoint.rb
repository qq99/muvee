class RenameColumnUriToEndpoint < ActiveRecord::Migration
  def change
    rename_column :external_metadata, :uri, :endpoint
  end
end
