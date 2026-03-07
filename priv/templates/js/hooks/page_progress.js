// PhiaPageProgress — reading progress bar
// Reads scroll position, computes percentage, and updates the element's
// inline width style and aria-valuenow attribute.

const PhiaPageProgress = {
  mounted() {
    this._onScroll = () => this.update()
    window.addEventListener('scroll', this._onScroll, { passive: true })
    this.update()
  },

  update() {
    const scrollTop = window.scrollY
    const docHeight = document.documentElement.scrollHeight - window.innerHeight
    const pct = docHeight > 0 ? Math.min(100, (scrollTop / docHeight) * 100) : 0
    this.el.style.width = `${pct}%`
    this.el.setAttribute('aria-valuenow', Math.round(pct))
  },

  destroyed() {
    window.removeEventListener('scroll', this._onScroll)
  }
}

export default PhiaPageProgress
