class ChangeMultipleColumns < ActiveRecord::Migration
  def change
	  change_column_default :relationships, :confirmed, false
  end
end
