// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
  if (window.Telegram && window.Telegram.WebApp) {
    const webapp = window.Telegram.WebApp;
    webapp.ready(); // Tells Telegram the app is ready to be displayed

    // Optional: Expand to full height immediately
    webapp.expand();
  } else {
    console.warn("Telegram WebApp SDK not found.");
  }
});
