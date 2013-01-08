class AddOutToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :inout, :integer
    #0 = Out, 1 = in
    Rsvp.all.each do |r|
    	r.inout = 1
    	r.save
    end

  end
end
