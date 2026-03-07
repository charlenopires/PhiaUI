/**
 * PhiaCardSpotlight — cursor-following spotlight overlay.
 *
 * Reads:
 *   data-size   — spotlight radius in pixels (default: 300)
 *   data-color  — CSS color for spotlight center (default: rgba(255,255,255,0.1))
 *
 * Expects:
 *   A child element with [data-spotlight-overlay] to receive the gradient style.
 */
const PhiaCardSpotlight = {
  mounted() {
    this.overlay = this.el.querySelector("[data-spotlight-overlay]");
    this.size = parseInt(this.el.dataset.size || "300", 10);
    this.color = this.el.dataset.color || "rgba(255,255,255,0.1)";

    this._onMove = (e) => {
      if (!this.overlay) return;
      const rect = this.el.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      this.overlay.style.background = `radial-gradient(circle ${this.size}px at ${x}px ${y}px, ${this.color}, transparent)`;
    };

    this._onLeave = () => {
      if (this.overlay) this.overlay.style.background = "transparent";
    };

    this.el.addEventListener("mousemove", this._onMove);
    this.el.addEventListener("mouseleave", this._onLeave);
  },

  destroyed() {
    this.el.removeEventListener("mousemove", this._onMove);
    this.el.removeEventListener("mouseleave", this._onLeave);
  },
};

export default PhiaCardSpotlight;
