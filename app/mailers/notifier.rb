class Notifier < ActionMailer::Base
  layout 'email' # use email.(html|text).erb as the layout for emails
  default from: "Calenshare@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.welcome.subject
  #


  #AUTOMATIC NOTIFIERS

  def welcome(user)
    mail to: user.email, subject: "Welcome to Calenshare"
  end

  def cancellation(event)
    @guests = event.guests

    @guest_emails = []

    @guests.each do |g|
      @guest_emails.push(g.email)
    end

    @guest_emails.join('; ')

    mail bcc: @guest_emails, subject: "Your event #{event.title} has been canceled!"
  end

  def rsvp_reminder(event)
    @guests = event.guests

    @guest_emails = []

    @guests.each do |g|
      @guest_emails.push(g.email)
    end

    @guest_emails.join('; ')

    mail bcc: @guest_emails, subject: "Your event #{event.title} begins in 2 hours!"
  end


  def invitation(email, event)

    #should we include here an invited by X to make them more likely to join?
    if @user = User.find_by_email(email)
      mail to: @user.email, subject: "Hello, #{@user.first_name} you've been invited to #{event.title}; visit www.calenshare.com/events/#{event.id}"
    else
      mail to: email, subject: "Hello, you've been invited to #{event.title}; visit www.calenshare.com/events/#{event.id}"
    end
  end

  def event_tipped(event)

    @guests = event.guests

    @guest_emails = []

    @guests.each do |g|
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

    @guest_phone_numbers.each do |gp|
      Twilio::SMS.create :to => gp.to_str, :from => '+16084675636',
                          :body => "Hey baby, how's your day going? xoxo"
    end

    @guest_emails.join('; ')

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
    @invitees = @event.invites.join('; ')

    mail bcc: @invitees, subject: "#{event.user.name} has invited you to #{event.title} on Calenshare"
  end

  #PREFERENCE NOTIFIERS, DEFAULT YES

  def confirm_follow(user, follower)

    mail to: user.email, subject: "You have a view request from: #{follower.name}"
  end

  def new_follower(user, follower)

    mail to: user.email, subject: "You have a new viewer from: #{follower.name}"
  end

  def noncritical_change(event)

    @guests = event.guests

    @guest_emails = []

    @guests.each do |g|
      if g.notify_noncritical_change?
        @guest_emails.push(g.email)
      end
    end

    @guest_emails.join('; ')

    mail bcc: @guest_emails, subject: "#{event.title.capitalize} now starts at #{event.chronic_starts_at}!"
  end
  
  #CHRON JOBS
  def digest
    @users = User.where('users.daily_digest = "t"')

    @users.each do |u|
      #@events = u.plans; something to send all plans, but need to lay this out

      mail to: u.email, subject: "Your daily digest from Calenshare!"
    end
  end
end
