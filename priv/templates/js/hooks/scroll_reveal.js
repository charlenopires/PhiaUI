/**
 * PhiaScrollReveal — fade+slide element into view on scroll (IntersectionObserver).
 *
 * HTML anatomy:
 *   <div phx-hook="PhiaScrollReveal"
 *        data-direction="up|down|left|right|none"
 *        data-delay="0"
 *        data-duration="500"
 *        data-once="true"
 *        data-threshold="0.1"
 *        class="opacity-0 translate-y-6"
 *        style="transition: opacity 500ms ease, transform 500ms ease;">
 *     ...content...
 *   </div>
 *
 * The initial opacity-0 + translate classes are set in the Elixir template.
 * This hook reveals them by setting opacity:1 and transform:none.
 *
 * Respects prefers-reduced-motion (reveals immediately without transition).
 */

const TRANSLATE_MAP = {
  up:    'translateY(24px)',
  down:  'translateY(-24px)',
  left:  'translateX(24px)',
  right: 'translateX(-24px)',
  none:  'none'
};

const PhiaScrollReveal = {
  mounted() {
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    if (reduced) {
      this._reveal();
      return;
    }

    const threshold = parseFloat(this.el.dataset.threshold) || 0.1;
    const once = this.el.dataset.once !== 'false';

    this._observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this._reveal();
          if (once) this._observer.disconnect();
        } else if (!once) {
          this._hide();
        }
      });
    }, { threshold });

    this._observer.observe(this.el);
  },

  _reveal() {
    this.el.style.opacity = '1';
    this.el.style.transform = 'translate(0, 0)';
  },

  _hide() {
    const dir = this.el.dataset.direction || 'up';
    this.el.style.opacity = '0';
    this.el.style.transform = TRANSLATE_MAP[dir] || 'translateY(24px)';
  },

  destroyed() {
    if (this._observer) this._observer.disconnect();
  }
};

export default PhiaScrollReveal;
