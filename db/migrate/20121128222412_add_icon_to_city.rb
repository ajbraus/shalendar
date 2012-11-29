class AddIconToCity < ActiveRecord::Migration
	def self.up
    change_table :cities do |t|
      t.has_attached_file :icon
    end
  end

  def self.down
    drop_attached_file :cities, :icon
  end
end
