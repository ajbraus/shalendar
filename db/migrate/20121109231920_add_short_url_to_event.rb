class AddShortUrlToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :short_url, :string
  end
end
