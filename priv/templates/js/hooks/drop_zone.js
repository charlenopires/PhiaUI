/**
 * PhiaDropZone — file/payload drop zone hook.
 *
 * Uses _depth counter (same as PhiaFullscreenDrop) to avoid flickering on
 * nested elements. Transitions data-state between idle/hover/active.
 *
 * Emits: pushEvent(onDrop, { zone_id: "dom-id" })
 * (File handling is wired through phx-drop-target on the inner element.)
 *
 * Registration:
 *   import { PhiaDropZone, PhiaDragTransferList } from "./hooks/drop_zone"
 *   let liveSocket = new LiveSocket("/live", Socket, {
 *     hooks: { PhiaDropZone, PhiaDragTransferList }
 *   })
 */
const PhiaDropZone = {
  mounted() {
    this._onDrop = this.el.dataset.onDrop || "zone_drop";
    this._depth = 0;

    this._onDragEnter = (e) => {
      if (!this._acceptsDrag(e)) return;
      this._depth++;
      if (this._depth === 1) this._setState("hover");
    };

    this._onDragLeave = () => {
      this._depth--;
      if (this._depth <= 0) {
        this._depth = 0;
        this._setState("idle");
      }
    };

    this._onDragOver = (e) => {
      if (!this._acceptsDrag(e)) return;
      e.preventDefault();
      e.dataTransfer.dropEffect = "copy";
      if (this._depth > 0 && this.el.dataset.state !== "active") {
        this._setState("active");
      }
    };

    this._onDrop = (e) => {
      e.preventDefault();
      this._depth = 0;
      this._setState("idle");
      this.pushEvent(this.el.dataset.onDrop || "zone_drop", { zone_id: this.el.id });
    };

    this._onClick = () => {
      const input = this.el.querySelector("input[type=file]");
      if (input) input.click();
    };

    this.el.addEventListener("dragenter", this._onDragEnter);
    this.el.addEventListener("dragleave", this._onDragLeave);
    this.el.addEventListener("dragover", this._onDragOver);
    this.el.addEventListener("drop", this._onDrop);
    this.el.addEventListener("click", this._onClick);
  },

  destroyed() {
    this.el.removeEventListener("dragenter", this._onDragEnter);
    this.el.removeEventListener("dragleave", this._onDragLeave);
    this.el.removeEventListener("dragover", this._onDragOver);
    this.el.removeEventListener("drop", this._onDrop);
    this.el.removeEventListener("click", this._onClick);
  },

  _acceptsDrag(e) {
    return e.dataTransfer && (
      e.dataTransfer.types.includes("Files") ||
      e.dataTransfer.types.includes("text/plain")
    );
  },

  _setState(state) {
    this.el.dataset.state = state;
  },
};

/**
 * PhiaDragTransferList — dual-list drag-and-drop transfer widget hook.
 *
 * Manages drag between source/target lists and button-click fallback.
 * Tracks selected item via data-selected attribute.
 *
 * Emits: pushEvent(onTransfer, { item_id: "...", direction: "to_target" | "to_source" })
 */
