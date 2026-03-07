/**
 * PhiaImageComparison — drag-to-reveal before/after image comparison hook.
 *
 * Markup contract:
 *   - Hook root: `phx-hook="PhiaImageComparison"`, `id`, `data-initial-position`
 *   - Before container: `[data-before-container]` with initial `clip-path` style
 *   - Divider: `[data-divider]` — draggable handle
 *
 * Touch support: passive:false on touchstart/touchmove to prevent scroll during drag.
 */
const PhiaImageComparison = {
  mounted() {
    this.beforeContainer = this.el.querySelector("[data-before-container]");
    this.divider = this.el.querySelector("[data-divider]");
    this.dragging = false;

    if (!this.beforeContainer || !this.divider) return;

    this._onMouseDown = this._onMouseDown.bind(this);
    this._onMouseMove = this._onMouseMove.bind(this);
    this._onMouseUp = this._onMouseUp.bind(this);
    this._onTouchStart = this._onTouchStart.bind(this);
    this._onTouchMove = this._onTouchMove.bind(this);
    this._onTouchEnd = this._onTouchEnd.bind(this);

    this.divider.addEventListener("mousedown", this._onMouseDown);
    this.divider.addEventListener("touchstart", this._onTouchStart, { passive: false });
    document.addEventListener("mouseup", this._onMouseUp);
    document.addEventListener("touchend", this._onTouchEnd);
  },

  destroyed() {
    if (!this.divider) return;
    this.divider.removeEventListener("mousedown", this._onMouseDown);
    this.divider.removeEventListener("touchstart", this._onTouchStart);
    document.removeEventListener("mousemove", this._onMouseMove);
    document.removeEventListener("mouseup", this._onMouseUp);
    document.removeEventListener("touchmove", this._onTouchMove);
    document.removeEventListener("touchend", this._onTouchEnd);
  },

  _onMouseDown(e) {
    e.preventDefault();
    this.dragging = true;
    document.addEventListener("mousemove", this._onMouseMove);
  },

  _onMouseMove(e) {
    if (!this.dragging) return;
    this._updatePosition(e.clientX);
  },

  _onMouseUp() {
    this.dragging = false;
    document.removeEventListener("mousemove", this._onMouseMove);
  },

  _onTouchStart(e) {
    e.preventDefault();
    this.dragging = true;
    document.addEventListener("touchmove", this._onTouchMove, { passive: false });
  },

  _onTouchMove(e) {
    if (!this.dragging) return;
    e.preventDefault();
    const touch = e.touches[0];
    this._updatePosition(touch.clientX);
  },

  _onTouchEnd() {
    this.dragging = false;
    document.removeEventListener("touchmove", this._onTouchMove);
  },

  _updatePosition(clientX) {
    const rect = this.el.getBoundingClientRect();
    let pct = ((clientX - rect.left) / rect.width) * 100;
    pct = Math.min(Math.max(pct, 0), 100);
    const pctStr = pct.toFixed(2);
    this.divider.style.left = `${pctStr}%`;
    this.beforeContainer.style.clipPath = `inset(0 ${(100 - pct).toFixed(2)}% 0 0)`;
  },
};

export default PhiaImageComparison;
