/**
 * PhiaConfirmButton — vanilla JS hook for inline two-step confirmation.
 *
 * On first click, the initial button is hidden and a confirmation row
 * ("Are you sure?" + Yes + Cancel) appears in its place. An auto-reset
 * timer reverts to the initial state after `data-timeout` ms.
 *
 * HTML anatomy expected:
 *   <div phx-hook="PhiaConfirmButton" id="..." data-timeout="3000">
 *     <button data-confirm-initial>Delete</button>
 *     <div data-confirm-state class="hidden">
 *       <span>Are you sure?</span>
 *       <button data-confirm-yes phx-click="...">Yes, delete</button>
 *       <button data-confirm-cancel>Cancel</button>
 *     </div>
 *   </div>
 */
const PhiaConfirmButton = {
  mounted() {
    this._initial = this.el.querySelector('[data-confirm-initial]');
    this._state = this.el.querySelector('[data-confirm-state]');
    this._yes = this.el.querySelector('[data-confirm-yes]');
    this._cancel = this.el.querySelector('[data-confirm-cancel]');
    this._timeout = parseInt(this.el.dataset.timeout || '3000', 10);
    this._timer = null;

    if (this._initial) {
      this._initial.addEventListener('click', () => this._showConfirm());
    }
    if (this._cancel) {
      this._cancel.addEventListener('click', () => this._reset());
    }
  },

  _showConfirm() {
    if (this._initial) this._initial.classList.add('hidden');
    if (this._state) this._state.classList.remove('hidden');

    // Focus the Yes button for keyboard users
    if (this._yes) this._yes.focus();

    // Auto-reset after timeout
    if (this._timer) clearTimeout(this._timer);
    this._timer = setTimeout(() => this._reset(), this._timeout);
  },

  _reset() {
    if (this._timer) {
      clearTimeout(this._timer);
      this._timer = null;
    }
    if (this._state) this._state.classList.add('hidden');
    if (this._initial) this._initial.classList.remove('hidden');
  },

  destroyed() {
    if (this._timer) clearTimeout(this._timer);
  }
};

export default PhiaConfirmButton;
