/**
 * PhiaAutoresize — Auto-growing textarea.
 *
 * Feature-detects field-sizing: content (Chrome 123+) for native growth.
 * Falls back to scrollHeight measurement on input events.
 *
 * data-min-rows — minimum visible rows
 * data-max-rows — maximum rows (caps growth)
 */
const PhiaAutoresize = {
  mounted() {
    this._minRows = parseInt(this.el.dataset.minRows || '2', 10)
    this._maxRows = parseInt(this.el.dataset.maxRows || '12', 10)

    // Feature detect field-sizing CSS property (Chrome 123+)
    if ('fieldSizing' in this.el.style) {
      this.el.style.fieldSizing = 'content'
      return
    }

    // Fallback: scrollHeight measurement
    this._lineHeight = parseFloat(getComputedStyle(this.el).lineHeight) || 20
    this._handler = () => this._resize()
    this.el.addEventListener('input', this._handler)
    this._resize()
  },

  updated() {
    if (!('fieldSizing' in this.el.style)) {
      this._resize()
    }
  },

  destroyed() {
    if (this._handler) this.el.removeEventListener('input', this._handler)
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

export default PhiaAutoresize
