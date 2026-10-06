module ApplicationHelper
  def app_name
    Rails.configuration.x.app_name
  end

  LINK_HTML = { target: "_blank", rel: "noopener noreferrer", class: "text-primary hover:text-accent underline decoration-accent/40 underline-offset-2" }.freeze

  def formatted_text(text)
    return "" if text.blank?
    auto_link(simple_format(text), html: LINK_HTML)
  end

  def flash_classes(type)
    case type.to_sym
    when :notice, :success
      "bg-green-50 border-green-200 text-green-800"
    when :alert, :error
      "bg-red-50 border-red-200 text-red-800"
    when :warning
      "bg-yellow-50 border-yellow-200 text-yellow-800"
    else
      "bg-blue-50 border-blue-200 text-blue-800"
    end
  end

  # icon: references a shared icon partial (generated from root icons/ by `bundle exec rake theme:generate`)
  def main_navigation_items
    [
      {
        name: t("home_menu"),
        path: root_path,
        match_controllers: [ "home" ], # Match if we're in the home controller
        icon: "home"
      },
      {
        name: t("library_menu"),
        path: library_path,
        match_controllers: [ "books" ],
        icon: "library"
      },
      {
        name: t("club_menu"),
        path: book_clubs_path,
        match_controllers: [ "book_clubs" ],
        icon: "clubs"
      },
      {
        name: t("profile_menu"),
        path: user_signed_in? ? profile_path : new_user_session_path,
        match_controllers: [ "users", "devise/sessions", "devise/registrations", "devise/passwords" ],
        icon: "profile"
      }
    ]
  end

  def is_active_nav_item?(item)
    return false unless item[:match_controllers]

    # Check if the current controller name matches any in the item's list
    # e.g., if we are at /books/123, the controller is 'books'
    item[:match_controllers].include?(controller_name)
  end

  def show_bottom_nav?
    controller_name == "home" && action_name == "index"
  end
end
