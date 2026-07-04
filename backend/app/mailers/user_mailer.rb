class UserMailer < ApplicationMailer
  default from: "#{Rails.configuration.x.app_name} <noreply@#{Rails.configuration.x.mail_from_domain}>" # this domain must be verified with Resend

  def rsvp_confirmation
    @rsvp = params[:rsvp]
    @user = @rsvp.user
    @book_read = @rsvp.book_read

    # Use the passed time_zone or default to Taipei (UTC+8)
    @time_zone = params[:time_zone] || "Taipei"

    cal = Icalendar::Calendar.new
    cal.event do |e|
      # Explicitly marking as UTC ensures calendars auto-adjust to user's local time
      e.dtstart     = Icalendar::Values::DateTime.new(@book_read.meetup_time.utc, tzid: "UTC")
      e.dtend       = Icalendar::Values::DateTime.new((@book_read.meetup_time + 2.hours).utc, tzid: "UTC")
      e.summary     = "Book Read: #{@book_read.book&.title || 'Discussion'}"
      e.description = "RSVP for #{@book_read.book_club.name}"
      e.location    = @book_read.meetup_location
      e.ip_class    = "PRIVATE"
    end

    attachments["invite.ics"] = {
      mime_type: "text/calendar",
      content: cal.to_ical
    }

    mail(to: @user.email, subject: "RSVP Confirmation: #{@book_read.book&.title || 'Book Read'}")
  end
end
