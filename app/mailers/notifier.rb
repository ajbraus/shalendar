class Notifier < ActionMailer::Base
  include UsersHelper
  include ActionView::Helpers::AssetTagHelper
  layout 'hoosin_email' # use email.(html|text).erb as the layout for emails
  default from: "hoos.in info@hoos.in"

  require 'apn_on_rails'
  require 'gcm_on_rails'

  # AD HOC NOTIFIERS

  def user_update(email)
    mail to: email, from: "info@hoos.in", subject: "Upgraded Site"
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

    mail bcc: @friend_emails, from: "info@hoos.in", subject: "hoos.in Launch"
  end

  def hoosin_update(user)
    @user = user

    if @user.allow_contact?
      mail to: @user.email, subject: "Mobile apps, train cars and blogs, oh my"
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

  def new_friend(user, friend)
    @user = user
    @follower = friend
    @image_url = invite_raster_picture(@follower)
    mail to: user.email, subject: "#{@follower.name} starred you on hoos.in"
  end

  def cancellation(event, user)
    @event = event
    @user = user 
    unless @user == @event.user
      mail to: user.email, subject: "#{@event.user.first_name} canceled the idea: #{@event.title}" 
    end
  end

  def email_comment(comment, user)
    @comment = comment
    @user = user
    @commenter = @comment.user.first_name_with_last_initial
    @event = @comment.event
    @comments = @event.comments.order('created_at DESC').limit(4)
    @comments.shift(1)
    @comment_time = @comment.created_at.strftime "%l:%M%P, %A %B %e"
    @event_link = event_url(@event)
    mail to: @user.email, subject: ".info - #{@commenter} chatted - #{@comment.content}"
  end

  def new_idea(event, user)
    @event = event
    @user = user
    unless @user == User.find_by_email("info@hoos.in")
      mail to: @user.email, subject: ".invite - #{@event.user.first_name} invited you! - #{@event.short_event_title} "
    end
  end

  def rsvp_reminder(event, user)
    @user = user
    @event = event

    unless @user == User.find_by_email("info@hoos.in")
      mail to: @user.email, subject: "reminder - #{@event.user.first_name}'s idea is starting - #{@event.short_event_title}"
    end
  end

  def time_change(event, user)
    @user = user
    @event = event
    @event_link = event_url(@event)
    mail to: @user.email, subject: ".interruption -#{@event.user.first_name} changed times for an idea - #{@event.short_event_title}"
    rescue => ex
    Airbrake.notify(ex)
  end
  
  def new_time(event, user)
    @user = user
    @event = event
    @event_link = event_url(@event)
    mail to: @user.email, from: "info@hoos.in", subject: "new time - #{@event.user.first_name} created a new time - #{@event.start_time} - #{@event.title}"
  end

  def new_rsvp(event, user, rsvping_user)
    @event = event
    @user = @event.user
    @rsvping_user = rsvping_user
    @image_url = invite_raster_picture(@rsvping_user)
    mail to: @user.email, from: "info@hoos.in", subject: "new .in - #{@rsvping_user.name}"
  end

  def digest(user, upcoming_times, has_times, new_inner_ideas, new_inmate_ideas, users_new_ideas_count)
    @user = user
    @upcoming_times = upcoming_times
    @has_times = has_times
    @new_inner_ideas = new_inner_ideas
    @new_inmate_ideas = new_inmate_ideas
    @new_ideas_count = users_new_ideas_count
    mail to: @user.email, from: "info@hoos.in", subject: "your new and upcoming ideas on hoos.in"
  end

  # def follow_up(user, event, new_inmates)
  #   @user = user
  #   @event = event
  #   @new_inmates = new_inmates
  #   mail to: @user.email, from: "info@hoos.in", subject: ".introductions - #{@event.title}"
  # end

  def new_fb_inmate(user, new_inmate)
    @user = user
    @new_inmate = new_inmate
    @image_url = invite_raster_picture(@new_inmate)
    mail to: @user.email, from: "info@hoos.in", subject: "Your friend #{@new_inmate.name} just joined hoos.in and you are now friends."
  end

  def inmate_invite(recipient_email, inviter)
    @inviter = inviter
    @image_url = invite_raster_picture(@inviter)
    mail to: recipient_email, from: "info@hoos.in", subject: "#{@inviter.name} wants you to be friends on hoos.in."
  end

  def new_inmate(recipient, inmate)
    @user = recipient
    @inmate = inmate
    @image_url = invite_raster_picture(@inmate)
    mail to: @user.email, from: "info@hoos.in", subject: "#{@inmate.name} is now friends with you on hoos.in."
  end



  # def email_invitation(invite, event)
  #   @invite = invite
  #   @event = event
  #   @event_time = event.starts_at.strftime("%l:%M%P, %A %B %e")
  #   @inviter = User.find_by_id(@invite.inviter_id)
  #   @event_link = event_url(@event)
  #   @message = @invite.message
  #   #@inviter_pic = raster_profile_picture(@inviter)
  #   #should we include here an invited by X to make them more likely to join?
  #   mail to: @invite.email, subject: "#{@inviter.name} .invited you"
  # end

  # def fb_app_invite(invitee_email, subject, message)
  #   @invitee_email = invitee_email
  #   @subject = subject
  #   @message = message
  #   mail(to: @invitee_email, from: "info@hoos.in", subject: @subject) do |format|
  #     format.html { render :layout => 'fb_message' }
  #   end
  #   # rescue => ex
  #   # Airbrake.notify(ex)
  # end

  # def fb_event_invite(email, event)
  #   @event = event
  #   @email = email 
  #   mail to: @email, from: "info@hoos.in", subject: ".invite" do |format|
  #     format.html { render :layout => 'fb_message' }
  #   end
  # end

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
