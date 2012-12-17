class MakingIsBigIdeaDefaultFalse < ActiveRecord::Migration
  def change
  	change_column_default :events, :is_big_idea, false
  end

end
