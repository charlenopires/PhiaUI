/**
 * PhiaChartCrosshair — SVG crosshair hook with snap-to-point.
 *
 * Renders vertical/horizontal guide lines that follow pointer position
 * within the chart area, optionally snapping to the nearest data point.
 *
 * @attribute data-type      — "x", "y", or "both"
 * @attribute data-snap      — "true" or "false"
 * @attribute data-area-x    — Chart area left position
 * @attribute data-area-y    — Chart area top position
 * @attribute data-area-w    — Chart area width
 * @attribute data-area-h    — Chart area height
 * @attribute data-points    — JSON array of {px, py, label, value}
 * @attribute data-color     — Crosshair line color
 * @attribute data-show-label — "true" or "false"
 */
const PhiaChartCrosshair = {
  mounted() {
    this.type = this.el.dataset.type || "x";
    this.snap = this.el.dataset.snap === "true";
    this.area = {
      x: parseFloat(this.el.dataset.areaX),
      y: parseFloat(this.el.dataset.areaY),
      w: parseFloat(this.el.dataset.areaW),
      h: parseFloat(this.el.dataset.areaH)
    };

    try {
      this.points = JSON.parse(this.el.dataset.points || "[]");
    } catch {
      this.points = [];
    }

    this.lineX = this.el.querySelector('[data-role="crosshair-x"]');
    this.lineY = this.el.querySelector('[data-role="crosshair-y"]');
    this.dot = this.el.querySelector('[data-role="crosshair-dot"]');
    this.overlay = this.el.querySelector('[data-role="crosshair-overlay"]');

    if (this.overlay) {
      this.overlay.addEventListener("pointermove", (e) => this.onPointerMove(e));
      this.overlay.addEventListener("pointerleave", () => this.onPointerLeave());
    }

    // Respect prefers-reduced-motion
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    // Listen for sync updates from ChartSync wrapper
    this.el.closest("[data-sync-id]")?.addEventListener("phia:sync-update", (e) => {
      const detail = e.detail;
      if (!detail || detail.xRatio == null) {
        this.onPointerLeave();
        return;
      }
      const targetX = this.area.x + detail.xRatio * this.area.w;
      const targetY = this.area.y + detail.yRatio * this.area.h;

      if (this.lineX) {
        this.lineX.setAttribute("x1", targetX);
        this.lineX.setAttribute("x2", targetX);
        this.lineX.setAttribute("opacity", "0.6");
      }
      if (this.lineY) {
        this.lineY.setAttribute("y1", targetY);
        this.lineY.setAttribute("y2", targetY);
        this.lineY.setAttribute("opacity", "0.6");
      }
    });
  },

  onPointerMove(e) {
    const svg = this.el.closest("svg");
    if (!svg) return;

    const pt = svg.createSVGPoint();
    pt.x = e.clientX;
    pt.y = e.clientY;

    const ctm = svg.getScreenCTM();
    if (!ctm) return;

    const svgPt = pt.matrixTransform(ctm.inverse());
    let targetX = Math.max(this.area.x, Math.min(this.area.x + this.area.w, svgPt.x));
    let targetY = Math.max(this.area.y, Math.min(this.area.y + this.area.h, svgPt.y));

    // Snap to nearest point
    if (this.snap && this.points.length > 0) {
      const nearest = this.findNearest(targetX, targetY);
      if (nearest) {
        targetX = nearest.px;
        targetY = nearest.py;
      }
    }

    // Emit sync event for multi-chart coordination
    const syncWrapper = this.el.closest("[data-sync-id]");
    if (syncWrapper) {
      const svgRect = svg.getBoundingClientRect();
      const xRatio = svgRect.width > 0 ? (targetX - this.area.x) / this.area.w : 0;
      const yRatio = svgRect.height > 0 ? (targetY - this.area.y) / this.area.h : 0;

      document.dispatchEvent(
        new CustomEvent("phia:chart-sync", {
          detail: {
            syncId: syncWrapper.dataset.syncId,
            sourceId: syncWrapper.id,
            mode: "crosshair",
            xRatio: Math.max(0, Math.min(1, xRatio)),
            yRatio: Math.max(0, Math.min(1, yRatio))
          }
        })
      );
    }

    // Update vertical line
    if (this.lineX) {
      this.lineX.setAttribute("x1", targetX);
      this.lineX.setAttribute("x2", targetX);
      this.lineX.setAttribute("opacity", "0.6");
    }

    // Update horizontal line
    if (this.lineY) {
      this.lineY.setAttribute("y1", targetY);
      this.lineY.setAttribute("y2", targetY);
      this.lineY.setAttribute("opacity", "0.6");
    }

    // Update snap dot
    if (this.dot && this.snap) {
      this.dot.setAttribute("cx", targetX);
      this.dot.setAttribute("cy", targetY);
      this.dot.setAttribute("opacity", "1");
    }
  },

  onPointerLeave() {
    if (this.lineX) this.lineX.setAttribute("opacity", "0");
    if (this.lineY) this.lineY.setAttribute("opacity", "0");
    if (this.dot) this.dot.setAttribute("opacity", "0");
  },

  findNearest(px, py) {
    let minDist = Infinity;
    let nearest = null;

    for (const point of this.points) {
      const dx = point.px - px;
      const dy = point.py - py;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < minDist) {
        minDist = dist;
        nearest = point;
      }
    }

    return nearest;
  },

  updated() {
    try {
      this.points = JSON.parse(this.el.dataset.points || "[]");
    } catch {
      this.points = [];
    }
  },

  destroyed() {
    // Cleanup handled by element removal
  }
};

export { PhiaChartCrosshair };
export default PhiaChartCrosshair;
