import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    clubName: String,
    title: String,
    author: String,
    time: String,
    location: String,
    host: String,
    coverUrl: String,
    rsvpUrl: String,
    bookReadId: String
  };

  async download() {
    this.setLoading(true);
    try {
      const canvas = await this.drawFlyerCanvas();
      const dataUrl = canvas.toDataURL("image/png");
      
      const link = document.createElement("a");
      link.download = `meetup-story-flyer-${this.bookReadIdValue}.png`;
      link.href = dataUrl;
      link.click();
      
      this.notify("Flyer downloaded successfully!");
    } catch (error) {
      console.error("Failed to download flyer:", error);
      this.notify("Failed to generate flyer.", "error");
    } finally {
      this.setLoading(false);
    }
  }

  async share() {
    this.setLoading(true);
    try {
      const canvas = await this.drawFlyerCanvas();
      const blob = await new Promise(resolve => canvas.toBlob(resolve, "image/png"));
      
      if (!blob) {
        this.download();
        return;
      }

      const filename = `meetup-story-flyer-${this.bookReadIdValue}.png`;
      const file = new File([blob], filename, { type: "image/png" });

      if (navigator.canShare && navigator.canShare({ files: [file] })) {
        await navigator.share({
          files: [file],
          title: "Book Club Meetup Flyer",
          text: `Join us at ${this.clubNameValue} for a discussion on "${this.titleValue}"!`,
        });
      } else {
        this.download();
      }
    } catch (error) {
      if (error?.name === "AbortError") return;
      console.error("Failed to share flyer:", error);
      this.download();
    } finally {
      this.setLoading(false);
    }
  }

  async drawFlyerCanvas() {
    const canvas = document.createElement("canvas");
    canvas.width = 1080;  // Instagram Story standard width
    canvas.height = 1920; // Instagram Story standard height
    const ctx = canvas.getContext("2d");

    // Coordinates & Padding Settings
    const padding = 80;
    const W = canvas.width;
    const H = canvas.height;

    // 1. Background (Deep space gradient)
    const bgGradient = ctx.createLinearGradient(0, 0, 0, H);
    bgGradient.addColorStop(0, "#090d16");
    bgGradient.addColorStop(0.5, "#020617");
    bgGradient.addColorStop(1, "#12102e");
    ctx.fillStyle = bgGradient;
    ctx.fillRect(0, 0, W, H);

    // Glowing atmospheric lights (Top Indigo, Bottom Purple)
    const glow1 = ctx.createRadialGradient(W / 2, 250, 100, W / 2, 250, 600);
    glow1.addColorStop(0, "rgba(99, 102, 241, 0.3)"); // Indigo
    glow1.addColorStop(1, "rgba(99, 102, 241, 0)");
    ctx.fillStyle = glow1;
    ctx.fillRect(0, 0, W, H);

    const glow2 = ctx.createRadialGradient(W / 2, H - 400, 100, W / 2, H - 400, 600);
    glow2.addColorStop(0, "rgba(168, 85, 247, 0.24)"); // Purple
    glow2.addColorStop(1, "rgba(168, 85, 247, 0)");
    ctx.fillStyle = glow2;
    ctx.fillRect(0, 0, W, H);

    // Helper: Rounded Rectangle path builder
    const drawRoundedRect = (x, y, w, h, r) => {
      ctx.beginPath();
      ctx.moveTo(x + r, y);
      ctx.lineTo(x + w - r, y);
      ctx.quadraticCurveTo(x + w, y, x + w, y + r);
      ctx.lineTo(x + w, y + h - r);
      ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
      ctx.lineTo(x + r, y + h);
      ctx.quadraticCurveTo(x, y + h, x, y + h - r);
      ctx.lineTo(x, y + r);
      ctx.quadraticCurveTo(x, y, x + r, y);
      ctx.closePath();
    };

    // Helper: Wrap text helper (with alignment support)
    const wrapText = (text, x, y, maxWidth, lineHeight, maxLines = 10, align = "left") => {
      const words = text.split(/\s+/);
      let line = "";
      let currentY = y;
      let linesCount = 0;
      ctx.textAlign = align;
      
      for (let n = 0; n < words.length; n++) {
        let testLine = line + words[n] + " ";
        let metrics = ctx.measureText(testLine);
        let testWidth = metrics.width;
        if (testWidth > maxWidth && n > 0) {
          linesCount++;
          if (linesCount === maxLines) {
            ctx.fillText(line.trim() + "...", x, currentY);
            return currentY;
          }
          ctx.fillText(line, x, currentY);
          line = words[n] + " ";
          currentY += lineHeight;
        } else {
          line = testLine;
        }
      }
      if (linesCount < maxLines) {
        ctx.fillText(line, x, currentY);
      }
      return currentY;
    };

    // Draw clean frame border around the flyer (24px padding from edge)
    ctx.strokeStyle = "rgba(255, 255, 255, 0.05)";
    ctx.lineWidth = 3;
    drawRoundedRect(24, 24, W - 48, H - 48, 36);
    ctx.stroke();

    // 2. Header Block
    ctx.textAlign = "left";
    ctx.textBaseline = "top";
    
    // Subtitle & Club Name (Enlarged and positioned higher)
    ctx.fillStyle = "#a5b4fc";
    ctx.font = "bold 30px sans-serif";
    ctx.fillText("BOOK CLUB MEETUP", padding, 70);

    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 58px sans-serif";
    ctx.fillText(this.clubNameValue, padding, 115);

    // Separator line below header (tightened gap)
    ctx.strokeStyle = "rgba(255, 255, 255, 0.08)";
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(padding, 195);
    ctx.lineTo(W - padding, 195);
    ctx.stroke();

    // Reset baseline for body
    ctx.textBaseline = "top";

    // 3. Load Images concurrently
    const coverPromise = this.coverUrlValue ? this.loadImage(this.coverUrlValue) : Promise.resolve(null);
    const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(this.rsvpUrlValue)}`;
    const qrPromise = this.loadImage(qrUrl);

    const [coverImg, qrImg] = await Promise.all([coverPromise, qrPromise]);

    // 4. Draw Centered Cover Image (Maximized size: 520x780, positioned tightly at y: 235)
    const coverWidth = 520;
    const coverHeight = 780;
    const coverX = (W - coverWidth) / 2; // Center horizontally
    const coverY = 235;

    if (coverImg) {
      ctx.save();
      // Drop Shadow for Cover Image
      ctx.shadowColor = "rgba(0, 0, 0, 0.65)";
      ctx.shadowBlur = 45;
      ctx.shadowOffsetX = 0;
      ctx.shadowOffsetY = 22;
      
      drawRoundedRect(coverX, coverY, coverWidth, coverHeight, 32);
      ctx.fillStyle = "#020617";
      ctx.fill();
      ctx.restore();

      // Draw the image clipped inside rounded corners
      ctx.save();
      drawRoundedRect(coverX, coverY, coverWidth, coverHeight, 32);
      ctx.clip();
      ctx.drawImage(coverImg, coverX, coverY, coverWidth, coverHeight);
      ctx.restore();

      // Clean thin border overlay
      ctx.strokeStyle = "rgba(255, 255, 255, 0.12)";
      ctx.lineWidth = 2;
      drawRoundedRect(coverX, coverY, coverWidth, coverHeight, 32);
      ctx.stroke();
    } else {
      // Placeholder for Active Poll
      ctx.fillStyle = "rgba(255, 255, 255, 0.03)";
      drawRoundedRect(coverX, coverY, coverWidth, coverHeight, 32);
      ctx.fill();
      ctx.strokeStyle = "rgba(255, 255, 255, 0.08)";
      ctx.lineWidth = 1.5;
      ctx.stroke();

      // Placeholder icon/text
      ctx.fillStyle = "#a5b4fc";
      ctx.font = "bold 100px sans-serif";
      ctx.textAlign = "center";
      ctx.fillText("📝", W / 2, coverY + 260);

      ctx.font = "bold 32px sans-serif";
      ctx.fillStyle = "#a5b4fc";
      ctx.fillText("ACTIVE POLL", W / 2, coverY + 410);
      ctx.font = "24px sans-serif";
      ctx.fillStyle = "#64748b";
      ctx.fillText("Voting in Progress", W / 2, coverY + 468);
    }

    // 5. Draw Book Details (Center-aligned, positioned closely below cover y: 1045)
    let currentY = 1045;
    const bodyWidth = W - (padding * 2); // 920

    // Title (Centered, maximum font size)
    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 64px sans-serif";
    const titleLastY = wrapText(this.titleValue, W / 2, currentY, bodyWidth, 76, 3, "center");
    currentY = titleLastY + 60;

    // Author (Centered, maximum font size)
    if (this.authorValue) {
      ctx.fillStyle = "#c7d2fe"; // Indigo-200
      ctx.font = "italic 42px sans-serif";
      ctx.textAlign = "center";
      ctx.fillText(`by ${this.authorValue}`, W / 2, currentY);
      currentY += 80;
    } else {
      currentY += 20;
    }

    // 6. Draw Meetup Info Box (Positioned tightly at y: 1250 with massive fonts)
    const boxY = 1250;
    const boxW = W - (padding * 2); // 920
    const boxH = 340;
    const boxX = padding;

    ctx.fillStyle = "rgba(255, 255, 255, 0.03)";
    drawRoundedRect(boxX, boxY, boxW, boxH, 24);
    ctx.fill();
    
    // Card border
    ctx.strokeStyle = "rgba(255, 255, 255, 0.06)";
    ctx.lineWidth = 2;
    drawRoundedRect(boxX, boxY, boxW, boxH, 24);
    ctx.stroke();

    // Box Title
    ctx.textAlign = "left";
    ctx.fillStyle = "#a5b4fc";
    ctx.font = "bold 26px sans-serif";
    ctx.fillText("MEETUP DETAILS", boxX + 40, boxY + 36);

    // Box Rows (Maximum font size: 42px, highly readable)
    ctx.fillStyle = "#f1f5f9";
    ctx.font = "bold 42px sans-serif";
    ctx.fillText(`📅  Time:  ${this.timeValue}`, boxX + 40, boxY + 100);
    ctx.fillText(`📍  Location:  ${this.locationValue}`, boxX + 40, boxY + 175);

    ctx.fillStyle = "#cbd5e1";
    ctx.font = "40px sans-serif";
    ctx.fillText(`👤  Host:  ${this.hostValue}`, boxX + 40, boxY + 250);

    // 7. Footer Block (Positioned higher, y: 1650)
    const footerY = 1650;
    ctx.strokeStyle = "rgba(255, 255, 255, 0.08)";
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(padding, footerY);
    ctx.lineTo(W - padding, footerY);
    ctx.stroke();

    // Left Footer Text (Scaled up)
    ctx.fillStyle = "#a5b4fc";
    ctx.font = "bold 32px sans-serif";
    ctx.fillText("SCAN TO RSVP", padding, footerY + 35);

    ctx.fillStyle = "#94a3b8";
    ctx.font = "26px sans-serif";
    wrapText(this.rsvpUrlValue, padding, footerY + 80, W - padding - 220, 32, 2, "left");

    // Right Footer QR Code (160x160)
    if (qrImg) {
      ctx.save();
      const qrSize = 160;
      const qrX = W - padding - qrSize;
      const qrY = footerY + 20;
      drawRoundedRect(qrX, qrY, qrSize, qrSize, 14);
      ctx.fillStyle = "#ffffff";
      ctx.fill();
      ctx.clip();
      ctx.drawImage(qrImg, qrX + 6, qrY + 6, qrSize - 12, qrSize - 12);
      ctx.restore();
    }

    return canvas;
  }

  loadImage(src) {
    return new Promise((resolve) => {
      const img = new Image();
      img.crossOrigin = "anonymous";
      img.onload = () => resolve(img);
      img.onerror = (e) => {
        console.warn(`Failed to load image: ${src}`, e);
        resolve(null);
      };
      img.src = src;
    });
  }

  setLoading(isLoading) {
    const buttons = this.element.querySelectorAll("button");
    buttons.forEach(btn => {
      if (isLoading) {
        btn.setAttribute("disabled", "true");
        btn.style.opacity = "0.7";
      } else {
        btn.removeAttribute("disabled");
        btn.style.opacity = "1";
      }
    });
  }

  notify(text, type = "success") {
    if (window.toast) {
      window.toast(text, { type });
    } else {
      alert(text);
    }
  }
}
