class AddPromoUrlAndPromoVidToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :promo_url, :string
  	add_column :events, :promo_vid, :string
  end
end
