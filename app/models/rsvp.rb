class Rsvp < ActiveRecord::Base
  attr_accessible :event_id, :muted, :friends_in, :intros_in

  belongs_to :guest, class_name: "User"
  belongs_to :event

  validates :guest_id, presence: true
  validates :event_id, presence: true

  before_destroy :update_who_is_going

  def sync_invitations
    if event.open_invite?
      guest.intros_and_friends.each do |u|
        invitation = u.invitations.find_by_event_id(event.id)
        rsvp = u.rsvps.find_by_event_id(event.id)
        if invitation.present? #UPDATE INVITATION FRIENDS_ AND INTROS_IN COUNTS
          if u.is_friends_with?(guest)
            invitation.friends_in += 1
            invitation.save
          elsif u.is_intros_with?(guest)
            invitation.intros_in += 1
            invitation.save
          end
        elsif rsvp.present? #UPDATE RSVP FRIENDS_ AND INTROS_IN COUNTS
          if u.is_friends_with?(guest)
            rsvp.friends_in += 1
            rsvp.save
          elsif u.is_intros_with?(guest)
            rsvp.intros_in += 1
            rsvp.save
          end
        else #CREATE AND SET INVITATION
          u.invite!(event, guest)
        end
      end        
    elsif event.friends_only?    
      guest.friends.each do |u|
        invitation = u.invitations.find_by_event_id(event.id)
        rsvp = u.rsvps.find_by_event_id(event.id)
        if invitation.present? #UPDATE INVITATION FRIENDS_ AND intros_in COUNTS
          if u.is_friends_with?(guest)
            invitation.friends_in += 1
            invitation.save
          elsif u.is_intros_with?(guest)
            invitation.intros_in += 1
            invitation.save
          end
        elsif rsvp.present? #UPDATE RSVP FRIENDS_ AND intros_in COUNTS
          if u.is_friends_with?(guest)
            rsvp.friends_in += 1
            rsvp.save
          elsif u.is_intros_with?(guest)
            rsvp.intros_in += 1
            rsvp.save
          end
        else #CREATE AND SET INVITATION
          u.invite!(event, guest)
        end
      end
    end
  end

  def update_who_is_going
    event.invitations.each do |i|
      if i.guest.is_friends_with(guest)
        i.friends_in -= 1
        i.save
      elsif i.guest.is_intros_with(guest)
        i.intros_in -= 1
        i.save
      end
    end
  end

end
