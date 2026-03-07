/**
 * PhiaCountdownButton — vanilla JS hook for timer-locked buttons.
 *
 * Decrements a counter every second. While counting, the button label
 * shows the countdown (replacing `{n}` in the counting_label template).
 * When the timer reaches zero, `disabled` is removed and the label reverts
 * to the static label — unless `data-user-disabled="true"`, in which case
 * the button stays disabled.
 *
 * HTML anatomy expected:
 *   <button
 *     phx-hook="PhiaCountdownButton"
 *     id="..."
 *     data-seconds="60"
 *     data-label="Resend"
 *     data-counting-label="Resend in {n}s"
 *     data-auto-start="true"
 *     data-user-disabled="false"
 *     disabled
 *   >
 *     <span data-countdown-text>Resend</span>
 *   </button>
 */
const PhiaCountdownButton = {
  mounted() {
    this._seconds = parseInt(this.el.dataset.seconds || '60', 10);
    this._label = this.el.dataset.label || 'Resend';
    this._countingLabel = this.el.dataset.countingLabel || 'Resend in {n}s';
    this._autoStart = this.el.dataset.autoStart !== 'false';
    this._userDisabled = this.el.dataset.userDisabled === 'true';
    this._remaining = this._seconds;
    this._interval = null;
    this._textEl = this.el.querySelector('[data-countdown-text]');

    if (this._autoStart) this._start();
  },

  _start() {
    if (this._interval) return;
    this._remaining = parseInt(this.el.dataset.seconds || '60', 10);
    this.el.disabled = true;
    this._updateText();

    this._interval = setInterval(() => {
      this._remaining -= 1;
      this._updateText();

      if (this._remaining <= 0) {
        clearInterval(this._interval);
        this._interval = null;
        if (!this._userDisabled) {
          this.el.disabled = false;
        }
        if (this._textEl) {
          this._textEl.textContent = this._label;
        }
      }
    }, 1000);
  },

  _updateText() {
    if (this._textEl) {
      this._textEl.textContent = this._countingLabel.replace('{n}', String(this._remaining));
    }
  },

  destroyed() {
    if (this._interval) {
      clearInterval(this._interval);
      this._interval = null;
    }
  }
};

export default PhiaCountdownButton;
