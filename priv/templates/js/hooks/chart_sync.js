/**
 * PhiaChartSync — Multi-chart synchronization hook.
 *
 * Coordinates crosshair/brush state across charts with the same syncId.
 * Uses document-level custom events for cross-component communication.
 *
 * @attribute data-sync-id   — Group identifier (charts with same id sync together)
 * @attribute data-sync-mode — "crosshair", "brush", or "both"
 */
const PhiaChartSync = {
  mounted() {
    this.syncId = this.el.dataset.syncId;
    this.syncMode = this.el.dataset.syncMode || "crosshair";
    this.sourceId = this.el.id;

    // Listen for sync events from other charts in the same group
    this._onSync = (e) => {
      const detail = e.detail;
      if (!detail || detail.syncId !== this.syncId) return;
      if (detail.sourceId === this.sourceId) return;

      // Forward to children as a non-bubbling event
      this.el.dispatchEvent(
        new CustomEvent("phia:sync-update", {
          bubbles: false,
          detail: detail
        })
      );
    };

    document.addEventListener("phia:chart-sync", this._onSync);

    // Listen for pointer events on child SVGs to broadcast sync
    this.el.addEventListener("pointermove", (e) => this.onPointerMove(e));
    this.el.addEventListener("pointerleave", () => this.onPointerLeave());
  },

  onPointerMove(e) {
    const svg = this.el.querySelector("svg");
    if (!svg) return;

    const rect = svg.getBoundingClientRect();
    if (rect.width === 0 || rect.height === 0) return;

    const xRatio = (e.clientX - rect.left) / rect.width;
    const yRatio = (e.clientY - rect.top) / rect.height;

    document.dispatchEvent(
      new CustomEvent("phia:chart-sync", {
        detail: {
          syncId: this.syncId,
          sourceId: this.sourceId,
          mode: this.syncMode,
          xRatio: Math.max(0, Math.min(1, xRatio)),
          yRatio: Math.max(0, Math.min(1, yRatio))
        }
      })
    );
  },

  onPointerLeave() {
    document.dispatchEvent(
      new CustomEvent("phia:chart-sync", {
        detail: {
          syncId: this.syncId,
          sourceId: this.sourceId,
          mode: this.syncMode,
          xRatio: null,
          yRatio: null
        }
      })
    );
  },

  updated() {
    this.syncId = this.el.dataset.syncId;
    this.syncMode = this.el.dataset.syncMode || "crosshair";
  },

  destroyed() {
    if (this._onSync) {
      document.removeEventListener("phia:chart-sync", this._onSync);
    }
  }
};

export { PhiaChartSync };
export default PhiaChartSync;
