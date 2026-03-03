/**
 * PhiaDarkMode — vanilla JS hook for dark mode toggle.
 *
 * Toggles `.dark` class on `<html>`, persists to localStorage['phia-theme'],
 * and fires `phia:theme-changed` for other hooks (e.g. PhiaChart) to react.
 *
 * Anti-FOUC: add this inline script to <head> before any stylesheet:
 *
 *   <script>
 *     (function() {
 *       var t = localStorage.getItem('phia-theme');
 *       if (t === 'dark' || (!t && matchMedia('(prefers-color-scheme: dark)').matches)) {
 *         document.documentElement.classList.add('dark');
 *       }
 *     })();
 *   </script>
 */
const PhiaDarkMode = {
  mounted() {
    this._sync();
    this._onClick = this._onClick.bind(this);
    this.el.addEventListener("click", this._onClick);
  },

  destroyed() {
    this.el.removeEventListener("click", this._onClick);
  },

  _onClick() {
    const isDark = document.documentElement.classList.toggle("dark");
    const theme = isDark ? "dark" : "light";
    localStorage.setItem("phia-theme", theme);
    this._updateLabel(isDark);
    document.dispatchEvent(
      new CustomEvent("phia:theme-changed", { detail: { theme }, bubbles: true })
    );
  },

  _sync() {
    // Read persisted preference, fall back to prefers-color-scheme
    const stored = localStorage.getItem("phia-theme");
    let isDark;
    if (stored) {
      isDark = stored === "dark";
    } else {
      isDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
      localStorage.setItem("phia-theme", isDark ? "dark" : "light");
    }
    if (isDark) {
      document.documentElement.classList.add("dark");
    } else {
      document.documentElement.classList.remove("dark");
    }
    this._updateLabel(isDark);
  },

  _updateLabel(isDark) {
    this.el.setAttribute(
      "aria-label",
      isDark ? "Switch to light mode" : "Switch to dark mode"
    );
  },
};

export default PhiaDarkMode;
