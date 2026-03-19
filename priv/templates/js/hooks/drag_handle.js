/**
 * PhiaDragHandle — 6-dot grip for block-level drag reordering.
 *
 * Shows on hover near the left edge of blocks. Drag-and-drop reorder
 * via the v2 engine's PhiaBlockOps.moveBlock(). Ghost preview and
 * drop indicator line.
 *
 * Markup contract:
 *   <div phx-hook="PhiaDragHandle" id="..." data-editor-id="...">
 *     <div data-rich-content> ... blocks ... </div>
 *   </div>
 */
const PhiaDragHandle = {
  mounted() {
    this._editorId = this.el.dataset.editorId || this.el.id;
    this._contentEl = this.el.querySelector("[data-rich-content]");
    if (!this._contentEl) return;

    this._handle = null;
    this._dragBlock = null;
    this._dropIndicator = null;
    this._isDragging = false;

    this._createHandle();
    this._createDropIndicator();
    this._bindHover();
    this._bindDrag();
  },

  destroyed() {
    if (this._handle) this._handle.remove();
    if (this._dropIndicator) this._dropIndicator.remove();
  },

  _createHandle() {
    this._handle = document.createElement("div");
    this._handle.className = "phia-block-drag-handle";
    this._handle.setAttribute("draggable", "true");
    this._handle.setAttribute("aria-label", "Drag to reorder block");
    this._handle.style.cssText = `
      position: absolute; left: -28px; width: 20px; height: 20px;
      display: none; align-items: center; justify-content: center;
      cursor: grab; border-radius: 4px; z-index: 20;
      color: var(--color-muted-foreground, #6b7280);
      transition: opacity 150ms, background 150ms;
    `;
    this._handle.innerHTML = `
      <svg width="14" height="14" viewBox="0 0 16 16" fill="currentColor">
        <circle cx="5" cy="3" r="1.2"/><circle cx="11" cy="3" r="1.2"/>
        <circle cx="5" cy="8" r="1.2"/><circle cx="11" cy="8" r="1.2"/>
        <circle cx="5" cy="13" r="1.2"/><circle cx="11" cy="13" r="1.2"/>
      </svg>
    `;
    this._handle.addEventListener("mouseenter", () => {
      this._handle.style.background = "var(--color-muted, #f4f4f5)";
    });
    this._handle.addEventListener("mouseleave", () => {
      if (!this._isDragging) {
        this._handle.style.background = "transparent";
      }
    });

    this._contentEl.style.position = "relative";
    this._contentEl.appendChild(this._handle);
  },

  _createDropIndicator() {
    this._dropIndicator = document.createElement("div");
    this._dropIndicator.className = "phia-drop-indicator";
    this._dropIndicator.style.cssText = `
      position: absolute; left: 0; right: 0; height: 3px;
      background: var(--color-primary, #3b82f6); border-radius: 2px;
      display: none; z-index: 25; pointer-events: none;
      box-shadow: 0 0 6px var(--color-primary, #3b82f6);
    `;
    this._contentEl.appendChild(this._dropIndicator);
  },

  _getBlocks() {
    return Array.from(this._contentEl.children).filter(
      (el) => !el.classList.contains("phia-block-drag-handle") && !el.classList.contains("phia-drop-indicator")
    );
  },

  _bindHover() {
    this._contentEl.addEventListener("mousemove", (e) => {
      if (this._isDragging) return;

      const blocks = this._getBlocks();
      let hovered = null;

      for (const block of blocks) {
        const rect = block.getBoundingClientRect();
        if (e.clientY >= rect.top && e.clientY <= rect.bottom) {
          hovered = block;
          break;
        }
      }

      if (hovered) {
        const containerRect = this._contentEl.getBoundingClientRect();
        const blockRect = hovered.getBoundingClientRect();
        this._handle.style.display = "flex";
        this._handle.style.top = `${blockRect.top - containerRect.top + (blockRect.height / 2) - 10}px`;
        this._dragBlock = hovered;
      }
    });

    this._contentEl.addEventListener("mouseleave", () => {
      if (!this._isDragging) {
        this._handle.style.display = "none";
      }
    });
  },

  _bindDrag() {
    this._handle.addEventListener("dragstart", (e) => {
      if (!this._dragBlock) return;
      this._isDragging = true;
      this._handle.style.cursor = "grabbing";

      const blockId = this._dragBlock.dataset.blockId || "";
      e.dataTransfer.setData("text/plain", blockId);
      e.dataTransfer.effectAllowed = "move";

      // Ghost preview
      const ghost = this._dragBlock.cloneNode(true);
      ghost.style.cssText = "opacity: 0.6; position: absolute; top: -9999px; pointer-events: none;";
      document.body.appendChild(ghost);
      e.dataTransfer.setDragImage(ghost, 0, 0);
      requestAnimationFrame(() => ghost.remove());

      this._dragBlock.style.opacity = "0.4";
    });

    this._contentEl.addEventListener("dragover", (e) => {
      e.preventDefault();
      e.dataTransfer.dropEffect = "move";

      const blocks = this._getBlocks();
      const containerRect = this._contentEl.getBoundingClientRect();
      let closestBlock = null;
      let closestDist = Infinity;
      let insertBefore = true;

      blocks.forEach((block) => {
        const rect = block.getBoundingClientRect();
        const midY = rect.top + rect.height / 2;
        const dist = Math.abs(e.clientY - midY);
        if (dist < closestDist) {
          closestDist = dist;
          closestBlock = block;
          insertBefore = e.clientY < midY;
        }
      });

      if (closestBlock) {
        const rect = closestBlock.getBoundingClientRect();
        const y = insertBefore ? rect.top - containerRect.top : rect.bottom - containerRect.top;
        this._dropIndicator.style.display = "block";
        this._dropIndicator.style.top = `${y - 1}px`;
      }
    });

    this._contentEl.addEventListener("dragleave", (e) => {
      if (!this._contentEl.contains(e.relatedTarget)) {
        this._dropIndicator.style.display = "none";
      }
    });

    this._contentEl.addEventListener("drop", (e) => {
      e.preventDefault();
      this._dropIndicator.style.display = "none";

      if (!this._dragBlock) return;

      const blocks = this._getBlocks();
      const containerRect = this._contentEl.getBoundingClientRect();
      let targetBlock = null;
      let insertBefore = true;

      blocks.forEach((block) => {
        const rect = block.getBoundingClientRect();
        const midY = rect.top + rect.height / 2;
        if (Math.abs(e.clientY - midY) < (rect.height / 2 + 10)) {
          targetBlock = block;
          insertBefore = e.clientY < midY;
        }
      });

      if (targetBlock && targetBlock !== this._dragBlock) {
        if (insertBefore) {
          this._contentEl.insertBefore(this._dragBlock, targetBlock);
        } else {
          this._contentEl.insertBefore(this._dragBlock, targetBlock.nextSibling);
        }

        this.pushEvent("editor:block-move", {
          editor_id: this._editorId,
          block_id: this._dragBlock.dataset.blockId,
          before_id: this._dragBlock.nextElementSibling?.dataset?.blockId || null
        });
      }
    });

    this._handle.addEventListener("dragend", () => {
      this._isDragging = false;
      this._handle.style.cursor = "grab";
      this._dropIndicator.style.display = "none";
      if (this._dragBlock) {
        this._dragBlock.style.opacity = "";
      }
    });
  }
};

export default PhiaDragHandle;
