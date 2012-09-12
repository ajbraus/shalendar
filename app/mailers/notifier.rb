class Notifier < ActionMailer::Base
  layout 'email' # use email.(html|text).erb as the layout for emails
  default from: "info@hoos.in"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.welcome.subject
  #


  # AD HOC NOTIFIERS

  def beta_users
    mail to: "msfenchel@gmail.com", subject: "Welcome, Beta-User, to hoos.in!"
  end

  #AUTOMATIC NOTIFIERS

  def welcome(user)
    @user_first_name = user.first_name
    mail to: user.email, subject: "Welcome to hoos.in, #{user.first_name}!"
    
  end

  def cancellation(event)
    @guests = event.guests

    # @guest_emails = []
    @guests.each do |g|
      if(g.iPhone_user == true)
        APN.notify(g.APNtoken, {:alert => "#{event.title} Canceled!", :badge => 1, :sound => true})
      end
      mail to: g.email, subject: "#{event.title} Canceled!"
      # @guest_emails.push(g.email)
    end
    # @guest_emails.join('; ')

    # mail bcc: @guest_emails, subject: "#{event.title} Canceled!"
  end

  def rsvp_reminder(event)
    @guests = event.guests

    @guest_emails = []

    @guests.each do |g|
      if(g.iPhone_user == true)
        APN.notify(g.APNtoken, { :alert => "#{event.title} starting soon!", :badge => 1, :sound => true})
      elsif(g.android_user == true)
        #need to know how Gcm::Devices behave- do they persist?
        if(Gcm::Device.find_by_id(g.GCMdevice_id).nil? == false)#if we have a device for user
          notification = Gcm::Notification.new
          notification.device = Gcm::Device.find_by_id(g.GCMdevice_id)
          notification.collapse_key = "RSVP_Reminder"
          notification.delay_while_idle = true
          notification.data = {:registration_ids => [@user.regis], :data => {:message_text => "#{event.title} starting soon!"}}
          notification.save
        end
      end
      @guest_emails.push(g.email)
    end

    @guest_emails.join('; ')

    mail bcc: @guest_emails, subject: "Your event #{event.title} begins in 2 hours!"
  end


  def invitation(email, event)

    #should we include here an invited by X to make them more likely to join?
    if @user = User.find_by_email(email)
      if(@user.iPhone_user == true)
        APN.notify(@user.APNtoken, {:alert => "You've been invited to #{event.title}", :badge => 1, :sound => true})
      end
      mail to: @user.email, subject: "Hello, #{@user.first_name} you've been invited to #{event.title}; visit www.hoos.in.com/events/#{event.id}"
    else
      mail to: email, subject: "Hello, you've been invited to #{event.title}; visit www.hoos.in.com/events/#{event.id}"
    end
  end

  def event_tipped(event)

    @guests = event.guests

    @guest_emails = []

    @guests.each do |g|
      if(g.iPhone_user == true)
        APN.notify(g.APNtoken, {:alert => "#{event.title} has tipped!", :badge => 1, :sound => true})
      end
      @guest_emails.push(g.email)
    end

    @guest_emails.join('; ')

    mail bcc: @guest_emails, subject: "Your plan #{event.title} has tipped!"
  end

  def time_change(event)

    @guests = event.guests

    @guest_emails = []
    @guest_phone_numbers = []

    @guests.each do |g|
      if g.phone_number
        @guest_phone_numbers.push(g.phone_number)
      end
      @guest_emails.push(g.email)
    end

    # @guest_phone_numbers.each do |gp|
    #   Twilio::SMS.create :to => gp.to_str, :from => '+16084675636',
    #                       :body => "Hey baby, how's your day going? xoxo"
    # end

    @guest_emails.join('; ')

    #HOW DO WE DO EACH TIME FOR THE CORRECT TIME ZONE??
    mail bcc: @guest_emails, subject: "Your plan #{event.title} has changed start time to #{event.chronic_starts_at}!"
  end

  def location_change(event)

    @guests = event.guests

    @guest_emails = []

    @guests.each do |g|
      @guest_emails.push(g.email)
    end

    @guest_emails.join('; ')

    mail bcc: @guest_emails, subject: "Your plan #{event.title} has changed location to #{event.map_location}!"
  end

  def send_invites(event)

    @event.invites.each do |i|
      @user = User.find_by_email(i.email)
      unless @user.nil?
        if(@user.iPhone_user == true)
          APN.notify(@user.APNtoken, {:alert => "#{event.title} has tipped!", :badge => 1, :sound => true})
        end
      end
    @invitees = @event.invites.join('; ')
    mail bcc: @invitees, subject: "#{event.user.name} has invited you to #{event.title} on hoos.in"
    end
  end

  #PREFERENCE NOTIFIERS, DEFAULT YES

  def confirm_follow(user, follower)

    mail to: user.email, subject: "You have a view request from: #{follower.name}"
  end

  def new_follower(user, follower)

    mail to: user.email, subject: "You have a new viewer from: #{follower.name}"
  end
  
  #CHRON JOBS
  def digest
    @users = User.where('users.allow_contact = "t"')

    @users.each do |u|
      #@events = u.plans; something to send all plans, but need to lay this out

      mail to: u.email, subject: "Your daily digest from hoos.in!"
    end
  end
end
