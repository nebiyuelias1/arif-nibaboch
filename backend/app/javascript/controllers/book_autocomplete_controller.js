import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "hidden", "results"];
  static values = { url: String };

  connect() {
    this.timeout = null;
    this.lastSelectedTitle = this.inputTarget.value;

    // Close dropdown when clicking outside
    document.addEventListener("click", (e) => {
      if (!this.element.contains(e.target)) {
        this.hideResults();
      }
    });
  }

  performSearch(event) {
    clearTimeout(this.timeout);
    const query = this.inputTarget.value.trim();

    // If user types something different from what was selected, clear the hidden ID
    if (event.type === "keyup" && query !== this.lastSelectedTitle) {
      this.hiddenTarget.value = "";
      this.lastSelectedTitle = "";
    }

    if (query.length < 2) {
      this.hideResults();
      return;
    }

    this.timeout = setTimeout(() => {
      this.fetchResults(query);
    }, 300);
  }

  fetchResults(query) {
    const url = `${this.urlValue}?query=${encodeURIComponent(query)}`;

    fetch(url, {
      headers: {
        Accept: "application/json",
      },
    })
      .then((response) => response.json())
      .then((data) => {
        this.renderResults(data);
      });
  }

  renderResults(books) {
    this.resultsTarget.innerHTML = "";

    if (books.length === 0) {
      this.resultsTarget.innerHTML = `<div class="p-3 text-sm text-gray-500 text-center">No books found.</div>`;
    } else {
      books.forEach((book) => {
        const item = document.createElement("div");
        item.className =
          "flex items-center p-3 hover:bg-blue-50 cursor-pointer border-b border-gray-100 last:border-b-0 transition-colors";

        let coverHtml = `<div class="w-8 h-12 bg-gray-200 rounded flex-shrink-0 flex items-center justify-center text-xs text-gray-400 mr-3">No Cover</div>`;
        if (book.cover_url) {
          coverHtml = `<img src="${book.cover_url}" class="w-8 h-12 object-cover rounded flex-shrink-0 mr-3 shadow-sm" alt="Cover">`;
        }

        item.innerHTML = `
          ${coverHtml}
          <div class="flex-1 min-w-0">
            <div class="text-sm font-bold text-gray-900 truncate">${book.title}</div>
            <div class="text-xs text-gray-500 truncate">by ${book.author}</div>
          </div>
        `;

        item.addEventListener("click", () => {
          this.selectBook(book.id, book.title);
        });

        this.resultsTarget.appendChild(item);
      });
    }

    this.showResults();
  }

  selectBook(id, title) {
    this.hiddenTarget.value = id;
    this.inputTarget.value = title;
    this.lastSelectedTitle = title;
    this.hideResults();

    this.inputTarget.classList.add(
      "ring-2",
      "ring-green-500",
      "border-green-500",
    );
    setTimeout(() => {
      this.inputTarget.classList.remove(
        "ring-2",
        "ring-green-500",
        "border-green-500",
      );
    }, 500);
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden");
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden");
  }
}
