import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["minute", "status"]
  static values = {
    interval: { type: Number, default: 500 },
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
      this.updateEvents(payload)
      if (payload.status_key !== "running") {
        const url = new URL(window.location.href)
        url.searchParams.set("details", "true")
        Turbo.visit(url.toString(), { action: "replace" })
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

  updateEvents(payload) {
    Object.entries(payload.fixtures).forEach(([fixtureId, fixture]) => {
      const target = this.element.querySelector(`[data-fixture-events-id="${fixtureId}"]`)
      if (!target) return

      target.replaceChildren(...fixture.events.map((event) => this.eventElement(event)))
    })
  }

  eventElement(event) {
    const item = document.createElement("li")
    item.textContent = `${event.minute}' ${event.event_type} - ${event.description}`
    return item
  }
}
