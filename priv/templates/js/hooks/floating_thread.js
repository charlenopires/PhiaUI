/**
 * PhiaFloatingThread — JS hook for absolutely-positioned thread panels.
 *
 * Features:
 * - Positions the thread at (x, y) from data attributes
 * - Draggable via the thread header (data-thread-drag-handle)
 * - Click-outside-to-dismiss (with 100ms delay to avoid immediate close)
 * - Scroll repositioning within an editor container
 */
const PhiaFloatingThread = {
  mounted() {
    this._container = this.el;
    this._isDragging = false;
    this._dragOffset = { x: 0, y: 0 };

    // Set initial position from data attributes
    this._updatePosition();

    // Click outside to dismiss (delayed to avoid immediate close on creation)
    this._onClickOutside = (e) => {
      if (!this._container.contains(e.target)) {
        this.pushEvent("collab:thread:close", {
          thread_id: this._container.dataset.threadId,
        });
      }
    };

    this._outsideTimer = setTimeout(() => {
      document.addEventListener("mousedown", this._onClickOutside);
    }, 100);

    // Draggable via header handle
    const header = this._container.querySelector(
      "[data-thread-drag-handle]"
    );

    if (header) {
      this._onDragStart = (e) => {
        this._isDragging = true;
        const rect = this._container.getBoundingClientRect();
        this._dragOffset = {
          x: e.clientX - rect.left,
          y: e.clientY - rect.top,
        };
        header.style.cursor = "grabbing";
        e.preventDefault();
      };

      header.addEventListener("mousedown", this._onDragStart);
      header.style.cursor = "grab";
    }

    this._onMouseMove = (e) => {
      if (!this._isDragging) return;

      const parent = this._container.parentElement;
      if (!parent) return;

      const parentRect = parent.getBoundingClientRect();
      const x = e.clientX - parentRect.left - this._dragOffset.x;
      const y = e.clientY - parentRect.top - this._dragOffset.y;

      // Clamp to parent bounds
      const maxX = parent.scrollWidth - this._container.offsetWidth;
      const maxY = parent.scrollHeight - this._container.offsetHeight;

      this._container.style.left = `${Math.max(0, Math.min(x, maxX))}px`;
      this._container.style.top = `${Math.max(0, Math.min(y, maxY))}px`;
    };

    this._onMouseUp = () => {
      if (this._isDragging) {
        this._isDragging = false;
        const headerEl = this._container.querySelector(
          "[data-thread-drag-handle]"
        );
        if (headerEl) headerEl.style.cursor = "grab";
      }
    };

    document.addEventListener("mousemove", this._onMouseMove);
    document.addEventListener("mouseup", this._onMouseUp);

    // Recalculate position on editor scroll
    const editor = this._container.closest("[data-collab-editor]");
    if (editor) {
      this._onScroll = () => {
        if (!this._isDragging) {
          this._updatePosition();
        }
      };
      editor.addEventListener("scroll", this._onScroll);
      this._editor = editor;
    }
  },

  _updatePosition() {
    const x = parseInt(this._container.dataset.x, 10) || 0;
    const y = parseInt(this._container.dataset.y, 10) || 0;
    this._container.style.left = `${x}px`;
    this._container.style.top = `${y}px`;
  },

  updated() {
    // Re-position if data attributes change from server
    if (!this._isDragging) {
      this._updatePosition();
    }
  },

  destroyed() {
    clearTimeout(this._outsideTimer);
    document.removeEventListener("mousedown", this._onClickOutside);
    document.removeEventListener("mousemove", this._onMouseMove);
    document.removeEventListener("mouseup", this._onMouseUp);

    if (this._editor && this._onScroll) {
      this._editor.removeEventListener("scroll", this._onScroll);
    }
  },
};

export default PhiaFloatingThread;
