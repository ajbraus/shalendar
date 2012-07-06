class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, 
  								:password, 
  								:password_confirmation, 
  								:remember_me, 
  								:first_name, 
  								:last_name
  # attr_accessible :title, :body
  has_many :events, :dependent => :destroy
  has_many :rsvps, foreign_key: "guest_id", dependent: :destroy
  has_many :plans, through: :rsvps


  def rsvpd?(event)
    rsvps.find_by_plan_id(event.id)
  end

  def rsvp!(event)
    rsvps.create!(plan_id: event.id)
  end

  def unrsvp!(event)
    rsvps.find_by_plan_id(event.id).destroy
  end

  def current_user?(user)
    user == current_user
  end

  #rsvp list

  def fullname
    "#{first_name} #{last_name}"
  end

end
