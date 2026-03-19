/**
 * PhiaImageResize — corner/edge handles for inline image resizing.
 *
 * Attaches to an image block element. On hover, shows resize handles at
 * corners and edges. Shift+drag locks aspect ratio. Double-click resets
 * to original size. Pushes `editor:image-resize` event to server.
 *
 * Markup contract:
 *   <div phx-hook="PhiaImageResize" id="..." data-min-width="50" data-max-width="1200">
 *     <img src="..." />
 *   </div>
 */
const PhiaImageResize = {
  mounted() {
    this._img = this.el.querySelector("img");
    if (!this._img) return;

    this._handles = [];
    this._dragging = false;
    this._startX = 0;
    this._startY = 0;
    this._startW = 0;
    this._startH = 0;
    this._aspectRatio = 1;
    this._activeHandle = null;
    this._minW = parseInt(this.el.dataset.minWidth || "50", 10);
    this._maxW = parseInt(this.el.dataset.maxWidth || "1200", 10);
    this._originalWidth = null;

    this._createHandles();
    this._bindEvents();
  },

  destroyed() {
    this._removeHandles();
    document.removeEventListener("pointermove", this._onPointerMove);
    document.removeEventListener("pointerup", this._onPointerUp);
  },

  _createHandles() {
    const positions = ["nw", "ne", "sw", "se", "n", "s", "e", "w"];
    const cursors = {
      nw: "nwse-resize", ne: "nesw-resize", sw: "nesw-resize", se: "nwse-resize",
      n: "ns-resize", s: "ns-resize", e: "ew-resize", w: "ew-resize"
    };

    this.el.style.position = "relative";
    this.el.style.display = "inline-block";

    positions.forEach((pos) => {
      const handle = document.createElement("div");
      handle.dataset.handle = pos;
      handle.style.cssText = `
        position: absolute; width: 10px; height: 10px;
        background: var(--color-primary, #3b82f6); border: 2px solid white;
        border-radius: 2px; cursor: ${cursors[pos]};
        opacity: 0; transition: opacity 150ms; z-index: 10;
        pointer-events: auto;
      `;
      this._positionHandle(handle, pos);
      this.el.appendChild(handle);
      this._handles.push(handle);

      handle.addEventListener("pointerdown", (e) => {
        e.preventDefault();
        e.stopPropagation();
        this._startResize(e, pos);
      });
    });

    this.el.addEventListener("mouseenter", () => this._showHandles());
    this.el.addEventListener("mouseleave", () => {
      if (!this._dragging) this._hideHandles();
    });

    this._img.addEventListener("dblclick", () => this._resetSize());
  },

  _positionHandle(handle, pos) {
    const offset = "-5px";
    const mid = "calc(50% - 5px)";
    const map = {
      nw: { top: offset, left: offset },
      ne: { top: offset, right: offset },
      sw: { bottom: offset, left: offset },
      se: { bottom: offset, right: offset },
      n: { top: offset, left: mid },
      s: { bottom: offset, left: mid },
      e: { top: mid, right: offset },
      w: { top: mid, left: offset }
    };
    Object.assign(handle.style, map[pos]);
  },

  _showHandles() {
    this._handles.forEach((h) => (h.style.opacity = "1"));
    this.el.style.outline = "2px solid var(--color-primary, #3b82f6)";
    this.el.style.outlineOffset = "2px";
  },

  _hideHandles() {
    this._handles.forEach((h) => (h.style.opacity = "0"));
    this.el.style.outline = "none";
  },

  _removeHandles() {
    this._handles.forEach((h) => h.remove());
    this._handles = [];
  },

  _startResize(e, pos) {
    this._dragging = true;
    this._activeHandle = pos;
    this._startX = e.clientX;
    this._startY = e.clientY;
    this._startW = this._img.offsetWidth;
    this._startH = this._img.offsetHeight;
    this._aspectRatio = this._startW / this._startH;

    if (!this._originalWidth) {
      this._originalWidth = this._startW;
    }

    this._onPointerMove = this._handlePointerMove.bind(this);
    this._onPointerUp = this._handlePointerUp.bind(this);

    document.addEventListener("pointermove", this._onPointerMove);
    document.addEventListener("pointerup", this._onPointerUp);
  },

  _handlePointerMove(e) {
    if (!this._dragging) return;

    const dx = e.clientX - this._startX;
    const dy = e.clientY - this._startY;
    const lockAspect = e.shiftKey;
    let newW = this._startW;
    let newH = this._startH;
    const pos = this._activeHandle;

    if (pos.includes("e")) newW = this._startW + dx;
    if (pos.includes("w")) newW = this._startW - dx;
    if (pos.includes("s")) newH = this._startH + dy;
    if (pos.includes("n")) newH = this._startH - dy;

    if (lockAspect || ["nw", "ne", "sw", "se"].includes(pos)) {
      newH = newW / this._aspectRatio;
    }

    newW = Math.max(this._minW, Math.min(this._maxW, newW));
    newH = newW / this._aspectRatio;

    this._img.style.width = `${Math.round(newW)}px`;
    this._img.style.height = `${Math.round(newH)}px`;
  },

  _handlePointerUp() {
    this._dragging = false;
    document.removeEventListener("pointermove", this._onPointerMove);
    document.removeEventListener("pointerup", this._onPointerUp);

    const newWidth = this._img.offsetWidth;
    const newHeight = this._img.offsetHeight;

    this.pushEvent("editor:image-resize", {
      id: this.el.id,
      width: newWidth,
      height: newHeight
    });

    if (!this.el.matches(":hover")) {
      this._hideHandles();
    }
  },

  _resetSize() {
    if (this._originalWidth) {
      this._img.style.width = "";
      this._img.style.height = "";
      this.pushEvent("editor:image-resize", {
        id: this.el.id,
        width: null,
        height: null,
        reset: true
      });
    }
  }
};

export default PhiaImageResize;
