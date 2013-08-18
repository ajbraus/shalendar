class InstanceInvitation < ActiveRecord::Base
  attr_accessible :instance_id, :user_id, :inviter_id, :friends_in, :intros_in, :randos_in

  belongs_to :user
  belongs_to :instance
  belongs_to :inviter, class_name: "User"

  validates :user_id, presence: true
  validates :instance_id, presence: true
  validates :inviter_id, presence: true

  def self.remove_overs
    InstanceInvitation.all.each do |i|
      Time.zone = i.user.city.timezone
      if i.ends_at > Time.zone.now
        i.destroy
      end
    end    
  end
end