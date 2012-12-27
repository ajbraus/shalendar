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

  def hoosin_update(user)
    @user = user

    if @user.allow_contact?
      mail to: @user.email, subject: "Mobile apps, train cars and blogs, oh my!"
    end
    rescue => ex
    Airbrake.notify(ex)
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

  def confirm_friend(user, friend)
    @user = user
    @follower = friend
    mail to: @user.email, subject: "New Friend Request - #{@follower.name}"
  end

  def new_friend(user, friend)
    @user = user
    @follower = friend
    mail to: user.email, subject: "New Friend - #{@follower.name}"
  end

  def event_tipped(event, user)
    @event = event
    @user = user
    mail to: @user.email, subject: "Tipped - #{@event.event_day}\'s Idea Tipped! - #{@event.title}"
  end

  def event_deadline(event)
    @user = event.user
    @event = event
    mail to: @user.email, subject: "Untipped idea - #{@event.title}"
  end

  def cancellation(event, user)
    @event = event
    @user = user 
    unless @user == @event.user
      mail to: user.email, subject: "Cancellation - #{@event.event_day}, #{@event.title}" 
    end

  end

  def email_comment(event, comment, user)
    @commenter = comment.user.name
    @event = event
    @comment = comment
    @comments = event.comments.order('created_at DESC').limit(4)
    @comments.shift(1)
    @user = user
    @comment_time = comment.created_at.strftime "%l:%M%P, %A %B %e"
    @event_link = event_url(@event)
    mail to: @user.email, subject: "New Comment - #{@event.short_event_title}"
  end

  def rsvp_reminder(event, user)
    @user = user
    @event = event

    unless @user == User.find_by_email("info@hoos.in")
      mail to: @user.email, subject: "Reminder: Activity starts in 2 hours! - #{@event.short_event_title}"
    end
  end

  def invitation(event, invitee, inviter)
    @event = event
    @user = invitee
    @inviter = inviter
    mail to: @user.email, subject: "#{@inviter.name} .invited you to #{@event.short_event_title}"
    # rescue => ex
    # Airbrake.notify(ex)
  end

  def email_invitation(invite, event)
    @invite = invite
    @event = event
    @event_time = event.starts_at.strftime("%l:%M%P, %A %B %e")
    @inviter = User.find_by_id(@invite.inviter_id)
    @event_link = event_url(@event)
    @message = @invite.message
    #@inviter_pic = raster_profile_picture(@inviter)
    #should we include here an invited by X to make them more likely to join?
    mail to: @invite.email, subject: "#{@inviter.name} .invited you"
  end

  def time_change(event, user)
    @user = user
    @event = event
    @event_link = event_url(@event)
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
    # rescue => ex
    # Airbrake.notify(ex)
  end

  def fb_event_invite(email, event)
    @event = event
    @email = email 
    mail to: @email, from: "info@hoos.in", subject: "You've been .invited!" do |format|
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

  def new_time(event, user)
    @user = user
    @event = event
    mail to: @user.email, from: "info@hoos.in", subject: "New Time - #{@event.start_time} - #{@event.title}"

  end

  # def recurring_receipt(user, amount)
  #   @user = user
  #   @amount = "$" + "%.2f" % amount
  #   mail to: @user.email, from: "info@hoos.in", subject: "Successful Monthly Payment"
  # end

  # def downgrade(user)
  #   @user = user
  #   mail to: @user.email, from: "info@hoos.in", subject: "Your Account is now Private"
  # end

  # def missing_bank_account(user)
  #   @user = user
  #   mail to: @user.email, from: "info@hoos.in", subject: "Missing Account Data"
  # end

###########################################################################
########################## METHODS FOR MARKETPLACE ########################
###########################################################################

  # def receipt(user, event)
  #   @user = user
  #   @event = event
  #   mail to: @user.email, from: "info@hoos.in", subject: "Your Receipt for #{@event.title}"
  # end

  # def venue_receipt(user, events, amount)
  #   @user = user
  #   @events = events
  #   @amount = amount
  #   mail to: @user.email, from: "info@hoos.in", subject: "Payment for today's ideas on hoos.in"
  # end

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
