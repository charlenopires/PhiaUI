/**
 * PhiaToast — vanilla JS hook for toast notification stack.
 *
 * Usage in LiveView:
 *   push_event(socket, "phia-toast", %{
 *     title: "Saved!",
 *     description: "Optional body text.",
 *     variant: "success",   // default | success | destructive | warning
 *     duration_ms: 5000     // auto-dismiss delay, 0 = no auto-dismiss
 *   })
 *
 * Markup contract:
 *   - Hook root: `phx-hook="PhiaToast"`, `data-max-toasts`
 *   - Toasts are created dynamically inside the viewport container
 */

const VARIANT_CLASSES = {
  default: "bg-background text-foreground border-border",
  success: "bg-green-50 text-green-900 border-green-200 dark:bg-green-950 dark:text-green-100 dark:border-green-800",
  destructive: "bg-destructive/10 text-destructive border-destructive/30",
  warning: "bg-yellow-50 text-yellow-900 border-yellow-200 dark:bg-yellow-950 dark:text-yellow-100 dark:border-yellow-800",
};

const PhiaToast = {
  mounted() {
    this.maxToasts = parseInt(this.el.dataset.maxToasts ?? "5", 10);
    this._handleEvent("phia-toast", (payload) => this._createToast(payload));
  },

  _createToast({ title, description, variant = "default", duration_ms = 5000 }) {
    // Enforce max stack
    const existing = this.el.querySelectorAll("[data-toast-item]");
    if (existing.length >= this.maxToasts) {
      this._dismiss(existing[0]);
    }

    const id = `phia-toast-${Date.now()}`;
    const variantClass = VARIANT_CLASSES[variant] ?? VARIANT_CLASSES.default;

    const node = document.createElement("div");
    node.setAttribute("data-toast-item", "");
    node.setAttribute("role", "alert");
    node.setAttribute("aria-atomic", "true");
    node.className = [
      "pointer-events-auto relative flex w-full items-start justify-between gap-2",
      "overflow-hidden rounded-md border p-4 pr-6 shadow-lg transition-all",
      "translate-x-full opacity-0",   // initial state (off-screen right)
      variantClass,
    ].join(" ");
    node.id = id;

    node.innerHTML = `
      <div class="flex flex-col gap-1 flex-1">
        ${title ? `<div class="text-sm font-semibold">${this._esc(title)}</div>` : ""}
        ${description ? `<div class="text-sm opacity-90">${this._esc(description)}</div>` : ""}
      </div>
      <button
        type="button"
        aria-label="Close"
        data-toast-close
        class="absolute right-1 top-1 rounded-md p-1 opacity-70 hover:opacity-100 focus:outline-none"
        onclick="this.closest('[data-toast-item]').dispatchEvent(new CustomEvent('phia:toast-dismiss', {bubbles:true}))"
      >
        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M18 6 6 18M6 6l12 12"/>
        </svg>
      </button>
    `;

    node.addEventListener("phia:toast-dismiss", () => this._dismiss(node));
    this.el.appendChild(node);

    // Slide-in animation (next frame)
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        node.classList.remove("translate-x-full", "opacity-0");
        node.classList.add("translate-x-0", "opacity-100");
      });
    });

    // Auto-dismiss
    if (duration_ms > 0) {
      setTimeout(() => this._dismiss(node), duration_ms);
    }
  },

  _dismiss(node) {
    if (!node || !node.isConnected) return;
    node.classList.remove("translate-x-0", "opacity-100");
    node.classList.add("translate-x-full", "opacity-0");
    node.addEventListener("transitionend", () => node.remove(), { once: true });
    // Fallback remove if transition doesn't fire
    setTimeout(() => node.isConnected && node.remove(), 400);
  },

  _esc(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  },
};

export default PhiaToast;
