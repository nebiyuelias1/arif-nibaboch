import { Controller } from "@hotwired/stimulus";

// Client-side tab switcher for the club detail page.
// Tabs are buttons with role="tab" carrying data-tab; panels are siblings with
// data-tab and the [hidden] attribute for the inactive ones. The active tab is
// marked with aria-selected="true" so Tailwind's aria-selected variant styles it.
export default class extends Controller {
  static targets = ["tab", "panel"];
  static values = { active: { type: String, default: "" } };

  connect() {
    const initial =
      this.activeValue ||
      this.tabTargets.find((tab) => tab.getAttribute("aria-selected") === "true")
        ?.dataset.tab ||
      this.tabTargets[0]?.dataset.tab;

    if (initial) this.show(initial);
  }

  select(event) {
    event.preventDefault();
    this.show(event.currentTarget.dataset.tab);
  }

  show(name) {
    if (!name) return;

    this.tabTargets.forEach((tab) => {
      tab.setAttribute("aria-selected", tab.dataset.tab === name ? "true" : "false");
    });

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.tab !== name;
    });
  }
}
