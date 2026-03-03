/**
 * PhiaCarousel — vanilla JS hook for carousel navigation.
 *
 * Manages CSS transform-based sliding, touch swipe detection,
 * keyboard navigation (ArrowLeft/Right or ArrowUp/Down for vertical),
 * and optional loop behaviour.
 *
 * Markup contract:
 *   - Hook root:  `phx-hook="PhiaCarousel"`, `data-orientation`, `data-loop`, `tabindex="0"`
 *   - Track:      `[data-carousel-track]` — receives `transform: translateX/Y(n%)`
 *   - Slides:     `[aria-roledescription="slide"]` — determine the slide count
 *   - Prev btn:   `[data-carousel-prev]` — click navigates back, `disabled` when at start
 *   - Next btn:   `[data-carousel-next]` — click navigates forward, `disabled` when at end
 *
 * Touch swipe threshold: 50px in the primary axis direction.
 * Slide transition: CSS `transition-transform duration-300 ease-in-out` (set in HEEx).
 */
const PhiaCarousel = {
  mounted() {
    this._currentIndex = 0;
    this._track = this.el.querySelector("[data-carousel-track]");
    this._items = Array.from(
      this.el.querySelectorAll('[aria-roledescription="slide"]')
    );
    this._prevBtn = this.el.querySelector("[data-carousel-prev]");
    this._nextBtn = this.el.querySelector("[data-carousel-next]");
    this._loop = this.el.dataset.loop === "true";
    this._orientation = this.el.dataset.orientation || "horizontal";
    this._touchStartX = 0;
    this._touchStartY = 0;

    // Set initial button states
    this._updateButtons();

    // Previous button
    if (this._prevBtn) {
      this._handlePrev = () => this._goTo(this._currentIndex - 1);
      this._prevBtn.addEventListener("click", this._handlePrev);
    }

    // Next button
    if (this._nextBtn) {
      this._handleNext = () => this._goTo(this._currentIndex + 1);
      this._nextBtn.addEventListener("click", this._handleNext);
    }

    // Keyboard navigation
    this._handleKeydown = (e) => {
      if (this._orientation === "horizontal") {
        if (e.key === "ArrowLeft") {
          e.preventDefault();
          this._goTo(this._currentIndex - 1);
        } else if (e.key === "ArrowRight") {
          e.preventDefault();
          this._goTo(this._currentIndex + 1);
        }
      } else {
        if (e.key === "ArrowUp") {
          e.preventDefault();
          this._goTo(this._currentIndex - 1);
        } else if (e.key === "ArrowDown") {
          e.preventDefault();
          this._goTo(this._currentIndex + 1);
        }
      }
    };
    this.el.addEventListener("keydown", this._handleKeydown);

    // Touch swipe support
    this._handleTouchStart = (e) => {
      this._touchStartX = e.touches[0].clientX;
      this._touchStartY = e.touches[0].clientY;
    };

    this._handleTouchEnd = (e) => {
      const dx = e.changedTouches[0].clientX - this._touchStartX;
      const dy = e.changedTouches[0].clientY - this._touchStartY;
      const threshold = 50;

      if (this._orientation === "horizontal" && Math.abs(dx) > threshold) {
        // Swipe left → next, swipe right → prev
        this._goTo(dx < 0 ? this._currentIndex + 1 : this._currentIndex - 1);
      } else if (
        this._orientation === "vertical" &&
        Math.abs(dy) > threshold
      ) {
        // Swipe up → next, swipe down → prev
        this._goTo(dy < 0 ? this._currentIndex + 1 : this._currentIndex - 1);
      }
    };

    this.el.addEventListener("touchstart", this._handleTouchStart, {
      passive: true,
    });
    this.el.addEventListener("touchend", this._handleTouchEnd);
  },

  /**
   * Navigate to a specific slide index.
   * Clamps to [0, count-1] or wraps around when loop=true.
   */
  _goTo(idx) {
    const count = this._items.length;
    if (count === 0) return;

    if (this._loop) {
      // Modulo that handles negative values correctly
      idx = ((idx % count) + count) % count;
    } else {
      idx = Math.max(0, Math.min(idx, count - 1));
    }

    this._currentIndex = idx;
    const offset = -(idx * 100);

    if (this._track) {
      if (this._orientation === "horizontal") {
        this._track.style.transform = `translateX(${offset}%)`;
      } else {
        this._track.style.transform = `translateY(${offset}%)`;
      }
    }

    this._updateButtons();
  },

  /**
   * Disable prev/next buttons at the boundaries when loop is off.
   * No-op when loop=true (both buttons always active).
   */
  _updateButtons() {
    if (this._loop) return;

    const count = this._items.length;
    if (this._prevBtn) {
      this._prevBtn.disabled = this._currentIndex === 0;
    }
    if (this._nextBtn) {
      this._nextBtn.disabled = this._currentIndex === count - 1;
    }
  },

  destroyed() {
    if (this._prevBtn && this._handlePrev) {
      this._prevBtn.removeEventListener("click", this._handlePrev);
    }
    if (this._nextBtn && this._handleNext) {
      this._nextBtn.removeEventListener("click", this._handleNext);
    }
    this.el.removeEventListener("keydown", this._handleKeydown);
    this.el.removeEventListener("touchstart", this._handleTouchStart);
    this.el.removeEventListener("touchend", this._handleTouchEnd);
  },
};

export default PhiaCarousel;
