/**
 * PhiaMagicCard — cursor-tracked radial gradient card.
 *
 * Reads:
 *   data-gradient-color  — CSS color for the gradient center (default: #262626)
 *
 * Expects:
 *   A child element with [data-magic-overlay] to receive the gradient style.
 */
const PhiaMagicCard = {
  mounted() {
    this.overlay = this.el.querySelector("[data-magic-overlay]");
    this.color = this.el.dataset.gradientColor || "#262626";

    this._onMove = (e) => {
      if (!this.overlay) return;
      const rect = this.el.getBoundingClientRect();
      const x = (((e.clientX - rect.left) / rect.width) * 100).toFixed(1);
      const y = (((e.clientY - rect.top) / rect.height) * 100).toFixed(1);
      this.overlay.style.background = `radial-gradient(circle at ${x}% ${y}%, ${this.color} 0%, transparent 60%)`;
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

export default PhiaMagicCard;
