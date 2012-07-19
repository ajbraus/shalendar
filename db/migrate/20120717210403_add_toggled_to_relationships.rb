class AddToggledToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :toggled, :boolean, :default => true
  end
end
