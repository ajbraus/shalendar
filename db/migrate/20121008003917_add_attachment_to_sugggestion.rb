class AddAttachmentToSugggestion < ActiveRecord::Migration
  def self.up
    change_table :suggestions do |t|
      t.has_attached_file :promo_img
    end
  end

  def self.down
    drop_attached_file :suggestions, :promo_img
  end
end
