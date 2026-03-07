/**
 * PhiaChatTextarea — Chat-style textarea with Enter-to-submit.
 *
 * Enter (without Shift) fires pushEvent and clears the textarea.
 * Shift+Enter inserts a newline. Auto-grows like PhiaAutoresize.
 *
 * data-on-submit — push_event name to fire (default: "chat_submit")
 * data-min-rows — minimum rows
 * data-max-rows — maximum rows
 */
const PhiaChatTextarea = {
  mounted() {
    this._onSubmit = this.el.dataset.onSubmit || 'chat_submit'
    this._minRows = parseInt(this.el.dataset.minRows || '1', 10)
    this._maxRows = parseInt(this.el.dataset.maxRows || '6', 10)
    this._lineHeight = parseFloat(getComputedStyle(this.el).lineHeight) || 20

    this._keyHandler = (e) => this._onKeydown(e)
    this._inputHandler = () => this._resize()

    this.el.addEventListener('keydown', this._keyHandler)
    this.el.addEventListener('input', this._inputHandler)
    this._resize()
  },

  destroyed() {
    this.el.removeEventListener('keydown', this._keyHandler)
    this.el.removeEventListener('input', this._inputHandler)
  },

  _onKeydown(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      const value = this.el.value.trim()
      if (!value) return
      this.pushEvent(this._onSubmit, { value })
      this.el.value = ''
      this._resize()
    }
  },

  _resize() {
    const min = this._minRows * this._lineHeight
    const max = this._maxRows * this._lineHeight
    this.el.style.height = 'auto'
    const h = Math.min(Math.max(this.el.scrollHeight, min), max)
    this.el.style.height = `${h}px`
    this.el.style.overflowY = this.el.scrollHeight > max ? 'auto' : 'hidden'
  },
}

export default PhiaChatTextarea
