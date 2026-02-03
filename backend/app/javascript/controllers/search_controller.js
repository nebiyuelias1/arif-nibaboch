import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "loader"]

  connect() {
    this.resultsTarget.addEventListener("turbo:frame-load", () => {
      this.hideLoader()
    })
  }

  perform() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.search()
    }, 300)
  }

  search() {
    const query = this.inputTarget.value.trim()
    const resultsFrame = this.resultsTarget

    if (query.length < 2) {
      resultsFrame.innerHTML = ""
      resultsFrame.src = null
      this.hideLoader()
      return
    }

    resultsFrame.innerHTML = ""
    this.showLoader()

    const url = `/books/search?query=${encodeURIComponent(query)}`
    resultsFrame.src = url
  }

  showLoader() {
    this.loaderTarget.classList.remove("hidden")
  }

  hideLoader() {
    this.loaderTarget.classList.add("hidden")
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
