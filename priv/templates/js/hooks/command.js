/**
 * PhiaCommand — vanilla JS hook for global command palette (Ctrl+K / Cmd+K).
 *
 * Behaviour:
 *  - Global Ctrl+K / Cmd+K → open command modal
 *  - Escape → close and restore focus
 *  - Arrow Down / Up → navigate command items
 *  - Enter → trigger phx-click on focused item
 *  - Updates aria-expanded, aria-activedescendant on input
 *
 * Markup contract:
 *   - Hook root: `phx-hook="PhiaCommand"`, `role="dialog"`
 *   - Input: `[data-command-input]`, `role="combobox"`
 *   - List: `[data-command-list]`
 *   - Items: `[data-command-item]`
 *   - Backdrop: `[data-command-backdrop]`
 */
const PhiaCommand = {
  mounted() {
    this.input = this.el.querySelector("[data-command-input]");
    this.list = this.el.querySelector("[data-command-list]");
    this.backdrop = this.el.querySelector("[data-command-backdrop]");
    this.open = false;
    this._focusedIndex = -1;
    this._previousFocus = null;

    this._onGlobalKeydown = this._onGlobalKeydown.bind(this);
    this._onInternalKeydown = this._onInternalKeydown.bind(this);
    this._onBackdropClick = this._onBackdropClick.bind(this);

    document.addEventListener("keydown", this._onGlobalKeydown);
    this.el.addEventListener("keydown", this._onInternalKeydown);
    if (this.backdrop) {
      this.backdrop.addEventListener("mousedown", this._onBackdropClick);
    }
  },

  destroyed() {
    document.removeEventListener("keydown", this._onGlobalKeydown);
    if (this.backdrop) {
      this.backdrop.removeEventListener("mousedown", this._onBackdropClick);
    }
  },

  updated() {
    // Re-query items after LiveView patch (search results update)
    this._focusedIndex = -1;
    this._updateFocus();
  },

  _onGlobalKeydown(e) {
    const isK = e.key === "k" || e.key === "K";
    if (isK && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.open ? this._close() : this._openModal();
    }
  },

  _onInternalKeydown(e) {
    if (!this.open) return;
    switch (e.key) {
      case "Escape":
        e.preventDefault();
        this._close();
        break;
      case "ArrowDown":
        e.preventDefault();
        this._moveFocus(1);
        break;
      case "ArrowUp":
        e.preventDefault();
        this._moveFocus(-1);
        break;
      case "Enter":
        e.preventDefault();
        this._selectFocused();
        break;
    }
  },

  _onBackdropClick() {
    this._close();
  },

  _openModal() {
    this.open = true;
    this._previousFocus = document.activeElement;
    this.el.classList.remove("hidden");
    if (this.input) {
      this.input.setAttribute("aria-expanded", "true");
      this.input.value = "";
      requestAnimationFrame(() => this.input.focus());
    }
  },

  _close() {
    this.open = false;
    this.el.classList.add("hidden");
    this._focusedIndex = -1;
    this._updateFocus();
    if (this.input) {
      this.input.setAttribute("aria-expanded", "false");
      this.input.removeAttribute("aria-activedescendant");
    }
    if (this._previousFocus) {
      this._previousFocus.focus();
      this._previousFocus = null;
    }
  },

  _items() {
    return Array.from(this.el.querySelectorAll("[data-command-item]"));
  },

  _moveFocus(delta) {
    const items = this._items();
    if (items.length === 0) return;
    this._focusedIndex = Math.max(
      0,
      Math.min(items.length - 1, this._focusedIndex + delta)
    );
    this._updateFocus();
  },

  _updateFocus() {
    const items = this._items();
    items.forEach((item, i) => {
      const active = i === this._focusedIndex;
      item.setAttribute("aria-selected", active ? "true" : "false");
      item.dataset.selected = active ? "" : undefined;
      if (!active) delete item.dataset.selected;
    });
    if (this.input && this._focusedIndex >= 0 && items[this._focusedIndex]) {
      this.input.setAttribute(
        "aria-activedescendant",
        items[this._focusedIndex].id || ""
      );
    }
  },

  _selectFocused() {
    const items = this._items();
    const item = items[this._focusedIndex];
    if (item) item.click();
  },
};

export default PhiaCommand;
