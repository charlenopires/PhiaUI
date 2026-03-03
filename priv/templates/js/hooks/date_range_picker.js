/**
 * PhiaDateRangePicker — vanilla JS hook for date range picker enhancements.
 *
 * The calendar grid is rendered server-side via LiveView.
 * This hook handles:
 *  - Text input date parsing (format: "MMM D, YYYY – MMM D, YYYY")
 *  - Escape key closes the calendar panel
 *  - Click outside closes the calendar panel
 *
 * Markup contract:
 *   - Hook root: `phx-hook="PhiaDateRangePicker"`, `id`
 *   - Text input: `[data-drp-input]` (optional manual input)
 *   - Calendar panel: `[data-drp-calendar]`
 */
const PhiaDateRangePicker = {
  mounted() {
    this.input = this.el.querySelector("[data-drp-input]");
    this.calendar = this.el.querySelector("[data-drp-calendar]");

    this._onKeydown = this._onKeydown.bind(this);
    this._onClickOutside = this._onClickOutside.bind(this);

    document.addEventListener("keydown", this._onKeydown);
    document.addEventListener("mousedown", this._onClickOutside);
  },

  destroyed() {
    document.removeEventListener("keydown", this._onKeydown);
    document.removeEventListener("mousedown", this._onClickOutside);
  },

  _onKeydown(e) {
    if (e.key === "Escape" && this.calendar) {
      this.calendar.classList.add("hidden");
    }
  },

  _onClickOutside(e) {
    if (this.calendar && !this.el.contains(e.target)) {
      this.calendar.classList.add("hidden");
    }
  },
};

export default PhiaDateRangePicker;
