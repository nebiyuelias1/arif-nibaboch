import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = {
    allowAll: Boolean // New value to skip check for public items
  }

  connect() {
    if (this.allowAllValue) {
      this.element.classList.remove("hidden")
      this.itemTargets.forEach(item => item.classList.remove("hidden"))
      return
    }

    const currentUserId = document.querySelector('meta[name="current-user-id"]')?.content
    if (!currentUserId) return

    let anyVisible = false

    this.itemTargets.forEach(item => {
      const allowedIds = JSON.parse(item.dataset.allowedIds || "[]").map(String)
      
      if (allowedIds.includes(String(currentUserId))) {
        item.classList.remove("hidden")
        anyVisible = true
      } else {
        item.classList.add("hidden")
      }
    })

    if (anyVisible) {
      this.element.classList.remove("hidden")
    } else {
      this.element.classList.add("hidden")
    }
  }
}
