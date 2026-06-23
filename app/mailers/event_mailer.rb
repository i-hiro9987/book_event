class EventMailer < ApplicationMailer
  default from: 'noreply@eventhub.example.com'

  def participation_confirmation(participation)
    @participation = participation
    @event = participation.event
    @user = participation.user

    mail(
      to: @user.email,
      subject: "【EventHub】#{@event.name} への参加を受け付けました"
    )
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.event_mailer.event_reminder.subject
  #
  def event_reminder(event, user)
    @event = event
    @user = user
    @participation = event.participations.find_by(user: user)

    mail(
      to: @user.email,
      subject: "【EventHub】明日開催:#{@event.name}"
    )
  end
end
