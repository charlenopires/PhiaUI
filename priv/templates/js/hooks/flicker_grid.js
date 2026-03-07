/**
 * PhiaFlickerGrid — Canvas flickering dot grid background.
 *
 * Draws a grid of dots that independently flicker opacity.
 * Respects prefers-reduced-motion.
 *
 * data-color — dot color (rgba string)
 * data-dot-size — dot radius in pixels
 * data-gap — grid spacing in pixels
 */
const PhiaFlickerGrid = {
  mounted() {
    this._prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    this._rafId = null
    this._ctx = this.el.getContext('2d')
    this._dots = []

    this._resize()
    this._resizeObserver = new ResizeObserver(() => this._resize())
    this._resizeObserver.observe(this.el.parentElement || this.el)

    if (!this._prefersReduced) {
      this._animate()
    } else {
      this._drawFrame()
    }
  },

  destroyed() {
    if (this._rafId) cancelAnimationFrame(this._rafId)
    if (this._resizeObserver) this._resizeObserver.disconnect()
  },

  _resize() {
    const parent = this.el.parentElement
    if (!parent) return
    this.el.width = parent.offsetWidth
    this.el.height = parent.offsetHeight
    this._buildGrid()
    if (!this._prefersReduced) {
      if (!this._rafId) this._animate()
    } else {
      this._drawFrame()
    }
  },

  _buildGrid() {
    const gap = parseInt(this.el.dataset.gap || '20', 10)
    const w = this.el.width
    const h = this.el.height
    this._dots = []
    for (let x = gap; x < w; x += gap) {
      for (let y = gap; y < h; y += gap) {
        this._dots.push({ x, y, opacity: Math.random() })
      }
    }
  },

  _drawFrame() {
    const ctx = this._ctx
    const dotSize = parseFloat(this.el.dataset.dotSize || '3')
    const color = this.el.dataset.color || 'rgba(99,102,241,0.5)'
    ctx.clearRect(0, 0, this.el.width, this.el.height)

    this._dots.forEach((dot) => {
      // Randomly flicker ~5% of dots per frame
      if (Math.random() < 0.05) {
        dot.opacity = Math.random()
      }
      // Parse color and apply opacity
      ctx.globalAlpha = dot.opacity
      ctx.fillStyle = color
      ctx.beginPath()
      ctx.arc(dot.x, dot.y, dotSize, 0, Math.PI * 2)
      ctx.fill()
    })
    ctx.globalAlpha = 1
  },

  _animate() {
    this._drawFrame()
    this._rafId = requestAnimationFrame(() => this._animate())
  },
}

export default PhiaFlickerGrid
