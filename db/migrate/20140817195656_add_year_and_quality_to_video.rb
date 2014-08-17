class AddYearAndQualityToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :year, :integer
    add_column :videos, :quality, :string
  end
end
