class MakingIsBigIdeaDefaultFalse < ActiveRecord::Migration
  def change
  	remove_column :events, :is_big_idea
  end

end
