class Notifier < ActionMailer::Base
  include UsersHelper
  include ActionView::Helpers::AssetTagHelper
  layout 'hoosin_email' # use email.(html|text).erb as the layout for emails
  default from: "hoos.in info@hoos.in"

  # AD HOC NOTIFIERS

  def user_update(email)
    mail to: email, from: "info@hoos.in", subject: "Upgraded Site!"

  end

  def super_beta_users
    @sbu_emails = ["msfenchel@gmail.com", "ajbraus@gmail.com", "javfenchel@gmail.com",
      "matt@womstreet.com", "marykvernon@gmail.com", "rsfenchel@gmail.com", "scott.j.resnick@gmail.com", 
      "johnbwheel@gmail.com", "acconnel7@gmail.com", "nikolaiskievaski@gmail.com",
      "nolanbjohnson@gmail.com", "drew.cohen@epic.com", "Dkevitch@gmail.com",
      "SBwells@wisc.edu", "gstratch@gmail.com", "ohfortuna@gmail.com", "mcorear@gmail.com"
      ]
    mail bcc: @sbu_emails, from: "info@hoos.in", subject: "Ten Days In- Beta v.2"

  end

  def friend_beta_users
    @friend_emails = ["MadIterators@madisoniterators.com", "woolworth@gmail.com", "galbraks@gmail.com", 
                      "dylanbmathieu@gmail.com", "jakebrower87@gmail.com", "dgamoran@gmail.com", 
                      "galbraks@uwec.edu", "walshandj@gmail.com>", "cecekress@gmail.com", 
                      "jhschneider09@gmail.com", "max.rosen17@gmail.com", "samlundsten@gmail.com", 
                      "malone2@wisc.edu", "jsh4ft@gmail.com", "waterppk@gmail.com", 
                      "kmabra@uwalumni.com", "jrd309@gmail.com", "dangormich@gmail.com", "jbornhorst@gmail.com", 
                      "stratsgoo@gmail.com", "rkyoung366@gmail.com", "shawn@vitruvianfarms.com", 
                      "tommy@vitruvianfarms.com", "craig@vitruvianfarms.com", "ari.eisenstat@gmail.com", 
                      "nick.guggenbuehl@gmail.com", "alexandra@7cees.org", "rocheleau.jen@gmail.com",  
                      "becca.m.cohen@gmail.com", "Christopher.Galbraith@associatedbank.com", "rbhaya2@gmail.com", 
                      "kari.k.design@gmail.com", "a.mearini@gmail.com", "reebz22@gmail.com", 
                      "msfenchel@gmail.com", "ajbraus@gmail.com"]

    mail bcc: @friend_emails, from: "info@hoos.in", subject: "hoos.in Launch!"
  end
  #AUTOMATIC NOTIFIERS

  def welcome(user)
    @user = user
    mail to: user.email, subject: "welcome to hoos.in"
  end

  #PREFERENCE NOTIFIERS, DEFAULT YES

  def confirm_follow(user, follower)
    @user = user
    @follower = follower
    #@friend_pic = raster_profile_picture(@follower)
    mail to: user.email, subject: "New Friend Request - #{@follower.name}"
  end

  def new_friend(user, friend)
    @user = user
    @follower = friend
    #@follower_pic = raster_profile_picture(@user)
    mail to: user.email, subject: "New Friend - #{@follower.name}"
  end

  def event_tipped(event, user)
    @event = event
    @user = user
    @event_link = "http://www.hoos.in/events/#{event.id}"
    if(@user.iPhone_user == true)
      APN.notify(@user.APNtoken, {:alert => "#{@event.user.first_name}\'s plan for #{@event.event_day} tipped!", :badge => 1, :sound => true})
    end
    mail to: @user.email, subject: "Tipped - #{@event.event_day}\'s Idea Tipped! - #{@event.short_event_title}"
  end

  def tip_or_destroy(event)
    @user = event.user
    @event = event
    if(@user.iPhone_user == true)
      APN.notify(g.APNtoken, {:alert => "Untipped idea - #{@event.short_event_title}", :badge => 1, :sound => true})
    end
    mail to: @user.email, subject: "Untipped idea - #{@event.short_event_title}"
  end

  def cancellation(event, user)
    @user = user
    @event = event
    if(@user.iPhone_user == true)
      APN.notify(@user.APNtoken, {:alert => "Canceled #{@event.title}", :badge => 1, :sound => true})
    end
    mail to: @user.email, subject: "Cancellation - #{@event.event_day}, #{@event.short_event_title}" 
  end

  def email_comment(event, comment, user)
    @commenter = comment.creator
    @event = event
    @comment = comment
    @comments = event.comments.order('created_at DESC').limit(4)
    @comments.shift(1)
    @guest = user
    if(@guest.iPhone_user == true)
      APN.notify(@guest.APNtoken, {:alert => "#{@commenter.name} said #{comment.content}!", :badge => 1, :sound => true})
    end
    @comment_time = comment.created_at.strftime "%l:%M%P, %A %B %e"
    @event_link = "http://www.hoos.in/events/#{event.id}"
    mail to: @guest.email, subject: "New Comment - #{@event.short_event_title}"
  end

  def rsvp_reminder(event, user)
    @user = user
    @event = event
    @event_link = "http://www.hoos.in/events/#{event.id}"

    if(@user.iPhone_user == true)
      APN.notify(@user.APNtoken, { :alert => "#{@vent.title} starting soon!", :badge => 1, :sound => true})
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
      mail to: @user.email, subject: "Reminder: Activity starts in 2 hours! - #{@event.short_event_title}"
  end

  def invitation(event, invitee, inviter)
    @event = event
    @user = invitee
    @event_time = event.starts_at.strftime("%l:%M%P, %A %B %e")
    @inviter = inviter
    #@inviter_pic = raster_profile_picture(@inviter)
    @event_link = "http://www.hoos.in/events/#{@event.id}"
    if(@user.iPhone_user == true)
      APN.notify(@user.APNtoken, {:alert => "#{@inviter.name} sent you an invitation!", :badge => 1, :sound => true})
    end
    mail to: @user.email, subject: "You're invited to #{@event.short_event_title}"
  end

  def email_invitation(invite, event)
    @invite = invite
    @event = event
    @event_time = event.starts_at.strftime("%l:%M%P, %A %B %e")
    @inviter = User.find_by_id(@invite.inviter_id)
    @event_link = "http://www.hoos.in/events/#{@event.id}"
    @message = @invite.message
    #@inviter_pic = raster_profile_picture(@inviter)
    #should we include here an invited by X to make them more likely to join?
    if @user = User.find_by_email(@invite.email)
      if(@user.iPhone_user == true)
        APN.notify(@user.APNtoken, {:alert => "#{@inviter.name} sent you an invitation!", :badge => 1, :sound => true})
      end
      mail to: @user.email, subject: "You're invited to #{@event.short_event_title}"
    else
      mail to: @invite.email, subject: "#{@inviter.name} sent you an invitation"
    end

  end

  def time_change(*args)

    @event = Event.find_by_id(args[0])
    @user = User.find_by_id(args[1])

    if(@user.iPhone_user == true)
      APN.notify(@user.APNtoken, {:alert => "Time Change - #{@event.short_event_title}", :badge => 1, :sound => true})
    end

    mail to: @user.email, from: "info@hoos.in", subject: "Time Change - #{@event.short_event_title}"
    
    rescue => ex
    Airbrake.notify(ex)
  end

  def fb_invite(invitee_email, subject, message)
    @invitee_email = invitee_email
    @subject = subject
    @message = message
    mail to: @invitee_email, from: "info@hoos.in", subject: @subject
  end
  
  # def failed_to_tip(event, user)
  #   @user = user
  #   @event = event
  #   if(@user.iPhone_user == true)
  #     APN.notify(@user.APNtoken, {:alert => "Failed to Tip - #{@event.event_day}, #{@event.short_event_title}", :badge => 1, :sound => true})
  #   end
  #   mail to: @user.email, subject: "Failed to Tip - #{@event.event_day}, #{@event.short_event_title}" 
  # end
  
  # def digest
  #   @users = User.where('users.allow_contact = "t"')

  #   @users.each do |u|
  #     #@events = u.plans; something to send all plans, but need to lay this out

  #     mail to: u.email, subject: "Your daily digest from hoos.in!"
  #   end
  # end
end
