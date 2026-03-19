/**
 * PhiaDrawingCanvas — freehand drawing on HTML canvas.
 *
 * Tools: pen, eraser, line, rect, circle. Supports color/width config,
 * undo stack, touch+pressure, export to data URL.
 *
 * Markup contract:
 *   <canvas phx-hook="PhiaDrawingCanvas" id="..." />
 */
const PhiaDrawingCanvas = {
  mounted() {
    this._canvas = this.el;
    this._ctx = this._canvas.getContext("2d");
    this._drawing = false;
    this._tool = "pen"; // pen | eraser | line | rect | circle
    this._color = "#000000";
    this._lineWidth = 2;
    this._strokes = []; // undo stack: array of ImageData snapshots
    this._maxUndo = 50;
    this._currentPath = [];
    this._shapeStart = null;
    this._snapshotBeforeShape = null;
    this._reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    this._resizeCanvas();
    this._fillBackground();
    this._bindEvents();

    // Listen for server-driven commands
    this.handleEvent(`drawing:tool:${this.el.id}`, ({ tool }) => {
      this._tool = tool;
    });
    this.handleEvent(`drawing:color:${this.el.id}`, ({ color }) => {
      this._color = color;
    });
    this.handleEvent(`drawing:width:${this.el.id}`, ({ width }) => {
      this._lineWidth = width;
    });
    this.handleEvent(`drawing:clear:${this.el.id}`, () => {
      this._clear();
    });
    this.handleEvent(`drawing:undo:${this.el.id}`, () => {
      this._undo();
    });
    this.handleEvent(`drawing:export:${this.el.id}`, () => {
      this._export();
    });

    this._resizeObserver = new ResizeObserver(() => this._resizeCanvas());
    this._resizeObserver.observe(this._canvas.parentElement);
  },

  destroyed() {
    if (this._resizeObserver) this._resizeObserver.disconnect();
  },

  _resizeCanvas() {
    const parent = this._canvas.parentElement;
    if (!parent) return;
    const rect = parent.getBoundingClientRect();
    const dpr = window.devicePixelRatio || 1;

    // Save current content
    let imageData = null;
    if (this._canvas.width > 0 && this._canvas.height > 0) {
      imageData = this._ctx.getImageData(0, 0, this._canvas.width, this._canvas.height);
    }

    this._canvas.width = rect.width * dpr;
    this._canvas.height = (parseInt(this._canvas.style.height, 10) || 300) * dpr;
    this._ctx.scale(dpr, dpr);

    this._fillBackground();
    if (imageData) {
      this._ctx.putImageData(imageData, 0, 0);
    }
  },

  _fillBackground() {
    const isDark = document.documentElement.classList.contains("dark");
    this._ctx.fillStyle = isDark ? "#18181b" : "#ffffff";
    this._ctx.fillRect(0, 0, this._canvas.width, this._canvas.height);
  },

  _bindEvents() {
    this._canvas.addEventListener("pointerdown", (e) => this._onPointerDown(e));
    this._canvas.addEventListener("pointermove", (e) => this._onPointerMove(e));
    this._canvas.addEventListener("pointerup", (e) => this._onPointerUp(e));
    this._canvas.addEventListener("pointerleave", (e) => this._onPointerUp(e));

    // Prevent scrolling on touch
    this._canvas.addEventListener("touchstart", (e) => e.preventDefault(), { passive: false });
  },

  _getPos(e) {
    const rect = this._canvas.getBoundingClientRect();
    return {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top,
      pressure: e.pressure || 0.5
    };
  },

  _onPointerDown(e) {
    e.preventDefault();
    this._drawing = true;
    this._canvas.setPointerCapture(e.pointerId);
    const pos = this._getPos(e);

    // Save snapshot for undo
    this._pushUndo();

    if (this._tool === "pen" || this._tool === "eraser") {
      this._currentPath = [pos];
      this._ctx.beginPath();
      this._ctx.moveTo(pos.x, pos.y);
      this._ctx.strokeStyle = this._tool === "eraser" ? this._getBgColor() : this._color;
      this._ctx.lineWidth = this._tool === "eraser" ? this._lineWidth * 5 : this._lineWidth * (0.5 + pos.pressure);
      this._ctx.lineCap = "round";
      this._ctx.lineJoin = "round";
    } else {
      this._shapeStart = pos;
      this._snapshotBeforeShape = this._ctx.getImageData(0, 0, this._canvas.width, this._canvas.height);
    }
  },

  _onPointerMove(e) {
    if (!this._drawing) return;
    const pos = this._getPos(e);

    if (this._tool === "pen" || this._tool === "eraser") {
      this._ctx.strokeStyle = this._tool === "eraser" ? this._getBgColor() : this._color;
      this._ctx.lineWidth = this._tool === "eraser" ? this._lineWidth * 5 : this._lineWidth * (0.5 + pos.pressure);
      this._ctx.lineTo(pos.x, pos.y);
      this._ctx.stroke();
      this._ctx.beginPath();
      this._ctx.moveTo(pos.x, pos.y);
      this._currentPath.push(pos);
    } else if (this._shapeStart && this._snapshotBeforeShape) {
      // Redraw snapshot then draw shape preview
      this._ctx.putImageData(this._snapshotBeforeShape, 0, 0);
      this._drawShape(this._shapeStart, pos, false);
    }
  },

  _onPointerUp(e) {
    if (!this._drawing) return;
    this._drawing = false;

    if (this._tool === "pen" || this._tool === "eraser") {
      this._ctx.beginPath(); // reset path
    } else if (this._shapeStart) {
      const pos = this._getPos(e);
      if (this._snapshotBeforeShape) {
        this._ctx.putImageData(this._snapshotBeforeShape, 0, 0);
      }
      this._drawShape(this._shapeStart, pos, true);
      this._shapeStart = null;
      this._snapshotBeforeShape = null;
    }
  },

  _drawShape(start, end, fill) {
    this._ctx.strokeStyle = this._color;
    this._ctx.lineWidth = this._lineWidth;
    this._ctx.lineCap = "round";
    this._ctx.lineJoin = "round";

    if (this._tool === "line") {
      this._ctx.beginPath();
      this._ctx.moveTo(start.x, start.y);
      this._ctx.lineTo(end.x, end.y);
      this._ctx.stroke();
    } else if (this._tool === "rect") {
      const x = Math.min(start.x, end.x);
      const y = Math.min(start.y, end.y);
      const w = Math.abs(end.x - start.x);
      const h = Math.abs(end.y - start.y);
      this._ctx.strokeRect(x, y, w, h);
    } else if (this._tool === "circle") {
      const cx = (start.x + end.x) / 2;
      const cy = (start.y + end.y) / 2;
      const rx = Math.abs(end.x - start.x) / 2;
      const ry = Math.abs(end.y - start.y) / 2;
      this._ctx.beginPath();
      this._ctx.ellipse(cx, cy, rx, ry, 0, 0, Math.PI * 2);
      this._ctx.stroke();
    }
  },

  _getBgColor() {
    return document.documentElement.classList.contains("dark") ? "#18181b" : "#ffffff";
  },

  _pushUndo() {
    const data = this._ctx.getImageData(0, 0, this._canvas.width, this._canvas.height);
    this._strokes.push(data);
    if (this._strokes.length > this._maxUndo) {
      this._strokes.shift();
    }
  },

  _undo() {
    if (this._strokes.length === 0) return;
    const data = this._strokes.pop();
    this._ctx.putImageData(data, 0, 0);
  },

  _clear() {
    this._pushUndo();
    this._fillBackground();
  },

  _export() {
    const dataUrl = this._canvas.toDataURL("image/png");
    this.pushEvent("drawing:exported", { id: this.el.id, data_url: dataUrl });
  }
};

export default PhiaDrawingCanvas;
