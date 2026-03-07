/**
 * PhiaSortable — sortable list drag-and-drop hook.
 *
 * Handles vertical and horizontal lists with optional handle-restricted dragging.
 * Supports keyboard navigation (Space=grab, Arrow=move, Enter/Space=drop, Escape=cancel)
 * and touch events. Announces actions via an ARIA live region.
 *
 * Emits: pushEvent(onReorder, { old_index: N, new_index: M, id: "dom-id" })
 *
 * Registration:
 *   import { PhiaSortable } from "./hooks/sortable"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaSortable } })
 */
const PhiaSortable = {
  mounted() {
    this._orientation = this.el.dataset.orientation || "vertical";
    this._useHandle = this.el.dataset.handle === "true";
    this._onReorder = this.el.dataset.onReorder || "reorder";
    this._dragging = null;
    this._dragStartIndex = -1;
    this._prefersReducedMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches;

    // ARIA live region for screen reader announcements
    this._liveRegion = document.createElement("div");
    this._liveRegion.setAttribute("aria-live", "assertive");
    this._liveRegion.setAttribute("aria-atomic", "true");
    this._liveRegion.className = "sr-only";
    document.body.appendChild(this._liveRegion);

    // Mouse/pointer drag events (delegated on root)
    this._onDragStart = (e) => this._handleDragStart(e);
    this._onDragOver = (e) => this._handleDragOver(e);
    this._onDragEnter = (e) => this._handleDragEnter(e);
    this._onDragleave = (e) => this._handleDragLeave(e);
    this._onDrop = (e) => this._handleDrop(e);
    this._onDragEnd = (e) => this._handleDragEnd(e);
    this._onKeyDown = (e) => this._handleKeyDown(e);

    // Touch events
    this._onTouchStart = (e) => this._handleTouchStart(e);
    this._onTouchMove = (e) => this._handleTouchMove(e);
    this._onTouchEnd = (e) => this._handleTouchEnd(e);

    this.el.addEventListener("dragstart", this._onDragStart);
    this.el.addEventListener("dragover", this._onDragOver);
    this.el.addEventListener("dragenter", this._onDragEnter);
    this.el.addEventListener("dragleave", this._onDragleave);
    this.el.addEventListener("drop", this._onDrop);
    this.el.addEventListener("dragend", this._onDragEnd);
    this.el.addEventListener("keydown", this._onKeyDown);
    this.el.addEventListener("touchstart", this._onTouchStart, { passive: false });
    this.el.addEventListener("touchmove", this._onTouchMove, { passive: false });
    this.el.addEventListener("touchend", this._onTouchEnd);
  },

  destroyed() {
    this.el.removeEventListener("dragstart", this._onDragStart);
    this.el.removeEventListener("dragover", this._onDragOver);
    this.el.removeEventListener("dragenter", this._onDragEnter);
    this.el.removeEventListener("dragleave", this._onDragleave);
    this.el.removeEventListener("drop", this._onDrop);
    this.el.removeEventListener("dragend", this._onDragEnd);
    this.el.removeEventListener("keydown", this._onKeyDown);
    this.el.removeEventListener("touchstart", this._onTouchStart);
    this.el.removeEventListener("touchmove", this._onTouchMove);
    this.el.removeEventListener("touchend", this._onTouchEnd);
    if (this._liveRegion) this._liveRegion.remove();
  },

  _items() {
    return Array.from(this.el.querySelectorAll("[data-sortable-item]"));
  },

  _announce(msg) {
    if (this._liveRegion) {
      this._liveRegion.textContent = "";
      requestAnimationFrame(() => { this._liveRegion.textContent = msg; });
    }
  },

  _handleDragStart(e) {
    const item = e.target.closest("[data-sortable-item]");
    if (!item) return;

    if (this._useHandle) {
      const handle = e.target.closest("[data-sortable-handle]");
      if (!handle) { e.preventDefault(); return; }
    }

    this._dragging = item;
    this._dragStartIndex = parseInt(item.dataset.index, 10);
    e.dataTransfer.effectAllowed = "move";
    e.dataTransfer.setData("text/plain", item.id);

    if (!this._prefersReducedMotion) {
      requestAnimationFrame(() => item.setAttribute("data-dragging", "true"));
    }
    this._announce("Item grabbed. Use arrow keys to reorder, Enter to drop, Escape to cancel.");
  },

  _handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = "move";
    const target = this._dropTarget(e.clientX, e.clientY);
    if (target && target !== this._dragging) {
      this._clearDragOver();
      target.setAttribute("data-drag-over", "true");
    }
  },

  _handleDragEnter(e) {
    e.preventDefault();
  },

  _handleDragLeave(e) {
    if (!this.el.contains(e.relatedTarget)) {
      this._clearDragOver();
    }
  },

  _handleDrop(e) {
    e.preventDefault();
    if (!this._dragging) return;

    const target = this._dropTarget(e.clientX, e.clientY);
    this._clearDragOver();

    if (!target || target === this._dragging) {
      this._cleanup();
      return;
    }

    const items = this._items();
    const oldIndex = items.indexOf(this._dragging);
    const targetIndex = items.indexOf(target);
    if (oldIndex === -1 || targetIndex === -1) { this._cleanup(); return; }

    // Reorder in DOM
    const newIndex = this._insertBefore(e.clientX, e.clientY, target)
      ? targetIndex
      : targetIndex + 1;

    if (newIndex > oldIndex) {
      target.after(this._dragging);
    } else {
      target.before(this._dragging);
    }

    const resolvedNew = this._items().indexOf(this._dragging);
    this._announce(`Dropped at position ${resolvedNew + 1}.`);
    this.pushEvent(this._onReorder, {
      old_index: oldIndex,
      new_index: resolvedNew,
      id: this._dragging.id,
    });
    this._cleanup();
  },

  _handleDragEnd(_e) {
    this._cleanup();
  },

  // Keyboard navigation
  _handleKeyDown(e) {
    const item = e.target.closest("[data-sortable-item]");
    if (!item) return;

    if (e.key === " " || e.key === "Enter") {
      e.preventDefault();
      if (!this._dragging) {
        // Grab
        this._dragging = item;
        this._dragStartIndex = parseInt(item.dataset.index, 10);
        item.setAttribute("data-dragging", "true");
        this._announce("Item grabbed. Use arrow keys to reorder, Enter to drop, Escape to cancel.");
      } else {
        // Drop
        const items = this._items();
        const newIndex = items.indexOf(this._dragging);
        this._announce(`Dropped at position ${newIndex + 1}.`);
        this.pushEvent(this._onReorder, {
          old_index: this._dragStartIndex,
          new_index: newIndex,
          id: this._dragging.id,
        });
        this._cleanup();
      }
    } else if (e.key === "Escape") {
      e.preventDefault();
      this._cleanup();
      this._announce("Drag cancelled.");
    } else if (this._dragging) {
      const vertical = this._orientation === "vertical";
      const moveNext = vertical ? e.key === "ArrowDown" : e.key === "ArrowRight";
      const movePrev = vertical ? e.key === "ArrowUp" : e.key === "ArrowLeft";

      if (moveNext || movePrev) {
        e.preventDefault();
        const items = this._items();
        const idx = items.indexOf(this._dragging);
        const nextIdx = moveNext ? idx + 1 : idx - 1;
        if (nextIdx < 0 || nextIdx >= items.length) return;
        const sibling = items[nextIdx];
        if (moveNext) sibling.after(this._dragging);
        else sibling.before(this._dragging);
        this._dragging.focus();
        this._announce(`Item moved to position ${this._items().indexOf(this._dragging) + 1}.`);
      }
    }
  },

  // Touch support
  _handleTouchStart(e) {
    const item = e.target.closest("[data-sortable-item]");
    if (!item) return;
    if (this._useHandle && !e.target.closest("[data-sortable-handle]")) return;
    this._dragging = item;
    this._dragStartIndex = parseInt(item.dataset.index, 10);
    if (!this._prefersReducedMotion) item.setAttribute("data-dragging", "true");
  },

  _handleTouchMove(e) {
    if (!this._dragging) return;
    e.preventDefault();
    const touch = e.touches[0];
    const el = document.elementFromPoint(touch.clientX, touch.clientY);
    const target = el && el.closest("[data-sortable-item]");
    this._clearDragOver();
    if (target && target !== this._dragging) {
      target.setAttribute("data-drag-over", "true");
    }
  },

  _handleTouchEnd(e) {
    if (!this._dragging) return;
    const touch = e.changedTouches[0];
    const el = document.elementFromPoint(touch.clientX, touch.clientY);
    const target = el && el.closest("[data-sortable-item]");
    this._clearDragOver();

    if (target && target !== this._dragging) {
      const items = this._items();
      const oldIndex = items.indexOf(this._dragging);
      const targetIndex = items.indexOf(target);
      target.before(this._dragging);
      const newIndex = this._items().indexOf(this._dragging);
      this.pushEvent(this._onReorder, {
        old_index: oldIndex,
        new_index: newIndex,
        id: this._dragging.id,
      });
    }
    this._cleanup();
  },

  _dropTarget(clientX, clientY) {
    const items = this._items();
    for (const item of items) {
      if (item === this._dragging) continue;
      const rect = item.getBoundingClientRect();
      if (
        clientX >= rect.left && clientX <= rect.right &&
        clientY >= rect.top && clientY <= rect.bottom
      ) return item;
    }
    return null;
  },

  _insertBefore(clientX, clientY, target) {
    const rect = target.getBoundingClientRect();
    if (this._orientation === "vertical") {
      return clientY < rect.top + rect.height / 2;
    }
    return clientX < rect.left + rect.width / 2;
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
    this._dragStartIndex = -1;
  },
};

export { PhiaSortable };
export default PhiaSortable;
