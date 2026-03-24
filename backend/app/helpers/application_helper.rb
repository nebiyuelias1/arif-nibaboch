module ApplicationHelper
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

  def main_navigation_items
    [
      {
        name: "Home",
        path: root_path,
        match_controllers: ["books"], # Match if we're in the books controller
        icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/>'
      },
      {
        name: "Library",
        path: library_path,
        match_controllers: ["libraries"],
        icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25"/>'
      },
      {
        name: "Clubs",
        path: book_clubs_path,
        match_controllers: ["clubs"],
        icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>'
      },
      {
        name: "Profile",
        path: user_signed_in? ? profile_path : new_user_session_path,
        match_controllers: ["users", "devise/sessions", "devise/registrations", "devise/passwords"],
        icon: '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>'
      }
    ]
  end
  
  def is_active_nav_item?(item)
    return false unless item[:match_controllers]
    
    # Check if the current controller name matches any in the item's list
    # e.g., if we are at /books/123, the controller is 'books'
    item[:match_controllers].include?(controller_name)
  end
end
