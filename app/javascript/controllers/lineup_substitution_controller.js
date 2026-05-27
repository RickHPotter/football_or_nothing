import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "starter",
    "substitute",
    "substitutionForm",
    "swapForm",
    "offInput",
    "onInput",
    "fromInput",
    "toInput",
  ]

  dragToken(event) {
    this.draggedToken = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.lineupAthleteId)
  }

  allowDrop(event) {
    if (!this.draggedToken) return

    event.preventDefault()
  }

  dropOnToken(event) {
    event.preventDefault()

    const source = this.draggedToken || this.findToken(event.dataTransfer.getData("text/plain"))
    this.draggedToken = null
    this.clearSelection()
    this.submitMove(source, event.currentTarget)
  }

  selectToken(event) {
    const token = event.currentTarget

    if (!this.selectedToken) {
      this.markSelected(token)
      return
    }

    if (this.selectedToken === token) {
      this.clearSelection()
      return
    }

    if (this.canSubmitMove(this.selectedToken, token)) {
      this.submitMove(this.selectedToken, token)
    } else {
      this.markSelected(token)
    }
  }

  submitMove(source, target) {
    if (!source || !target || source === target) return

    if (this.isStarter(source) && this.isStarter(target)) {
      this.submitSwap(source, target)
    } else if (this.isSubstitution(source, target)) {
      this.submitSubstitution(source, target)
    }
  }

  submitSwap(source, target) {
    if (!this.hasSwapFormTarget) return

    this.fromInputTarget.value = source.dataset.lineupAthleteId
    this.toInputTarget.value = target.dataset.lineupAthleteId
    this.submitForm(this.swapFormTarget)
  }

  submitSubstitution(source, target) {
    if (!this.hasSubstitutionFormTarget) return

    const starter = this.isStarter(source) ? source : target
    const substitute = this.isSubstitute(source) ? source : target

    this.offInputTarget.value = starter.dataset.lineupAthleteId
    this.onInputTarget.value = substitute.dataset.lineupAthleteId
    this.submitForm(this.substitutionFormTarget)
  }

  submitForm(form) {
    if (form.requestSubmit) {
      form.requestSubmit()
    } else {
      form.submit()
    }
  }

  canSubmitMove(source, target) {
    return (this.isStarter(source) && this.isStarter(target)) || this.isSubstitution(source, target)
  }

  isSubstitution(source, target) {
    return (this.isStarter(source) && this.isSubstitute(target)) || (this.isSubstitute(source) && this.isStarter(target))
  }

  isStarter(token) {
    return token.dataset.lineupTokenKind === "starter"
  }

  isSubstitute(token) {
    return token.dataset.lineupTokenKind === "substitute"
  }

  markSelected(token) {
    this.clearSelection()
    this.selectedToken = token
    token.classList.add("is-selected")
  }

  clearSelection() {
    this.selectedToken = null
    this.starterTargets.forEach((target) => target.classList.remove("is-selected"))
    this.substituteTargets.forEach((target) => target.classList.remove("is-selected"))
  }

  findToken(lineupAthleteId) {
    return [...this.starterTargets, ...this.substituteTargets].find((target) => target.dataset.lineupAthleteId === lineupAthleteId)
  }
}
