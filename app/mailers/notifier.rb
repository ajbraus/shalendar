class Notifier < ActionMailer::Base
  include UsersHelper
  include ActionView::Helpers::AssetTagHelper
  layout 'hoosin_email' # use email.(html|text).erb as the layout for emails
  default from: "hoos.in info@hoos.in"

  require 'apn_on_rails'
  require 'gcm_on_rails'

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
    rescue => ex
    Airbrake.notify(ex)
  end

  def vendor_welcome(vendor)
    @vendor = vendor
    mail to: vendor.email, subject: "welcome to hoos.in"
  end

  #PREFERENCE NOTIFIERS, DEFAULT YES

  def confirm_follow(user, follower)
    @user = user
    @follower = follower
        if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "Confirm Friend - #{@follower.name}"
        n.badge = 1
        n.sound = true
        n.save
      end
    end
    if(@user.android_user == true)
      d = GCM::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "Confirm Friend - #{@follower.name}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "Confirm Friend - #{@follower.name}"}}
        n.save
      end
    end
    #@friend_pic = raster_profile_picture(@follower)
    mail to: user.email, subject: "New Friend Request - #{@follower.name}"
    rescue => ex
    Airbrake.notify(ex)
  end

  def new_friend(user, friend)
    @user = user
    @follower = friend
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "New Friend - #{@follower.name}"
        n.badge = 1
        n.sound = true
        n.save
      end
    end
    if(@user.android_user == true)
      d = GCM::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "New Friend - #{@follower.name}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "New Friend - #{@follower.name}"}}
        n.save
      end
    end
    #@follower_pic = raster_profile_picture(@user)
    mail to: user.email, subject: "New Friend - #{@follower.name}"
    rescue => ex
    Airbrake.notify(ex)
  end

  def event_tipped(event, user)
    @event = event
    @user = user
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "#{@event.title} Tipped!"
        n.badge = 1
        n.sound = true
        n.save
      end
    end
    if(@user.android_user == true)
      d = GCM::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@event.title} Tipped!"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "#{@event.title} Tipped!"}}
        n.save
      end
    end
    mail to: @user.email, subject: "Tipped - #{@event.event_day}\'s Idea Tipped! - #{@event.title}"
    rescue => ex
    Airbrake.notify(ex)
  end

  def tip_or_destroy(event)
    @user = event.user
    @event = event
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "Untipped idea - #{@event.title}"
        n.badge = 1
        n.sound = true
        n.save
      end
    end
    if(@user.android_user == true)
      d = GCM::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "Untipped idea - #{@event.title}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "Untipped idea - #{@event.title}"}}
        n.save
      end
    end
    mail to: @user.email, subject: "Untipped idea - #{@event.title}"
    rescue => ex
    Airbrake.notify(ex)
  end

  def cancellation(event, user)
    @user = user
    @event = event
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "Cancellation - #{@event.event_day}, #{@event.title}"
        n.badge = 1
        n.sound = true
        n.custom_properties = {:test_action => "#{@event.id}"}
        n.save
      end
    end
    if(@user.android_user == true)
      d = GCM::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "Cancellation - #{@event.event_day}, #{@event.title}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "Cancellation - #{@event.event_day}, #{@event.title}"}}
        n.save
      end
    end
    mail to: @user.email, subject: "Cancellation - #{@event.event_day}, #{@event.title}" 
    
    @event.destroy
    
    rescue => ex
    Airbrake.notify(ex)
  end

  def email_comment(event, comment, user)
    @commenter = comment.user.name
    @event = event
    @comment = comment
    @comments = event.comments.order('created_at DESC').limit(4)
    @comments.shift(1)
    @user = user
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "New Comment - #{@event.short_event_title}"
        n.badge = 1
        n.sound = true
        n.save
      end
    end
    if(@user.android_user == true)
      d = GCM::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "New Comment - #{@event.short_event_title}"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "New Comment - #{@event.short_event_title}"}}
        n.save
      end
    end
    @comment_time = comment.created_at.strftime "%l:%M%P, %A %B %e"
    @event_link = "http://www.hoos.in/events/#{event.id}"
    mail to: @user.email, subject: "New Comment - #{@event.short_event_title}"
    rescue => ex
    Airbrake.notify(ex)
  end

  def rsvp_reminder(event, user)
    @user = user
    @event = event
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "#{@event.short_event_title} starts soon"
        n.badge = 1
        n.sound = true
        n.save
      end
    end
    if(@user.android_user == true)
      d = GCM::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@event.short_event_title} starts soon"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "#{@event.short_event_title} starts soon"}}
        n.save
      end
    end
    mail to: @user.email, subject: "Reminder: Activity starts in 2 hours! - #{@event.short_event_title}"
    rescue => ex
    Airbrake.notify(ex)
  end

  def invitation(event, invitee, inviter)
    @event = event
    @user = invitee
    @inviter = inviter
    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "#{@event.user.name} Shared an idea"
        n.badge = 1
        n.sound = true
        n.save
      end
    end
    if(@user.android_user == true)
      d = GCM::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@event.user.name} Shared an idea"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "#{@event.user.name} Shared an idea"}}
        n.save
      end
    end
    mail to: @user.email, subject: "You're invited to #{@event.short_event_title}"
    rescue => ex
    Airbrake.notify(ex)
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
    mail to: @invite.email, subject: "#{@inviter.name} sent you an invitation"
  end

  def time_change(event, user)
    @user = user
    @event = event
    @event_link = "http://www.hoos.in/events/#{event.id}"

    if(@user.iPhone_user == true)
      d = APN::Device.find_by_id(@user.apn_device_id)
      if d.nil?
        Airbrake.notify("thought we had an iphone user but can't find their device")
      else
        n = APN::Notification.new
        n.device = d
        n.alert = "#{@event.title} changed time!"
        n.badge = 1
        n.sound = true
        n.save
      end
    end
    if(@user.android_user == true)
      d = GCM::Device.find_by_id(@user.GCMdevice_id)
      if d.nil?
        Airbrake.notify("thought we had an android user but can't find their device")
      else
        n = Gcm::Notification.new
        n.device = d
        n.collapse_key = "#{@event.title} changed time!"
        n.delay_while_idle = true
        n.data = {:registration_ids => [@user.GCMregistration_id], :data => {:message_text => "#{event.title} changed time!"}}
        n.save
      end
    end
    mail to: @user.email, subject: "Time change - #{@event.short_event_title}"
    
    rescue => ex
    Airbrake.notify(ex)
  end

  def fb_app_invite(invitee_email, subject, message)
    @invitee_email = invitee_email
    @subject = subject
    @message = message
    mail(to: @invitee_email, from: "info@hoos.in", subject: @subject) do |format|
      format.html { render :layout => 'fb_message' }
    end
    rescue => ex
    Airbrake.notify(ex)
  end

  def fb_event_invite(email, event)
    @event = event
    @email = email 
    mail to: @email, from: "info@hoos.in", subject: "An Idea has Been Shared with You" do |format|
      format.html { render :layout => 'fb_message' }
    end
  end
  
  # def failed_to_tip(event, user)
  #   @user = user
  #   @event = event
  #   if(@user.iPhone_user == true)
  #   end
  #   mail to: @user.email, subject: "Failed to Tip - #{@event.event_day}, #{@event.short_event_title}" 
  # end
  
  def digest(user, upcoming_events)
    @user = user
    @upcoming_events = upcoming_events
    mail to: @user.email, from: "info@hoos.in", subject: "You Have New Ideas on Hoos.in"
  end

  def follow_up(user, event, new_friends)
    @user = user
    @event = event
    @new_friends = new_friends
    mail to: @user.email, from: "info@hoos.in", subject: "Connect With People - #{@event.title}"
  end

  # def time_change(*args)

  #   @event = Event.find_by_id(args[0])
  #   @user = User.find_by_id(args[1])

  #   if(@user.iPhone_user == true)
  #   end

  #   mail to: @user.email, from: "info@hoos.in", subject: "Time Change - #{@event.short_event_title}"
    
  #   rescue => ex
  #   Airbrake.notify(ex)
  # end

end
