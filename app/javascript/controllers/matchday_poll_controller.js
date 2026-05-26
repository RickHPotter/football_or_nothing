import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 1000 }
  }

  connect() {
    this.timer = window.setInterval(() => {
      if (document.visibilityState === "visible") {
        Turbo.visit(window.location.href, { action: "replace" })
      }
    }, this.intervalValue)
  }

  disconnect() {
    window.clearInterval(this.timer)
  }
}
