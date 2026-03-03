/**
 * PhiaPopover — vanilla JS hook for popover open/close.
 *
 * Behaviour:
 *  - Click trigger → open content panel
 *  - Click outside → close
 *  - Escape key → close and return focus to trigger
 *  - Tab / Shift+Tab → focus trap within open panel
 *  - Smart positioning via getBoundingClientRect() with auto-flip
 *
 * Markup contract:
 *   - Hook root: `phx-hook="PhiaPopover"`, `id`
 *   - Trigger child: `[data-popover-trigger]`, `aria-expanded`, `aria-controls`
 *   - Content child: `[data-popover-content]`, `data-position`, `role="dialog"`
 */
const PhiaPopover = {
  mounted() {
    this.trigger = this.el.querySelector("[data-popover-trigger]");
    this.content = this.el.querySelector("[data-popover-content]");
    this.open = false;

    if (!this.trigger || !this.content) return;

    this._onTriggerClick = this._onTriggerClick.bind(this);
    this._onKeydown = this._onKeydown.bind(this);
    this._onClickOutside = this._onClickOutside.bind(this);

    this.trigger.addEventListener("click", this._onTriggerClick);
    document.addEventListener("keydown", this._onKeydown);
    document.addEventListener("mousedown", this._onClickOutside);
  },

  destroyed() {
    if (!this.trigger) return;
    this.trigger.removeEventListener("click", this._onTriggerClick);
    document.removeEventListener("keydown", this._onKeydown);
    document.removeEventListener("mousedown", this._onClickOutside);
  },

  _onTriggerClick() {
    this.open ? this._close() : this._open();
  },

  _open() {
    this.open = true;
    this._position();
    this.content.classList.remove("hidden");
    this.trigger.setAttribute("aria-expanded", "true");
    // Focus first focusable element inside content
    const first = this._focusable()[0];
    if (first) first.focus();
  },

  _close() {
    this.open = false;
    this.content.classList.add("hidden");
    this.trigger.setAttribute("aria-expanded", "false");
    this.trigger.focus();
  },

  _onKeydown(e) {
    if (!this.open) return;
    if (e.key === "Escape") {
      e.preventDefault();
      this._close();
      return;
    }
    if (e.key === "Tab") {
      this._trapFocus(e);
    }
  },

  _onClickOutside(e) {
    if (this.open && !this.el.contains(e.target)) {
      this._close();
    }
  },

  _trapFocus(e) {
    const focusable = this._focusable();
    if (focusable.length === 0) return;
    const first = focusable[0];
    const last = focusable[focusable.length - 1];
    if (e.shiftKey) {
      if (document.activeElement === first) {
        e.preventDefault();
        last.focus();
      }
    } else {
      if (document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }
  },

  _focusable() {
    return Array.from(
      this.content.querySelectorAll(
        'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
      )
    );
  },

  _position() {
    const preferred = this.content.dataset.position ?? "bottom";
    const triggerRect = this.trigger.getBoundingClientRect();
    const contentRect = this.content.getBoundingClientRect();
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const gap = 4;

    let position = preferred;
    if (preferred === "bottom" && triggerRect.bottom + contentRect.height + gap > vh) {
      position = "top";
    } else if (preferred === "top" && triggerRect.top < contentRect.height + gap) {
      position = "bottom";
    } else if (preferred === "left" && triggerRect.left < contentRect.width + gap) {
      position = "right";
    } else if (preferred === "right" && triggerRect.right + contentRect.width + gap > vw) {
      position = "left";
    }

    Object.assign(this.content.style, { top: "", bottom: "", left: "", right: "" });

    switch (position) {
      case "bottom":
        this.content.style.top = `calc(100% + ${gap}px)`;
        this.content.style.left = "0";
        break;
      case "top":
        this.content.style.bottom = `calc(100% + ${gap}px)`;
        this.content.style.left = "0";
        break;
      case "left":
        this.content.style.right = `calc(100% + ${gap}px)`;
        this.content.style.top = "0";
        break;
      case "right":
        this.content.style.left = `calc(100% + ${gap}px)`;
        this.content.style.top = "0";
        break;
    }
  },
};

export default PhiaPopover;
