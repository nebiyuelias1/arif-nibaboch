module ClubHelper
  # Human label for the signed-in viewer's relationship to a club.
  # Returns nil when the viewer is not signed in or not a member, so callers
  # can skip rendering a status badge entirely.
  def club_member_role_label(club, user)
    return nil unless user

    membership = club.book_club_members.find_by(user: user)
    return nil unless membership
    return "Owner" if club.owner_id == user.id

    membership.admin? ? "Admin" : "Member"
  end

  # Whether the viewer can edit a reading session. Mirrors the controller's
  # authorize_club_owner! check, plus the host of the read.
  def can_manage_book_read?(club, book_read, user)
    return false unless user
    return true if book_read.host_id == user.id

    club.owner_id == user.id || club.book_club_members.exists?(user: user, role: :admin)
  end

  # Short human hint for a meetup time, e.g. "In 18 days • Saturday Afternoon".
  def relative_meetup_hint(time)
    return if time.blank?

    days = (time.to_date - Time.zone.today).to_i
    phrase =
      if days.zero?
        "Today"
      elsif days == 1
        "Tomorrow"
      elsif days.positive?
        "In #{pluralize(days, 'day')}"
      else
        "#{pluralize(days.abs, 'day')} ago"
      end

    period = if time.hour < 12
      "Morning"
    elsif time.hour < 17
      "Afternoon"
    else
      "Evening"
    end

    "#{phrase} • #{time.strftime('%A')} #{period}"
  end
end
