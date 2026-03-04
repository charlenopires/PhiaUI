/**
 * PhiaCopyButton — vanilla JS hook for copy-to-clipboard button.
 *
 * Reads the text from `data-value`, copies it to the clipboard using the
 * Clipboard API (with execCommand fallback for older browsers), then briefly
 * shows a check icon in place of the copy icon to give visual feedback.
 *
 * The feedback duration is configurable via `data-timeout` (default 2000 ms).
 *
 * HTML anatomy expected:
 *   <button phx-hook="PhiaCopyButton" data-value="..." data-timeout="2000">
 *     <svg data-copy-icon ...>...</svg>
 *     <svg data-copy-check class="hidden" ...>...</svg>
 *     <span aria-live="polite" class="sr-only"></span>
 *   </button>
 */
const PhiaCopyButton = {
  mounted() {
    this.btn = this.el;
    this.copyIcon = this.el.querySelector('[data-copy-icon]');
    this.checkIcon = this.el.querySelector('[data-copy-check]');
    this.timeout = parseInt(this.el.dataset.timeout || '2000', 10);

    this.el.addEventListener('click', () => this.copy());
  },

  copy() {
    const value = this.el.dataset.value;

    const doFallback = () => {
      const ta = document.createElement('textarea');
      ta.value = value;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      document.execCommand('copy');
      document.body.removeChild(ta);
      this.showCopied();
    };

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(value)
        .then(() => this.showCopied())
        .catch(() => doFallback());
    } else {
      doFallback();
    }
  },

  showCopied() {
    if (this.copyIcon) this.copyIcon.classList.add('hidden');
    if (this.checkIcon) this.checkIcon.classList.remove('hidden');

    const liveEl = this.el.querySelector('[aria-live]');
    if (liveEl) liveEl.textContent = 'Copied!';

    if (this._timer) clearTimeout(this._timer);
    this._timer = setTimeout(() => this.reset(), this.timeout);
  },

  reset() {
    if (this.copyIcon) this.copyIcon.classList.remove('hidden');
    if (this.checkIcon) this.checkIcon.classList.add('hidden');
    const liveEl = this.el.querySelector('[aria-live]');
    if (liveEl) liveEl.textContent = '';
  },

  destroyed() {
    if (this._timer) clearTimeout(this._timer);
  }
};

export default PhiaCopyButton;
