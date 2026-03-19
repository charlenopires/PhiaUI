/**
 * PhiaRibbonToolbar — Office-style ribbon toolbar tab management.
 *
 * Handles keyboard navigation between ribbon tabs and panels.
 * Tabs switch via phx-click events; this hook adds keyboard support.
 */

const PhiaRibbonToolbar = {
  mounted() {
    this._tabs = Array.from(this.el.querySelectorAll("[role=tab]"));

    this._keyHandler = (e) => {
      const current = this._tabs.indexOf(document.activeElement);
      if (current === -1) return;

      let next = -1;
      if (e.key === "ArrowRight") {
        next = (current + 1) % this._tabs.length;
      } else if (e.key === "ArrowLeft") {
        next = (current - 1 + this._tabs.length) % this._tabs.length;
      } else if (e.key === "Home") {
        next = 0;
      } else if (e.key === "End") {
        next = this._tabs.length - 1;
      }

      if (next !== -1) {
        e.preventDefault();
        this._tabs[next].focus();
        this._tabs[next].click();
      }
    };

    const tablist = this.el.querySelector("[role=tablist]");
    if (tablist) {
      tablist.addEventListener("keydown", this._keyHandler);
    }
  },

  destroyed() {
    const tablist = this.el.querySelector("[role=tablist]");
    if (tablist && this._keyHandler) {
      tablist.removeEventListener("keydown", this._keyHandler);
    }
  },
};

export default PhiaRibbonToolbar;
