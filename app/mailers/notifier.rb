class Notifier < ActionMailer::Base
  layout 'email' # use email.(html|text).erb as the layout for emails
  default from: "info@hoos.in"

  # AD HOC NOTIFIERS

  def beta_users
    @emails = ["msfenchel@gmail.com", "ajbraus@gmail.com", "matt@womstreet.com", 
      "marykvernon@gmail.com", "rsfenchel@gmail.com", "scott.j.resnick@gmail.com", 
      "johnbwheel@gmail.com", "acconnel7@gmail.com", "nikolaiskievaski@gmail.com",
      "nolanbjohnson@gmail.com", "drew.cohen@epic.com", "Dkevitch@gmail.com",
      "SBwells@wisc.edu", "gstratch@gmail.com", "ohfortuna@gmail.com", 
       ]
    mail to: "msfenchel@gmail.com", subject: "Hoos.in? You are!"
  end

  #AUTOMATIC NOTIFIERS

  def welcome(user)
    @user = user
    mail to: user.email, subject: "Welcome to hoos.in, #{user.first_name}!"
    
  end

  def cancellation(event, user)
    @user = user
    @event = event
    if(@user.iPhone_user == true)
      APN.notify(@user.APNtoken, {:alert => "#{event.title} Canceled!", :badge => 1, :sound => true})
    end
    mail to: @user.email, subject: "Your Plan got Canceled!"
  end


  def event_tipped(event, user)
    @event = event
    @user = user
    if(@user.iPhone_user == true)
      APN.notify(@user.APNtoken, {:alert => "#{event.title} has tipped!", :badge => 1, :sound => true})
    end
    mail to: @user.email, subject: "Your plan has tipped!"
  end

  def rsvp_reminder(event, user)
    @user = user
    @event = event

    if(@user.iPhone_user == true)
      APN.notify(@user.APNtoken, { :alert => "#{event.title} starting soon!", :badge => 1, :sound => true})
    elsif(@user.android_user == true)
      #need to know how Gcm::Devices behave- do they persist?
      if(Gcm::Device.find_by_id(@user.GCMdevice_id).nil? == false)#if we have a device for user
        notification = Gcm::Notification.new
        notification.device = Gcm::Device.find_by_id(@user.GCMdevice_id)
        notification.collapse_key = "RSVP_Reminder"
        notification.delay_while_idle = true
        notification.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "#{event.title} starting soon!"}}
        notification.save
      end
    end
      mail to: @user.email, subject: "Reminder: Activity starts in 2 hours!"
  end

  def invitation(email, event, inviter_id)
    @event = event
    @email = email
    @inviter = User.find_by_id(inviter_id)
    #should we include here an invited by X to make them more likely to join?
    if @user = User.find_by_email(email)
      if(@user.iPhone_user == true)
        APN.notify(@user.APNtoken, {:alert => "#{@inviter.name} sent you an invitation!", :badge => 1, :sound => true})
      end
      mail to: @user.email, subject: "#{@inviter.name} sent you an invitation!" 
    else
      mail to: email, subject: "#{@inviter.name} sent you an invitation!"
    end
  end

  def time_change(event, user)
    @event = event
    @user= user
    if(@user.iPhone_user == true)
      APN.notify(g.APNtoken, {:alert => "#{event.title} has changed time!", :badge => 1, :sound => true})
    end
    mail to: @user.email, subject: "Your plan has changed start time."
  end

  def tip_or_destroy(event)
    @user = event.user
    @event = event
    if(@user.iPhone_user == true)
      APN.notify(g.APNtoken, {:alert => "Untipped idea: either tip or cancel", :badge => 1, :sound => true})
    end
    mail to: @user.email, subject: "Untipped idea: please tip or cancel"
  end

  #PREFERENCE NOTIFIERS, DEFAULT YES

  def confirm_follow(user, follower)
    @user = user
    @follower = follower
    mail to: user.email, subject: "You have a view request from: #{follower.name}"
  end

  def new_follower(user, follower)
    @user = user
    @follower = follower
    mail to: user.email, subject: "You have a new viewer: #{follower.name}"
  end
  
  # def digest
  #   @users = User.where('users.allow_contact = "t"')

  #   @users.each do |u|
  #     #@events = u.plans; something to send all plans, but need to lay this out

  #     mail to: u.email, subject: "Your daily digest from hoos.in!"
  #   end
  # end
end
