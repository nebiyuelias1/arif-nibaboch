import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
    
    // Optional: Trigger any nested controllers if needed
    // This is useful for things like autocompletes in the new fields
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest("[data-dynamic-nested-fields-wrapper]")
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      wrapper.querySelector("input[name*='_destroy']").value = "1"
      wrapper.classList.add("hidden")
    }
  }
}
