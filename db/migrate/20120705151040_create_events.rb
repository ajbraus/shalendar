class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.integer :price
      t.references :user

      t.timestamps
    end

    add_column :events, :visibility, :integer, default:2
    add_column :events, :link, :string
    add_column :events, :address, :string
    add_column :events, :longitude, :float
    add_column :events, :latitude, :float
    add_column :events, :gmaps, :boolean, default: false
    add_column :events, :slug, :string
    add_column :events, :fb_id, :string    
    add_column :events, :one_time, :boolean, default: false
    add_column :events, :short_url, :string
    add_column :events, :promo_url, :string
    add_column :events, :promo_vid, :string
    add_column :events, :require_payment, :boolean
    add_column :events, :city_id, :integer
    
    add_index :events, :slug
    add_index :events, :fb_id
  end
end
