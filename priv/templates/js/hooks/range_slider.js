/**
 * PhiaRangeSlider — two-thumb range slider hook.
 *
 * Manages two overlapping `<input type="range">` elements to produce a
 * dual-handle slider. Reads initial state from data attributes on the container:
 *   data-min, data-max, data-step, data-from, data-to
 *
 * Updates:
 *   - `--from` / `--to` CSS custom properties on the container (drives track fill)
 *   - Visual thumb positions via `style.left` on `[data-range-thumb-from/to]`
 *   - Label text on `[data-range-from-label]` and `[data-range-to-label]`
 *
 * Sends a `range-change` LiveView event: `%{from: integer, to: integer}`
 */
export const PhiaRangeSlider = {
  mounted() {
    const el = this.el;

    this.fromInput = el.querySelector("[data-range-from]");
    this.toInput = el.querySelector("[data-range-to]");
    this.track = el.querySelector("[data-range-track]");
    this.thumbFrom = el.querySelector("[data-range-thumb-from]");
    this.thumbTo = el.querySelector("[data-range-thumb-to]");
    this.fromLabel = el.querySelector("[data-range-from-label]");
    this.toLabel = el.querySelector("[data-range-to-label]");

    if (!this.fromInput || !this.toInput) return;

    this._onInput = () => this._update();

    this.fromInput.addEventListener("input", this._onInput);
    this.toInput.addEventListener("input", this._onInput);

    // Apply initial state from server-rendered values
    this._update();
  },

  destroyed() {
    if (this.fromInput) this.fromInput.removeEventListener("input", this._onInput);
    if (this.toInput) this.toInput.removeEventListener("input", this._onInput);
  },

  _update() {
    const el = this.el;
    const min = parseFloat(el.dataset.min ?? 0);
    const max = parseFloat(el.dataset.max ?? 100);
    let from = parseFloat(this.fromInput.value);
    let to = parseFloat(this.toInput.value);

    // Prevent thumbs from crossing
    if (from > to) {
      if (document.activeElement === this.fromInput) {
        from = to;
        this.fromInput.value = from;
      } else {
        to = from;
        this.toInput.value = to;
      }
    }

    const range = max - min;
    const fromPct = range > 0 ? ((from - min) / range) * 100 : 0;
    const toPct = range > 0 ? ((to - min) / range) * 100 : 100;

    // Update CSS custom properties for track fill
    el.style.setProperty("--from", `${fromPct}%`);
    el.style.setProperty("--to", `${toPct}%`);

    // Update track fill div
    if (this.track) {
      this.track.style.left = `${fromPct}%`;
      this.track.style.right = `${100 - toPct}%`;
    }

    // Update visual thumb positions
    if (this.thumbFrom) {
      this.thumbFrom.style.left = `${fromPct}%`;
    }
    if (this.thumbTo) {
      this.thumbTo.style.left = `${toPct}%`;
    }

    // Update value labels
    if (this.fromLabel) this.fromLabel.textContent = Math.round(from);
    if (this.toLabel) this.toLabel.textContent = Math.round(to);

    // Manage z-index so the active thumb is always on top
    const zFrom = from > (max - min) / 2 + min ? "z-20" : "z-10";
    const zTo = from > (max - min) / 2 + min ? "z-10" : "z-20";
    if (this.fromInput) {
      this.fromInput.style.zIndex = from >= to ? "20" : "10";
    }
    if (this.toInput) {
      this.toInput.style.zIndex = to <= from ? "20" : "10";
    }

    // Send event to LiveView (throttled — only on pointer-up to avoid flooding)
    clearTimeout(this._debounceTimer);
    this._debounceTimer = setTimeout(() => {
      this.pushEvent("range-change", { from: Math.round(from), to: Math.round(to) });
    }, 100);
  },
};
