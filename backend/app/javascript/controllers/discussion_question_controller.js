import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form"]
  static values = {
    status: String,
    privilegedIds: Array
  }

  edit(event) {
    if (event) event.preventDefault()
    this.displayTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
  }

  confirmUpdate(event) {
    const currentUserId = document.querySelector('meta[name="current-user-id"]')?.content
    const isPrivileged = this.privilegedIdsValue.map(String).includes(String(currentUserId))
    const isDraft = this.statusValue === 'draft'

    if (!isDraft && !isPrivileged) {
      const msg = "Editing this question will reset its status to draft and it will need to be re-approved. Continue?"
      if (!window.confirm(msg)) {
        event.preventDefault()
      }
    }
  }

  cancel(event) {
    if (event) event.preventDefault()
    this.displayTarget.classList.remove("hidden")
    this.formTarget.classList.add("hidden")
    
    const formElement = this.formTarget.querySelector("form")
    if (formElement) {
      formElement.reset()
    }
  }
}
