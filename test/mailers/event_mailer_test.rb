require "test_helper"

class EventMailerTest < ActionMailer::TestCase
  test "participation_confirmation" do
    mail = EventMailer.participation_confirmation
    assert_equal "Participation confirmation", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "event_reminder" do
    mail = EventMailer.event_reminder
    assert_equal "Event reminder", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
