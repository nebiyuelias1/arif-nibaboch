# Timezone Auto-Detection Strategy

To ensure that user-inputted dates (like poll end dates or meetup times) are correctly interpreted and displayed in the user's local time, we will implement an automatic timezone detection mechanism using a JavaScript Stimulus controller and a cookie.

## Steps

### 1. Create a Timezone Detection Stimulus Controller
Create `app/javascript/controllers/timezone_controller.js` to detect the browser's timezone and store it in a cookie.

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone
    if (this.getCookie("user_time_zone") !== tz) {
      this.setCookie("user_time_zone", tz, 365)
      // Optional: Refresh the page if the timezone just changed to ensure server-side rendering is correct
      // window.location.reload()
    }
  }

  setCookie(name, value, days) {
    let expires = ""
    if (days) {
      const date = new Date()
      date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000))
      expires = "; expires=" + date.toUTCString()
    }
    document.cookie = name + "=" + (value || "") + expires + "; path=/; SameSite=Lax"
  }

  getCookie(name) {
    const nameEQ = name + "="
    const ca = document.cookie.split(';')
    for (let i = 0; i < ca.length; i++) {
      let c = ca[i]
      while (c.charAt(0) === ' ') c = c.substring(1, c.length)
      if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length)
    }
    return null
  }
}
```

### 2. Attach the Controller to the Layout
Modify `app/views/layouts/application.html.erb` to include the `data-controller="timezone"` on the `<body>` tag.

### 3. Update ApplicationController to use the Timezone
Add an `around_action` in `app/controllers/application_controller.rb` to set the timezone for each request.

```ruby
class ApplicationController < ActionController::Base
  around_action :set_time_zone

  private

  def set_time_zone(&block)
    time_zone = cookies[:user_time_zone] || Time.zone.name
    Time.use_zone(time_zone, &block)
  end
end
```

### 4. Benefits
- **Automatic:** No user configuration required.
- **Consistent Storage:** Database stays in UTC.
- **Accurate Input:** Form inputs are interpreted as being in the user's timezone.
- **Accurate Display:** Values retrieved from the database are automatically converted to the user's timezone when displayed in views.

### 5. Validation
- Create a poll and check if the `end_date` matches your local input.
- Check the database (via console) to verify it's stored as UTC with the correct offset applied.
- View the poll and verify the displayed date matches your local time.
