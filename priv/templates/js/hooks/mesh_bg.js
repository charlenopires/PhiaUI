/**
 * PhiaMeshBg — Animated mesh gradient background.
 *
 * Creates floating, blurred blob divs that animate via rAF.
 * Respects prefers-reduced-motion.
 *
 * data-colors — JSON array of hex/rgb colors
 * data-blob-count — number of blobs (default 4)
 */
const PhiaMeshBg = {
  mounted() {
    this._colors = JSON.parse(this.el.dataset.colors || '[]')
    this._count = parseInt(this.el.dataset.blobCount || '4', 10)
    this._blobs = []
    this._rafId = null
    this._prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches

    this._createBlobs()

    if (!this._prefersReduced) {
      this._animate()
    }
  },

  destroyed() {
    if (this._rafId) cancelAnimationFrame(this._rafId)
    this._blobs.forEach((b) => b.el.remove())
  },

  _createBlobs() {
    const colors = this._colors
    for (let i = 0; i < this._count; i++) {
      const el = document.createElement('div')
      const color = colors[i % colors.length] || '#6366f1'
      const size = 200 + Math.random() * 300
      el.style.cssText = `
        position: absolute;
        width: ${size}px;
        height: ${size}px;
        border-radius: 50%;
        background: ${color};
        filter: blur(80px);
        opacity: 0.4;
        left: ${Math.random() * 80}%;
        top: ${Math.random() * 80}%;
        will-change: transform;
      `
      this.el.appendChild(el)
      this._blobs.push({
        el,
        x: Math.random() * 80,
        y: Math.random() * 80,
        vx: (Math.random() - 0.5) * 0.05,
        vy: (Math.random() - 0.5) * 0.05,
      })
    }
  },

  _animate() {
    this._blobs.forEach((blob) => {
      blob.x += blob.vx
      blob.y += blob.vy
      if (blob.x < 0 || blob.x > 80) blob.vx *= -1
      if (blob.y < 0 || blob.y > 80) blob.vy *= -1
      blob.el.style.left = `${blob.x}%`
      blob.el.style.top = `${blob.y}%`
    })
    this._rafId = requestAnimationFrame(() => this._animate())
  },
}

export default PhiaMeshBg
