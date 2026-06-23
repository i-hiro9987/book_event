class EventMailerPreview < ActionMailer::Preview
  def participation_confirmation
    participation = Participation.first
    EventMailer.participation_confirmation(participation)
  end

  def event_reminder
    event = Event.first
    user = event.participations.first.user
    EventMailer.event_reminder(event, user)
  end
end