const PhiaDragTransferList = {
  mounted() {
    this._onTransfer = this.el.dataset.onTransfer || "items_transferred";
    this._draggingId = null;
    this._draggingSource = null; // "source" | "target"
    this._selectedId = null;

    this._onDragStart = (e) => this._handleDragStart(e);
    this._onDragOver = (e) => this._handleDragOver(e);
    this._onDragEnter = (e) => this._handleDragEnter(e);
    this._onDragLeave = (e) => this._handleDragLeave(e);
    this._onDrop = (e) => this._handleDrop(e);
    this._onDragEnd = (e) => this._handleDragEnd(e);
    this._onClick = (e) => this._handleClick(e);

    this.el.addEventListener("dragstart", this._onDragStart);
    this.el.addEventListener("dragover", this._onDragOver);
    this.el.addEventListener("dragenter", this._onDragEnter);
    this.el.addEventListener("dragleave", this._onDragLeave);
    this.el.addEventListener("drop", this._onDrop);
    this.el.addEventListener("dragend", this._onDragEnd);
    this.el.addEventListener("click", this._onClick);
  },

  destroyed() {
    this.el.removeEventListener("dragstart", this._onDragStart);
    this.el.removeEventListener("dragover", this._onDragOver);
    this.el.removeEventListener("dragenter", this._onDragEnter);
    this.el.removeEventListener("dragleave", this._onDragLeave);
    this.el.removeEventListener("drop", this._onDrop);
    this.el.removeEventListener("dragend", this._onDragEnd);
    this.el.removeEventListener("click", this._onClick);
  },

  _sourceList() { return this.el.querySelector("[data-transfer-source]"); },
  _targetList() { return this.el.querySelector("[data-transfer-target]"); },

  _listOf(item) {
    if (item.closest("[data-transfer-source]")) return "source";
    if (item.closest("[data-transfer-target]")) return "target";
    return null;
  },

  _handleDragStart(e) {
    const item = e.target.closest("li[data-item-id]");
    if (!item) return;
    this._draggingId = item.dataset.itemId;
    this._draggingSource = this._listOf(item);
    e.dataTransfer.effectAllowed = "move";
    e.dataTransfer.setData("text/plain", this._draggingId);
    requestAnimationFrame(() => item.setAttribute("data-dragging", "true"));
    // Also track as selected
    this._selectedId = this._draggingId;
  },

  _handleDragOver(e) {
    const list = e.target.closest("[data-transfer-source],[data-transfer-target]");
    if (list) { e.preventDefault(); e.dataTransfer.dropEffect = "move"; }
  },

  _handleDragEnter(e) {
    const list = e.target.closest("[data-transfer-source],[data-transfer-target]");
    if (list) list.setAttribute("data-drag-over", "true");
  },

  _handleDragLeave(e) {
    const list = e.target.closest("[data-transfer-source],[data-transfer-target]");
    if (list && !list.contains(e.relatedTarget)) list.removeAttribute("data-drag-over");
  },

  _handleDrop(e) {
    const list = e.target.closest("[data-transfer-source],[data-transfer-target]");
    if (!list || !this._draggingId) return;
    e.preventDefault();

    const droppedInto = list.hasAttribute("data-transfer-source") ? "source" : "target";
    if (droppedInto === this._draggingSource) { this._cleanup(); return; }

    const direction = droppedInto === "target" ? "to_target" : "to_source";
    this._transfer(this._draggingId, direction, list);
    this._cleanup();
  },

  _handleDragEnd(_e) {
    this._cleanup();
  },

  _handleClick(e) {
    // Button clicks for accessibility fallback
    if (e.target.closest("[data-transfer-to-target]")) {
      if (this._selectedId) {
        const srcList = this._sourceList();
        this._transfer(this._selectedId, "to_target", this._targetList());
      }
    } else if (e.target.closest("[data-transfer-to-source]")) {
      if (this._selectedId) {
        this._transfer(this._selectedId, "to_source", this._sourceList());
      }
    } else {
      // Item click = select
      const item = e.target.closest("li[data-item-id]");
      if (item) {
        this.el.querySelectorAll("[data-selected]").forEach((el) =>
          el.removeAttribute("data-selected")
        );
        item.setAttribute("data-selected", "true");
        this._selectedId = item.dataset.itemId;
      }
    }
  },

  _transfer(itemId, direction, targetList) {
    const item = this.el.querySelector(`[data-item-id="${itemId}"]`);
    if (item && targetList) {
      targetList.appendChild(item);
      this.pushEvent(this._onTransfer, { item_id: itemId, direction });
    }
    this._cleanup();
  },

  _cleanup() {
    this.el.querySelectorAll("[data-dragging]").forEach((el) =>
      el.removeAttribute("data-dragging")
    );
    this.el.querySelectorAll("[data-drag-over]").forEach((el) =>
      el.removeAttribute("data-drag-over")
    );
    this._draggingId = null;
    this._draggingSource = null;
  },
};

export { PhiaDropZone, PhiaDragTransferList };
export default PhiaDropZone;
