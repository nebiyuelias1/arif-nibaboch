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
    assert_match "UID:book-read-#{book_read.id}-rsvp-#{rsvp.id}@", attachment.body.to_s
    assert_match "SEQUENCE:0", attachment.body.to_s
    assert_match "METHOD:REQUEST", attachment.body.to_s
    assert_match "ORGANIZER", attachment.body.to_s
    assert_match "ATTENDEE", attachment.body.to_s
    assert_match "mailto:#{user.email}", attachment.body.to_s
  end

  test "book_read_updated_invite" do
    user = users(:one)
    book_read = book_reads(:one)
    rsvp = BookReadRsvp.create!(user: user, book_read: book_read, status: :going)
    book_read.update!(meetup_location: "Updated Room 404")

    email = UserMailer.with(rsvp: rsvp).book_read_updated_invite

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ rsvp.user.email ], email.to
    assert_equal "[Updated Calendar Invite] Book Read: #{rsvp.book_read.book.title}", email.subject
    assert_match "Calendar Invite Updated", email.html_part.body.to_s
    assert_match "Updated Room 404", email.html_part.body.to_s

    assert_equal 1, email.attachments.size
    attachment = email.attachments[0]
    assert_equal "invite.ics", attachment.filename
    assert_match "UID:book-read-#{book_read.id}-rsvp-#{rsvp.id}@", attachment.body.to_s
    assert_match "SEQUENCE:1", attachment.body.to_s
    assert_match "METHOD:REQUEST", attachment.body.to_s
    assert_match "LOCATION:Updated Room 404", attachment.body.to_s
    assert_match "ORGANIZER", attachment.body.to_s
    assert_match "ATTENDEE", attachment.body.to_s
    assert_match "mailto:#{user.email}", attachment.body.to_s
  end

  test "book_read_reminder_email" do
    user = users(:one)
    book_read = book_reads(:one)
    rsvp = BookReadRsvp.create!(user: user, book_read: book_read, status: :going)
    email = UserMailer.with(rsvp: rsvp).book_read_reminder_email

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ rsvp.user.email ], email.to
    assert_equal "Reminder: Upcoming Book Read for #{rsvp.book_read.book.title}", email.subject
    assert_match "Upcoming Book Read Reminder", email.html_part.body.to_s
    assert_match "Upcoming Book Read Reminder", email.text_part.body.to_s
    assert_match book_read.meetup_location, email.html_part.body.to_s
    assert_match book_read.meetup_location, email.text_part.body.to_s
    assert_equal 0, email.attachments.size
  end

  test "membership_request_decision approved notifies the requester" do
    book_club = book_clubs(:one)
    requester = users(:three)
    request = book_club.membership_requests.create!(user: requester, status: :pending)
    request.approve!

    email = UserMailer.with(membership_request: request).membership_request_decision

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ requester.email ], email.to
    assert_equal "Join Request Approved: #{book_club.name}", email.subject
    assert_match "has been approved", email.html_part.body.to_s
    assert_match "has been approved", email.text_part.body.to_s
    assert_match "Welcome to the club", email.html_part.body.to_s
    assert_match "Welcome to the club", email.text_part.body.to_s
    assert_match "/book_clubs/#{book_club.id}", email.text_part.body.to_s
    assert_equal 0, email.attachments.size
  end

  test "membership_request_decision rejected notifies the requester" do
    book_club = book_clubs(:one)
    requester = users(:three)
    request = book_club.membership_requests.create!(user: requester, status: :pending)
    request.reject!

    email = UserMailer.with(membership_request: request).membership_request_decision

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ requester.email ], email.to
    assert_equal "Join Request Rejected: #{book_club.name}", email.subject
    assert_match "was not approved", email.html_part.body.to_s
    assert_match "was not approved", email.text_part.body.to_s
    assert_no_match(/Welcome/, email.text_part.body.to_s)
    assert_equal 0, email.attachments.size
  end
end
