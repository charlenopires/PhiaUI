/**
 * PhiaRichEditor — LiveView hook for PhiaUI's native rich text editor.
 *
 * Uses the vanilla PhiaEditor engine (execCommand-based, zero npm dependencies).
 * Provides server-driven commands, debounced content updates, and throttled
 * selection state for toolbar reactivity.
 *
 * Setup:
 *   import PhiaRichEditor from "./hooks/phia_rich_editor"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaRichEditor } })
 *
 * Markup contract:
 *   - Hook root: phx-hook="PhiaRichEditor", id, data-content (initial content)
 *   - Required children: [data-rich-content] (editor mount point),
 *                         [data-rich-hidden] (hidden input for forms)
 *   - Optional attrs: data-placeholder, data-on-update (event name),
 *                      data-on-selection (event name), data-content-format ("json" or "html")
 */

const PhiaRichEditor = {
  mounted() {
    this._editor = null;
    this._debounceTimer = null;
    this._throttleTimer = null;
    this._reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    this._contentEl = this.el.querySelector("[data-rich-content]");
    this._hiddenInput = this.el.querySelector("[data-rich-hidden]");

    if (!this._contentEl) return;

    this._initEditor();

    // Server-driven commands
    this.handleEvent(`editor:command:${this.el.id}`, (payload) => {
      this._handleCommand(payload);
    });

    // Server-driven content replacement
    this.handleEvent(`editor:set-content:${this.el.id}`, ({ content }) => {
      this._setContent(content);
    });
  },

  updated() {
    // Re-sync hidden input value on LiveView patch
    if (this._hiddenInput && this._editor) {
      this._hiddenInput.value = this._editor.getHTML();
    }
  },

  destroyed() {
    if (this._debounceTimer) clearTimeout(this._debounceTimer);
    if (this._throttleTimer) clearTimeout(this._throttleTimer);

    if (this._editor) {
      this._editor.destroy();
      this._editor = null;
    }
  },

  // ===========================================================================
  // Initialization — vanilla PhiaEditor only (zero npm deps)
  // ===========================================================================

  _initEditor() {
    // Prefer v2 engine (modern DOM manipulation) over v1 (execCommand-based)
    if (window.PhiaEditorV2) {
      this._initV2();
    } else if (window.PhiaEditor) {
      this._initVanilla();
    } else {
      // Neither engine loaded — wait briefly then retry once
      setTimeout(() => {
        if (window.PhiaEditorV2) {
          this._initV2();
        } else if (window.PhiaEditor) {
          this._initVanilla();
        } else {
          this._contentEl.innerHTML =
            '<p style="color: var(--color-muted-foreground); padding: 1rem;">' +
            "Include PhiaEditor (rich_text_editor.js or phia_editor_v2.js) for rich text editing." +
            "</p>";
        }
      }, 100);
    }
  },

  _initV2() {
    const placeholder = this.el.dataset.placeholder || "";
    const initialContent = this.el.dataset.content || "";

    this._editor = new window.PhiaEditorV2({
      element: this._contentEl,
      content: initialContent,
      placeholder,
      onUpdate: (html) => {
        if (this._hiddenInput) {
          this._hiddenInput.value = html;
        }
        this._debouncedPush({
          html,
          json: null,
          word_count: this._countWords(this._contentEl.textContent),
        });
      },
      onSelectionChange: () => {
        this._onSelectionUpdate();
      },
    });
  },

  _initVanilla() {
    const placeholder = this.el.dataset.placeholder || "";
    const initialContent = this.el.dataset.content || "";

    this._editor = new window.PhiaEditor({
      element: this._contentEl,
      content: initialContent,
      placeholder,
      onUpdate: (html) => {
        if (this._hiddenInput) {
          this._hiddenInput.value = html;
        }
        this._debouncedPush({
          html,
          json: null,
          word_count: this._countWords(this._contentEl.textContent),
        });
      },
      onSelectionChange: () => {
        this._onSelectionUpdate();
      },
    });
  },

  // ===========================================================================
  // Content updates — debounced push to server
  // ===========================================================================

  _debouncedPush(payload) {
    if (this._debounceTimer) clearTimeout(this._debounceTimer);
    this._debounceTimer = setTimeout(() => {
      const eventName = this.el.dataset.onUpdate || "editor:update";
      this.pushEvent(eventName, payload);
    }, 300);
  },

  // ===========================================================================
  // Selection updates — throttled push for toolbar state
  // ===========================================================================

  _onSelectionUpdate() {
    if (!this._editor) return;

    const activeMarks = [];
    const activeNodes = [];

    // Check marks
    const marks = ["bold", "italic", "underline", "strike", "code", "link", "superscript", "subscript"];
    marks.forEach((mark) => {
      if (this._editor.isActive(mark)) activeMarks.push(mark);
    });

    // Check nodes
    const nodes = ["paragraph", "h1", "h2", "h3", "h4", "h5", "bulletList", "orderedList", "blockquote", "codeBlock"];
    nodes.forEach((node) => {
      if (this._editor.isActive(node)) activeNodes.push(node);
    });

    // Get heading level
    let headingLevel = null;
    for (let i = 1; i <= 6; i++) {
      if (this._editor.isActive(`h${i}`)) {
        headingLevel = i;
        break;
      }
    }

    this._throttledSelectionPush({
      active_marks: activeMarks,
      active_nodes: activeNodes,
      heading_level: headingLevel,
    });
  },

  _throttledSelectionPush(payload) {
    if (this._throttleTimer) return;
    this._throttleTimer = setTimeout(() => {
      this._throttleTimer = null;
      const eventName = this.el.dataset.onSelection || "editor:selection";
      this.pushEvent(eventName, payload);
    }, 50);
  },

  // ===========================================================================
  // Server-driven commands
  // ===========================================================================

  _handleCommand({ command, attrs }) {
    if (!this._editor) return;

    switch (command) {
      case "toggleBold":        this._editor.toggleBold(); break;
      case "toggleItalic":      this._editor.toggleItalic(); break;
      case "toggleUnderline":   this._editor.toggleUnderline(); break;
      case "toggleStrike":      this._editor.toggleStrike(); break;
      case "toggleCode":        this._editor.toggleCode(); break;
      case "toggleSuperscript": this._editor.toggleSuperscript(); break;
      case "toggleSubscript":   this._editor.toggleSubscript(); break;
      case "toggleBulletList":  this._editor.toggleBulletList(); break;
      case "toggleOrderedList": this._editor.toggleOrderedList(); break;
      case "toggleBlockquote":  this._editor.toggleBlockquote(); break;
      case "toggleCodeBlock":   this._editor.toggleCodeBlock(); break;
      case "setHeading":
        this._editor.setHeading(attrs && attrs.level || 2);
        break;
      case "setParagraph":      this._editor.setParagraph(); break;
      case "setLink":
        if (attrs && attrs.href) this._editor.setLink(attrs.href);
        break;
      case "unsetLink":         this._editor.unsetLink(); break;
      case "undo":              this._editor.undo(); break;
      case "redo":              this._editor.redo(); break;
      case "setContent":
        if (attrs && attrs.content) this._editor.setContent(attrs.content);
        break;
      case "insertContent":
      case "insertHTML":
        if (attrs && attrs.content) this._editor.insertHTML(attrs.content);
        break;
      case "setTextAlign":
        if (attrs && attrs.alignment) this._editor.setTextAlign(attrs.alignment);
        break;
      case "setHorizontalRule": this._editor.insertHorizontalRule(); break;
      case "setColor":
        if (attrs && attrs.color) this._editor.setColor(attrs.color);
        break;
      case "setHighlight":
        if (attrs && attrs.color) this._editor.setHighlight(attrs.color);
        break;
      case "setFontFamily":
        if (attrs && attrs.font) this._editor.setFontFamily(attrs.font);
        break;
      case "setFontSize":
        if (attrs && attrs.size && typeof this._editor.setFontSize === "function") {
          this._editor.setFontSize(attrs.size);
        }
        break;
      case "clearFormatting":   this._editor.clearFormatting(); break;
      case "insertTable":
        this._editor.insertTable(attrs && attrs.rows || 3, attrs && attrs.cols || 3);
        break;
      default:
        // Try direct method call on editor
        if (typeof this._editor[command] === "function") {
          this._editor[command](attrs || {});
        }
    }

    // Re-sync after command
    if (this._hiddenInput && this._editor) {
      this._hiddenInput.value = this._editor.getHTML();
    }
    this._onSelectionUpdate();
  },

  _setContent(content) {
    if (this._editor) {
      const html = typeof content === "string" ? content : "";
      this._editor.setContent(html);
      if (this._hiddenInput) {
        this._hiddenInput.value = this._editor.getHTML();
      }
    }
  },

  // ===========================================================================
  // Helpers
  // ===========================================================================

  _countWords(text) {
    if (!text) return 0;
    const trimmed = text.trim();
    if (!trimmed) return 0;
    return trimmed.split(/\s+/).length;
  },
};

export default PhiaRichEditor;
