/**
 * PhiaMentionInput — @mention textarea hook for PhiaUI
 *
 * Detects when the user types `@` in a textarea, extracts the search term,
 * and pushes a `mention_search` event to the server via pushEvent.
 * When the server responds (by updating `open` + `suggestions`), the dropdown
 * renders server-side. On selection (via phx-click on a suggestion), the hook
 * inserts the mention text into the textarea and updates the hidden IDs input.
 *
 * ## Setup
 *
 *     import PhiaMentionInput from "./hooks/mention_input"
 *     let liveSocket = new LiveSocket("/live", Socket, {
 *       hooks: { PhiaMentionInput }
 *     })
 *
 * ## Required data attributes on the textarea
 *
 * - `data-on-mention` — server event name for search (e.g. "mention_search")
 * - `data-on-select` — server event name for selection (e.g. "mention_select")
 *
 * ## Server events emitted
 *
 * - `mention_search` — `%{query: string}` when user types after @
 * - `mention_close` — `%{}` when mention is cancelled (space/escape after @)
 */
const PhiaMentionInput = {
  mounted() {
    this.textarea = this.el
    this.mentionActive = false
    this.mentionStart = -1

    this._onKeyUp = this._handleKeyUp.bind(this)
    this._onKeyDown = this._handleKeyDown.bind(this)
    this.textarea.addEventListener("keyup", this._onKeyUp)
    this.textarea.addEventListener("keydown", this._onKeyDown)
  },

  destroyed() {
    this.textarea.removeEventListener("keyup", this._onKeyUp)
    this.textarea.removeEventListener("keydown", this._onKeyDown)
  },

  _handleKeyDown(event) {
    // Close dropdown on Escape
    if (event.key === "Escape" && this.mentionActive) {
      this._closeMention()
    }
  },

  _handleKeyUp(event) {
    const { selectionStart, value } = this.textarea

    // Detect @ character typed
    if (event.key === "@" || (event.key !== "Backspace" && this.mentionActive)) {
      const textBefore = value.slice(0, selectionStart)
      const atIndex = textBefore.lastIndexOf("@")

      if (atIndex !== -1) {
        const term = textBefore.slice(atIndex + 1)

        // If no space after @, we're in mention mode
        if (!term.includes(" ")) {
          this.mentionActive = true
          this.mentionStart = atIndex
          const onMention = this.el.dataset.onMention
          if (onMention) {
            this.pushEvent(onMention, { query: term })
          }
          return
        }
      }

      this._closeMention()
    } else if (event.key === "Backspace" && this.mentionActive) {
      const textBefore = value.slice(0, selectionStart)
      const atIndex = textBefore.lastIndexOf("@")
      if (atIndex === -1 || textBefore.slice(atIndex + 1).includes(" ")) {
        this._closeMention()
      }
    }
  },

  _closeMention() {
    if (this.mentionActive) {
      this.mentionActive = false
      this.mentionStart = -1
      this.pushEvent("mention_close", {})
    }
  },

  /**
   * Called by the LiveView after a suggestion is selected (via phx-click on
   * a dropdown option). Inserts "@name" at the mention position in the textarea
   * and appends the user id to the hidden input.
   *
   * Usage: call from handle_event or use JS.push with a reply.
   */
  insertMention(id, name) {
    const { value, selectionStart } = this.textarea
    const before = value.slice(0, this.mentionStart)
    const after = value.slice(selectionStart)
    const inserted = `@${name} `

    this.textarea.value = before + inserted + after

    // Move cursor after inserted mention
    const newPos = this.mentionStart + inserted.length
    this.textarea.setSelectionRange(newPos, newPos)
    this.textarea.focus()

    // Update hidden IDs input
    const hiddenInput = this.el.closest("div").querySelector('input[type="hidden"]')
    if (hiddenInput) {
      const existing = hiddenInput.value ? hiddenInput.value.split(",") : []
      if (!existing.includes(id)) {
        hiddenInput.value = [...existing, id].join(",")
      }
    }

    this.mentionActive = false
    this.mentionStart = -1
  }
}

export default PhiaMentionInput
