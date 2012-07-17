class AddToggledToRelationships < ActiveRecord::Migration
  def change
    change_column :relationships, :toggled, :boolean, :default => true
  end
end
