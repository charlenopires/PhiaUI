/**
 * PhiaDarkMode — vanilla JS hook for dark mode toggle.
 *
 * Toggles `.dark` class on `<html>`, persists preference to
 * localStorage['phia-mode'] (and 'phia-theme' for backward compatibility),
 * and fires `phia:theme-changed` for other hooks (e.g. PhiaChart) to react.
 *
 * Anti-FOUC: add this inline script to <head> before any stylesheet:
 *
 *   <script>
 *     (function() {
 *       var mode = localStorage.getItem('phia-mode') || localStorage.getItem('phia-theme');
 *       if (mode === 'dark' || (!mode && matchMedia('(prefers-color-scheme: dark)').matches)) {
 *         document.documentElement.classList.add('dark');
 *       }
 *       var ct = localStorage.getItem('phia-color-theme');
 *       if (ct) document.documentElement.setAttribute('data-phia-theme', ct);
 *     })();
 *   </script>
 *
 * localStorage keys:
 *   'phia-mode'        — "dark" | "light" (this hook)
 *   'phia-theme'       — same as phia-mode (backward compat, deprecated)
 *   'phia-color-theme' — color preset name (PhiaTheme hook)
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
    const mode = isDark ? "dark" : "light";
    // Write new key + legacy key for backward compat
    localStorage.setItem("phia-mode", mode);
    localStorage.setItem("phia-theme", mode);
    this._updateLabel(isDark);
    document.dispatchEvent(
      new CustomEvent("phia:theme-changed", {
        detail: { mode, theme: mode },
        bubbles: true,
      })
    );
  },

  _sync() {
    // Read persisted preference: new key first, fall back to legacy key, then prefers-color-scheme
    const stored = localStorage.getItem("phia-mode") || localStorage.getItem("phia-theme");
    let isDark;
    if (stored) {
      isDark = stored === "dark";
    } else {
      isDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    }
    // Persist to both keys
    const mode = isDark ? "dark" : "light";
    localStorage.setItem("phia-mode", mode);
    localStorage.setItem("phia-theme", mode);

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
