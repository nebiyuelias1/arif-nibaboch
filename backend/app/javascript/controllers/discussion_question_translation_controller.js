import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["translationContent", "button"];

  connect() {
    if (this.hasButtonTarget) {
      this.select(this.buttonTargets[0]);
    }
  }

  showTranslation(event) {
    this.select(event.currentTarget);
  }

  select(button) {
    const content = button.dataset.discussionQuestionTranslationContentParam;
    this.translationContentTarget.textContent = content;

    this.buttonTargets.forEach((btn) => {
      btn.classList.remove(
        "bg-primary",
        "text-primary-contrast",
        "border-primary",
      );
      btn.classList.add("bg-surface", "text-content", "border-border");
      btn.setAttribute("aria-pressed", "false");
    });

    button.classList.add(
      "bg-primary",
      "text-primary-contrast",
      "border-primary",
    );
    button.classList.remove("bg-surface", "text-content", "border-border");
    btn.setAttribute("aria-pressed", "true");
  }
}
