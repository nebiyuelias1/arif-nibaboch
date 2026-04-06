import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "count"];
  static values = {
    clubId: Number,
  };

  connect() {}

  async toggle(event) {
    event.preventDefault();
    this.buttonTarget.disabled = true;

    try {
      const response = await fetch(`/book_clubs/${this.clubIdValue}/membership`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          accept: "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        },
      });

      if (response.ok) {
        const data = await response.json();
        
        // Update the UI
        if (data.status === "joined") {
          this.buttonTarget.textContent = "Leave Club";
          this.buttonTarget.classList.replace("btn-primary", "btn-secondary");
        } else {
          this.buttonTarget.textContent = "Join Club";
          this.buttonTarget.classList.replace("btn-secondary", "btn-primary");
        }

        // Update the counter
        if (this.hasCountTarget) {
          this.countTarget.textContent = data.count;
        }
      }
    } catch (error) {
      console.error("Failed to toggle membership", error);
    } finally {
      this.buttonTarget.disabled = false;
    }
  }
}
