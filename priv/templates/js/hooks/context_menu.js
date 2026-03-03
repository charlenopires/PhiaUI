// PhiaUI ContextMenu Hook — PhiaContextMenu
//
// Implements a right-click context menu with:
// - contextmenu event listener that prevents the native browser menu
// - Smart viewport-aware positioning (flips if overflows)
// - Click-outside detection to close the panel
// - Full keyboard navigation: Escape, ArrowUp/ArrowDown, Enter
//
// Registration in app.js:
//   import PhiaContextMenu from "./phia_hooks/context_menu.js"
//   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaContextMenu } })

const PhiaContextMenu = {
  mounted() {
    this._contentId = this.el.dataset.contentId;
    this._content = document.getElementById(this._contentId);

    // Bound handlers stored on `this` so destroyed() can removeEventListener
    // without memory leaks.
    this._handleContextMenu = (e) => {
      e.preventDefault();
      this._open(e.clientX, e.clientY);
    };

    this._handleClickOutside = (e) => {
      if (!this._content) return;
      if (
        !this._content.contains(e.target) &&
        !this.el.contains(e.target)
      ) {
        this._close();
      }
    };

    this._handleKeydown = (e) => {
      if (!this._content || this._content.style.display === "none") return;

      switch (e.key) {
        case "Escape":
          // Close on Escape and return focus to the trigger area.
          e.preventDefault();
          this._close();
          this.el.focus();
          break;

        case "ArrowDown":
          // Move focus to next item, wrapping around.
          e.preventDefault();
          this._focusNext(1);
          break;

        case "ArrowUp":
          // Move focus to previous item, wrapping around.
          e.preventDefault();
          this._focusNext(-1);
          break;

        case "Enter":
          // Activate the focused item.
          e.preventDefault();
          const active = document.activeElement;
          if (active && this._content.contains(active)) {
            active.click();
            this._close();
          }
          break;
      }
    };

    this.el.addEventListener("contextmenu", this._handleContextMenu);
    document.addEventListener("click", this._handleClickOutside);
    document.addEventListener("keydown", this._handleKeydown);
  },

  // ---------------------------------------------------------------------------
  // Open — show content at (x, y) with smart viewport flip
  // ---------------------------------------------------------------------------

  _open(x, y) {
    if (!this._content) return;

    this._content.style.display = "block";
    this._content.style.left = x + "px";
    this._content.style.top = y + "px";

    // Smart positioning: after the element is visible, measure its bounds and
    // flip direction if it would overflow the viewport edge.
    requestAnimationFrame(() => {
      if (!this._content) return;
      const rect = this._content.getBoundingClientRect();

      if (rect.right > window.innerWidth) {
        this._content.style.left = x - rect.width + "px";
      }
      if (rect.bottom > window.innerHeight) {
        this._content.style.top = y - rect.height + "px";
      }

      // Focus the first menu item for keyboard navigation.
      const first = this._content.querySelector(
        '[role="menuitem"],[role="menuitemcheckbox"]'
      );
      if (first) first.focus();
    });
  },

  // ---------------------------------------------------------------------------
  // Close — hide content
  // ---------------------------------------------------------------------------

  _close() {
    if (this._content) {
      this._content.style.display = "none";
    }
  },

  // ---------------------------------------------------------------------------
  // Keyboard focus cycling
  // ---------------------------------------------------------------------------

  // Returns all focusable, non-disabled menu items within the content panel.
  _getItems() {
    if (!this._content) return [];
    return Array.from(
      this._content.querySelectorAll(
        '[role="menuitem"],[role="menuitemcheckbox"]'
      )
    );
  },

  // Moves focus to the next (direction=+1) or previous (direction=-1) item
  // with wrap-around behaviour.
  _focusNext(direction) {
    const items = this._getItems();
    if (items.length === 0) return;

    const current = document.activeElement;
    const currentIndex = items.indexOf(current);

    let nextIndex;
    if (currentIndex === -1) {
      nextIndex = direction === 1 ? 0 : items.length - 1;
    } else {
      nextIndex = (currentIndex + direction + items.length) % items.length;
    }

    items[nextIndex].focus();
  },

  // ---------------------------------------------------------------------------
  // Cleanup — remove all listeners to prevent memory leaks
  // ---------------------------------------------------------------------------

  destroyed() {
    this.el.removeEventListener("contextmenu", this._handleContextMenu);
    document.removeEventListener("click", this._handleClickOutside);
    document.removeEventListener("keydown", this._handleKeydown);
  },
};

export default PhiaContextMenu;
