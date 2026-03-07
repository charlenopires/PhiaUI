/**
 * PhiaTypewriter — char-by-char text reveal with optional blinking cursor.
 *
 * HTML anatomy:
 *   <span phx-hook="PhiaTypewriter"
 *         data-text="Hello World"
 *         data-speed="80"
 *         data-cursor="true"
 *         data-loop="false"
 *         data-delay="0">
 *     <span data-typewriter-text></span>
 *     <span data-typewriter-cursor .../>
 *   </span>
 *
 * Respects prefers-reduced-motion (instantly shows full text).
 */
const PhiaTypewriter = {
  mounted() {
    this.textEl = this.el.querySelector('[data-typewriter-text]');
    if (!this.textEl) return;

    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const text = this.el.dataset.text || '';
    const speed = parseInt(this.el.dataset.speed) || 80;
    const loop = this.el.dataset.loop === 'true';
    const delay = parseInt(this.el.dataset.delay) || 0;

    if (reduced) {
      this.textEl.textContent = text;
      return;
    }

    this._delayTimer = setTimeout(() => this._start(text, speed, loop), delay);
  },

  _start(text, speed, loop) {
    let i = 0;
    const type = () => {
      if (i <= text.length) {
        this.textEl.textContent = text.slice(0, i);
        i++;
        this._timer = setTimeout(type, speed);
      } else if (loop) {
        this._timer = setTimeout(() => {
          i = 0;
          type();
        }, 1200);
      }
    };
    type();
  },

  destroyed() {
    clearTimeout(this._delayTimer);
    clearTimeout(this._timer);
  }
};

export default PhiaTypewriter;
