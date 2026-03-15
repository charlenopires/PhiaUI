/**
 * PhiaTipTap — LiveView hook for TipTap rich text editor integration.
 *
 * Follows the established PhiaChart pattern: optional npm dependency via
 * `window.tiptap`. Falls back to the vanilla PhiaEditor engine (execCommand)
 * when TipTap is not installed.
 *
 * Setup with TipTap (optional):
 *   npm install @tiptap/core @tiptap/starter-kit @tiptap/extension-placeholder
 *   // in app.js:
 *   import { Editor } from "@tiptap/core"
 *   import StarterKit from "@tiptap/starter-kit"
 *   import Placeholder from "@tiptap/extension-placeholder"
 *   window.tiptap = { Editor, StarterKit, Placeholder }
 *
 * Setup without TipTap (vanilla fallback):
 *   import PhiaTipTap from "./hooks/tiptap_editor"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaTipTap } })
 *
 * Markup contract:
 *   - Hook root: phx-hook="PhiaTipTap", id, data-content (JSON string)
 *   - Required children: [data-tiptap-content] (editor mount point),
 *                         [data-tiptap-hidden] (hidden input for forms)
 *   - Optional attrs: data-placeholder, data-extensions (JSON array),
 *                      data-on-update (event name), data-on-selection (event name),
 *                      data-content-format ("json" or "html")
 */

