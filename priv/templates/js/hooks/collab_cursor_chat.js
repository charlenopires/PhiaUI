/**
 * PhiaCollabCursorChat — Figma-style inline micro-chat at cursor position.
 *
 * Provides keyboard shortcuts for quick cursor-level messaging:
 *   - "/" key: opens the chat input at the cursor position
 *   - Enter: sends the message
 *   - Escape: dismisses the input
 *
 * Received messages auto-dismiss after 5 seconds.
 *
 * Emits:
 *   pushEvent("collab:cursor:chat:open", {})
 *   pushEvent("collab:cursor:chat:send", { message: String })
 *   pushEvent("collab:cursor:chat:close", {})
 *   pushEvent("collab:cursor:chat:dismiss", {})
 *
 * Registration:
 *   import PhiaCollabCursorChat from "./hooks/collab_cursor_chat"
 *   let liveSocket = new LiveSocket("/live", Socket, {
 *     hooks: { PhiaCollabCursorChat }
 *   })
 */
const PhiaCollabCursorChat = {
  mounted() {
    this._dismissTimer = null;
    this._input = this.el.querySelector("[data-cursor-chat-input]");

    // Global keyboard shortcut: "/" to open chat input
    this._onKeyDown = (e) => {
      // Ignore if user is already typing in an input or textarea
      const tag = e.target.tagName;
      if (
        tag === "INPUT" ||
        tag === "TEXTAREA" ||
        e.target.isContentEditable
      ) {
        return;
      }

      if (e.key === "/" && !this._input) {
        e.preventDefault();
        this.pushEvent("collab:cursor:chat:open", {});
      }
    };

    document.addEventListener("keydown", this._onKeyDown);

    // Input event handlers
    if (this._input) {
      this._input.focus();

      this._onInputKeyDown = (e) => {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          const msg = this._input.value.trim();
          if (msg) {
            this.pushEvent("collab:cursor:chat:send", { message: msg });
            this._input.value = "";
          }
        }
        if (e.key === "Escape") {
          e.preventDefault();
          this.pushEvent("collab:cursor:chat:close", {});
        }
      };

      this._input.addEventListener("keydown", this._onInputKeyDown);
    }

    // Auto-dismiss timer for received messages
    const msgEl = this.el.querySelector("[data-cursor-chat-message]");
    if (msgEl) {
      this._dismissTimer = setTimeout(() => {
        this.pushEvent("collab:cursor:chat:dismiss", {});
      }, 5000);
    }
  },

  updated() {
    // Re-bind input if it appeared after a LiveView patch
    const input = this.el.querySelector("[data-cursor-chat-input]");
    if (input && input !== this._input) {
      this._input = input;
      this._input.focus();

      this._onInputKeyDown = (e) => {
        if (e.key === "Enter" && !e.shiftKey) {
          e.preventDefault();
          const msg = this._input.value.trim();
          if (msg) {
            this.pushEvent("collab:cursor:chat:send", { message: msg });
            this._input.value = "";
          }
        }
        if (e.key === "Escape") {
          e.preventDefault();
          this.pushEvent("collab:cursor:chat:close", {});
        }
      };

      this._input.addEventListener("keydown", this._onInputKeyDown);
    }

    // Re-set dismiss timer for new messages
    const msgEl = this.el.querySelector("[data-cursor-chat-message]");
    if (msgEl) {
      clearTimeout(this._dismissTimer);
      this._dismissTimer = setTimeout(() => {
        this.pushEvent("collab:cursor:chat:dismiss", {});
      }, 5000);
    }
  },

  destroyed() {
    document.removeEventListener("keydown", this._onKeyDown);
    clearTimeout(this._dismissTimer);
  },
};

export { PhiaCollabCursorChat };
export default PhiaCollabCursorChat;
