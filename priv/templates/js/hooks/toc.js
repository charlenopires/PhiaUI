// PhiaToc — sticky table of contents with IntersectionObserver scroll-spy
// Marks the active TOC link with data-toc-active as headings enter the viewport.

const PhiaToc = {
  mounted() {
    this.links = Array.from(this.el.querySelectorAll('[data-toc-target]'))
    this.headings = this.links
      .map(l => document.getElementById(l.dataset.tocTarget))
      .filter(Boolean)

    this.observer = new IntersectionObserver(this._onIntersect.bind(this), {
      rootMargin: '-80px 0px -70% 0px',
      threshold: 0
    })
    this.headings.forEach(h => this.observer.observe(h))

    const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches

    this.links.forEach(link => {
      link.addEventListener('click', e => {
        e.preventDefault()
        const target = document.getElementById(link.dataset.tocTarget)
        if (target) {
          target.scrollIntoView({
            behavior: prefersReduced ? 'auto' : 'smooth',
            block: 'start'
          })
        }
      })
    })
  },

  _onIntersect(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const id = entry.target.id
        this.links.forEach(l => l.removeAttribute('data-toc-active'))
        const active = this.links.find(l => l.dataset.tocTarget === id)
        if (active) active.setAttribute('data-toc-active', '')
      }
    })
  },

  updated() {
    // Re-query after LiveView patch to pick up any new toc items
    this.links = Array.from(this.el.querySelectorAll('[data-toc-target]'))
  },

  destroyed() {
    if (this.observer) this.observer.disconnect()
  }
}

export default PhiaToc
