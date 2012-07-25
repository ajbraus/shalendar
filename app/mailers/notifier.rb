class Notifier < ActionMailer::Base
  default from: "Calenshare@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.welcome.subject
  #


  #AUTOMATIC NOTIFIERS

  def welcome(user)
    #@calenshare = root_path

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

    @guests.each do |g|
      @guest_emails.push(g.email)
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

    mail bcc: @guest_emails, subject: "Your plan #{event.title} has changed location to #{event.location}!"
  end

  def send_invites(event)
    @invitees = @event.invites.join('; ')

    mail bcc: @invitees, subject: "Invitation to: #{event.title}"
  end

  #PREFERENCE NOTIFIERS, DEFAULT YES

  def confirm_follow(user, follower)

    mail to: user.email, subject: "You have a follow from: #{follower.fullname}"
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

    mail bcc: @guest_emails, subject: "Your plan #{event.title} has changed start time to #{event.chronic_starts_at}!"
  end

  #CHRON JOBS
  def digest
    @users = User.where('users.daily_digest = "t"')

    @users.each do |u|
      #@events = u.plans; something to send all plans, but need to lay this out

      mail to: u.email, subject: "Your daily digest from Calenshare!"
    end
  end

  def rsvp_reminder
    @greeting = "Hi"

    mail to: "to@example.org"
  end

end
