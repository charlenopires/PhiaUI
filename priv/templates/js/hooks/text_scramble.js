/**
 * PhiaTextScramble — scrambles then reveals text with a glitch effect.
 *
 * HTML anatomy:
 *   <span phx-hook="PhiaTextScramble"
 *         data-text="Decode me"
 *         data-trigger="mount|hover|click"
 *         data-duration="800">
 *     Decode me
 *   </span>
 *
 * Respects prefers-reduced-motion (shows final text immediately).
 */
const SCRAMBLE_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';

const PhiaTextScramble = {
  mounted() {
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    this._text = this.el.dataset.text || this.el.textContent;
    this._duration = parseInt(this.el.dataset.duration) || 800;
    this._trigger = this.el.dataset.trigger || 'mount';

    if (reduced) {
      this.el.textContent = this._text;
      return;
    }

    if (this._trigger === 'mount') {
      this._scramble();
    } else if (this._trigger === 'hover') {
      this._onEnter = () => this._scramble();
      this.el.addEventListener('mouseenter', this._onEnter);
    } else if (this._trigger === 'click') {
      this._onClick = () => this._scramble();
      this.el.addEventListener('click', this._onClick);
    }
  },

  _scramble() {
    const text = this._text;
    const duration = this._duration;
    const startTime = performance.now();

    const step = (now) => {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const revealed = Math.floor(progress * text.length);
      let result = '';

      for (let i = 0; i < text.length; i++) {
        if (i < revealed) {
          result += text[i];
        } else if (text[i] === ' ') {
          result += ' ';
        } else {
          result += SCRAMBLE_CHARS[Math.floor(Math.random() * SCRAMBLE_CHARS.length)];
        }
      }

      this.el.textContent = result;

      if (progress < 1) {
        this._raf = requestAnimationFrame(step);
      }
    };

    if (this._raf) cancelAnimationFrame(this._raf);
    this._raf = requestAnimationFrame(step);
  },

  destroyed() {
    if (this._raf) cancelAnimationFrame(this._raf);
    if (this._onEnter) this.el.removeEventListener('mouseenter', this._onEnter);
    if (this._onClick) this.el.removeEventListener('click', this._onClick);
  }
};

export default PhiaTextScramble;
