// PhiaUI MegaMenu Hook — PhiaMegaMenu
// Implements hover + click toggle, keyboard navigation, and delay timers.
//
// Registration in app.js:
//   import PhiaMegaMenu from "./phia_hooks/mega_menu.js"
//   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaMegaMenu } })

const PhiaMegaMenu = {
  mounted() {
    this._trigger = this.el.querySelector("[data-mega-trigger]");
    this._content = this.el.querySelector("[data-mega-content]");

    if (!this._trigger || !this._content) return;

    this._openTimer = null;
    this._closeTimer = null;
    this._reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    this._handleTriggerClick = () => this._toggle();
    this._handleMouseEnter = () => this._scheduleOpen();
    this._handleMouseLeave = () => this._scheduleClose();
    this._handleClickOutside = (e) => this._onClickOutside(e);
    this._handleKeydown = (e) => this._onKeydown(e);

    this._trigger.addEventListener("click", this._handleTriggerClick);
    this.el.addEventListener("mouseenter", this._handleMouseEnter);
    this.el.addEventListener("mouseleave", this._handleMouseLeave);
    document.addEventListener("click", this._handleClickOutside);
    document.addEventListener("keydown", this._handleKeydown);
  },

  destroyed() {
    if (this._trigger) {
      this._trigger.removeEventListener("click", this._handleTriggerClick);
    }
    if (this.el) {
      this.el.removeEventListener("mouseenter", this._handleMouseEnter);
      this.el.removeEventListener("mouseleave", this._handleMouseLeave);
    }
    document.removeEventListener("click", this._handleClickOutside);
    document.removeEventListener("keydown", this._handleKeydown);
    clearTimeout(this._openTimer);
    clearTimeout(this._closeTimer);
  },

  _isOpen() {
    return !this._content.classList.contains("hidden");
  },

  _open() {
    this._content.classList.remove("hidden");
    this._content.setAttribute("data-open", "");
    this._trigger.setAttribute("aria-expanded", "true");
    this._trigger.setAttribute("data-open", "");
    // Focus first focusable item
    const first = this._content.querySelector("a, button, [tabindex]");
    if (first) first.focus();
  },

  _close() {
    this._content.classList.add("hidden");
    this._content.removeAttribute("data-open");
    this._trigger.setAttribute("aria-expanded", "false");
    this._trigger.removeAttribute("data-open");
    this._trigger.focus();
  },

  _toggle() {
    this._isOpen() ? this._close() : this._open();
  },

  _scheduleOpen() {
    clearTimeout(this._closeTimer);
    this._openTimer = setTimeout(() => this._open(), 150);
  },

  _scheduleClose() {
    clearTimeout(this._openTimer);
    this._closeTimer = setTimeout(() => this._close(), 300);
  },

  _onClickOutside(e) {
    if (!this._isOpen()) return;
    if (!this.el.contains(e.target)) this._close();
  },

  _onKeydown(e) {
    if (!this._isOpen()) return;

    switch (e.key) {
      case "Escape":
        e.preventDefault();
        this._close();
        break;
      case "Tab":
        // Let Tab close naturally by detecting focus leaving el
        setTimeout(() => {
          if (!this.el.contains(document.activeElement)) this._close();
        }, 0);
        break;
    }
  },
};

export default PhiaMegaMenu;
