/**
 * PhiaGlobalMessage — top-center auto-dismissing global message hook.
 *
 * Inspired by Ant Design `message` API. Messages appear at the top-center
 * of the viewport and auto-dismiss after a configurable duration.
 *
 * Usage from LiveView:
 *   push_event(socket, "phia-message", %{
 *     content: "Settings saved.",
 *     type: "success",      // info | success | error | warning | loading
 *     duration_ms: 3000     // 0 = no auto-dismiss (default: 3000)
 *   })
 *
 * Markup contract:
 *   - Hook root: `phx-hook="PhiaGlobalMessage"`, `data-max-messages`
 *   - Messages are created dynamically inside the container
 */

const TYPE_CONFIG = {
  info: {
    icon: `<svg class="h-4 w-4 text-blue-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>`,
  },
  success: {
    icon: `<svg class="h-4 w-4 text-green-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>`,
  },
  error: {
    icon: `<svg class="h-4 w-4 text-red-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="m15 9-6 6M9 9l6 6"/></svg>`,
  },
  warning: {
    icon: `<svg class="h-4 w-4 text-amber-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><path d="M12 9v4M12 17h.01"/></svg>`,
  },
  loading: {
    icon: `<svg class="h-4 w-4 text-muted-foreground animate-spin" viewBox="0 0 24 24" fill="none"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/></svg>`,
  },
};

const PhiaGlobalMessage = {
  mounted() {
    this.maxMessages = parseInt(this.el.dataset.maxMessages ?? "5", 10);
    this._handleEvent("phia-message", (payload) => this._createMessage(payload));
  },

  _createMessage({ content, type = "info", duration_ms = 3000 }) {
    // Enforce max stack
    const existing = this.el.querySelectorAll("[data-phia-message]");
    if (existing.length >= this.maxMessages) {
      this._dismiss(existing[0]);
    }

    const config = TYPE_CONFIG[type] ?? TYPE_CONFIG.info;

    const node = document.createElement("div");
    node.setAttribute("data-phia-message", "");
    node.setAttribute("role", "status");
    node.setAttribute("aria-live", "polite");
    node.className = [
      "pointer-events-auto flex items-center gap-2.5 rounded-lg border",
      "bg-background shadow-lg px-4 py-2.5 text-sm text-foreground",
      "border-border min-w-[240px] max-w-sm",
      "opacity-0 -translate-y-2 scale-95 transition-all duration-200 ease-out",
    ].join(" ");

    node.innerHTML = `
      <span aria-hidden="true">${config.icon}</span>
      <span class="flex-1">${this._esc(content)}</span>
    `;

    this.el.appendChild(node);

    // Slide-in animation
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        node.classList.remove("opacity-0", "-translate-y-2", "scale-95");
        node.classList.add("opacity-100", "translate-y-0", "scale-100");
      });
    });

    // Auto-dismiss
    if (duration_ms > 0) {
      setTimeout(() => this._dismiss(node), duration_ms);
    }
  },

  _dismiss(node) {
    if (!node || !node.isConnected) return;
    node.classList.remove("opacity-100", "translate-y-0", "scale-100");
    node.classList.add("opacity-0", "-translate-y-2", "scale-95");
    node.addEventListener("transitionend", () => node.remove(), { once: true });
    setTimeout(() => node.isConnected && node.remove(), 350);
  },

  _esc(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  },
};

export default PhiaGlobalMessage;
