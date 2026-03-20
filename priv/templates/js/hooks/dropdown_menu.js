// PhiaUI DropdownMenu Hook — PhiaDropdownMenu
// Implements WAI-ARIA Menu Button pattern:
// - Smart positioning via getBoundingClientRect() + auto-flip
// - Click-outside detection with cleanup
// - Full keyboard navigation: Escape, Arrow keys, Enter, Space
// - Submenu support: hover open/close with delay, keyboard ArrowRight/Left
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

    // Initialize submenu handling
    this._initSubs();
  },

  destroyed() {
    // Remove all document-level listeners to prevent memory leaks
    // (AC: cleanup em destroyed()).
    if (this._trigger) {
      this._trigger.removeEventListener("click", this._handleTriggerClick);
    }
    document.removeEventListener("click", this._handleClickOutside);
    document.removeEventListener("keydown", this._handleKeydown);

    // Clear any pending submenu timers
    if (this._subs) {
      for (const sub of this._subs) {
        if (sub.timer) clearTimeout(sub.timer);
      }
    }
  },

  // ---------------------------------------------------------------------------
  // Submenu initialization
  // ---------------------------------------------------------------------------

  _initSubs() {
    this._subs = [];
    if (!this._content) return;

    const subWrappers = this._content.querySelectorAll("[data-dropdown-sub]");
    for (const wrapper of subWrappers) {
      const trigger = wrapper.querySelector("[data-dropdown-sub-trigger]");
      const content = wrapper.querySelector("[data-dropdown-sub-content]");
      if (!trigger || !content) continue;

      const sub = { wrapper, trigger, content, timer: null };
      this._subs.push(sub);

      // Hover handlers with 150ms close delay
      wrapper.addEventListener("mouseenter", () => {
        if (sub.timer) { clearTimeout(sub.timer); sub.timer = null; }
        this._openSub(sub);
      });

      wrapper.addEventListener("mouseleave", () => {
        sub.timer = setTimeout(() => this._closeSub(sub), 150);
      });
    }

    // Click handler on items (excluding sub-triggers) to close menu after action
    this._content.addEventListener("click", (e) => {
      const item = e.target.closest("[data-dropdown-item]");
      if (!item) return;
      // Don't close when clicking a sub-trigger — it should open the submenu
      if (item.hasAttribute("data-dropdown-sub-trigger")) return;
      // Don't close disabled items
      if (item.getAttribute("aria-disabled") === "true") return;
      // Let the click propagate (phx-click), then close
      requestAnimationFrame(() => this._close());
    });
  },

  // ---------------------------------------------------------------------------
  // Submenu open / close
  // ---------------------------------------------------------------------------

  _openSub(sub) {
    // Close sibling subs first
    for (const s of this._subs) {
      if (s !== sub) this._closeSub(s);
    }
    sub.content.classList.remove("hidden");
    sub.trigger.setAttribute("aria-expanded", "true");

    // Flip position if right-edge overflow
    const rect = sub.content.getBoundingClientRect();
    if (rect.right > window.innerWidth - 8) {
      // Open to the left instead
      sub.content.style.left = "auto";
      sub.content.style.right = "100%";
    } else {
      sub.content.style.left = "";
      sub.content.style.right = "";
    }
  },

  _closeSub(sub) {
    sub.content.classList.add("hidden");
    sub.trigger.setAttribute("aria-expanded", "false");
    // Reset positioning
    sub.content.style.left = "";
    sub.content.style.right = "";
    if (sub.timer) { clearTimeout(sub.timer); sub.timer = null; }
  },

  _closeAllSubs() {
    if (!this._subs) return;
    for (const sub of this._subs) {
      this._closeSub(sub);
    }
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
    this._closeAllSubs();
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

    // Find if we're currently inside a submenu
    const activeSub = this._getActiveSub();

    switch (e.key) {
      case "Escape":
        e.preventDefault();
        if (activeSub) {
          // Close only the submenu, return focus to sub-trigger
          this._closeSub(activeSub);
          activeSub.trigger.focus();
        } else {
          this._close();
        }
        break;

      case "ArrowDown":
        e.preventDefault();
        this._focusNext(1);
        break;

      case "ArrowUp":
        e.preventDefault();
        this._focusNext(-1);
        break;

      case "ArrowRight": {
        // If focused element is a sub-trigger, open its submenu
        const sub = this._findSubByTrigger(document.activeElement);
        if (sub) {
          e.preventDefault();
          this._openSub(sub);
          const subItems = this._getItemsIn(sub.content);
          if (subItems.length > 0) subItems[0].focus();
        }
        break;
      }

      case "ArrowLeft":
        // If inside a submenu, close it and return to sub-trigger
        if (activeSub) {
          e.preventDefault();
          this._closeSub(activeSub);
          activeSub.trigger.focus();
        }
        break;

      case "Enter":
      case " ": {
        e.preventDefault();
        const active = document.activeElement;
        if (!active || !this._content.contains(active)) break;
        // If it's a sub-trigger, open submenu instead of closing
        const subForTrigger = this._findSubByTrigger(active);
        if (subForTrigger) {
          this._openSub(subForTrigger);
          const subItems = this._getItemsIn(subForTrigger.content);
          if (subItems.length > 0) subItems[0].focus();
        } else if (active.getAttribute("aria-disabled") !== "true") {
          active.click();
          this._close();
        }
        break;
      }
    }
  },

  // ---------------------------------------------------------------------------
  // Submenu helpers
  // ---------------------------------------------------------------------------

  _getActiveSub() {
    if (!this._subs) return null;
    const active = document.activeElement;
    if (!active) return null;
    for (const sub of this._subs) {
      if (!sub.content.classList.contains("hidden") && sub.content.contains(active)) {
        return sub;
      }
    }
    return null;
  },

  _findSubByTrigger(el) {
    if (!this._subs || !el) return null;
    for (const sub of this._subs) {
      if (sub.trigger === el) return sub;
    }
    return null;
  },

  // Returns items scoped to a specific container
  _getItemsIn(container) {
    return Array.from(
      container.querySelectorAll('[data-dropdown-item]:not([aria-disabled="true"])')
    ).filter((item) => {
      // Exclude items inside hidden sub-content panels
      const parent = item.closest("[data-dropdown-sub-content]");
      if (parent && parent !== container && parent.classList.contains("hidden")) return false;
      // Only include direct items of this container
      const closestSubContent = item.closest("[data-dropdown-sub-content]");
      if (container.hasAttribute("data-dropdown-content")) {
        // Main content: exclude items inside any sub-content (unless that sub-content is visible and is the container)
        return !closestSubContent || closestSubContent === container;
      }
      return closestSubContent === container;
    });
  },

  // Returns all focusable, non-disabled menu items scoped to the active container.
  _getItems() {
    const activeSub = this._getActiveSub();
    const container = activeSub ? activeSub.content : this._content;
    return this._getItemsIn(container);
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
