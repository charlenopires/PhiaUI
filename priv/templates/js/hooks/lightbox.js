/**
 * PhiaLightbox — Full-screen image/video gallery overlay.
 *
 * Manages: click-to-open, keyboard navigation (Escape/Arrow),
 * touch swipe (left/right), body scroll lock, and reduced-motion.
 */
const PhiaLightbox = {
  mounted() {
    this.items = []
    this.currentIndex = 0
    this.overlay = null
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.touchStartX = 0

    this._collectItems()
    this._bindClicks()
  },

  updated() {
    this._collectItems()
    this._bindClicks()
  },

  destroyed() {
    this._close()
  },

  // ── Internal ──────────────────────────────────────────────────────────────

  _collectItems() {
    this.items = Array.from(this.el.querySelectorAll("[data-lightbox-src]")).map(btn => ({
      src: btn.dataset.lightboxSrc,
      type: btn.dataset.lightboxType || "image",
      alt: btn.dataset.lightboxAlt || "",
      caption: btn.dataset.lightboxCaption || ""
    }))
  },

  _bindClicks() {
    const buttons = this.el.querySelectorAll("[data-lightbox-src]")
    buttons.forEach((btn, i) => {
      btn._phiaLightboxHandler && btn.removeEventListener("click", btn._phiaLightboxHandler)
      btn._phiaLightboxHandler = () => this._open(i)
      btn.addEventListener("click", btn._phiaLightboxHandler)
    })
  },

  _open(index) {
    this.currentIndex = index
    document.body.classList.add("overflow-hidden")
    this._createOverlay()
    this._render()
    this._onKeyDown = (e) => this._handleKey(e)
    document.addEventListener("keydown", this._onKeyDown)
  },

  _close() {
    document.body.classList.remove("overflow-hidden")
    if (this.overlay) {
      this.overlay.remove()
      this.overlay = null
    }
    if (this._onKeyDown) {
      document.removeEventListener("keydown", this._onKeyDown)
      this._onKeyDown = null
    }
  },

  _createOverlay() {
    if (this.overlay) this.overlay.remove()

    const div = document.createElement("div")
    div.className = "fixed inset-0 z-50 flex items-center justify-center bg-black/90"
    if (!this.reducedMotion) {
      div.style.animation = "phia-lightbox-in 200ms ease-out"
    }

    // Backdrop click
    div.addEventListener("click", (e) => {
      if (e.target === div || e.target.dataset.lightboxBackdrop) this._close()
    })

    // Touch swipe
    div.addEventListener("touchstart", (e) => {
      this.touchStartX = e.changedTouches[0].clientX
    }, { passive: true })
    div.addEventListener("touchend", (e) => {
      const dx = e.changedTouches[0].clientX - this.touchStartX
      if (Math.abs(dx) > 50) {
        dx < 0 ? this._next() : this._prev()
      }
    }, { passive: true })

    document.body.appendChild(div)
    this.overlay = div
  },

  _render() {
    if (!this.overlay || this.items.length === 0) return
    const item = this.items[this.currentIndex]

    const transition = this.reducedMotion ? "" : "style=\"animation: phia-lightbox-slide 200ms ease-out\""

    let media
    if (item.type === "video") {
      media = `<video controls autoplay class="max-h-[85vh] max-w-[90vw] rounded-lg" ${transition}>
        <source src="${item.src}" type="video/mp4" />
      </video>`
    } else {
      media = `<img src="${item.src}" alt="${item.alt}" class="max-h-[85vh] max-w-[90vw] object-contain rounded-lg" ${transition} />`
    }

    const caption = item.caption
      ? `<p class="mt-2 text-center text-sm text-white/80">${item.caption}</p>`
      : ""

    const counter = this.items.length > 1
      ? `<span class="absolute top-4 left-4 text-sm text-white/70">${this.currentIndex + 1} / ${this.items.length}</span>`
      : ""

    const prevBtn = this.items.length > 1
      ? `<button data-lightbox-prev class="absolute left-2 top-1/2 -translate-y-1/2 rounded-full bg-white/10 p-2 text-white hover:bg-white/20 transition-colors focus:outline-none focus:ring-2 focus:ring-white" aria-label="Previous">
          <svg class="size-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M15 19l-7-7 7-7"/></svg>
        </button>`
      : ""

    const nextBtn = this.items.length > 1
      ? `<button data-lightbox-next class="absolute right-2 top-1/2 -translate-y-1/2 rounded-full bg-white/10 p-2 text-white hover:bg-white/20 transition-colors focus:outline-none focus:ring-2 focus:ring-white" aria-label="Next">
          <svg class="size-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M9 5l7 7-7 7"/></svg>
        </button>`
      : ""

    this.overlay.innerHTML = `
      <div data-lightbox-backdrop class="absolute inset-0"></div>
      <button data-lightbox-close class="absolute top-4 right-4 rounded-full bg-white/10 p-2 text-white hover:bg-white/20 transition-colors focus:outline-none focus:ring-2 focus:ring-white z-10" aria-label="Close">
        <svg class="size-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M18 6L6 18M6 6l12 12"/></svg>
      </button>
      ${counter}
      ${prevBtn}
      <div class="relative z-10 flex flex-col items-center pointer-events-none">
        <div class="pointer-events-auto">${media}</div>
        ${caption}
      </div>
      ${nextBtn}
    `

    // Bind nav buttons
    const closeBtn = this.overlay.querySelector("[data-lightbox-close]")
    if (closeBtn) closeBtn.addEventListener("click", () => this._close())

    const prev = this.overlay.querySelector("[data-lightbox-prev]")
    if (prev) prev.addEventListener("click", (e) => { e.stopPropagation(); this._prev() })

    const next = this.overlay.querySelector("[data-lightbox-next]")
    if (next) next.addEventListener("click", (e) => { e.stopPropagation(); this._next() })
  },

  _prev() {
    this.currentIndex = (this.currentIndex - 1 + this.items.length) % this.items.length
    this._render()
  },

  _next() {
    this.currentIndex = (this.currentIndex + 1) % this.items.length
    this._render()
  },

  _handleKey(e) {
    switch (e.key) {
      case "Escape": this._close(); break
      case "ArrowLeft": this._prev(); break
      case "ArrowRight": this._next(); break
    }
  }
}

export default PhiaLightbox
