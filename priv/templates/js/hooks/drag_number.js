// PhiaDragNumber — Figma-style numeric scrubber.
// Drag horizontally to increment/decrement a value.

const PhiaDragNumber = {
  mounted() {
    this._value = parseFloat(this.el.dataset.value || "0") || 0;
    this._dragging = false;
    this._startX = 0;
    this._startValue = 0;

    // Respect prefers-reduced-motion by disabling drag
    this._reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    this._onMouseDown = (e) => this._startDrag(e.clientX);
    this._onMouseMove = (e) => this._onDrag(e.clientX);
    this._onMouseUp = () => this._endDrag();
    this._onTouchStart = (e) => this._startDrag(e.touches[0].clientX);
    this._onTouchMove = (e) => this._onDrag(e.touches[0].clientX);
    this._onTouchEnd = () => this._endDrag();

    if (!this._reducedMotion) {
      this.el.addEventListener("mousedown", this._onMouseDown);
      this.el.addEventListener("touchstart", this._onTouchStart, { passive: true });
      document.addEventListener("mousemove", this._onMouseMove);
      document.addEventListener("mouseup", this._onMouseUp);
      document.addEventListener("touchmove", this._onTouchMove, { passive: true });
      document.addEventListener("touchend", this._onTouchEnd);
    }

    // Keyboard support
    this._onKeydown = (e) => {
      if (e.key === "ArrowLeft" || e.key === "ArrowDown") {
        e.preventDefault();
        this._updateValue(this._value - this._step());
      } else if (e.key === "ArrowRight" || e.key === "ArrowUp") {
        e.preventDefault();
        this._updateValue(this._value + this._step());
      }
    };
    this.el.addEventListener("keydown", this._onKeydown);
  },

  destroyed() {
    document.removeEventListener("mousemove", this._onMouseMove);
    document.removeEventListener("mouseup", this._onMouseUp);
    document.removeEventListener("touchmove", this._onTouchMove);
    document.removeEventListener("touchend", this._onTouchEnd);
  },

  _startDrag(x) {
    this._dragging = true;
    this._startX = x;
    this._startValue = this._value;
    this.el.style.cursor = "ew-resize";
  },

  _onDrag(x) {
    if (!this._dragging) return;
    const delta = x - this._startX;
    const step = this._step();
    const sensitivity = parseFloat(this.el.dataset.sensitivity || "1");
    const newVal = this._startValue + Math.round(delta / sensitivity) * step;
    this._updateValue(newVal);
  },

  _endDrag() {
    if (!this._dragging) return;
    this._dragging = false;
    this.el.style.cursor = "";
  },

  _step() {
    return parseFloat(this.el.dataset.step || "1") || 1;
  },

  _clamp(val) {
    const min = this.el.dataset.min !== undefined && this.el.dataset.min !== ""
      ? parseFloat(this.el.dataset.min) : -Infinity;
    const max = this.el.dataset.max !== undefined && this.el.dataset.max !== ""
      ? parseFloat(this.el.dataset.max) : Infinity;
    return Math.min(max, Math.max(min, val));
  },

  _updateValue(val) {
    this._value = this._clamp(val);
    // Update display
    const display = this.el.querySelector("[data-drag-display]");
    if (display) {
      const unit = this.el.dataset.unit || "";
      display.textContent = this._value + unit;
    }
    // Update hidden input
    const input = this.el.querySelector("[data-drag-input]");
    if (input) input.value = this._value;
    // Update aria
    this.el.setAttribute("aria-valuenow", this._value);
    // Fire event
    const eventName = this.el.dataset.onchange;
    if (eventName) {
      this.pushEvent(eventName, { value: this._value });
    }
  },
};

export default PhiaDragNumber;
