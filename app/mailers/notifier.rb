class Notifier < ActionMailer::Base
  default from: "Calenshare@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.welcome.subject
  #
  def welcome(user)
    @calenshare = root_path
    mail to: user.email, subject: "Welcome to Calenshare"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.cancellation.subject
  #
  def cancellation(event)
    @guests = event.guests

    @guest_emails = []

    @guests.each do |g|
      @guest_emails.push(g.email)
    end

    @guest_emails.join('; ')

    mail bcc: @guest_emails
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.confirm_follow.subject
  #
  def confirm_follow
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.rsvp_reminder.subject
  #
  def rsvp_reminder
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.event_tipped.subject
  #
  def event_tipped
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.digest.subject
  #
  def digest
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
