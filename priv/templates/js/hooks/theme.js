/**
 * PhiaTheme — vanilla JS hook for runtime color theme switching.
 *
 * Sets `data-phia-theme` on `<html>`, persists the chosen preset to
 * localStorage['phia-color-theme'], and fires a `phia:color-theme-changed`
 * CustomEvent so other hooks (e.g. PhiaChart) can react.
 *
 * Requires `phia-themes.css` to be imported in your app.css:
 *   @import "./phia-themes.css";
 *
 * Generate the CSS file with:
 *   mix phia.theme install
 *
 * ## Usage — button (click)
 *
 *   <button phx-hook="PhiaTheme" id="t-blue" data-theme="blue">Blue</button>
 *   <button phx-hook="PhiaTheme" id="t-zinc" data-theme="zinc">Zinc</button>
 *
 * ## Usage — select (change)
 *
 *   <select phx-hook="PhiaTheme" id="theme-select">
 *     <option value="zinc">Zinc</option>
 *     <option value="blue">Blue</option>
 *     <option value="rose">Rose</option>
 *   </select>
 *
 * ## Anti-FOUC — add to <head> before any stylesheet
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
 * ## localStorage keys
 *
 *   'phia-mode'         — "dark" | "light"  (written by PhiaDarkMode)
 *   'phia-color-theme'  — "zinc" | "blue" | ... (written by PhiaTheme)
 */
const PhiaTheme = {
  mounted() {
    this._restore();
    this._onEvent = this._onEvent.bind(this);

    if (this.el.tagName === "SELECT") {
      this.el.addEventListener("change", this._onEvent);
    } else {
      this.el.addEventListener("click", this._onEvent);
    }
  },

  destroyed() {
    if (this.el.tagName === "SELECT") {
      this.el.removeEventListener("change", this._onEvent);
    } else {
      this.el.removeEventListener("click", this._onEvent);
    }
  },

  _restore() {
    const stored = localStorage.getItem("phia-color-theme");
    if (stored) {
      this._applyTheme(stored);
      // Sync select value if this element is a select
      if (this.el.tagName === "SELECT") {
        this.el.value = stored;
      }
    }
  },

  _onEvent(evt) {
    let theme;
    if (evt.type === "change") {
      theme = evt.target.value;
    } else {
      theme = this.el.dataset.theme;
    }
    if (theme) {
      this._applyTheme(theme);
    }
  },

  _applyTheme(theme) {
    document.documentElement.setAttribute("data-phia-theme", theme);
    localStorage.setItem("phia-color-theme", theme);
    document.dispatchEvent(
      new CustomEvent("phia:color-theme-changed", {
        detail: { theme },
        bubbles: true,
      })
    );
  },
};

export default PhiaTheme;
