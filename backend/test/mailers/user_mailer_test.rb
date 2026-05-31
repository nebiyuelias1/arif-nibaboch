require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "rsvp_confirmation" do
    user = users(:one)
    book_read = book_reads(:one)
    rsvp = BookReadRsvp.create!(user: user, book_read: book_read, status: :going)
    email = UserMailer.with(rsvp: rsvp).rsvp_confirmation

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ rsvp.user.email ], email.to
    assert_equal "RSVP Confirmation: #{rsvp.book_read.book.title}", email.subject
    assert_match "You have successfully RSVP'd", email.html_part.body.to_s
    assert_match "You have successfully RSVP'd", email.text_part.body.to_s

    assert_equal 1, email.attachments.size
    attachment = email.attachments[0]
    assert_equal "invite.ics", attachment.filename
    assert_equal "text/calendar", attachment.content_type.split(";")[0]
    assert_match "BEGIN:VCALENDAR", attachment.body.to_s
    assert_match "SUMMARY:Book Read: #{rsvp.book_read.book.title}", attachment.body.to_s
  end
end
