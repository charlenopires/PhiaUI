/**
 * PhiaTooltip — vanilla JS hook for tooltip show/hide.
 *
 * Triggers on mouseenter/mouseleave and focus/blur.
 * Uses getBoundingClientRect() for positioning with smart viewport-edge flip.
 * Respects `data-delay` (ms) and `data-position` (top|bottom|left|right).
 * Escape key closes the tooltip.
 *
 * Markup contract:
 *   - Hook root: `phx-hook="PhiaTooltip"`, `data-delay`, `id`
 *   - Trigger child: `[data-tooltip-trigger]`
 *   - Content child: `[data-tooltip-content]`, `data-position`
 */
const PhiaTooltip = {
  mounted() {
    this.trigger = this.el.querySelector("[data-tooltip-trigger]");
    this.content = this.el.querySelector("[data-tooltip-content]");
    this.delay = parseInt(this.el.dataset.delay ?? "200", 10);
    this._timer = null;

    if (!this.trigger || !this.content) return;

    this._show = this._show.bind(this);
    this._hide = this._hide.bind(this);
    this._onKeydown = this._onKeydown.bind(this);

    this.trigger.addEventListener("mouseenter", this._show);
    this.trigger.addEventListener("mouseleave", this._hide);
    this.trigger.addEventListener("focus", this._show);
    this.trigger.addEventListener("blur", this._hide);
    document.addEventListener("keydown", this._onKeydown);
  },

  destroyed() {
    if (!this.trigger) return;
    this.trigger.removeEventListener("mouseenter", this._show);
    this.trigger.removeEventListener("mouseleave", this._hide);
    this.trigger.removeEventListener("focus", this._show);
    this.trigger.removeEventListener("blur", this._hide);
    document.removeEventListener("keydown", this._onKeydown);
    clearTimeout(this._timer);
  },

  _show() {
    clearTimeout(this._timer);
    this._timer = setTimeout(() => {
      this._position();
      this.content.classList.remove("opacity-0", "invisible");
      this.content.classList.add("opacity-100", "visible");
    }, this.delay);
  },

  _hide() {
    clearTimeout(this._timer);
    this.content.classList.remove("opacity-100", "visible");
    this.content.classList.add("opacity-0", "invisible");
  },

  _onKeydown(e) {
    if (e.key === "Escape") this._hide();
  },

  _position() {
    const preferred = this.content.dataset.position ?? "top";
    const triggerRect = this.trigger.getBoundingClientRect();
    const contentRect = this.content.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const gap = 8; // px gap between trigger and content

    // Determine actual position with smart flip
    let position = preferred;
    if (preferred === "top" && triggerRect.top < contentRect.height + gap) {
      position = "bottom";
    } else if (preferred === "bottom" && triggerRect.bottom + contentRect.height + gap > vh) {
      position = "top";
    } else if (preferred === "left" && triggerRect.left < contentRect.width + gap) {
      position = "right";
    } else if (preferred === "right" && triggerRect.right + contentRect.width + gap > vw) {
      position = "left";
    }

    // Reset positioning styles
    Object.assign(this.content.style, {
      top: "",
      bottom: "",
      left: "",
      right: "",
      transform: "",
    });

    switch (position) {
      case "top":
        this.content.style.bottom = `calc(100% + ${gap}px)`;
        this.content.style.left = "50%";
        this.content.style.transform = "translateX(-50%)";
        break;
      case "bottom":
        this.content.style.top = `calc(100% + ${gap}px)`;
        this.content.style.left = "50%";
        this.content.style.transform = "translateX(-50%)";
        break;
      case "left":
        this.content.style.right = `calc(100% + ${gap}px)`;
        this.content.style.top = "50%";
        this.content.style.transform = "translateY(-50%)";
        break;
      case "right":
        this.content.style.left = `calc(100% + ${gap}px)`;
        this.content.style.top = "50%";
        this.content.style.transform = "translateY(-50%)";
        break;
    }
  },
};

export default PhiaTooltip;
