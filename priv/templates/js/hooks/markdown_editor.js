/**
 * PhiaMarkdownEditor — Split-pane Markdown editor with debounced LiveView push.
 *
 * Manages Write/Preview tab switching and pushes textarea content to the LiveView
 * via `pushEvent(onChange, {raw, length, words})` with a 300ms debounce.
 *
 * Optional features controlled via data attributes:
 *   - data-allow-tab="true" — Insert 2-space indent on Tab key
 *   - data-sync-scroll="true" — Sync scroll position between panes (best effort)
 *
 * HTML anatomy (rendered by markdown_editor/1):
 *   <div id="my-editor">
 *     <div> ← tab bar
 *       <button data-md-tab="write" data-md-active>Write</button>
 *       <button data-md-tab="preview">Preview</button>
 *     </div>
 *     <div> ← panes wrapper
 *       <textarea phx-hook="PhiaMarkdownEditor" data-md-write data-on-change="md_changed"/>
 *       <div data-md-preview class="hidden">...</div>
 *     </div>
 *   </div>
 *
 * Note: phx-hook is on the textarea, not the wrapper.
 *
 * Registration:
 *   import PhiaMarkdownEditor from "./hooks/markdown_editor"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaMarkdownEditor } })
 */
const PhiaMarkdownEditor = {
  mounted() {
    this._textarea = this.el; // hook is on the textarea
    this._onChange = this.el.dataset.onChange;
    this._allowTab = this.el.dataset.allowTab === "true";
    this._syncScroll = this.el.dataset.syncScroll === "true";
    this._debounceMs = 300;
    this._timer = null;

    // Find siblings via parent
    const wrapper = this.el.parentElement;
    const container = wrapper?.parentElement;

    this._previewPane = wrapper?.querySelector("[data-md-preview]");
    this._tabBar = container?.querySelector("[data-md-tab]")?.parentElement;
    this._tabs = container ? Array.from(container.querySelectorAll("[data-md-tab]")) : [];

    // Input debounce
    this._onInput = () => {
      clearTimeout(this._timer);
      this._timer = setTimeout(() => this._push(), this._debounceMs);
    };
    this._textarea.addEventListener("input", this._onInput);

    // Tab key indent
    if (this._allowTab) {
      this._onKeydown = (e) => {
        if (e.key === "Tab") {
          e.preventDefault();
          const start = this._textarea.selectionStart;
          const end = this._textarea.selectionEnd;
          const val = this._textarea.value;
          this._textarea.value = val.slice(0, start) + "  " + val.slice(end);
          this._textarea.selectionStart = this._textarea.selectionEnd = start + 2;
          this._onInput();
        }
      };
      this._textarea.addEventListener("keydown", this._onKeydown);
    }

    // Tab switching
    this._onTabClick = (e) => {
      const tab = e.target.closest("[data-md-tab]");
      if (!tab) return;
      this._switchTab(tab.dataset.mdTab);
    };
    this._tabs.forEach(t => t.addEventListener("click", this._onTabClick));

    // Scroll sync
    if (this._syncScroll && this._previewPane) {
      this._onScroll = () => {
        const ratio = this._textarea.scrollTop / (this._textarea.scrollHeight - this._textarea.clientHeight);
        this._previewPane.scrollTop = ratio * (this._previewPane.scrollHeight - this._previewPane.clientHeight);
      };
      this._textarea.addEventListener("scroll", this._onScroll);
    }
  },

  destroyed() {
    clearTimeout(this._timer);
    this._textarea.removeEventListener("input", this._onInput);
    if (this._onKeydown) {
      this._textarea.removeEventListener("keydown", this._onKeydown);
    }
    if (this._onScroll) {
      this._textarea.removeEventListener("scroll", this._onScroll);
    }
    this._tabs.forEach(t => t.removeEventListener("click", this._onTabClick));
  },

  _push() {
    if (!this._onChange) return;
    const raw = this._textarea.value;
    const length = raw.length;
    const words = raw.trim() === "" ? 0 : raw.trim().split(/\s+/).length;
    this.pushEvent(this._onChange, { raw, length, words });
  },

  _switchTab(tab) {
    this._tabs.forEach(t => {
      const isActive = t.dataset.mdTab === tab;
      t.classList.toggle("border-primary", isActive);
      t.classList.toggle("bg-background", isActive);
      t.classList.toggle("text-foreground", isActive);
      t.classList.toggle("border-transparent", !isActive);
      t.classList.toggle("text-muted-foreground", !isActive);
      if (isActive) {
        t.setAttribute("data-md-active", "");
      } else {
        t.removeAttribute("data-md-active");
      }
    });

    if (tab === "write") {
      this._textarea.classList.remove("hidden");
      this._previewPane?.classList.add("hidden");
      this._textarea.focus();
    } else {
      this._textarea.classList.add("hidden");
      this._previewPane?.classList.remove("hidden");
    }
  },
};

export default PhiaMarkdownEditor;
