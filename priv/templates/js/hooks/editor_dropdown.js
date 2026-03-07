/**
 * PhiaEditorDropdown — Generic toolbar dropdown (heading level, font size, etc.).
 *
 * Toggles a listbox panel on trigger click. Selecting an item dispatches
 * execCommand to the linked editor via data-action, then closes the panel.
 * Updates the trigger label with the selected item's label.
 *
 * HTML anatomy (rendered by editor_toolbar_dropdown/1):
 *   <div phx-hook="PhiaEditorDropdown" id="heading-dd">
 *     <button data-dropdown-trigger aria-expanded="false" aria-haspopup="listbox">
 *       <span data-dropdown-label>Paragraph</span>
 *       <svg .../>
 *     </button>
 *     <div data-dropdown-panel role="listbox" class="hidden">
 *       <div role="option" data-value="paragraph" data-action="paragraph">Paragraph</div>
 *       <div role="option" data-value="h1" data-action="h1">Heading 1</div>
 *     </div>
 *   </div>
 *
 * Registration:
 *   import PhiaEditorDropdown from "./hooks/editor_dropdown"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaEditorDropdown } })
 */
const PhiaEditorDropdown = {
  mounted() {
    this._trigger = this.el.querySelector("[data-dropdown-trigger]");
    this._panel = this.el.querySelector("[data-dropdown-panel]");
    this._label = this.el.querySelector("[data-dropdown-label]");

    this._onTriggerClick = (e) => {
      e.stopPropagation();
      this._isOpen() ? this._close() : this._open();
    };

    this._onOptionClick = (e) => {
      const option = e.target.closest("[data-action]");
      if (!option) return;
      const action = option.dataset.action;
      const label = option.textContent.trim();
      this._executeAction(action);
      this._updateLabel(label);
      this._close();
    };

    this._onOutsideClick = (e) => {
      if (!this.el.contains(e.target)) this._close();
    };

    this._onKeydown = (e) => {
      if (!this._isOpen()) return;
      if (e.key === "Escape") {
        e.preventDefault();
        this._close();
      } else if (e.key === "ArrowDown" || e.key === "ArrowUp") {
        e.preventDefault();
        this._navigateOptions(e.key === "ArrowDown" ? 1 : -1);
      } else if (e.key === "Enter" || e.key === " ") {
        const focused = this._panel?.querySelector(":focus");
        if (focused) {
          e.preventDefault();
          focused.click();
        }
      }
    };

    this._trigger?.addEventListener("click", this._onTriggerClick);
    this._panel?.addEventListener("click", this._onOptionClick);
    document.addEventListener("click", this._onOutsideClick);
    document.addEventListener("keydown", this._onKeydown);
  },

  destroyed() {
    this._trigger?.removeEventListener("click", this._onTriggerClick);
    document.removeEventListener("click", this._onOutsideClick);
    document.removeEventListener("keydown", this._onKeydown);
  },

  _open() {
    this._panel?.classList.remove("hidden");
    this._trigger?.setAttribute("aria-expanded", "true");
  },

  _close() {
    this._panel?.classList.add("hidden");
    this._trigger?.setAttribute("aria-expanded", "false");
  },

  _isOpen() {
    return !this._panel?.classList.contains("hidden");
  },

  _updateLabel(text) {
    if (this._label) this._label.textContent = text;
  },

  _executeAction(action) {
    const actionMap = {
      h1: () => document.execCommand("formatBlock", false, "<h1>"),
      h2: () => document.execCommand("formatBlock", false, "<h2>"),
      h3: () => document.execCommand("formatBlock", false, "<h3>"),
      h4: () => document.execCommand("formatBlock", false, "<h4>"),
      paragraph: () => document.execCommand("formatBlock", false, "<p>"),
      blockquote: () => document.execCommand("formatBlock", false, "<blockquote>"),
      codeBlock: () => document.execCommand("formatBlock", false, "<pre>"),
    };
    if (actionMap[action]) {
      actionMap[action]();
    }
  },

  _navigateOptions(delta) {
    const options = Array.from(this._panel?.querySelectorAll("[role='option']") || []);
    if (options.length === 0) return;
    const current = options.indexOf(document.activeElement);
    const next = (current + delta + options.length) % options.length;
    options[next]?.focus();
  },
};

export default PhiaEditorDropdown;
