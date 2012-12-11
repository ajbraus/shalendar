class AddBigIdeaBoolToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :is_big_idea, :boolean
  end
end
