/**
 * PhiaEditorColorPicker — Toolbar color palette dropdown.
 *
 * Dispatches execCommand("foreColor"|"hiliteColor", false, hex) on swatch click.
 * Tracks the current color from queryCommandValue on selectionchange and updates
 * the color indicator bar.
 *
 * Firefox uses "backColor" instead of "hiliteColor" for background colors.
 *
 * HTML anatomy (rendered by editor_color_picker/1):
 *   <div phx-hook="PhiaEditorColorPicker" data-action="foreColor">
 *     <button data-color-trigger>
 *       <span data-color-indicator style="background-color: currentColor"/>
 *     </button>
 *     <div data-color-panel class="hidden">
 *       <button data-color-swatch="#FF0000" style="background-color: #FF0000"/>
 *       ...
 *     </div>
 *   </div>
 *
 * Registration:
 *   import PhiaEditorColorPicker from "./hooks/editor_color_picker"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaEditorColorPicker } })
 */
const PhiaEditorColorPicker = {
  mounted() {
    this._action = this.el.dataset.action || "foreColor";
    this._trigger = this.el.querySelector("[data-color-trigger]");
    this._panel = this.el.querySelector("[data-color-panel]");
    this._indicator = this.el.querySelector("[data-color-indicator]");

    this._onTriggerClick = (e) => {
      e.stopPropagation();
      this._togglePanel();
    };

    this._onSwatchClick = (e) => {
      const swatch = e.target.closest("[data-color-swatch]");
      if (!swatch) return;
      const color = swatch.dataset.colorSwatch;
      this._applyColor(color);
      this._updateIndicator(color);
      this._closePanel();
    };

    this._onSelectionChange = () => this._syncCurrentColor();

    this._onOutsideClick = (e) => {
      if (!this.el.contains(e.target)) this._closePanel();
    };

    this._onKeydown = (e) => {
      if (e.key === "Escape") this._closePanel();
    };

    this._trigger?.addEventListener("click", this._onTriggerClick);
    this._panel?.addEventListener("click", this._onSwatchClick);
    document.addEventListener("selectionchange", this._onSelectionChange);
    document.addEventListener("click", this._onOutsideClick);
    document.addEventListener("keydown", this._onKeydown);
  },

  destroyed() {
    this._trigger?.removeEventListener("click", this._onTriggerClick);
    document.removeEventListener("selectionchange", this._onSelectionChange);
    document.removeEventListener("click", this._onOutsideClick);
    document.removeEventListener("keydown", this._onKeydown);
  },

  _togglePanel() {
    if (this._panel?.classList.contains("hidden")) {
      this._openPanel();
    } else {
      this._closePanel();
    }
  },

  _openPanel() {
    this._panel?.classList.remove("hidden");
  },

  _closePanel() {
    this._panel?.classList.add("hidden");
  },

  _applyColor(hex) {
    const action = this._action === "hiliteColor"
      ? (this._isFirefox() ? "backColor" : "hiliteColor")
      : "foreColor";
    document.execCommand(action, false, hex);
  },

  _syncCurrentColor() {
    try {
      const color = document.queryCommandValue(this._action);
      if (color && color !== "false" && this._indicator) {
        // Convert rgb() to hex if needed
        const hex = this._toHex(color);
        if (hex) this._updateIndicator(hex);
      }
    } catch {
      // execCommand/queryCommandValue not supported — silently ignore
    }
  },

  _updateIndicator(color) {
    if (this._indicator) {
      this._indicator.style.backgroundColor = color;
    }
  },

  // Convert rgb(r, g, b) strings from queryCommandValue to hex
  _toHex(color) {
    if (color.startsWith("#")) return color;
    const match = color.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
    if (!match) return null;
    const toH = (n) => parseInt(n).toString(16).padStart(2, "0");
    return "#" + toH(match[1]) + toH(match[2]) + toH(match[3]);
  },

  _isFirefox() {
    return navigator.userAgent.toLowerCase().includes("firefox");
  },
};

export default PhiaEditorColorPicker;
