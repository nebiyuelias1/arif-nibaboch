import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "bookSection", "pollSection", "selectionBtn" ]

  connect() {
    this.toggle()
  }

  toggle(event) {
    let selection;
    if (event) {
      const input = event.currentTarget.querySelector('input[type="radio"]')
      if (input) {
        input.checked = true
        selection = input.value
      } else {
        selection = event.target.value
      }
    } else {
      const checkedInput = this.element.querySelector('input[name="selection_type"]:checked')
      selection = checkedInput ? checkedInput.value : "book"
    }

    // Update Section Visibility
    if (selection === "book") {
      this.bookSectionTarget.classList.remove("hidden")
      this.pollSectionTarget.classList.add("hidden")
    } else {
      this.bookSectionTarget.classList.add("hidden")
      this.pollSectionTarget.classList.remove("hidden")
    }

    // Update Toggle Button Styling
    this.selectionBtnTargets.forEach(btn => {
      const input = btn.querySelector('input')
      const label = btn.querySelector('span')
      const isSelected = input.value === selection
      
      if (isSelected) {
        btn.classList.add("bg-primary")
        btn.classList.remove("bg-transparent")
        if (label) {
          label.classList.remove("text-content")
          label.classList.add("text-primary-contrast")
        }
      } else {
        btn.classList.remove("bg-primary")
        btn.classList.add("bg-transparent")
        if (label) {
          label.classList.remove("text-primary-contrast")
          label.classList.add("text-content")
        }
      }
    })
  }
}
