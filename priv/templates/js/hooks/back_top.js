/**
 * PhiaBackTop — vanilla JS hook for the back-to-top floating button.
 *
 * Listens to the window scroll event and toggles `opacity-0` / `opacity-100`
 * on the button element based on whether the current scroll position exceeds
 * the configured threshold.  Clicking the button scrolls the page back to
 * the top using the native `scrollTo` API.
 *
 * HTML attributes read from the element:
 *   data-threshold  — scroll distance in pixels before showing (default 200)
 *   data-smooth     — "true" | "false", enables smooth scroll (default true)
 *
 * HTML anatomy expected:
 *   <button id="back-top" phx-hook="PhiaBackTop"
 *           data-threshold="200" data-smooth="true" aria-label="Scroll to top">
 *     <svg ...>...</svg>
 *     <span class="sr-only">Scroll to top</span>
 *   </button>
 */
const PhiaBackTop = {
  mounted() {
    this.threshold = parseInt(this.el.dataset.threshold || '200', 10);
    this.smooth = this.el.dataset.smooth !== 'false';

    this._onScroll = () => this.handleScroll();
    window.addEventListener('scroll', this._onScroll, { passive: true });

    // Click handler — scroll to the top of the page.
    this.el.addEventListener('click', () => {
      window.scrollTo({
        top: 0,
        behavior: this.smooth ? 'smooth' : 'auto'
      });
    });

    // Check initial scroll position in case the page is already scrolled.
    this.handleScroll();
  },

  handleScroll() {
    const scrollY = window.scrollY || window.pageYOffset;
    if (scrollY > this.threshold) {
      this.el.classList.remove('opacity-0');
      this.el.classList.add('opacity-100');
    } else {
      this.el.classList.remove('opacity-100');
      this.el.classList.add('opacity-0');
    }
  },

  destroyed() {
    window.removeEventListener('scroll', this._onScroll);
  }
};

export default PhiaBackTop;
