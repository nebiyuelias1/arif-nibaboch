import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["canvas"];
  static values = { title: String, coverUrl: String };

  connect() {
    this.drawFlyer();
  }

  async drawFlyer() {
    const canvas = this.canvasTarget;
    const ctx = canvas.getContext("2d");

    const img = await this.loadImage(this.coverUrlValue);

    if (img) {
      ctx.drawImage(img, 50, 50, 150, 225);
    }

    ctx.fillText(this.titleValue, canvas.width / 2, canvas.height / 2);
  }

  loadImage(src) {
    return new Promise((resolve) => {
      const img = new Image();
      img.crossOrigin = "anonymous";

      img.onload = () => resolve(img);
      img.onerror = () => {
        console.error("Could not load image: " + src);
        resolve(null);
      };

      img.src = src;
    });
  }

  download() {
    const canvas = this.canvasTarget;

    const dataUrl = canvas.toDataURL("image/png");

    const link = document.createElement("a");

    link.download = `book-club-flyer.png`;
    link.href = dataUrl;

    link.click();
  }
}
