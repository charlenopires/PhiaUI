/**
 * PhiaSonner — vanilla JS hook for Sonner-style stacked toast notifications.
 *
 * Usage in LiveView:
 *   push_event(socket, "phia-sonner", %{
 *     title: "Saved!",
 *     description: "Your changes have been persisted.",
 *     variant: "success",   // default | success | error | warning | info
 *     duration_ms: 4000     // auto-dismiss delay in ms; 0 = persistent
 *   })
 *
 * Markup contract:
 *   Hook root must have:
 *     phx-hook="PhiaSonner"
 *     data-position        — e.g. "bottom-right" (default)
 *     data-expand          — "true" | "false"
 *     data-rich-colors     — "true" | "false"
 *     data-max-visible     — integer string (default "3")
 */

// ---------------------------------------------------------------------------
// Variant styles
// ---------------------------------------------------------------------------

const BASE_CLASSES = [
  "pointer-events-auto relative flex w-full items-start gap-3",
  "overflow-hidden rounded-lg border p-4 shadow-lg",
  "transition-all duration-300 ease-out",
].join(" ");

const VARIANT_CLASSES = {
  default: "bg-background text-foreground border-border",
  success:
    "bg-background text-foreground border-border [&_[data-sonner-icon]]:text-green-500",
  error:
    "bg-background text-foreground border-border [&_[data-sonner-icon]]:text-red-500",
  warning:
    "bg-background text-foreground border-border [&_[data-sonner-icon]]:text-yellow-500",
  info:
    "bg-background text-foreground border-border [&_[data-sonner-icon]]:text-blue-500",
};

const RICH_VARIANT_CLASSES = {
  default: "bg-background text-foreground border-border",
  success:
    "bg-green-50 text-green-900 border-green-200 dark:bg-green-950 dark:text-green-100 dark:border-green-800",
  error:
    "bg-red-50 text-red-900 border-red-200 dark:bg-red-950 dark:text-red-100 dark:border-red-800",
  warning:
    "bg-yellow-50 text-yellow-900 border-yellow-200 dark:bg-yellow-950 dark:text-yellow-100 dark:border-yellow-800",
  info:
    "bg-blue-50 text-blue-900 border-blue-200 dark:bg-blue-950 dark:text-blue-100 dark:border-blue-800",
};

