/**
 * PhiaFullscreenDrop — full-viewport drag-and-drop overlay hook.
 *
 * Listens to document-level drag events and shows/hides the overlay element
 * via a `data-active` attribute toggled by JS. The overlay contains a
 * `phx-drop-target` wired to the LiveView upload system, so when files are
 * released the upload is handled server-side by Phoenix.
 *
 * Registration:
 *   import { PhiaFullscreenDrop } from "./hooks/fullscreen_drop"
 *   let liveSocket = new LiveSocket("/live", Socket, {
 *     hooks: { PhiaFullscreenDrop }
 *   })
 */
const PhiaFullscreenDrop = {
  mounted() {
    this.overlay = this.el;
    this._depth = 0; // track nested dragenter/dragleave

    this._onDragEnter = (e) => {
      if (!e.dataTransfer || !e.dataTransfer.types.includes("Files")) return;
      this._depth++;
      this._show();
    };

    this._onDragLeave = () => {
      this._depth--;
      if (this._depth <= 0) {
        this._depth = 0;
        this._hide();
      }
    };

    this._onDragOver = (e) => {
      // Prevent browser default (open file) and allow drop
      if (e.dataTransfer && e.dataTransfer.types.includes("Files")) {
        e.preventDefault();
      }
    };

    this._onDrop = (e) => {
      // The phx-drop-target inside the overlay handles the actual upload.
      // We only need to reset the overlay state here.
      this._depth = 0;
      this._hide();
    };

    document.addEventListener("dragenter", this._onDragEnter);
    document.addEventListener("dragleave", this._onDragLeave);
    document.addEventListener("dragover", this._onDragOver);
    document.addEventListener("drop", this._onDrop);
  },

  destroyed() {
    document.removeEventListener("dragenter", this._onDragEnter);
    document.removeEventListener("dragleave", this._onDragLeave);
    document.removeEventListener("dragover", this._onDragOver);
    document.removeEventListener("drop", this._onDrop);
  },

  _show() {
    this.overlay.setAttribute("data-active", "true");
    this.overlay.style.pointerEvents = "auto";
  },

  _hide() {
    this.overlay.removeAttribute("data-active");
    this.overlay.style.pointerEvents = "none";
  },
};

export { PhiaFullscreenDrop };
export default PhiaFullscreenDrop;