const PhiaTipTap = {
  mounted() {
    this._editor = null;
    this._vanillaEditor = null;
    this._debounceTimer = null;
    this._throttleTimer = null;
    this._reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    this._contentEl = this.el.querySelector("[data-tiptap-content]");
    this._hiddenInput = this.el.querySelector("[data-tiptap-hidden]");

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
      const format = this.el.dataset.contentFormat || "json";
      if (format === "json") {
        this._hiddenInput.value = JSON.stringify(this._editor.getJSON());
      } else {
        this._hiddenInput.value = this._editor.getHTML();
      }
    }
  },

  destroyed() {
    if (this._debounceTimer) clearTimeout(this._debounceTimer);
    if (this._throttleTimer) clearTimeout(this._throttleTimer);

    if (this._editor) {
      this._editor.destroy();
      this._editor = null;
    }

    if (this._vanillaEditor) {
      this._vanillaEditor.destroy();
      this._vanillaEditor = null;
    }
  },

  // ===========================================================================
  // Initialization — TipTap or vanilla fallback
  // ===========================================================================

  _initEditor() {
    if (window.tiptap && window.tiptap.Editor) {
      this._initTipTap();
    } else if (window.PhiaEditor) {
      this._initVanilla();
    } else {
      // No editor engine available — show placeholder
      this._contentEl.innerHTML =
        '<p style="color: var(--color-muted-foreground); padding: 1rem;">' +
        "Install @tiptap/core for rich text editing, or include PhiaEditor for basic editing." +
        "</p>";
    }
  },

  _initTipTap() {
    const { Editor, StarterKit, Placeholder } = window.tiptap;
    const placeholder = this.el.dataset.placeholder || "";
    const initialContent = this._parseInitialContent();

    // Build extensions array
    const extensions = [StarterKit.configure({})];

    if (Placeholder) {
      extensions.push(
        Placeholder.configure({ placeholder })
      );
    }

    // Load additional extensions from data-extensions attr
    const extraExts = this._parseExtensions();
    extensions.push(...extraExts);

    this._editor = new Editor({
      element: this._contentEl,
      extensions,
      content: initialContent,

      onUpdate: ({ editor }) => {
        this._onContentUpdate(editor);
      },

      onSelectionUpdate: ({ editor }) => {
        this._onSelectionUpdate(editor);
      },

      onCreate: ({ editor }) => {
        // Sync hidden input on creation
        this._syncHiddenInput(editor);
      },
    });
  },

  _initVanilla() {
    const placeholder = this.el.dataset.placeholder || "";
    const initialContent = this.el.dataset.content || "";

    this._vanillaEditor = new window.PhiaEditor({
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
      onSelectionChange: (activeFormats) => {
        this._throttledSelectionPush(activeFormats);
      },
    });
  },

  // ===========================================================================
  // Content updates — debounced push to server
  // ===========================================================================

  _onContentUpdate(editor) {
    this._syncHiddenInput(editor);

    const format = this.el.dataset.contentFormat || "json";
    const payload = {
      json: JSON.stringify(editor.getJSON()),
      html: editor.getHTML(),
      word_count: this._countWords(editor.state.doc.textContent),
    };

    this._debouncedPush(payload);
  },

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

  _onSelectionUpdate(editor) {
    const activeMarks = [];
    const activeNodes = [];

    // Check marks
    const marks = ["bold", "italic", "underline", "strike", "code", "link"];
    marks.forEach((mark) => {
      if (editor.isActive(mark)) activeMarks.push(mark);
    });

    // Check nodes
    const nodes = ["paragraph", "heading", "bulletList", "orderedList", "blockquote", "codeBlock"];
    nodes.forEach((node) => {
      if (editor.isActive(node)) activeNodes.push(node);
    });

    // Get heading level if active
    let headingLevel = null;
    if (editor.isActive("heading")) {
      for (let i = 1; i <= 6; i++) {
        if (editor.isActive("heading", { level: i })) {
          headingLevel = i;
          break;
        }
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
    const editor = this._editor;
    if (!editor) {
      // Vanilla fallback commands
      if (this._vanillaEditor && typeof this._vanillaEditor[command] === "function") {
        this._vanillaEditor[command](attrs);
      }
      return;
    }

    const chain = editor.chain().focus();

    switch (command) {
      case "toggleBold":
        chain.toggleBold().run();
        break;
      case "toggleItalic":
        chain.toggleItalic().run();
        break;
      case "toggleUnderline":
        chain.toggleUnderline().run();
        break;
      case "toggleStrike":
        chain.toggleStrike().run();
        break;
      case "toggleCode":
        chain.toggleCode().run();
        break;
      case "toggleBulletList":
        chain.toggleBulletList().run();
        break;
      case "toggleOrderedList":
        chain.toggleOrderedList().run();
        break;
      case "toggleBlockquote":
        chain.toggleBlockquote().run();
        break;
      case "toggleCodeBlock":
        chain.toggleCodeBlock().run();
        break;
      case "setHeading":
        chain.toggleHeading({ level: attrs && attrs.level || 2 }).run();
        break;
      case "setParagraph":
        chain.setParagraph().run();
        break;
      case "setLink":
        if (attrs && attrs.href) {
          chain.setLink({ href: attrs.href, target: attrs.target }).run();
        }
        break;
      case "unsetLink":
        chain.unsetLink().run();
        break;
      case "undo":
        chain.undo().run();
        break;
      case "redo":
        chain.redo().run();
        break;
      case "setContent":
        if (attrs && attrs.content) {
          editor.commands.setContent(attrs.content);
        }
        break;
      case "insertContent":
        if (attrs && attrs.content) {
          chain.insertContent(attrs.content).run();
        }
        break;
      case "setTextAlign":
        if (attrs && attrs.alignment) {
          chain.setTextAlign(attrs.alignment).run();
        }
        break;
      case "setHorizontalRule":
        chain.setHorizontalRule().run();
        break;
      default:
        // Try to call the command directly on the editor
        if (typeof editor.commands[command] === "function") {
          editor.commands[command](attrs || {});
        }
    }
  },

  _setContent(content) {
    if (this._editor) {
      this._editor.commands.setContent(content);
      this._syncHiddenInput(this._editor);
    } else if (this._vanillaEditor) {
      const html = typeof content === "string" ? content : "";
      this._vanillaEditor.setContent(html);
    }
  },

  // ===========================================================================
  // Helpers
  // ===========================================================================

  _syncHiddenInput(editor) {
    if (!this._hiddenInput) return;
    const format = this.el.dataset.contentFormat || "json";
    if (format === "json") {
      this._hiddenInput.value = JSON.stringify(editor.getJSON());
    } else {
      this._hiddenInput.value = editor.getHTML();
    }
  },

  _parseInitialContent() {
    const raw = this.el.dataset.content;
    if (!raw) return "";
    try {
      return JSON.parse(raw);
    } catch {
      // If not valid JSON, treat as HTML string
      return raw;
    }
  },

  _parseExtensions() {
    const raw = this.el.dataset.extensions;
    if (!raw) return [];
    try {
      const names = JSON.parse(raw);
      if (!Array.isArray(names)) return [];
      return names
        .map((name) => {
          // Look for extension on window.tiptap (e.g. window.tiptap.Link)
          const ext = window.tiptap && window.tiptap[name];
          return ext ? ext.configure({}) : null;
        })
        .filter(Boolean);
    } catch {
      return [];
    }
  },

  _countWords(text) {
    if (!text) return 0;
    const trimmed = text.trim();
    if (!trimmed) return 0;
    return trimmed.split(/\s+/).length;
  },
};

export default PhiaTipTap;
