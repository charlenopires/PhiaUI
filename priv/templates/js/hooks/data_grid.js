/**
 * PhiaDataGrid — minimal accessibility hook for DataGrid sorting.
 *
 * Server-side sorting is handled by phx-click + phx-value on column headers.
 * This hook adds keyboard navigation enhancements for sort buttons.
 *
 * Usage: Add phx-hook="PhiaDataGrid" to the <table> element if keyboard
 * navigation enhancements are needed. For basic sorting, the hook is
 * optional — phx-click alone is sufficient.
 */
const PhiaDataGrid = {
  mounted() {
    // Future: keyboard navigation between sort headers (Arrow keys)
    // For now, phx-click handles all sort interactions natively.
  },
};

export default PhiaDataGrid;
