/**
 * PhiaFocusTrap — Keyboard focus trap for modals and overlays.
 *
 * When enabled, Tab and Shift+Tab cycle only within focusable elements
 * inside this wrapper. Pressing Escape fires a "focus-trap-escape"
 * push event to the parent LiveView.
 *
 * data-enabled="true|false" — controls whether trap is active.
 */
const FOCUSABLE = [
  'a[href]',
  'button:not([disabled])',
  'input:not([disabled])',
  'select:not([disabled])',
  'textarea:not([disabled])',
  '[tabindex]:not([tabindex="-1"])',
].join(',')

const PhiaFocusTrap = {
  mounted() {
    this._handler = (e) => this._onKeydown(e)
    document.addEventListener('keydown', this._handler)
  },

  updated() {
    // Re-read enabled state on LV update
  },

  destroyed() {
    document.removeEventListener('keydown', this._handler)
  },

  _isEnabled() {
    return this.el.dataset.enabled === 'true'
  },

  _getFocusable() {
    return Array.from(this.el.querySelectorAll(FOCUSABLE)).filter(
      (el) => !el.closest('[hidden]') && getComputedStyle(el).display !== 'none'
    )
  },

  _onKeydown(e) {
    if (!this._isEnabled()) return

    if (e.key === 'Escape') {
      e.preventDefault()
      this.pushEvent('focus-trap-escape', {})
      return
    }

    if (e.key !== 'Tab') return

    const focusable = this._getFocusable()
    if (focusable.length === 0) return

    const first = focusable[0]
    const last = focusable[focusable.length - 1]
    const active = document.activeElement

    if (e.shiftKey) {
      if (active === first) {
        e.preventDefault()
        last.focus()
      }
    } else {
      if (active === last) {
        e.preventDefault()
        first.focus()
      }
    }
  },
}

export default PhiaFocusTrap
