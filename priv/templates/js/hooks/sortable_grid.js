/**
 * PhiaSortableGrid — sortable grid drag-and-drop hook.
 *
 * Uses 2D Euclidean nearest-neighbour comparison across all
 * [data-sortable-grid-item] elements to find the closest cell when dragging.
 *
 * Emits: pushEvent(onReorder, { old_index: N, new_index: M, id: "dom-id" })
 *
 * Registration:
 *   import { PhiaSortableGrid } from "./hooks/sortable_grid"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaSortableGrid } })
 */
const PhiaSortableGrid = {
  mounted() {
    this._onReorder = this.el.dataset.onReorder || "grid_reorder";
    this._dragging = null;
    this._prefersReducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches;

    this._onDragStart = (e) => this._handleDragStart(e);
    this._onDragOver = (e) => this._handleDragOver(e);
    this._onDrop = (e) => this._handleDrop(e);
    this._onDragEnd = (e) => this._handleDragEnd(e);

    this.el.addEventListener("dragstart", this._onDragStart);
    this.el.addEventListener("dragover", this._onDragOver);
    this.el.addEventListener("drop", this._onDrop);
    this.el.addEventListener("dragend", this._onDragEnd);
  },

  destroyed() {
    this.el.removeEventListener("dragstart", this._onDragStart);
    this.el.removeEventListener("dragover", this._onDragOver);
    this.el.removeEventListener("drop", this._onDrop);
    this.el.removeEventListener("dragend", this._onDragEnd);
  },

  _items() {
    return Array.from(this.el.querySelectorAll("[data-sortable-grid-item]"));
  },

  _handleDragStart(e) {
    const item = e.target.closest("[data-sortable-grid-item]");
    if (!item) return;
    this._dragging = item;
    e.dataTransfer.effectAllowed = "move";
    e.dataTransfer.setData("text/plain", item.id);
    if (!this._prefersReducedMotion) {
      requestAnimationFrame(() => item.setAttribute("data-dragging", "true"));
    }
  },

  _handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = "move";
    const nearest = this._nearestItem(e.clientX, e.clientY);
    this._clearDragOver();
    if (nearest && nearest !== this._dragging) {
      nearest.setAttribute("data-drag-over", "true");
    }
  },

  _handleDrop(e) {
    e.preventDefault();
    if (!this._dragging) return;
    const nearest = this._nearestItem(e.clientX, e.clientY);
    this._clearDragOver();

    if (!nearest || nearest === this._dragging) { this._cleanup(); return; }

    const items = this._items();
    const oldIndex = items.indexOf(this._dragging);
    const nearestIndex = items.indexOf(nearest);

    // Insert before or after based on horizontal midpoint
    const rect = nearest.getBoundingClientRect();
    if (e.clientX < rect.left + rect.width / 2) {
      nearest.before(this._dragging);
    } else {
      nearest.after(this._dragging);
    }

    const newIndex = this._items().indexOf(this._dragging);
    this.pushEvent(this._onReorder, {
      old_index: oldIndex,
      new_index: newIndex,
      id: this._dragging.id,
    });
    this._cleanup();
  },

  _handleDragEnd(_e) {
    this._cleanup();
  },

  // Find nearest grid cell by Euclidean distance from pointer to cell center
  _nearestItem(clientX, clientY) {
    const items = this._items();
    let nearest = null;
    let minDist = Infinity;

    for (const item of items) {
      if (item === this._dragging) continue;
      const rect = item.getBoundingClientRect();
      const cx = rect.left + rect.width / 2;
      const cy = rect.top + rect.height / 2;
      const dist = Math.hypot(clientX - cx, clientY - cy);
      if (dist < minDist) { minDist = dist; nearest = item; }
    }
    return nearest;
  },

  _clearDragOver() {
    this.el.querySelectorAll("[data-drag-over]").forEach((el) =>
      el.removeAttribute("data-drag-over")
    );
  },

  _cleanup() {
    if (this._dragging) {
      this._dragging.removeAttribute("data-dragging");
      this._dragging = null;
    }
    this._clearDragOver();
  },
};

export { PhiaSortableGrid };
export default PhiaSortableGrid;
