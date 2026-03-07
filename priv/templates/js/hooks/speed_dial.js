// PhiaUI SpeedDial Hook — PhiaSpeedDial
// FAB toggle with staggered item animations and outside click / Escape close.
//
// Registration in app.js:
//   import PhiaSpeedDial from "./phia_hooks/speed_dial.js"
//   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaSpeedDial } })

const PhiaSpeedDial = {
  mounted() {
    this._fab = this.el.querySelector("[data-speed-dial-fab]");
    this._itemsContainer = this.el.querySelector("[data-speed-dial-items]");
    this._items = Array.from(this.el.querySelectorAll("[data-speed-dial-item]"));
    this._isOpen = false;
    this._reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    if (!this._fab) return;

    this._handleFabClick = () => this._toggle();
    this._handleClickOutside = (e) => this._onClickOutside(e);
    this._handleKeydown = (e) => this._onKeydown(e);

    this._fab.addEventListener("click", this._handleFabClick);
    document.addEventListener("click", this._handleClickOutside);
    document.addEventListener("keydown", this._handleKeydown);
  },

  destroyed() {
    if (this._fab) {
      this._fab.removeEventListener("click", this._handleFabClick);
    }
    document.removeEventListener("click", this._handleClickOutside);
    document.removeEventListener("keydown", this._handleKeydown);
  },

  _toggle() {
    this._isOpen ? this._close() : this._open();
  },

  _open() {
    this._isOpen = true;
    this._fab.setAttribute("aria-expanded", "true");
    this.el.setAttribute("data-open", "");

    // Rotate FAB icon
    const icon = this._fab.querySelector("svg");
    if (icon && !this._reducedMotion) icon.style.transform = "rotate(45deg)";

    // Stagger items in
    this._items.forEach((item, i) => {
      if (this._reducedMotion) {
        item.classList.remove("opacity-0", "translate-y-4", "pointer-events-none");
        item.classList.add("opacity-100", "translate-y-0", "pointer-events-auto");
      } else {
        setTimeout(() => {
          item.classList.remove("opacity-0", "translate-y-4", "pointer-events-none");
          item.classList.add("opacity-100", "translate-y-0", "pointer-events-auto");
        }, i * 50);
      }
    });
  },

  _close() {
    this._isOpen = false;
    this._fab.setAttribute("aria-expanded", "false");
    this.el.removeAttribute("data-open");

    // Reset FAB icon
    const icon = this._fab.querySelector("svg");
    if (icon) icon.style.transform = "";

    // Stagger items out (reversed)
    const reversed = [...this._items].reverse();
    reversed.forEach((item, i) => {
      if (this._reducedMotion) {
        item.classList.add("opacity-0", "translate-y-4", "pointer-events-none");
        item.classList.remove("opacity-100", "translate-y-0", "pointer-events-auto");
      } else {
        setTimeout(() => {
          item.classList.add("opacity-0", "translate-y-4", "pointer-events-none");
          item.classList.remove("opacity-100", "translate-y-0", "pointer-events-auto");
        }, i * 50);
      }
    });
  },

  _onClickOutside(e) {
    if (!this._isOpen) return;
    if (!this.el.contains(e.target)) this._close();
  },

  _onKeydown(e) {
    if (e.key === "Escape" && this._isOpen) {
      e.preventDefault();
      this._close();
      if (this._fab) this._fab.focus();
    }
  },
};

export default PhiaSpeedDial;
