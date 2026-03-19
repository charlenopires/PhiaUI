/**
 * PhiaCollabComposer — JS hook for the collaboration comment composer.
 *
 * Features:
 * - @mention detection: triggers server search when user types "@" + query
 * - Enter-to-submit (Shift+Enter for newline)
 * - Mention insertion from server events
 * - Basic Markdown formatting shortcuts (Ctrl/Cmd+B, Ctrl/Cmd+I)
 * - Auto-resize textarea
 */
const PhiaCollabComposer = {
  mounted() {
    this._textarea = this.el.querySelector("[data-composer-input]");
    this._submitBtn = this.el.querySelector("[data-composer-submit]");
    this._mentionTrigger = false;
    this._mentionQuery = "";

    if (!this._textarea) return;

    // Auto-resize textarea
    this._autoResize = () => {
      this._textarea.style.height = "auto";
      this._textarea.style.height =
        Math.min(this._textarea.scrollHeight, 128) + "px";
    };

    // Input handler: detect @mention trigger
    this._onInput = (e) => {
      this._autoResize();

      const text = e.target.value;
      const cursorPos = e.target.selectionStart;
      const beforeCursor = text.substring(0, cursorPos);
      const atMatch = beforeCursor.match(/@(\w*)$/);

      if (atMatch) {
        this._mentionTrigger = true;
        this._mentionQuery = atMatch[1];
        this.pushEvent("collab:mention:search", {
          query: this._mentionQuery,
        });
      } else if (this._mentionTrigger) {
        this._mentionTrigger = false;
        this.pushEvent("collab:mention:close", {});
      }
    };

    // Keydown handler: Enter to submit, formatting shortcuts
    this._onKeydown = (e) => {
      // Enter to submit (without Shift)
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        this._submit();
        return;
      }

      // Bold: Ctrl/Cmd + B
      if ((e.ctrlKey || e.metaKey) && e.key === "b") {
        e.preventDefault();
        this._wrapSelection("**", "**");
        return;
      }

      // Italic: Ctrl/Cmd + I
      if ((e.ctrlKey || e.metaKey) && e.key === "i") {
        e.preventDefault();
        this._wrapSelection("_", "_");
        return;
      }

      // Escape: close mention dropdown
      if (e.key === "Escape" && this._mentionTrigger) {
        this._mentionTrigger = false;
        this.pushEvent("collab:mention:close", {});
      }
    };

    this._textarea.addEventListener("input", this._onInput);
    this._textarea.addEventListener("keydown", this._onKeydown);

    // Submit button click
    if (this._submitBtn) {
      this._onSubmitClick = () => this._submit();
      this._submitBtn.addEventListener("click", this._onSubmitClick);
    }

    // Handle mention selection from server
    this.handleEvent("collab:mention:insert", ({ name, user_id }) => {
      const text = this._textarea.value;
      const cursorPos = this._textarea.selectionStart;
      const beforeCursor = text.substring(0, cursorPos);
      const afterCursor = text.substring(cursorPos);
      const atIndex = beforeCursor.lastIndexOf("@");

      if (atIndex >= 0) {
        const mention = `@[${name}](${user_id}) `;
        const newText =
          beforeCursor.substring(0, atIndex) + mention + afterCursor;
        this._textarea.value = newText;
        const newPos = atIndex + mention.length;
        this._textarea.setSelectionRange(newPos, newPos);
        this._autoResize();
      }

      this._mentionTrigger = false;
    });
  },

  _submit() {
    if (!this._textarea) return;

    const value = this._textarea.value.trim();
    if (!value) return;

    const eventName =
      this.el.dataset.onSubmit || "collab:comment:create";

    this.pushEvent(eventName, {
      body: value,
      thread_id: this.el.dataset.threadId || null,
    });

    this._textarea.value = "";
    this._textarea.style.height = "auto";
    this._mentionTrigger = false;
  },

  _wrapSelection(before, after) {
    if (!this._textarea) return;

    const start = this._textarea.selectionStart;
    const end = this._textarea.selectionEnd;
    const text = this._textarea.value;
    const selected = text.substring(start, end);
    const replacement = before + selected + after;

    this._textarea.value =
      text.substring(0, start) + replacement + text.substring(end);
    this._textarea.setSelectionRange(
      start + before.length,
      start + before.length + selected.length
    );
  },

  destroyed() {
    if (this._textarea) {
      this._textarea.removeEventListener("input", this._onInput);
      this._textarea.removeEventListener("keydown", this._onKeydown);
    }
    if (this._submitBtn && this._onSubmitClick) {
      this._submitBtn.removeEventListener("click", this._onSubmitClick);
    }
  },
};

export default PhiaCollabComposer;
