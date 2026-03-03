// PhiaUI Drawer Hook — PhiaDrawer
// Implements a sliding drawer panel with focus trap, keyboard navigation,
// backdrop click dismissal, and CSS transform-based animations.
//
// Registration in app.js:
//   import PhiaDrawer from "./phia_hooks/drawer.js"
//   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaDrawer } })

const FOCUSABLE_SELECTORS = [
  "a[href]",
  "button:not([disabled])",
  "input:not([disabled])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  '[tabindex]:not([tabindex="-1"])',
].join(", ");

const PhiaDrawer = {
  mounted() {
    this._panel = this.el.querySelector("[data-drawer-panel]");
    this._backdrop = this.el.querySelector("[data-drawer-backdrop]");
    this._direction = this.el.dataset.direction || "bottom";

    // Store the element that had focus before the drawer opened so we can
    // return focus on close.
    this._previousFocus = document.activeElement;

    // Bound handlers stored on this so destroyed() can removeEventListener.
    this._handleKeydown = (e) => this._onKeydown(e);
    this._handleBackdropClick = (e) => {
      if (e.target === this._backdrop) this._close();
    };
    this._handleCloseBtn = () => this._close();

    // Wire up event listeners.
    document.addEventListener("keydown", this._handleKeydown);

    if (this._backdrop) {
      this._backdrop.addEventListener("click", this._handleBackdropClick);
    }

    const closeBtn = this.el.querySelector("[data-drawer-close]");
    if (closeBtn) {
      closeBtn.addEventListener("click", this._handleCloseBtn);
    }

    // Apply the initial closed transform so the animation works on open.
    this._applyClosedTransform();

    // Auto-focus first focusable element inside the panel on open.
    if (!this.el.classList.contains("hidden")) {
      requestAnimationFrame(() => {
        // Trigger open animation.
        this._applyOpenTransform();
        const first = this._focusableElements()[0];
        if (first) first.focus();
      });
    }

    // Wire up trigger buttons anywhere in the document that target this drawer.
    this._handleTriggerClick = (e) => {
      const trigger = e.target.closest("[data-drawer-trigger]");
      if (trigger && trigger.dataset.drawerTrigger === this.el.id) {
        this._previousFocus = trigger;
        this._open();
      }
    };

    document.addEventListener("click", this._handleTriggerClick);
  },

  destroyed() {
    // Remove all event listeners to prevent memory leaks.
    document.removeEventListener("keydown", this._handleKeydown);
    document.removeEventListener("click", this._handleTriggerClick);

    if (this._backdrop) {
      this._backdrop.removeEventListener("click", this._handleBackdropClick);
    }

    const closeBtn = this.el.querySelector("[data-drawer-close]");
    if (closeBtn) {
      closeBtn.removeEventListener("click", this._handleCloseBtn);
    }
  },

  // Opens the drawer: remove hidden, animate in.
  _open() {
    this.el.classList.remove("hidden");
    this._applyClosedTransform();
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this._applyOpenTransform();
        const first = this._focusableElements()[0];
        if (first) first.focus();
      });
    });
  },

  // Closes the drawer: animate out, then add hidden and restore focus.
  _close() {
    this._applyClosedTransform();
    const panel = this._panel;
    const el = this.el;
    const prevFocus = this._previousFocus;

    const onTransitionEnd = () => {
      el.classList.add("hidden");
      panel.removeEventListener("transitionend", onTransitionEnd);
      if (prevFocus && prevFocus.focus) prevFocus.focus();
    };

    if (panel) {
      panel.addEventListener("transitionend", onTransitionEnd);
    } else {
      el.classList.add("hidden");
      if (prevFocus && prevFocus.focus) prevFocus.focus();
    }
  },

  // Apply the CSS transform that hides the panel off-screen.
  _applyClosedTransform() {
    if (!this._panel) return;
    const transforms = {
      bottom: "translateY(100%)",
      top: "translateY(-100%)",
      left: "translateX(-100%)",
      right: "translateX(100%)",
    };
    this._panel.style.transform = transforms[this._direction] || "translateY(100%)";
  },

  // Apply identity transform so panel is fully visible.
  _applyOpenTransform() {
    if (!this._panel) return;
    this._panel.style.transform = "translate(0, 0)";
  },

  _focusableElements() {
    if (!this._panel) return [];
    return Array.from(this._panel.querySelectorAll(FOCUSABLE_SELECTORS)).filter(
      (el) => !el.hasAttribute("disabled") && el.tabIndex !== -1
    );
  },

  _trapFocus(e) {
    const focusable = this._focusableElements();
    if (focusable.length === 0) return;

    const first = focusable[0];
    const last = focusable[focusable.length - 1];

    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  },

  _onKeydown(e) {
    // Only handle keys when the drawer is open.
    if (this.el.classList.contains("hidden")) return;

    if (e.key === "Escape") {
      e.preventDefault();
      this._close();
    } else if (e.key === "Tab") {
      this._trapFocus(e);
    }
  },
};

export default PhiaDrawer;
