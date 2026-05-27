import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["starter", "substitute", "offInput", "onInput", "submit", "preview"]

  dragSubstitute(event) {
    this.selectSubstituteToken(event.currentTarget)
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.lineupAthleteId)
  }

  allowDrop(event) {
    if (!this.selectedSubstituteId) return

    event.preventDefault()
  }

  dropOnStarter(event) {
    event.preventDefault()
    this.selectStarterToken(event.currentTarget)
  }

  selectSubstitute(event) {
    this.selectSubstituteToken(event.currentTarget)
  }

  selectStarter(event) {
    this.selectStarterToken(event.currentTarget)
  }

  selectSubstituteToken(token) {
    this.selectedSubstituteId = token.dataset.lineupAthleteId
    this.selectedSubstituteName = token.dataset.playerName
    this.substituteTargets.forEach((target) => target.classList.toggle("is-selected", target === token))
    this.onInputTarget.value = this.selectedSubstituteId
    this.updatePreview()
  }

  selectStarterToken(token) {
    this.selectedStarterId = token.dataset.lineupAthleteId
    this.selectedStarterName = token.dataset.playerName
    this.starterTargets.forEach((target) => target.classList.toggle("is-selected", target === token))
    this.offInputTarget.value = this.selectedStarterId
    this.updatePreview()
  }

  updatePreview() {
    if (this.ready) {
      this.previewTarget.textContent = `${this.selectedSubstituteName} for ${this.selectedStarterName}`
      this.submitTarget.disabled = false
    } else if (this.selectedSubstituteName) {
      this.previewTarget.textContent = `${this.selectedSubstituteName} selected. Choose a player to replace.`
      this.submitTarget.disabled = true
    } else {
      this.previewTarget.textContent = "Select a substitute and a player to replace."
      this.submitTarget.disabled = true
    }
  }

  get ready() {
    return this.selectedStarterId && this.selectedSubstituteId
  }
}
