/**
 * PhiaMultiDrag — multi-select drag-and-drop list hook.
 *
 * Selection modes:
 *   - Click             → single select
 *   - Ctrl/Meta+click   → toggle
 *   - Shift+click       → range select
 *
 * Dragging any selected item moves all selected items together.
 * A ghost badge showing "N items" is appended to document.body during drag.
 *
 * Emits: pushEvent(onReorder, { ids: ["id1", "id2"], new_index: N })
 *
 * Registration:
 *   import { PhiaMultiDrag } from "./hooks/multi_drag"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaMultiDrag } })
 */
const PhiaMultiDrag = {
  mounted() {
    this._onReorder = this.el.dataset.onReorder || "multi_reorder";
    this._selected = new Set(); // Set of item IDs
    this._lastClickedIndex = -1;
    this._dragging = null;
    this._ghost = null;
    this._prefersReducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches;

    this._onMouseDown = (e) => this._handleMouseDown(e);
    this._onDragStart = (e) => this._handleDragStart(e);
    this._onDragOver = (e) => this._handleDragOver(e);
    this._onDrop = (e) => this._handleDrop(e);
    this._onDragEnd = (e) => this._handleDragEnd(e);
    this._onMouseMove = (e) => this._updateGhost(e);

    this.el.addEventListener("mousedown", this._onMouseDown);
    this.el.addEventListener("dragstart", this._onDragStart);
    this.el.addEventListener("dragover", this._onDragOver);
    this.el.addEventListener("drop", this._onDrop);
    this.el.addEventListener("dragend", this._onDragEnd);
  },

  destroyed() {
    this.el.removeEventListener("mousedown", this._onMouseDown);
    this.el.removeEventListener("dragstart", this._onDragStart);
    this.el.removeEventListener("dragover", this._onDragOver);
    this.el.removeEventListener("drop", this._onDrop);
    this.el.removeEventListener("dragend", this._onDragEnd);
    document.removeEventListener("mousemove", this._onMouseMove);
    this._removeGhost();
  },

  _items() {
    return Array.from(this.el.querySelectorAll("[data-sortable-item]"));
  },

  _handleMouseDown(e) {
    const item = e.target.closest("[data-sortable-item]");
    if (!item) return;

    const items = this._items();
    const idx = items.indexOf(item);
    const itemId = item.id;

    if (e.shiftKey && this._lastClickedIndex >= 0) {
      // Range select
      const from = Math.min(this._lastClickedIndex, idx);
      const to = Math.max(this._lastClickedIndex, idx);
      items.slice(from, to + 1).forEach((el) => {
        this._selected.add(el.id);
        el.setAttribute("data-selected", "true");
        el.setAttribute("aria-selected", "true");
      });
    } else if (e.ctrlKey || e.metaKey) {
      // Toggle
      if (this._selected.has(itemId)) {
        this._selected.delete(itemId);
        item.removeAttribute("data-selected");
        item.removeAttribute("aria-selected");
      } else {
        this._selected.add(itemId);
        item.setAttribute("data-selected", "true");
        item.setAttribute("aria-selected", "true");
      }
    } else {
      // Single select
      this._clearSelection();
      this._selected.add(itemId);
      item.setAttribute("data-selected", "true");
      item.setAttribute("aria-selected", "true");
    }
    this._lastClickedIndex = idx;
  },

  _handleDragStart(e) {
    const item = e.target.closest("[data-sortable-item]");
    if (!item) return;

    // If dragged item isn't in selection, make it the only selection
    if (!this._selected.has(item.id)) {
      this._clearSelection();
      this._selected.add(item.id);
      item.setAttribute("data-selected", "true");
      item.setAttribute("aria-selected", "true");
    }

    this._dragging = item;
    e.dataTransfer.effectAllowed = "move";
    e.dataTransfer.setData("text/plain", item.id);

    if (!this._prefersReducedMotion) {
      requestAnimationFrame(() => {
        this._items().forEach((el) => {
          if (this._selected.has(el.id)) el.setAttribute("data-dragging", "true");
        });
      });
    }

    this._createGhost(e.clientX, e.clientY);
    document.addEventListener("mousemove", this._onMouseMove);
  },

  _handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = "move";
    const target = this._dropTarget(e.clientY);
    this._clearDragOver();
    if (target && !this._selected.has(target.id)) {
      target.setAttribute("data-drag-over", "true");
    }
  },

  _handleDrop(e) {
    e.preventDefault();
    if (!this._dragging) return;

    const target = this._dropTarget(e.clientY);
    this._clearDragOver();
    const items = this._items();
    const selectedItems = items.filter((el) => this._selected.has(el.id));

    let newIndex;
    if (target && !this._selected.has(target.id)) {
      const targetIdx = items.indexOf(target);
      const insertBefore = e.clientY < target.getBoundingClientRect().top + target.getBoundingClientRect().height / 2;
      if (insertBefore) {
        selectedItems.forEach((el) => target.before(el));
        newIndex = targetIdx;
      } else {
        selectedItems.forEach((el) => target.after(el));
        newIndex = targetIdx + 1;
      }
    } else {
      // Drop at end
      selectedItems.forEach((el) => this.el.appendChild(el));
      newIndex = this._items().length - selectedItems.length;
    }

    this.pushEvent(this._onReorder, {
      ids: [...this._selected],
      new_index: newIndex,
    });
    this._cleanup();
  },

  _handleDragEnd(_e) {
    this._cleanup();
  },

  _dropTarget(clientY) {
    const items = this._items();
    for (const item of items) {
      if (this._selected.has(item.id)) continue;
      const rect = item.getBoundingClientRect();
      if (clientY >= rect.top && clientY <= rect.bottom) return item;
    }
    return null;
  },

  _createGhost(x, y) {
    this._removeGhost();
    const count = this._selected.size;
    const ghost = document.createElement("div");
    ghost.style.cssText = [
      "position:fixed",
      `left:${x + 10}px`,
      `top:${y - 10}px`,
      "z-index:9999",
      "pointer-events:none",
      "background:var(--color-primary, #3b82f6)",
      "color:#fff",
      "border-radius:9999px",
      "padding:2px 10px",
      "font-size:12px",
      "font-weight:600",
      "box-shadow:0 4px 12px rgba(0,0,0,0.2)",
    ].join(";");
    ghost.textContent = `${count} item${count !== 1 ? "s" : ""}`;
    document.body.appendChild(ghost);
    this._ghost = ghost;
  },

  _updateGhost(e) {
    if (this._ghost) {
      this._ghost.style.left = `${e.clientX + 10}px`;
      this._ghost.style.top = `${e.clientY - 10}px`;
    }
  },

  _removeGhost() {
    if (this._ghost) { this._ghost.remove(); this._ghost = null; }
  },

  _clearSelection() {
    this._items().forEach((el) => {
      el.removeAttribute("data-selected");
      el.removeAttribute("aria-selected");
    });
    this._selected.clear();
  },

  _clearDragOver() {
    this.el.querySelectorAll("[data-drag-over]").forEach((el) =>
      el.removeAttribute("data-drag-over")
    );
  },

  _cleanup() {
    this._items().forEach((el) => el.removeAttribute("data-dragging"));
    this._clearDragOver();
    this._removeGhost();
    document.removeEventListener("mousemove", this._onMouseMove);
    this._dragging = null;
  },
};

export { PhiaMultiDrag };
export default PhiaMultiDrag;
