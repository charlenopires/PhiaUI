/**
 * PhiaSpotlight — radial gradient spotlight that follows the cursor.
 *
 * HTML anatomy:
 *   <div phx-hook="PhiaSpotlight"
 *        data-color="rgba(255,255,255,0.15)"
 *        data-size="300"
 *        class="relative overflow-hidden">
 *     <div data-spotlight-bg class="pointer-events-none absolute inset-0 opacity-0"/>
 *     ...content...
 *   </div>
 */
const PhiaSpotlight = {
  mounted() {
    this.bg = this.el.querySelector('[data-spotlight-bg]');
    if (!this.bg) return;

    const size = parseInt(this.el.dataset.size) || 300;
    const color = this.el.dataset.color || 'rgba(255,255,255,0.15)';

    this._onMove = (e) => {
      const rect = this.el.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      this.bg.style.background = `radial-gradient(${size}px circle at ${x}px ${y}px, ${color}, transparent 80%)`;
      this.bg.style.opacity = '1';
    };

    this._onLeave = () => {
      this.bg.style.opacity = '0';
    };

    this.el.addEventListener('mousemove', this._onMove);
    this.el.addEventListener('mouseleave', this._onLeave);
  },

  destroyed() {
    if (this._onMove) this.el.removeEventListener('mousemove', this._onMove);
    if (this._onLeave) this.el.removeEventListener('mouseleave', this._onLeave);
  }
};

export default PhiaSpotlight;