const ICON_SVG = {
  success: `<svg data-sonner-icon class="h-5 w-5 shrink-0 text-green-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  error: `<svg data-sonner-icon class="h-5 w-5 shrink-0 text-red-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z"/></svg>`,
  warning: `<svg data-sonner-icon class="h-5 w-5 shrink-0 text-yellow-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"/></svg>`,
  info: `<svg data-sonner-icon class="h-5 w-5 shrink-0 text-blue-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z"/></svg>`,
};

// ---------------------------------------------------------------------------
// Animation entry direction based on position
// ---------------------------------------------------------------------------

function entryTranslate(position) {
  if (position.startsWith("top-")) return "-translate-y-2";
  return "translate-y-2";
}

// ---------------------------------------------------------------------------
// Hook
// ---------------------------------------------------------------------------

const PhiaSonner = {
  mounted() {
    this.position = this.el.dataset.position ?? "bottom-right";
    this.expand = this.el.dataset.expand === "true";
    this.richColors = this.el.dataset.richColors === "true";
    this.maxVisible = parseInt(this.el.dataset.maxVisible ?? "3", 10);

    // Expand on hover when expand mode is off
    if (!this.expand) {
      this._onMouseEnter = () => this._setExpanded(true);
      this._onMouseLeave = () => this._setExpanded(false);
      this.el.addEventListener("mouseenter", this._onMouseEnter);
      this.el.addEventListener("mouseleave", this._onMouseLeave);
    }

    this._handleEvent("phia-sonner", (payload) => this._createToast(payload));
  },

  destroyed() {
    if (this._onMouseEnter) {
      this.el.removeEventListener("mouseenter", this._onMouseEnter);
    }
    if (this._onMouseLeave) {
      this.el.removeEventListener("mouseleave", this._onMouseLeave);
    }
  },

  // -------------------------------------------------------------------------
  // Toast creation
  // -------------------------------------------------------------------------

  _createToast({ title, description, variant = "default", duration_ms = 4000 }) {
    // Enforce max visible — remove the oldest when over the limit
    const existing = this.el.querySelectorAll("[data-sonner-item]");
    if (existing.length >= this.maxVisible) {
      this._dismiss(existing[0]);
    }

    const id = `phia-sonner-${Date.now()}`;
    const variantMap = this.richColors ? RICH_VARIANT_CLASSES : VARIANT_CLASSES;
    const variantClass = variantMap[variant] ?? variantMap.default;
    const iconHtml = ICON_SVG[variant] ?? "";

    const node = document.createElement("div");
    node.setAttribute("data-sonner-item", "");
    node.setAttribute("role", "alert");
    node.setAttribute("aria-atomic", "true");
    node.id = id;

    // Initial state: invisible + slightly offset
    const entry = entryTranslate(this.position);
    node.className = [BASE_CLASSES, variantClass, "opacity-0", entry].join(" ");

    node.innerHTML = `
      ${iconHtml}
      <div class="flex flex-col gap-1 flex-1 min-w-0">
        ${title ? `<div class="text-sm font-semibold leading-tight">${this._esc(title)}</div>` : ""}
        ${description ? `<div class="text-sm opacity-80 leading-snug">${this._esc(description)}</div>` : ""}
      </div>
      <button
        type="button"
        aria-label="Close"
        data-sonner-close
        class="ml-auto shrink-0 rounded-md p-1 opacity-60 hover:opacity-100 focus:outline-none transition-opacity"
        onclick="this.closest('[data-sonner-item]').dispatchEvent(new CustomEvent('phia:sonner-dismiss', {bubbles:true}))"
      >
        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `;

    node.addEventListener("phia:sonner-dismiss", () => this._dismiss(node));
    this.el.appendChild(node);

    // Trigger enter animation on next frame
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        node.classList.remove("opacity-0", entry);
        node.classList.add("opacity-100", "translate-y-0", "translate-x-0");
        this._restack();
      });
    });

    // Auto-dismiss
    if (duration_ms > 0) {
      const timer = setTimeout(() => this._dismiss(node), duration_ms);
      node._dismissTimer = timer;
    }
  },

  // -------------------------------------------------------------------------
  // Dismiss a single toast node
  // -------------------------------------------------------------------------

  _dismiss(node) {
    if (!node || !node.isConnected) return;

    if (node._dismissTimer) {
      clearTimeout(node._dismissTimer);
    }

    // Fade + slide out based on position
    const exit = entryTranslate(this.position);
    node.classList.remove("opacity-100");
    node.classList.add("opacity-0", exit);

    const cleanup = () => {
      if (node.isConnected) {
        node.remove();
        this._restack();
      }
    };

    node.addEventListener("transitionend", cleanup, { once: true });
    // Fallback if transitionend never fires (e.g. hidden tab)
    setTimeout(cleanup, 400);
  },

  // -------------------------------------------------------------------------
  // Stacking / collapsed layout
  // -------------------------------------------------------------------------

  _setExpanded(expanded) {
    this.el.setAttribute("data-expanded", expanded ? "true" : "false");
    const items = Array.from(this.el.querySelectorAll("[data-sonner-item]"));
    const isBottom = this.position.startsWith("bottom-");

    items.forEach((item, i) => {
      const reverseIndex = items.length - 1 - i;
      if (expanded) {
        item.style.transform = "";
        item.style.scale = "";
        item.style.zIndex = i + 1;
      } else {
        // Collapsed: stack appearance — front item (last in DOM for bottom, first for top)
        const frontIndex = isBottom ? reverseIndex : i;
        const scale = 1 - frontIndex * 0.05;
        const translateY = isBottom
          ? -(frontIndex * 8)
          : frontIndex * 8;
        item.style.transform = `translateY(${translateY}px) scaleX(${scale})`;
        item.style.zIndex = items.length - frontIndex;
      }
    });
  },

  _restack() {
    if (!this.expand) {
      this._setExpanded(false);
    }
  },

  // -------------------------------------------------------------------------
  // HTML escape helper
  // -------------------------------------------------------------------------

  _esc(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  },
};

export default PhiaSonner;
