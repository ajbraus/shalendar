class InstanceRsvp < ActiveRecord::Base
  attr_accessible :instance_id, :friends_in, :intros_in

  belongs_to :user
  belongs_to :instance

  validates :user_id, presence: true
  validates :instance_id, presence: true
  
  before_destroy :update_who_is_going

  def sync_instance_invitations
    if instance.event.open_invite?
      user.intros_and_friends.each do |u|
        instance_invitation = u.instance_invitations.find_by_instance_id(instance.id)
        instance_rsvp = u.instance_rsvps.find_by_instance_id(instance.id)
        if instance_invitation.present? #UPDATE INVITATION FRIENDS_ AND intros_in COUNTS
          if u.is_friends_with?(user)
            instance_invitation.friends_in += 1
            instance_invitation.save
          elsif u.is_intros_with?(user)
            instance_invitation.intros_in += 1
            instance_invitation.save
          end
        elsif instance_rsvp.present? #UPDATE RSVP FRIENDS_ AND intros_in COUNTS
          if u.is_friends_with?(user)
            instance_rsvp.friends_in += 1
            instance_rsvp.save
          elsif u.is_intros_with?(user)
            instance_rsvp.rsvp.intros_in += 1
            instance_rsvp.save
          end
        else #CREATE INVITATION
          u.invite!(instance, user)
        end
      end        
    elsif instance.event.friends_only?    
      user.friends.each do |u|
        instance_invitation = u.instance_invitations.find_by_instance_id(instance.id)
        instance_rsvp = u.instance_rsvps.find_by_instance_rsvp_id(instance.id)
        if instance_invitation.present? #UPDATE INVITATION FRIENDS_ AND intros_in COUNTS
          if u.is_friends_with?(user)
            instance_invitation.friends_in += 1
            instance_invitation.save
          elsif u.is_intros_with?(user)
            instance_invitation.intros_in += 1
            instance_invitation.save
          end
        elsif instance_rsvp.present? #UPDATE RSVP FRIENDS_ AND intros_in COUNTS
          if u.is_friends_with?(user)
            instance_rsvp.friends_in += 1
            instance_rsvp.save
          elsif u.is_intros_with?(user)
            instance_rsvp.rsvp.intros_in += 1
            instance_rsvp.save
          end
        else #CREATE INVITATION
          u.invite!(instance, user)
        end
      end
    end
  end

  def update_who_is_going
    instance.instance_invitations.each do |i|
      if i.user.is_friends_with(user)
        i.friends_in -= 1
        i.save
      elsif i.user.is_intros_with(user)
        i.intros_in -=1
        i.save
      end
    end
  end

# END OF CLASS
end

