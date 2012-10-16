class AddAttachmentToEvents < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.has_attached_file :promo_img
    end
  end

  def self.down
    drop_attached_file :events, :promo_img
  end
end
