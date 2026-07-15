import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button", "count"];
  static values = {
    clubId: Number,
    activeClass: { type: String, default: "" },
    inactiveClass: { type: String, default: "" },
    activeText: { type: String, default: "Leave Club" },
    inactiveText: { type: String, default: "Join Club" }
  };

  connect() {}

  async toggle(event) {
    event.preventDefault();
    event.stopPropagation();
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

      if (response.status === 401 || response.status === 403) {
        window.location.href = "/users/sign_in";
        return;
      }

      if (response.redirected) {
        window.location.href = response.url;
        return;
      }

      const contentType = response.headers.get("content-type") || "";
      if (!contentType.includes("application/json")) {
        window.location.href = "/users/sign_in";
        return;
      }

      if (response.ok) {
        const data = await response.json();
        
        // Update the UI
        if (data.status === "joined") {
          this.buttonTarget.textContent = this.activeTextValue || "Leave Club";
          if (this.activeClassValue && this.inactiveClassValue) {
            this.buttonTarget.classList.remove(...this.inactiveClassValue.split(" "));
            this.buttonTarget.classList.add(...this.activeClassValue.split(" "));
          } else {
            this.buttonTarget.classList.replace("btn-primary", "btn-secondary");
          }
        } else {
          this.buttonTarget.textContent = this.inactiveTextValue || "Join Club";
          if (this.activeClassValue && this.inactiveClassValue) {
            this.buttonTarget.classList.remove(...this.activeClassValue.split(" "));
            this.buttonTarget.classList.add(...this.inactiveClassValue.split(" "));
          } else {
            this.buttonTarget.classList.replace("btn-secondary", "btn-primary");
          }
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
