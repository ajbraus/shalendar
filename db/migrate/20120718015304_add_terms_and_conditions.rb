class AddTermsAndConditions < ActiveRecord::Migration
  def change
  add_column :users, :terms, :boolean
  end
end
