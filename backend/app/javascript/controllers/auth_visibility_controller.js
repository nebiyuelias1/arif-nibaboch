import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];
  static values = {
    authorId: String,
    clubOwnerId: String,
  };

  connect() {
    const currentUserId = document.querySelector(
      'meta[name="current-user-id"]',
    )?.content;

    if (!currentUserId) return;

    const isAuthor = currentUserId === this.authorIdValue;
    const isClubOwner = currentUserId === this.clubOwnerIdValue;
    const isClubAdmin = this.clubAdminIdsValue.includes(
      parseInt(currentUserId),
    );

    if (isAuthor || isClubOwner || isClubAdmin) {
      this.menuTarget.classList.remove("hidden");
    }
  }
}
