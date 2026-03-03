// PhiaUI Tags Input Hook — PhiaTagsInput
//
// Manages a multi-tag input UI backed by a hidden input for form submission.
// Zero npm dependencies. All state managed via DOM + hidden input.
//
// Behaviour:
//   - Add tag: Enter key or separator character typed in the text input
//   - Remove tag: click the × button on a badge, or Backspace on empty input
//   - Deduplication: silently ignores duplicate tags (exact match)
//   - Sync: updates hidden input (CSV) on every add/remove
//
// Registration in app.js:
//   import PhiaTagsInput from "./phia_hooks/tags_input.js"
//   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaTagsInput } })
//
// Required HTML structure:
//   <div phx-hook="PhiaTagsInput" data-separator=",">
//     <div data-tag="elixir">...</div>          <!-- existing tags (server-rendered) -->
//     <input type="text" data-tags-input />      <!-- typing input -->
//   </div>
//   <input type="hidden" data-tags-hidden />     <!-- form value target -->

const PhiaTagsInput = {
  mounted() {
    // Elements scoped to this.el (never document.querySelector without scope)
    this._textInput = this.el.querySelector("[data-tags-input]");
    this._hiddenInput = this.el.closest("div").querySelector("[data-tags-hidden]");
    this._separator = this.el.getAttribute("data-separator") || ",";

    if (!this._textInput || !this._hiddenInput) return;

    // Initialize tag list from the hidden input's current CSV value
    // (set server-side from field.value). This is the single source of truth.
    const initialValue = this._hiddenInput.value || "";
    this._tags = initialValue
      ? initialValue.split(",").map((t) => t.trim()).filter(Boolean)
      : [];

    // Bound handlers stored on `this` so destroyed() can removeEventListener
    // AC: destroy() remove todos os event listeners (no memory leaks)
    this._handleKeydown = (e) => this._onKeydown(e);
    this._handleInput = (e) => this._onInput(e);

    this._textInput.addEventListener("keydown", this._handleKeydown);
    this._textInput.addEventListener("input", this._handleInput);

    // Bind remove buttons on server-rendered initial badges
    this._bindRemoveButtons();
  },

  destroyed() {
    if (this._textInput) {
      this._textInput.removeEventListener("keydown", this._handleKeydown);
      this._textInput.removeEventListener("input", this._handleInput);
    }
  },

  // ---------------------------------------------------------------------------
  // Keyboard handling
  // ---------------------------------------------------------------------------

  _onKeydown(e) {
    if (e.key === "Enter") {
      // AC: add tag on Enter
      e.preventDefault();
      this._commitInput();
    } else if (e.key === "Backspace" && this._textInput.value === "") {
      // AC: remove last tag on Backspace when input is empty
      e.preventDefault();
      if (this._tags.length > 0) {
        this._removeTag(this._tags[this._tags.length - 1]);
      }
    }
  },

  _onInput() {
    // AC: add tag when separator character is typed
    const val = this._textInput.value;
    if (val.includes(this._separator)) {
      const parts = val.split(this._separator);
      // Everything before the last separator becomes tags
      parts.slice(0, -1).forEach((part) => {
        const trimmed = part.trim();
        if (trimmed) this._addTag(trimmed);
      });
      // Keep whatever came after the last separator in the input
      this._textInput.value = parts[parts.length - 1];
    }
  },

  // ---------------------------------------------------------------------------
  // Add / remove
  // ---------------------------------------------------------------------------

  // AC: add tag + deduplication (silently ignore duplicates)
  _addTag(value) {
    const trimmed = value.trim();
    if (!trimmed) return;

    // AC: Duplicatas ignoradas silenciosamente
    if (this._tags.includes(trimmed)) return;

    this._tags.push(trimmed);
    this._renderTag(trimmed);
    this._syncHiddenInput();
    this._textInput.value = "";
  },

  // AC: remove tag by value
  _removeTag(value) {
    this._tags = this._tags.filter((t) => t !== value);
    // Remove the DOM badge
    const badge = this.el.querySelector(`[data-tag="${CSS.escape(value)}"]`);
    if (badge) badge.remove();
    this._syncHiddenInput();
  },

  _commitInput() {
    const val = this._textInput.value.trim();
    if (val) this._addTag(val);
  },

  // ---------------------------------------------------------------------------
  // DOM rendering
  // ---------------------------------------------------------------------------

  _renderTag(value) {
    const div = document.createElement("div");
    div.setAttribute("data-tag", value);
    div.className = "inline-flex items-center";

    // Build badge markup matching the server-rendered structure
    div.innerHTML = `
      <div class="inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-semibold transition-colors bg-secondary text-secondary-foreground hover:bg-secondary/80 gap-1 pr-1">
        <span>${this._escapeHtml(value)}</span>
        <button
          type="button"
          data-remove-tag="${this._escapeAttr(value)}"
          aria-label="Remover ${this._escapeAttr(value)}"
          class="ml-0.5 rounded-sm opacity-70 hover:opacity-100 focus:outline-none"
        >
          <svg class="w-3 h-3" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
               fill="none" stroke="currentColor" stroke-width="2"
               stroke-linecap="round" stroke-linejoin="round"
               aria-hidden="true" focusable="false">
            <path d="M18 6 6 18"/><path d="m6 6 12 12"/>
          </svg>
        </button>
      </div>
    `;

    // Insert before the text input
    this.el.insertBefore(div, this._textInput);
    this._bindRemoveButton(div.querySelector("[data-remove-tag]"));
  },

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------

  // AC: sync hidden input with CSV value on every change
  _syncHiddenInput() {
    this._hiddenInput.value = this._tags.join(",");
    this._hiddenInput.dispatchEvent(new Event("input", { bubbles: true }));
  },

  // ---------------------------------------------------------------------------
  // Event binding helpers
  // ---------------------------------------------------------------------------

  _bindRemoveButtons() {
    this.el.querySelectorAll("[data-remove-tag]").forEach((btn) => {
      this._bindRemoveButton(btn);
    });
  },

  _bindRemoveButton(btn) {
    btn.addEventListener("click", () => {
      const tag = btn.getAttribute("data-remove-tag");
      if (tag) this._removeTag(tag);
    });
  },

  // ---------------------------------------------------------------------------
  // HTML escaping utilities
  // ---------------------------------------------------------------------------

  _escapeHtml(str) {
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  },

  _escapeAttr(str) {
    return str.replace(/"/g, "&quot;").replace(/'/g, "&#039;");
  },
};

export default PhiaTagsInput;
