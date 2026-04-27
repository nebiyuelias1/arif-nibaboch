import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["bookSection", "pollSection"];

  connect() {
    this.updateVisibility();
  }

  selectBook() {
    this.mode = "book";
    this.updateVisibility();
  }

  selectPoll() {
    this.mode = "poll";
    this.updateVisibility();
  }

  get mode() {
    const el = this.element.querySelector('input[name="book_read[book_selection_mode]"]:checked');
    return el ? el.value : "book";
  }

  set mode(value) {
    const el = this.element.querySelector(`input[name="book_read[book_selection_mode]"][value="${value}"]`);
    if (el) el.checked = true;
  }

  updateVisibility() {
    if (this.mode === "book") {
      this.bookSectionTarget.classList.remove("hidden");
      this.pollSectionTarget.classList.add("hidden");
    } else {
      this.bookSectionTarget.classList.add("hidden");
      this.pollSectionTarget.classList.remove("hidden");

      const hiddenBookInput = this.bookSectionTarget.querySelector(
        'input[type="hidden"]',
      );
      if (hiddenBookInput) hiddenBookInput.value = "";
      const visibleBookInput =
        this.bookSectionTarget.querySelector('input[type="text"]');
      if (visibleBookInput) visibleBookInput.value = "";
    }
  }
}
