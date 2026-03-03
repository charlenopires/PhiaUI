// PhiaUI DropdownMenu Hook — PhiaDropdownMenu
// Implements WAI-ARIA Menu Button pattern:
// - Smart positioning via getBoundingClientRect() + auto-flip
// - Click-outside detection with cleanup
// - Full keyboard navigation: Escape, Arrow keys, Enter, Space
//
// Registration in app.js:
//   import PhiaDropdownMenu from "./phia_hooks/dropdown_menu.js"
//   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaDropdownMenu } })

const PhiaDropdownMenu = {
  mounted() {
    // Find trigger and content elements scoped to this.el (never document.querySelector).
    this._trigger = this.el.querySelector("[data-dropdown-trigger]");
    this._content = this.el.querySelector("[data-dropdown-content]");

    if (!this._trigger || !this._content) return;

    // Bound handlers stored on `this` so destroyed() can removeEventListener
    // without memory leaks (AC: cleanup em destroyed()).
    this._handleTriggerClick = () => this._toggle();
    this._handleClickOutside = (e) => this._onClickOutside(e);
    this._handleKeydown = (e) => this._onKeydown(e);

    this._trigger.addEventListener("click", this._handleTriggerClick);
    document.addEventListener("click", this._handleClickOutside);
    document.addEventListener("keydown", this._handleKeydown);
  },

  destroyed() {
    // Remove all document-level listeners to prevent memory leaks
    // (AC: cleanup em destroyed()).
    if (this._trigger) {
      this._trigger.removeEventListener("click", this._handleTriggerClick);
    }
    document.removeEventListener("click", this._handleClickOutside);
    document.removeEventListener("keydown", this._handleKeydown);
  },

  // ---------------------------------------------------------------------------
  // Open / close
  // ---------------------------------------------------------------------------

  _isOpen() {
    return !this._content.classList.contains("hidden");
  },

  _open() {
    this._content.classList.remove("hidden");
    this._trigger.setAttribute("aria-expanded", "true");
    this._position();
    // Focus first non-disabled item for keyboard nav (AC: Arrow keys navegam).
    const items = this._getItems();
    if (items.length > 0) items[0].focus();
  },

  _close() {
    this._content.classList.add("hidden");
    this._trigger.setAttribute("aria-expanded", "false");
    // Return focus to trigger (AC: Escape retorna foco ao trigger).
    this._trigger.focus();
  },

  _toggle() {
    this._isOpen() ? this._close() : this._open();
  },

  // ---------------------------------------------------------------------------
  // Positioning — getBoundingClientRect() + auto-flip
  // (AC: posicionamento via getBoundingClientRect, inline styles top/left)
  // ---------------------------------------------------------------------------

  _position() {
    const rect = this._trigger.getBoundingClientRect();

    // Default: position below the trigger, aligned to its left edge.
    // (AC: posicionamento padrão abaixo do trigger, alinhado à esquerda)
    let top = rect.bottom + window.scrollY;
    const left = rect.left + window.scrollX;

    // Apply initial position so we can measure the content height.
    this._content.style.top = `${top}px`;
    this._content.style.left = `${left}px`;

    // Auto-flip: if the bottom of the dropdown overflows the viewport,
    // reposition above the trigger instead.
    // (AC: auto-flip se bottom > window.innerHeight - 20)
    const contentRect = this._content.getBoundingClientRect();
    if (contentRect.bottom > window.innerHeight - 20) {
      top = rect.top + window.scrollY - this._content.offsetHeight;
      this._content.style.top = `${top}px`;
    }
  },

  // ---------------------------------------------------------------------------
  // Click outside — close if click is outside this.el
  // (AC: click outside fecha o menu, document event listener)
  // ---------------------------------------------------------------------------

  _onClickOutside(e) {
    if (!this._isOpen()) return;
    if (!this.el.contains(e.target)) {
      this._close();
    }
  },

  // ---------------------------------------------------------------------------
  // Keyboard navigation
  // ---------------------------------------------------------------------------

  _onKeydown(e) {
    if (!this._isOpen()) return;

    switch (e.key) {
      case "Escape":
        // Close and return focus to trigger (AC: Escape fecha e retorna foco).
        e.preventDefault();
        this._close();
        break;

      case "ArrowDown":
        // Move focus to next item, wrapping around (AC: Arrow keys navegam).
        e.preventDefault();
        this._focusNext(1);
        break;

      case "ArrowUp":
        // Move focus to previous item, wrapping around (AC: Arrow keys navegam).
        e.preventDefault();
        this._focusNext(-1);
        break;

      case "Enter":
      case " ":
        // Activate the focused item (AC: Enter/Space selecionam item focado).
        e.preventDefault();
        const active = document.activeElement;
        if (active && active.getAttribute("aria-disabled") !== "true" && this._content.contains(active)) {
          active.click();
          this._close();
        }
        break;
    }
  },

  // Returns all focusable, non-disabled menu items.
  _getItems() {
    return Array.from(
      this._content.querySelectorAll('[data-dropdown-item]:not([aria-disabled="true"])')
    );
  },

  // Moves focus to the next/previous item with wrap-around.
  // direction: +1 (down) or -1 (up).
  _focusNext(direction) {
    const items = this._getItems();
    if (items.length === 0) return;

    const current = document.activeElement;
    const currentIndex = items.indexOf(current);

    let nextIndex;
    if (currentIndex === -1) {
      // No item focused yet — go to first (down) or last (up).
      nextIndex = direction === 1 ? 0 : items.length - 1;
    } else {
      nextIndex = (currentIndex + direction + items.length) % items.length;
    }

    items[nextIndex].focus();
  },
};

export default PhiaDropdownMenu;
