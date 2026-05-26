import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["minute", "status"]
  static values = {
    interval: { type: Number, default: 250 },
    url: String
  }

  connect() {
    this.timer = window.setInterval(() => this.refresh(), this.intervalValue)
  }

  disconnect() {
    window.clearInterval(this.timer)
  }

  async refresh() {
    if (document.visibilityState !== "visible" || this.requesting) return

    this.requesting = true

    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "application/json" }
      })
      if (!response.ok) return

      const payload = await response.json()
      this.updateClock(payload)
      this.updateScores(payload)
      if (payload.status_key !== "running") {
        Turbo.visit(window.location.href, { action: "replace" })
      }
    } finally {
      this.requesting = false
    }
  }

  updateClock(payload) {
    this.minuteTarget.textContent = payload.minute
    this.statusTarget.textContent = payload.status
  }

  updateScores(payload) {
    Object.entries(payload.fixtures).forEach(([fixtureId, fixture]) => {
      const target = this.element.querySelector(`[data-fixture-score-id="${fixtureId}"]`)
      if (target) target.textContent = fixture.scoreline
    })
  }
}
