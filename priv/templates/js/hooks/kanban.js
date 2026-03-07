/**
 * PhiaKanban — Kanban board drag-and-drop hook.
 *
 * Enables dragging kanban cards (li elements) between columns (div elements
 * identified by data-column-id). Uses depth counter for dragenter/dragleave
 * to avoid flickering on nested elements (same pattern as PhiaFullscreenDrop).
 *
 * Keyboard: Arrow Left/Right to move cards between columns;
 *           Space/Enter to grab/drop; Escape to cancel.
 *
 * Emits: pushEvent(onMove, { id: "card-id", from: "col-id", to: "col-id", index: N })
 *
 * Registration:
 *   import { PhiaKanban } from "./hooks/kanban"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaKanban } })
 */
const PhiaKanban = {
  mounted() {
    this._onMove = this.el.dataset.onMove || "card_moved";
    this._draggingCard = null;
    this._sourceColumnId = null;
    this._columnDepths = new Map(); // columnId -> depth counter

    this._onDragStart = (e) => this._handleDragStart(e);
    this._onDragOver = (e) => this._handleDragOver(e);
    this._onDragEnter = (e) => this._handleDragEnter(e);
    this._onDragLeave = (e) => this._handleDragLeave(e);
    this._onDrop = (e) => this._handleDrop(e);
    this._onDragEnd = (e) => this._handleDragEnd(e);
    this._onKeyDown = (e) => this._handleKeyDown(e);

    this.el.addEventListener("dragstart", this._onDragStart);
    this.el.addEventListener("dragover", this._onDragOver);
    this.el.addEventListener("dragenter", this._onDragEnter);
    this.el.addEventListener("dragleave", this._onDragLeave);
    this.el.addEventListener("drop", this._onDrop);
    this.el.addEventListener("dragend", this._onDragEnd);
    this.el.addEventListener("keydown", this._onKeyDown);
  },

  destroyed() {
    this.el.removeEventListener("dragstart", this._onDragStart);
    this.el.removeEventListener("dragover", this._onDragOver);
    this.el.removeEventListener("dragenter", this._onDragEnter);
    this.el.removeEventListener("dragleave", this._onDragLeave);
    this.el.removeEventListener("drop", this._onDrop);
    this.el.removeEventListener("dragend", this._onDragEnd);
    this.el.removeEventListener("keydown", this._onKeyDown);
  },

  _columns() {
    return Array.from(this.el.querySelectorAll("[data-column-id]"));
  },

  _columnList(column) {
    return column.querySelector("ol");
  },

  _handleDragStart(e) {
    const card = e.target.closest("li[id]");
    if (!card) return;
    const col = card.closest("[data-column-id]");
    if (!col) return;

    this._draggingCard = card;
    this._sourceColumnId = col.dataset.columnId;
    e.dataTransfer.effectAllowed = "move";
    e.dataTransfer.setData("text/plain", card.id);
    requestAnimationFrame(() => card.setAttribute("data-dragging", "true"));
  },

  _handleDragOver(e) {
    const list = e.target.closest("ol");
    if (list) {
      e.preventDefault();
      e.dataTransfer.dropEffect = "move";
    }
  },

  _handleDragEnter(e) {
    const col = e.target.closest("[data-column-id]");
    if (!col) return;
    const id = col.dataset.columnId;
    this._columnDepths.set(id, (this._columnDepths.get(id) || 0) + 1);
    col.setAttribute("data-drag-over", "true");
  },

  _handleDragLeave(e) {
    const col = e.target.closest("[data-column-id]");
    if (!col) return;
    const id = col.dataset.columnId;
    const depth = (this._columnDepths.get(id) || 1) - 1;
    this._columnDepths.set(id, depth);
    if (depth <= 0) {
      this._columnDepths.set(id, 0);
      col.removeAttribute("data-drag-over");
    }
  },

  _handleDrop(e) {
    const list = e.target.closest("ol");
    if (!list || !this._draggingCard) return;
    e.preventDefault();

    const targetCol = list.closest("[data-column-id]");
    if (!targetCol) { this._cleanup(); return; }

    const targetColumnId = targetCol.dataset.columnId;
    const newIndex = this._dropIndex(e.clientY, list);

    list.appendChild(this._draggingCard);

    this._clearDragOver();
    this.pushEvent(this._onMove, {
      id: this._draggingCard.id,
      from: this._sourceColumnId,
      to: targetColumnId,
      index: newIndex,
    });
    this._cleanup();
  },

  _handleDragEnd(_e) {
    this._cleanup();
  },

  // Compute drop index by finding insertion position among sibling li elements
  _dropIndex(clientY, list) {
    const cards = Array.from(list.querySelectorAll("li"));
    for (let i = 0; i < cards.length; i++) {
      if (cards[i] === this._draggingCard) continue;
      const rect = cards[i].getBoundingClientRect();
      if (clientY < rect.top + rect.height / 2) return i;
    }
    return cards.length;
  },

  // Keyboard: grab card with Space, Arrow Left/Right to move between columns
  _handleKeyDown(e) {
    const card = e.target.closest("li[id]");
    if (!card) return;

    if (e.key === " " || e.key === "Enter") {
      e.preventDefault();
      if (!this._draggingCard) {
        const col = card.closest("[data-column-id]");
        this._draggingCard = card;
        this._sourceColumnId = col ? col.dataset.columnId : null;
        card.setAttribute("data-dragging", "true");
      } else {
        // Drop in current column
        const col = card.closest("[data-column-id]");
        const list = col ? this._columnList(col) : null;
        const cards = list ? Array.from(list.querySelectorAll("li")) : [];
        const newIndex = cards.indexOf(this._draggingCard);
        this.pushEvent(this._onMove, {
          id: this._draggingCard.id,
          from: this._sourceColumnId,
          to: col ? col.dataset.columnId : this._sourceColumnId,
          index: newIndex,
        });
        this._cleanup();
      }
    } else if (e.key === "Escape") {
      e.preventDefault();
      this._cleanup();
    } else if (this._draggingCard && (e.key === "ArrowLeft" || e.key === "ArrowRight")) {
      e.preventDefault();
      const cols = this._columns();
      const currentCol = this._draggingCard.closest("[data-column-id]");
      const currentIdx = cols.indexOf(currentCol);
      const targetIdx = e.key === "ArrowRight" ? currentIdx + 1 : currentIdx - 1;
      if (targetIdx < 0 || targetIdx >= cols.length) return;
      const targetList = this._columnList(cols[targetIdx]);
      if (targetList) {
        targetList.appendChild(this._draggingCard);
        this._draggingCard.focus();
      }
    }
  },

  _clearDragOver() {
    this._columnDepths.clear();
    this.el.querySelectorAll("[data-drag-over]").forEach((el) =>
      el.removeAttribute("data-drag-over")
    );
  },

  _cleanup() {
    if (this._draggingCard) {
      this._draggingCard.removeAttribute("data-dragging");
      this._draggingCard = null;
    }
    this._sourceColumnId = null;
    this._clearDragOver();
  },
};

export { PhiaKanban };
export default PhiaKanban;
