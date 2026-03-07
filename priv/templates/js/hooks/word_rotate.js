/**
 * PhiaWordRotate — cycles through a JSON-encoded list of words with a fade/slide.
 *
 * HTML anatomy:
 *   <span phx-hook="PhiaWordRotate"
 *         data-words='["Fast","Beautiful","Accessible"]'
 *         data-duration="2500">
 *   </span>
 *
 * Respects prefers-reduced-motion (shows first word, no animation).
 */
const PhiaWordRotate = {
  mounted() {
    let words;
    try {
      words = JSON.parse(this.el.dataset.words || '[]');
    } catch {
      words = [];
    }

    const duration = parseInt(this.el.dataset.duration) || 2500;

    if (!words.length) return;

    this.el.textContent = words[0];

    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduced) return;

    let idx = 0;
    this._interval = setInterval(() => {
      idx = (idx + 1) % words.length;

      this.el.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
      this.el.style.opacity = '0';
      this.el.style.transform = 'translateY(-8px)';

      setTimeout(() => {
        this.el.textContent = words[idx];
        this.el.style.opacity = '1';
        this.el.style.transform = 'translateY(0)';
      }, 300);
    }, duration);
  },

  destroyed() {
    clearInterval(this._interval);
  }
};

export default PhiaWordRotate;
