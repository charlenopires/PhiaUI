/**
 * PhiaDraggableTree — draggable tree hierarchy hook.
 *
 * Prevents circular moves by computing ancestor IDs on every dragstart.
 * Drop position is determined by vertical thirds of the target node:
 *   - Top third    → "before"
 *   - Middle third → "inside" (becomes child)
 *   - Bottom third → "after"
 *
 * Also handles expand/collapse via [data-tree-toggle] click.
 *
 * Emits: pushEvent(onReorder, { id: "node-id", target_id: "node-id",
 *                               position: "before"|"inside"|"after" })
 *
 * Registration:
 *   import { PhiaDraggableTree } from "./hooks/draggable_tree"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaDraggableTree } })
 */
const PhiaDraggableTree = {
  mounted() {
    this._onReorder = this.el.dataset.onReorder || "tree_reorder";
    this._dragging = null;
    this._ancestorIds = new Set();

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

  _handleDragStart(e) {
    const node = e.target.closest("[data-tree-node]");
    if (!node) return;

    this._dragging = node;
    this._ancestorIds = this._computeAncestors(node);

    e.dataTransfer.effectAllowed = "move";
    e.dataTransfer.setData("text/plain", node.id);
    requestAnimationFrame(() => node.setAttribute("data-dragging", "true"));
  },

  _handleDragOver(e) {
    const node = e.target.closest("[data-tree-node]");
    if (!node || !this._dragging) return;

    if (node === this._dragging || this._ancestorIds.has(node.id)) {
      e.dataTransfer.dropEffect = "none";
      return;
    }

    e.preventDefault();
    e.dataTransfer.dropEffect = "move";

    const position = this._dropPosition(e.clientY, node);
    this._clearDragOver();
    node.setAttribute("data-drag-over", position);
  },

  _handleDragEnter(e) {
    e.preventDefault();
  },

  _handleDragLeave(e) {
    const node = e.target.closest("[data-tree-node]");
    if (node && !node.contains(e.relatedTarget)) {
      node.removeAttribute("data-drag-over");
    }
  },

  _handleDrop(e) {
    const node = e.target.closest("[data-tree-node]");
    if (!node || !this._dragging) return;
    if (node === this._dragging || this._ancestorIds.has(node.id)) {
      this._cleanup();
      return;
    }
    e.preventDefault();

    const position = this._dropPosition(e.clientY, node);
    this._clearDragOver();

    this.pushEvent(this._onReorder, {
      id: this._dragging.id,
      target_id: node.id,
      position,
    });
    this._cleanup();
  },

  _handleDragEnd(_e) {
    this._cleanup();
  },

  // Expand/collapse via [data-tree-toggle] button click
  _handleClick(e) {
    const toggle = e.target.closest("[data-tree-toggle]");
    if (!toggle) return;
    e.stopPropagation();

    const node = toggle.closest("[data-tree-node]");
    if (!node) return;

    const isExpanded = node.getAttribute("aria-expanded") === "true";
    node.setAttribute("aria-expanded", String(!isExpanded));

    const childGroup = node.querySelector(":scope > ul[role='group']");
    if (childGroup) {
      childGroup.hidden = isExpanded;
    }
  },

  // Determine drop position from vertical thirds of the target node row
  _dropPosition(clientY, node) {
    const row = node.querySelector(":scope > div") || node;
    const rect = row.getBoundingClientRect();
    const third = rect.height / 3;
    const relY = clientY - rect.top;
    if (relY < third) return "before";
    if (relY < third * 2) return "inside";
    return "after";
  },

  // Walk up the tree collecting ancestor node IDs (to prevent circular drops)
  _computeAncestors(node) {
    const ids = new Set();
    // Collect all descendant IDs of `node` — dropping INTO them would be circular
    node.querySelectorAll("[data-tree-node]").forEach((n) => ids.add(n.id));
    return ids;
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
    this._ancestorIds = new Set();
    this._clearDragOver();
  },
};

export { PhiaDraggableTree };
export default PhiaDraggableTree;
