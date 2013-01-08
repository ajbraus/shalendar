class AddOutToRsvps < ActiveRecord::Migration
  def change
    add_column :rsvps, :inout, :integer
    #0 = Out, 1 = in
    Rsvp.all.each do |r|
    	r.inout = 1
    	r.save
    end

    #FRIEND HOOSIN
    User.all.each do |u|
    	if User.find_by_email('info@hoos.in').present?
    		@hoosin_user = User.find_by_email('info@hoos.in')
    		unless u.following?(@hoosin_user)
    			u.friend!(@hoosin_user)
    		end
    	end
    end

  end
end
