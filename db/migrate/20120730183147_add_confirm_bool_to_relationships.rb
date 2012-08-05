class AddConfirmBoolToRelationships < ActiveRecord::Migration
  def change
  	add_column :relationships, :confirmed, :boolean
  end
end
