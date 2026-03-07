/**
 * PhiaSplitButton — vanilla JS hook for split button dropdown.
 *
 * Toggles the dropdown on caret click, closes on outside click or Escape,
 * and supports roving keyboard focus on `[data-split-item]` elements.
 *
 * HTML anatomy expected:
 *   <div phx-hook="PhiaSplitButton" id="...">
 *     <button><!-- primary action --></button>
 *     <button data-split-caret aria-expanded="false"><!-- caret --></button>
 *     <div data-split-dropdown class="hidden" role="menu">
 *       <div data-split-item role="menuitem" tabindex="-1">Item</div>
 *       ...
 *     </div>
 *   </div>
 */
const PhiaSplitButton = {
  mounted() {
    this._caret = this.el.querySelector('[data-split-caret]');
    this._dropdown = this.el.querySelector('[data-split-dropdown]');

    this._onCaretClick = () => this._toggle();
    this._onDocClick = (e) => {
      if (!this.el.contains(e.target)) this._close();
    };
    this._onDocKeydown = (e) => {
      if (e.key === 'Escape') {
        this._close();
        this._caret && this._caret.focus();
      }
    };

    if (this._caret) {
      this._caret.addEventListener('click', this._onCaretClick);
    }
    document.addEventListener('click', this._onDocClick);
    document.addEventListener('keydown', this._onDocKeydown);

    // Roving focus within dropdown
    if (this._dropdown) {
      this._dropdown.addEventListener('keydown', (e) => {
        const items = [...this._dropdown.querySelectorAll('[data-split-item]')];
        if (items.length === 0) return;
        const idx = items.indexOf(document.activeElement);
        if (e.key === 'ArrowDown') {
          e.preventDefault();
          items[(idx + 1) % items.length].focus();
        } else if (e.key === 'ArrowUp') {
          e.preventDefault();
          items[(idx - 1 + items.length) % items.length].focus();
        }
      });
    }
  },

  _toggle() {
    const isOpen = this._dropdown && !this._dropdown.classList.contains('hidden');
    isOpen ? this._close() : this._open();
  },

  _open() {
    if (!this._dropdown) return;
    this._dropdown.classList.remove('hidden');
    if (this._caret) this._caret.setAttribute('aria-expanded', 'true');
    // Focus first focusable item
    const first = this._dropdown.querySelector('[data-split-item]');
    if (first) first.focus();
  },

  _close() {
    if (!this._dropdown) return;
    this._dropdown.classList.add('hidden');
    if (this._caret) this._caret.setAttribute('aria-expanded', 'false');
  },

  destroyed() {
    document.removeEventListener('click', this._onDocClick);
    document.removeEventListener('keydown', this._onDocKeydown);
  }
};

export default PhiaSplitButton;
