import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "prevBtn", "nextBtn"];

  connect() {
    this.toggleButtons();
  }

  scrollNext() {
    this.containerTarget.scrollBy({ left: 488, behavior: "smooth" });
  }

  scrollPrev() {
    this.containerTarget.scrollBy({ left: -488, behavior: "smooth" });
  }

  toggleButtons() {
    const container = this.containerTarget;
    const showPrev = container.scrollLeft > 10;
    const showNext =
      container.scrollLeft < container.scrollWidth - container.clientWidth - 15;

    if (this.hasPrevBtnTarget) {
      this.prevBtnTarget.classList.toggle("pointer-events-none", !showPrev);
      this.prevBtnTarget.classList.toggle("opacity-0", !showPrev);
      this.prevBtnTarget.classList.toggle("group-hover:opacity-100", showPrev);
    }
    if (this.hasNextBtnTarget) {
      this.nextBtnTarget.classList.toggle("pointer-events-none", !showNext);
      this.nextBtnTarget.classList.toggle("opacity-0", !showNext);
      this.nextBtnTarget.classList.toggle("group-hover:opacity-100", showNext);
    }
  }
}
