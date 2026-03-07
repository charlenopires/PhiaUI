/**
 * PhiaNumberTicker — animates a number from 0 up to data-value.
 *
 * HTML anatomy:
 *   <span phx-hook="PhiaNumberTicker"
 *         data-value="1248"
 *         data-duration="1500"
 *         data-format="plain|comma|percent"
 *         data-prefix="$"
 *         data-suffix="K"
 *         data-decimal-places="0">
 *     $0K
 *   </span>
 *
 * Easing: easeOutCubic.
 * Respects prefers-reduced-motion (instantly shows final value).
 */
const PhiaNumberTicker = {
  mounted() {
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const target = parseFloat(this.el.dataset.value) || 0;
    const duration = parseInt(this.el.dataset.duration) || 1500;
    const format = this.el.dataset.format || 'plain';
    const prefix = this.el.dataset.prefix || '';
    const suffix = this.el.dataset.suffix || '';
    const decimals = parseInt(this.el.dataset.decimalPlaces) || 0;

    if (reduced) {
      this.el.textContent = prefix + this._format(target, format, decimals) + suffix;
      return;
    }

    const startTime = performance.now();

    const step = (now) => {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3); // easeOutCubic
      const current = eased * target;
      this.el.textContent = prefix + this._format(current, format, decimals) + suffix;

      if (progress < 1) {
        this._raf = requestAnimationFrame(step);
      }
    };

    this._raf = requestAnimationFrame(step);
  },

  _format(value, format, decimals) {
    if (format === 'comma') {
      return value.toLocaleString(undefined, {
        minimumFractionDigits: decimals,
        maximumFractionDigits: decimals
      });
    }
    if (format === 'percent') return value.toFixed(decimals) + '%';
    return value.toFixed(decimals);
  },

  destroyed() {
    if (this._raf) cancelAnimationFrame(this._raf);
  }
};

export default PhiaNumberTicker;
