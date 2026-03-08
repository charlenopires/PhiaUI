/**
 * PhiaDataZoom — Range slider hook for chart data zooming.
 *
 * Handles drag interactions on start/end handles and the window region.
 * Sends phx-change events with normalized {start, end} values (0.0–1.0).
 *
 * @attribute data-start  — Initial start position (0.0–1.0)
 * @attribute data-end    — Initial end position (0.0–1.0)
 * @attribute data-event  — Event name to push on change
 */
const PhiaDataZoom = {
  mounted() {
    this.start = parseFloat(this.el.dataset.start) || 0;
    this.end = parseFloat(this.el.dataset.end) || 1;
    this.eventName = this.el.dataset.event;
    this.dragging = null;
    this.dragOffset = 0;

    this.handleStart = this.el.querySelector('[data-role="handle-start"]');
    this.handleEnd = this.el.querySelector('[data-role="handle-end"]');
    this.window = this.el.querySelector('[data-role="window"]');

    if (this.handleStart) {
      this.handleStart.addEventListener("pointerdown", (e) => this.onPointerDown(e, "start"));
    }
    if (this.handleEnd) {
      this.handleEnd.addEventListener("pointerdown", (e) => this.onPointerDown(e, "end"));
    }
    if (this.window) {
      this.window.addEventListener("pointerdown", (e) => this.onPointerDown(e, "window"));
    }

    this.onPointerMoveBound = this.onPointerMove.bind(this);
    this.onPointerUpBound = this.onPointerUp.bind(this);
  },

  onPointerDown(e, target) {
    e.preventDefault();
    this.dragging = target;

    if (target === "window") {
      const rect = this.el.getBoundingClientRect();
      const pos = (e.clientX - rect.left) / rect.width;
      this.dragOffset = pos - this.start;
    }

    document.addEventListener("pointermove", this.onPointerMoveBound);
    document.addEventListener("pointerup", this.onPointerUpBound);
  },

  onPointerMove(e) {
    if (!this.dragging) return;

    const rect = this.el.getBoundingClientRect();
    const pos = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));

    if (this.dragging === "start") {
      this.start = Math.min(pos, this.end - 0.01);
    } else if (this.dragging === "end") {
      this.end = Math.max(pos, this.start + 0.01);
    } else if (this.dragging === "window") {
      const width = this.end - this.start;
      let newStart = pos - this.dragOffset;
      newStart = Math.max(0, Math.min(1 - width, newStart));
      this.start = newStart;
      this.end = newStart + width;
    }

    this.updatePositions();
  },

  onPointerUp() {
    this.dragging = null;
    document.removeEventListener("pointermove", this.onPointerMoveBound);
    document.removeEventListener("pointerup", this.onPointerUpBound);

    if (this.eventName) {
      this.pushEvent(this.eventName, {
        start: Math.round(this.start * 1000) / 1000,
        end: Math.round(this.end * 1000) / 1000
      });
    }
  },

  updatePositions() {
    if (this.handleStart) {
      this.handleStart.style.left = `${this.start * 100}%`;
    }
    if (this.handleEnd) {
      this.handleEnd.style.left = `${this.end * 100}%`;
    }
    if (this.window) {
      this.window.style.left = `${this.start * 100}%`;
      this.window.style.right = `${(1 - this.end) * 100}%`;
    }
  },

  destroyed() {
    document.removeEventListener("pointermove", this.onPointerMoveBound);
    document.removeEventListener("pointerup", this.onPointerUpBound);
  }
};

export { PhiaDataZoom };
export default PhiaDataZoom;
