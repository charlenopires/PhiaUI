/**
 * PhiaCalendar — vanilla JS hook for keyboard navigation inside the calendar grid.
 *
 * The calendar grid is fully server-rendered; this hook only manages focus
 * movement between day buttons so that the widget is keyboard-accessible
 * without any server round-trips.
 *
 * ## Keyboard bindings
 *
 * | Key        | Action                                      |
 * |------------|---------------------------------------------|
 * | ArrowRight | Move focus to the next day                  |
 * | ArrowLeft  | Move focus to the previous day              |
 * | ArrowDown  | Move focus to the same day in the next week |
 * | ArrowUp    | Move focus to the same day in the prior week|
 * | Home       | Move focus to the first day of the week     |
 * | End        | Move focus to the last day of the week      |
 * | Enter      | Activate (click) the focused day button     |
 *
 * Markup contract:
 *   - Hook root: `phx-hook="PhiaCalendar"`, `id`
 *   - Day buttons: `[role="gridcell"] button:not([disabled])`
 */
const PhiaCalendar = {
  mounted() {
    this._handleKeydown = (e) => {
      const focused = document.activeElement;
      const cells = Array.from(
        this.el.querySelectorAll('[role="gridcell"] button:not([disabled])')
      );
      const idx = cells.indexOf(focused);

      if (idx === -1) return;

      let nextIdx = idx;

      if (e.key === "ArrowRight") {
        nextIdx = idx + 1;
      } else if (e.key === "ArrowLeft") {
        nextIdx = idx - 1;
      } else if (e.key === "ArrowDown") {
        nextIdx = idx + 7;
      } else if (e.key === "ArrowUp") {
        nextIdx = idx - 7;
      } else if (e.key === "Home") {
        // First cell of the current row (week)
        nextIdx = Math.floor(idx / 7) * 7;
      } else if (e.key === "End") {
        // Last cell of the current row (week)
        nextIdx = Math.floor(idx / 7) * 7 + 6;
      } else if (e.key === "Enter") {
        focused.click();
        return;
      } else {
        return;
      }

      e.preventDefault();

      if (nextIdx >= 0 && nextIdx < cells.length) {
        cells[nextIdx].focus();
      }
    };

    this.el.addEventListener("keydown", this._handleKeydown);
  },

  destroyed() {
    this.el.removeEventListener("keydown", this._handleKeydown);
  },
};

export default PhiaCalendar;
