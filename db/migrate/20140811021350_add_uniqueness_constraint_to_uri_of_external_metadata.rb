class AddUniquenessConstraintToUriOfExternalMetadata < ActiveRecord::Migration
  def change
    add_index :external_metadata, [:uri], :unique => true
  end
end
