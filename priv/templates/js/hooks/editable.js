/**
 * PhiaEditable — vanilla JS hook for inline-editable fields.
 *
 * Toggles between preview (read) mode and edit mode.
 *
 * Preview mode:
 *   - Shows `[data-editable-preview]`
 *   - Hides  `[data-editable-input]`
 *   - Click or Enter/Space on preview → startEdit()
 *
 * Edit mode:
 *   - Hides  `[data-editable-preview]`
 *   - Shows  `[data-editable-input]`
 *   - Enter (without Shift) on input → submit(value)
 *   - Escape on input → cancelEdit()
 *   - Click outside element → cancelEdit()
 *
 * LiveView event:
 *   Pushes `data-on-submit` event with `{ value: <string> }` payload.
 *   If `data-on-submit` is empty or absent, no event is pushed.
 *
 * Registration:
 *
 *   import PhiaEditable from "../../../deps/phia_ui/priv/templates/js/hooks/editable"
 *
 *   let liveSocket = new LiveSocket("/live", Socket, {
 *     hooks: { PhiaEditable }
 *   })
 */
const PhiaEditable = {
  mounted() {
    this.preview = this.el.querySelector("[data-editable-preview]");
    this.inputWrapper = this.el.querySelector("[data-editable-input]");
    this.onSubmit = this.el.dataset.onSubmit || null;

    // Bind class methods for stable references used in removeEventListener
    this._onPreviewClick = () => this.startEdit();
    this._onPreviewKeydown = (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        this.startEdit();
      }
    };
    this._outsideClick = (e) => {
      if (!this.el.contains(e.target)) {
        this.cancelEdit();
      }
    };

    // Preview interactions
    this.preview.addEventListener("click", this._onPreviewClick);
    this.preview.addEventListener("keydown", this._onPreviewKeydown);

    // Input interactions (bound once at mount; input element must be present in DOM)
    const input = this.inputWrapper.querySelector("input, textarea");
    if (input) {
      this._onInputKeydown = (e) => {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          this.submit(input.value);
        } else if (e.key === "Escape") {
          e.preventDefault();
          this.cancelEdit();
        }
      };
      input.addEventListener("keydown", this._onInputKeydown);
    }

    // Click-outside to cancel
    document.addEventListener("click", this._outsideClick);
  },

  /**
   * Switch to edit mode.
   * Hides the preview, reveals the input wrapper, and focuses the input.
   */
  startEdit() {
    this.preview.classList.add("hidden");
    this.inputWrapper.classList.remove("hidden");

    const input = this.inputWrapper.querySelector("input, textarea");
    if (input) {
      input.focus();
      // select() is only meaningful for text inputs
      if (typeof input.select === "function") {
        input.select();
      }
    }
  },

  /**
   * Return to preview mode without saving.
   */
  cancelEdit() {
    this.inputWrapper.classList.add("hidden");
    this.preview.classList.remove("hidden");
  },

  /**
   * Push the LiveView event and return to preview mode.
   * @param {string} value — the current input value
   */
  submit(value) {
    if (this.onSubmit) {
      this.pushEvent(this.onSubmit, { value });
    }
    this.cancelEdit();
  },

  destroyed() {
    this.preview.removeEventListener("click", this._onPreviewClick);
    this.preview.removeEventListener("keydown", this._onPreviewKeydown);
    document.removeEventListener("click", this._outsideClick);
  },
};

export default PhiaEditable;
