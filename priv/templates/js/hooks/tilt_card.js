/**
 * PhiaTiltCard — 3D perspective tilt on mouse hover.
 *
 * HTML anatomy:
 *   <div phx-hook="PhiaTiltCard"
 *        data-max-tilt="15"
 *        data-scale="1.05"
 *        data-glare="false"
 *        style="transform-style: preserve-3d;">
 *     ...content...
 *     <div data-tilt-glare .../>  <!-- optional, when glare=true -->
 *   </div>
 *
 * Respects prefers-reduced-motion (skips all transforms).
 */
const PhiaTiltCard = {
  mounted() {
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduced) return;

    const maxTilt = parseFloat(this.el.dataset.maxTilt) || 15;
    const scale = parseFloat(this.el.dataset.scale) || 1.05;
    this.glareEl = this.el.querySelector('[data-tilt-glare]');

    this._onMove = (e) => {
      const rect = this.el.getBoundingClientRect();
      const cx = rect.left + rect.width / 2;
      const cy = rect.top + rect.height / 2;
      const rx = ((e.clientY - cy) / (rect.height / 2)) * -maxTilt;
      const ry = ((e.clientX - cx) / (rect.width / 2)) * maxTilt;

      this.el.style.transform = `perspective(1000px) rotateX(${rx}deg) rotateY(${ry}deg) scale(${scale})`;

      if (this.glareEl) {
        const angle = Math.atan2(e.clientY - cy, e.clientX - cx) * (180 / Math.PI);
        this.glareEl.style.background = `linear-gradient(${angle}deg, rgba(255,255,255,0.3) 0%, transparent 60%)`;
        this.glareEl.style.opacity = '1';
      }
    };

    this._onLeave = () => {
      this.el.style.transform = `perspective(1000px) rotateX(0deg) rotateY(0deg) scale(1)`;
      if (this.glareEl) this.glareEl.style.opacity = '0';
    };

    this.el.addEventListener('mousemove', this._onMove);
    this.el.addEventListener('mouseleave', this._onLeave);
  },

  destroyed() {
    if (this._onMove) this.el.removeEventListener('mousemove', this._onMove);
    if (this._onLeave) this.el.removeEventListener('mouseleave', this._onLeave);
  }
};

export default PhiaTiltCard;
