/**
 * PhiaResizable — drag-to-resize split panels.
 *
 * Reads `data-direction` ("horizontal" | "vertical") from the hook element.
 * Each `[data-panel]` child has `data-min-size` and `data-max-size` (%).
 * The `[data-panel-handle]` child triggers drag on mousedown/touchstart.
 */
const PhiaResizable = {
  mounted() {
    this.direction = this.el.dataset.direction || "horizontal";
    this.panels = Array.from(this.el.querySelectorAll("[data-panel]"));
    this.handle = this.el.querySelector("[data-panel-handle]");

    if (!this.handle || this.panels.length < 2) return;

    this._onMouseDown = this._startDrag.bind(this);
    this._onMouseMove = this._drag.bind(this);
    this._onMouseUp = this._stopDrag.bind(this);
    this._onKeyDown = this._handleKey.bind(this);

    this.handle.addEventListener("mousedown", this._onMouseDown);
    this.handle.addEventListener("touchstart", this._onMouseDown, { passive: true });
    this.handle.addEventListener("keydown", this._onKeyDown);
  },

  destroyed() {
    if (this.handle) {
      this.handle.removeEventListener("mousedown", this._onMouseDown);
      this.handle.removeEventListener("touchstart", this._onMouseDown);
      this.handle.removeEventListener("keydown", this._onKeyDown);
    }
    this._stopDrag();
  },

  _startDrag(e) {
    e.preventDefault();
    this._dragging = true;
    this._containerRect = this.el.getBoundingClientRect();

    document.addEventListener("mousemove", this._onMouseMove);
    document.addEventListener("mouseup", this._onMouseUp);
    document.addEventListener("touchmove", this._onMouseMove);
    document.addEventListener("touchend", this._onMouseUp);
  },

  _drag(e) {
    if (!this._dragging) return;

    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    const rect = this._containerRect;

    let ratio;
    if (this.direction === "vertical") {
      ratio = (clientY - rect.top) / rect.height;
    } else {
      ratio = (clientX - rect.left) / rect.width;
    }

    this._applyRatio(ratio);
  },

  _stopDrag() {
    this._dragging = false;
    document.removeEventListener("mousemove", this._onMouseMove);
    document.removeEventListener("mouseup", this._onMouseUp);
    document.removeEventListener("touchmove", this._onMouseMove);
    document.removeEventListener("touchend", this._onMouseUp);
  },

  _handleKey(e) {
    const step = 0.05;
    const panel = this.panels[0];
    const current = parseFloat(panel.style.flex) / 100;

    if (e.key === "ArrowLeft" || e.key === "ArrowUp") {
      e.preventDefault();
      this._applyRatio(current - step);
    } else if (e.key === "ArrowRight" || e.key === "ArrowDown") {
      e.preventDefault();
      this._applyRatio(current + step);
    }
  },

  _applyRatio(ratio) {
    const p1 = this.panels[0];
    const p2 = this.panels[1];

    const minA = parseFloat(p1.dataset.minSize || 10) / 100;
    const maxA = parseFloat(p1.dataset.maxSize || 90) / 100;
    const minB = parseFloat(p2.dataset.minSize || 10) / 100;

    ratio = Math.max(minA, Math.min(maxA, ratio));
    ratio = Math.max(minB, Math.min(1 - minB, ratio));

    const pct = (ratio * 100).toFixed(2);
    const pctB = (100 - parseFloat(pct)).toFixed(2);

    p1.style.flex = `${pct} 1 0%`;
    p2.style.flex = `${pctB} 1 0%`;

    if (this.handle) {
      this.handle.setAttribute("aria-valuenow", Math.round(ratio * 100));
    }
  }
};

export default PhiaResizable;
