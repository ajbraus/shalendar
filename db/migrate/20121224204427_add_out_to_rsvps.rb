class AddOutToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :inout, :integer
    #0 = Out, 1 = in
  end
end
