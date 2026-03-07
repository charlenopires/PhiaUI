/**
 * PhiaSignaturePad — canvas-based freehand signature hook.
 *
 * Attaches pointer events to the `<canvas>` inside the hook root element.
 * On every stroke completion (pointerup), serializes to PNG data URL and:
 *   1. Updates `[data-signature-value]` hidden input (for native form submit)
 *   2. Sends `signature-change` LiveView event: `%{data: "data:image/png;base64,..."}` or `%{data: nil}` on clear
 *
 * Reads `data-stroke-color` from the root element (default `#000000`).
 * Respects `prefers-reduced-motion` (smooth drawing still works, no animations added).
 *
 * The `[data-clear]` button triggers `clearCanvas()`.
 */
export const PhiaSignaturePad = {
  mounted() {
    this.canvas = this.el.querySelector("canvas");
    if (!this.canvas) return;

    this.ctx = this.canvas.getContext("2d");
    this.drawing = false;
    this.strokeColor = this.el.dataset.strokeColor || "#000000";
    this.hiddenInput = this.el.querySelector("[data-signature-value]");
    this.clearBtn = this.el.querySelector("[data-clear]");

    // Set up canvas context defaults
    this.ctx.strokeStyle = this.strokeColor;
    this.ctx.lineWidth = 2;
    this.ctx.lineCap = "round";
    this.ctx.lineJoin = "round";

    // Pointer events (handles mouse + stylus + touch)
    this._onPointerDown = (e) => this._start(e);
    this._onPointerMove = (e) => this._draw(e);
    this._onPointerUp = () => this._stop();

    this.canvas.addEventListener("pointerdown", this._onPointerDown);
    this.canvas.addEventListener("pointermove", this._onPointerMove);
    this.canvas.addEventListener("pointerup", this._onPointerUp);
    this.canvas.addEventListener("pointerleave", this._onPointerUp);

    // Clear button
    if (this.clearBtn) {
      this._onClear = () => this._clear();
      this.clearBtn.addEventListener("click", this._onClear);
    }

    // Handle canvas resize if window resizes (preserve content)
    this._onResize = () => this._handleResize();
    window.addEventListener("resize", this._onResize);
  },

  destroyed() {
    if (this.canvas) {
      this.canvas.removeEventListener("pointerdown", this._onPointerDown);
      this.canvas.removeEventListener("pointermove", this._onPointerMove);
      this.canvas.removeEventListener("pointerup", this._onPointerUp);
      this.canvas.removeEventListener("pointerleave", this._onPointerUp);
    }
    if (this.clearBtn && this._onClear) {
      this.clearBtn.removeEventListener("click", this._onClear);
    }
    window.removeEventListener("resize", this._onResize);
  },

  _getPos(e) {
    const rect = this.canvas.getBoundingClientRect();
    // Scale for high-DPI displays
    const scaleX = this.canvas.width / rect.width;
    const scaleY = this.canvas.height / rect.height;
    return {
      x: (e.clientX - rect.left) * scaleX,
      y: (e.clientY - rect.top) * scaleY,
    };
  },

  _start(e) {
    this.drawing = true;
    this.canvas.setPointerCapture(e.pointerId);
    const pos = this._getPos(e);
    this.ctx.beginPath();
    this.ctx.moveTo(pos.x, pos.y);
  },

  _draw(e) {
    if (!this.drawing) return;
    e.preventDefault();
    const pos = this._getPos(e);
    this.ctx.lineTo(pos.x, pos.y);
    this.ctx.stroke();
  },

  _stop() {
    if (!this.drawing) return;
    this.drawing = false;
    this.ctx.closePath();
    this._serialize();
  },

  _clear() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    if (this.hiddenInput) this.hiddenInput.value = "";
    this.pushEvent("signature-change", { data: null });
  },

  _serialize() {
    const dataUrl = this.canvas.toDataURL("image/png");
    if (this.hiddenInput) this.hiddenInput.value = dataUrl;
    this.pushEvent("signature-change", { data: dataUrl });
  },

  _handleResize() {
    // Preserve content on resize by saving and restoring
    const dataUrl = this.canvas.toDataURL();
    const img = new Image();
    img.onload = () => {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      this.ctx.drawImage(img, 0, 0);
    };
    img.src = dataUrl;
  },
};
