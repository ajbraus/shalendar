class Rsvp < ActiveRecord::Base
  attr_accessible :guest_id, :rsvpable_id, :rsvpable_type, :muted, :friends_in, :intros_in, :randos_in

  belongs_to :guest, class_name: "User"
  belongs_to :rsvpable, polymorphic: true

  validates :guest_id, presence: true
  validates :rsvpable_id, presence: true
  validates :rsvpable_type, presence: true

  before_destroy :update_who_is_going

  def increment_hoos_in(event)
    guest.intros_and_friends.each do |u|
      invitation = u.invites.find_by_inviteable_id(event.id)
      rsvp = u.rsvps.find_by_rsvpable_id(event.id)
      if invitation.present? #UPDATE INVITATION FRIENDS_ AND INTROS_IN COUNTS
        if u.is_friends_with?(guest)
          invitation.friends_in += 1
          invitation.save
        elsif u.is_intros_with?(guest)
          invitation.intros_in += 1
          invitation.save
        else
          invitation.randos_in += 1
          invitation.save
        end
      elsif rsvp.present? #UPDATE RSVP FRIENDS_ AND INTROS_IN COUNTS
        if u.is_friends_with?(guest)
          rsvp.friends_in += 1
          rsvp.save
        elsif u.is_intros_with?(guest)
          rsvp.intros_in += 1
          rsvp.save
        else
          rsvp.randos_in += 1
          rsvp.save            
        end
      else #CREATE AND SET INVITATION
        u.invite!(event, guest)
      end
    end        
  end

  def decrement_hoos_in(event)
    guest.intros_and_friends.each do |u|
      invitation = u.invites.find_by_inviteable_id(event.id)
      rsvp = u.rsvps.find_by_rsvpable_id(event.id)
      if invitation.present? #UPDATE INVITATION FRIENDS_ AND INTROS_IN COUNTS
        if u.is_friends_with?(guest)
          invitation.friends_in -= 1
          invitation.save
        elsif u.is_intros_with?(guest)
          invitation.intros_in -= 1
          invitation.save
        else
          invitation.randos_in -= 1
          invitation.save
        end
      elsif rsvp.present? #UPDATE RSVP FRIENDS_ AND INTROS_IN COUNTS
        if u.is_friends_with?(guest)
          rsvp.friends_in -= 1
          rsvp.save
        elsif u.is_intros_with?(guest)
          rsvp.intros_in -= 1
          rsvp.save
        else
          rsvp.randos_in -= 1
          rsvp.save            
        end
      else #CREATE AND SET INVITATION
        u.invite!(event, guest)
      end
    end        
  end

  def update_who_is_going
    rsvpable.invites.each do |i|
      if i.guest.is_friends_with(guest)
        i.friends_in -= 1
        i.save
      elsif i.guest.is_intros_with(guest)
        i.intros_in -= 1
        i.save
      end
    end
  end

#END CLASS
end
