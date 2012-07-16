class Notifier < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.welcome.subject
  #
  def welcome(user)
    @user = user

    mail to: user.email, subject: "Welcome to Calenshare"

  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.cancellation.subject
  #
  def cancellation
    @event = event
    @rsvps = event.rsvp.all.join("; ")

    mail bcc: @rsvps
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
