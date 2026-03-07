/**
 * PhiaMarquee — infinite scroll marquee (horizontal or vertical).
 *
 * HTML anatomy:
 *   <div phx-hook="PhiaMarquee"
 *        data-direction="horizontal|vertical"
 *        data-speed="40"
 *        data-pause-on-hover="true|false"
 *        data-reverse="true|false">
 *     <div data-marquee-inner>...</div>
 *   </div>
 *
 * Respects prefers-reduced-motion.
 */
const PhiaMarquee = {
  mounted() {
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduced) return;

    const direction = this.el.dataset.direction || 'horizontal';
    const speed = parseInt(this.el.dataset.speed) || 40;
    const reverse = this.el.dataset.reverse === 'true';
    const pauseOnHover = this.el.dataset.pauseOnHover === 'true';

    this.inner = this.el.querySelector('[data-marquee-inner]');
    if (!this.inner) return;

    const animName = direction === 'vertical' ? 'marquee-vertical' : 'marquee';
    const dir = reverse ? 'reverse' : 'normal';
    this.inner.style.animation = `${animName} ${speed}s linear infinite ${dir}`;

    if (pauseOnHover) {
      this._pause = () => { this.inner.style.animationPlayState = 'paused'; };
      this._play = () => { this.inner.style.animationPlayState = 'running'; };
      this.el.addEventListener('mouseenter', this._pause);
      this.el.addEventListener('mouseleave', this._play);
    }
  },

  destroyed() {
    if (this._pause) {
      this.el.removeEventListener('mouseenter', this._pause);
      this.el.removeEventListener('mouseleave', this._play);
    }
  }
};

export default PhiaMarquee;
