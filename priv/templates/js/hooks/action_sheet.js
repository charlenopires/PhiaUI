// PhiaUI ActionSheet Hook — PhiaActionSheet
// Slide-up panel with backdrop, swipe-down detection, and body scroll lock.
//
// Registration in app.js:
//   import PhiaActionSheet from "./phia_hooks/action_sheet.js"
//   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaActionSheet } })

const PhiaActionSheet = {
  mounted() {
    this._backdrop = this.el.querySelector("[data-action-sheet-backdrop]");
    this._panel = this.el.querySelector("[data-action-sheet-panel]");
    this._isOpen = false;
    this._touchStartY = 0;
    this._currentTranslate = 0;

    // Find all triggers scoped to this action sheet id
    this._id = this.el.id;
    this._handleTriggerClick = (e) => {
      const trigger = e.target.closest(`[data-action-sheet-trigger="${this._id}"]`);
      if (trigger) this._open();
    };

    this._handleBackdropClick = () => this._close();
    this._handleKeydown = (e) => {
      if (e.key === "Escape" && this._isOpen) this._close();
    };
    this._handleCloseButton = (e) => {
      if (e.target.closest("[data-action-sheet-close]")) this._close();
    };

    this._handleTouchStart = (e) => {
      this._touchStartY = e.touches[0].clientY;
      this._currentTranslate = 0;
    };
    this._handleTouchMove = (e) => {
      const dy = e.touches[0].clientY - this._touchStartY;
      if (dy > 0 && this._panel) {
        this._currentTranslate = dy;
        this._panel.style.transform = `translateY(${dy}px)`;
      }
    };
    this._handleTouchEnd = () => {
      if (this._currentTranslate > 100) {
        this._close();
      } else if (this._panel) {
        this._panel.style.transform = "";
      }
      this._currentTranslate = 0;
    };

    document.addEventListener("click", this._handleTriggerClick);
    document.addEventListener("keydown", this._handleKeydown);
    if (this._backdrop) {
      this._backdrop.addEventListener("click", this._handleBackdropClick);
    }
    if (this._panel) {
      this._panel.addEventListener("click", this._handleCloseButton);
      this._panel.addEventListener("touchstart", this._handleTouchStart, { passive: true });
      this._panel.addEventListener("touchmove", this._handleTouchMove, { passive: true });
      this._panel.addEventListener("touchend", this._handleTouchEnd);
    }
  },

  destroyed() {
    document.removeEventListener("click", this._handleTriggerClick);
    document.removeEventListener("keydown", this._handleKeydown);
    if (this._backdrop) {
      this._backdrop.removeEventListener("click", this._handleBackdropClick);
    }
    if (this._panel) {
      this._panel.removeEventListener("click", this._handleCloseButton);
      this._panel.removeEventListener("touchstart", this._handleTouchStart);
      this._panel.removeEventListener("touchmove", this._handleTouchMove);
      this._panel.removeEventListener("touchend", this._handleTouchEnd);
    }
    this._restoreBodyScroll();
  },

  _open() {
    this._isOpen = true;
    document.body.style.overflow = "hidden";

    if (this._backdrop) {
      this._backdrop.classList.remove("hidden");
    }
    if (this._panel) {
      this._panel.style.transform = "";
      this._panel.classList.remove("translate-y-full");
      this._panel.classList.add("translate-y-0");
    }
  },

  _close() {
    this._isOpen = false;

    if (this._panel) {
      this._panel.style.transform = "";
      this._panel.classList.remove("translate-y-0");
      this._panel.classList.add("translate-y-full");
    }
    if (this._backdrop) {
      this._backdrop.classList.add("hidden");
    }
    this._restoreBodyScroll();
  },

  _restoreBodyScroll() {
    document.body.style.overflow = "";
  },
};

export default PhiaActionSheet;
