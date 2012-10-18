class ChangeMultipleColumns < ActiveRecord::Migration
  def change
	  change_column_null :events, :max, 1000000
	  change_column_null :suggestions, :max, 1000000
	  change_column_default :relationships, :confirmed, false
  end
end
