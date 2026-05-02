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
        btn.classList.add("bg-blue-600")
        if (label) {
          label.classList.remove("text-gray-700")
          label.classList.add("text-white")
        }
      } else {
        btn.classList.remove("bg-blue-600")
        if (label) {
          label.classList.remove("text-white")
          label.classList.add("text-gray-700")
        }
      }
    })
  }
}
