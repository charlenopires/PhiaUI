// PhiaUI Dialog Hook — PhiaDialog
// Implements WAI-ARIA Dialog pattern with focus trap, keyboard navigation,
// auto-focus, and scroll locking.
//
// Registration in app.js:
//   import PhiaDialog from "./phia_hooks/dialog.js"
//   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaDialog } })

const FOCUSABLE_SELECTORS = [
  "a[href]",
  "button:not([disabled])",
  "input:not([disabled])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  '[tabindex]:not([tabindex="-1"])',
].join(", ");

const PhiaDialog = {
  mounted() {
    // Store the element that had focus before the dialog opened so we can
    // return focus on close (AC: foco retorna ao trigger ao fechar).
    this.previouslyFocused = document.activeElement;

    // Find the dialog content container (data-dialog-content).
    // Scoped to this.el — never document.querySelector without scope (AC: scoped ao this.el).
    this._contentEl = this.el.querySelector("[data-dialog-content]");

    // Bound handlers stored on this so destroyed() can removeEventListener (AC: sem memory leaks).
    this._handleKeydown = (e) => this._onKeydown(e);

    document.addEventListener("keydown", this._handleKeydown);

    // Observe the dialog content container for visibility changes (hidden class toggle).
    // When the dialog opens (hidden removed), trigger onOpen().
    if (this._contentEl) {
      this._wasOpen = !this._contentEl.classList.contains("hidden");

      this._observer = new MutationObserver(() => {
        const isOpen = !this._contentEl.classList.contains("hidden");

        if (isOpen && !this._wasOpen) {
          this._wasOpen = true;
          this._onOpen();
        } else if (!isOpen && this._wasOpen) {
          this._wasOpen = false;
          this._onClose();
        }
      });

      this._observer.observe(this._contentEl, {
        attributes: true,
        attributeFilter: ["class", "style"],
      });

      // If the dialog is already open at mount time, trigger onOpen immediately.
      if (this._wasOpen) {
        this._onOpen();
      }
    }
  },

  destroyed() {
    // Remove all event listeners to prevent memory leaks (AC: sem memory leaks).
    document.removeEventListener("keydown", this._handleKeydown);

    if (this._observer) {
      this._observer.disconnect();
    }

    // Restore body scroll (AC: scroll desbloqueado ao fechar).
    document.body.classList.remove("overflow-hidden");

    // Return focus to the previously focused element (AC: foco retorna ao trigger).
    if (this.previouslyFocused && this.previouslyFocused.focus) {
      this.previouslyFocused.focus();
    }
  },

  // Called when the dialog becomes visible.
  _onOpen() {
    // Block page scroll while dialog is open (AC: overflow-hidden no body).
    document.body.classList.add("overflow-hidden");

    // Auto-focus first focusable element inside the panel (AC: auto-focus ao abrir).
    const focusable = this._getFocusable();
    if (focusable.length > 0) {
      focusable[0].focus();
    }
  },

  // Called when the dialog is hidden again.
  _onClose() {
    // Unblock page scroll.
    document.body.classList.remove("overflow-hidden");

    // Return focus to the element that opened the dialog (AC: foco retorna ao trigger).
    if (this.previouslyFocused && this.previouslyFocused.focus) {
      this.previouslyFocused.focus();
    }
  },

  _onKeydown(e) {
    // Only handle keys when the dialog is open.
    if (!this._contentEl || this._contentEl.classList.contains("hidden")) return;

    if (e.key === "Escape") {
      // Close dialog on Escape (AC: Escape fecha o dialog).
      e.preventDefault();
      this._hide();
    } else if (e.key === "Tab") {
      // Trap focus inside the dialog (AC: focus trap Tab/Shift+Tab).
      this._trapFocus(e);
    }
  },

  // Programmatically hide the dialog content (mirrors JS.hide behaviour).
  _hide() {
    if (this._contentEl) {
      this._contentEl.classList.add("hidden");
    }
  },

  // Returns focusable elements scoped to this.el (AC: scoped ao this.el).
  _getFocusable() {
    const panel = this.el.querySelector("[data-dialog-panel]");
    if (!panel) return [];

    return Array.from(panel.querySelectorAll(FOCUSABLE_SELECTORS)).filter(
      (el) => !el.hasAttribute("disabled") && el.tabIndex !== -1
    );
  },

  // Keeps Tab/Shift+Tab cycling inside the focusable elements (AC: focus trap).
  _trapFocus(e) {
    const focusable = this._getFocusable();
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
};

export default PhiaDialog;
