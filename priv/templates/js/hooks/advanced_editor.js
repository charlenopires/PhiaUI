/**
 * PhiaAdvancedEditor — Full-featured WYSIWYG editor hook.
 *
 * Inspired by TipTap (the most popular headless rich text editor, 2.5M+ weekly
 * npm downloads, built on ProseMirror). Transpiled to PhiaUI as a vanilla JS hook
 * using the PhiaEditor engine from rich_text_editor.js.
 *
 * This hook:
 *  1. Instantiates PhiaEditor on the contenteditable area (data-phia-editor)
 *  2. Wires all toolbar buttons via [data-action] attributes
 *  3. Syncs HTML to a hidden input on every change
 *  4. Manages the bubble menu (show/hide + active-state updates)
 *  5. Bridges the find-replace bar toggle (Ctrl+F)
 *  6. Bridges the link dialog (open/close, apply)
 *
 * HTML anatomy (rendered by advanced_editor/1):
 *   <div phx-hook="PhiaAdvancedEditor"
 *        data-editor-id="adv-1-content"
 *        data-bubble-id="adv-1-bubble"
 *        data-find-id="adv-1-find"
 *        data-link-id="adv-1-link">
 *     <!-- Find & replace bar -->
 *     <!-- Toolbar with [data-action] buttons -->
 *     <!-- Bubble menu -->
 *     <!-- contenteditable div#adv-1-content data-phia-editor -->
 *     <!-- Footer with word count -->
 *     <!-- Link dialog -->
 *     <!-- Hidden input -->
 *   </div>
 *
 * Depends on:
 *   - PhiaEditor class exported from rich_text_editor.js
 *   - PhiaBubbleMenu hook for the bubble menu element
 *
 * Registration in app.js:
 *   import PhiaAdvancedEditor from "./hooks/advanced_editor"
 *   import { PhiaEditor } from "./hooks/rich_text_editor"
 *   // Make PhiaEditor available globally for this hook:
 *   window.PhiaEditor = PhiaEditor
 *
 *   let liveSocket = new LiveSocket("/live", Socket, {
 *     hooks: {
 *       PhiaAdvancedEditor,
 *       PhiaBubbleMenu,
 *       PhiaEditorColorPicker,
 *       PhiaEditorDropdown,
 *       PhiaEditorFindReplace
 *     }
 *   })
 */
const PhiaAdvancedEditor = {
  mounted() {
    // Resolve sub-elements
    this._editorEl = document.getElementById(this.el.dataset.editorId);
    this._hiddenInput = this.el.querySelector("input[type='hidden']");
    this._bubbleEl = document.getElementById(this.el.dataset.bubbleId);
    this._findEl = document.getElementById(this.el.dataset.findId);
    this._linkEl = document.getElementById(this.el.dataset.linkId);

    if (!this._editorEl) return;

    const content = this._editorEl.dataset.content || "";
    const placeholder = this._editorEl.dataset.placeholder || "";

    // Instantiate the PhiaEditor engine
    const EditorClass = window.PhiaEditor || this._fallbackEditor();
    this._editor = new EditorClass({
      element: this._editorEl,
      content,
      placeholder,
      onUpdate: (html) => {
        if (this._hiddenInput) {
          this._hiddenInput.value = html;
          this._hiddenInput.dispatchEvent(new Event("input", { bubbles: true }));
        }
      },
      onSelectionChange: () => {
        this._updateActiveStates();
      },
    });

    // Collect all [data-action] buttons (toolbar + bubble)
    this._buttons = Array.from(this.el.querySelectorAll("[data-action]"));

    this._handleButtonClick = (e) => {
      const btn = e.target.closest("[data-action]");
      if (!btn || btn.disabled) return;
      const action = btn.dataset.action;
      this._dispatchAction(action);
    };
    this.el.addEventListener("click", this._handleButtonClick);

    // Keyboard shortcut: Ctrl/Cmd+F opens find bar
    this._onKeydown = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "f") {
        e.preventDefault();
        this._toggleFindBar();
      }
    };
    this._editorEl.addEventListener("keydown", this._onKeydown);

    // Link dialog: close on backdrop click
    if (this._linkEl) {
      this._linkEl.querySelector("[data-link-backdrop]")
        ?.addEventListener("click", () => this._closeLinkDialog());
      this._linkEl.querySelectorAll("[data-link-close]").forEach(btn =>
        btn.addEventListener("click", () => this._closeLinkDialog())
      );
      this._linkEl.querySelector("[data-link-submit]")
        ?.addEventListener("click", () => this._applyLink());
    }

    this._updateActiveStates();
  },

  destroyed() {
    if (this._editor) {
      this._editor.destroy();
    }
    this.el.removeEventListener("click", this._handleButtonClick);
    if (this._editorEl) {
      this._editorEl.removeEventListener("keydown", this._onKeydown);
    }
  },

  // Map data-action to editor commands
  _dispatchAction(action) {
    if (!this._editor) return;

    switch (action) {
      case "bold":        this._editor.toggleBold(); break;
      case "italic":      this._editor.toggleItalic(); break;
      case "underline":   this._editor.toggleUnderline(); break;
      case "strike":      this._editor.toggleStrike(); break;
      case "code":        this._editor.toggleCode(); break;
      case "link":        this._openLinkDialog(); return; // don't refocus yet
      case "unlink":      this._editor.unsetLink(); break;
      case "h1":          this._editor.setHeading(1); break;
      case "h2":          this._editor.setHeading(2); break;
      case "h3":          this._editor.setHeading(3); break;
      case "paragraph":   this._editor.setParagraph(); break;
      case "bulletList":  this._editor.toggleBulletList(); break;
      case "orderedList": this._editor.toggleOrderedList(); break;
      case "blockquote":  this._editor.toggleBlockquote(); break;
      case "codeBlock":   this._editor.toggleCodeBlock(); break;
      case "undo":        this._editor.undo(); break;
      case "redo":        this._editor.redo(); break;
      case "findReplace": this._toggleFindBar(); return;
      default: break;
    }

    this._editorEl.focus();
    this._updateActiveStates();
  },

  _updateActiveStates() {
    if (!this._editor || !this._buttons) return;
    this._buttons.forEach(btn => {
      const action = btn.dataset.action;
      const active = this._editor.isActive(action);
      btn.classList.toggle("is-active", active);
      btn.classList.toggle("bg-accent", active);
      btn.setAttribute("aria-pressed", active ? "true" : "false");
    });
  },

  _toggleFindBar() {
    if (!this._findEl) return;
    const isHidden = this._findEl.classList.contains("hidden");
    if (isHidden) {
      this._findEl.classList.remove("hidden");
      this._findEl.classList.add("phia-find-bar-open");
      this._findEl.querySelector("[data-find-input]")?.focus();
    } else {
      this._findEl.classList.add("hidden");
      this._findEl.classList.remove("phia-find-bar-open");
      this._editorEl.focus();
    }
  },

  _openLinkDialog() {
    if (!this._linkEl) {
      // Fallback to browser prompt
      const href = prompt("URL:");
      if (href && this._editor) this._editor.setLink(href);
      this._editorEl.focus();
      this._updateActiveStates();
      return;
    }
    // Pre-fill with current link if cursor is inside one
    const sel = window.getSelection();
    if (sel && sel.rangeCount > 0) {
      const node = sel.anchorNode;
      const el = node?.nodeType === Node.TEXT_NODE ? node.parentElement : node;
      const anchor = el?.closest("a[href]");
      if (anchor) {
        const urlInput = this._linkEl.querySelector("[data-link-url]");
        const titleInput = this._linkEl.querySelector("[data-link-title]");
        if (urlInput) urlInput.value = anchor.href;
        if (titleInput) titleInput.value = anchor.title || "";
      }
    }
    this._linkEl.classList.remove("hidden");
    this._linkEl.querySelector("[data-link-url]")?.focus();
  },

  _closeLinkDialog() {
    if (this._linkEl) {
      this._linkEl.classList.add("hidden");
      // Clear inputs
      const urlInput = this._linkEl.querySelector("[data-link-url]");
      const titleInput = this._linkEl.querySelector("[data-link-title]");
      const newTab = this._linkEl.querySelector("[data-link-new-tab]");
      if (urlInput) urlInput.value = "";
      if (titleInput) titleInput.value = "";
      if (newTab) newTab.checked = false;
    }
    this._editorEl.focus();
  },

  _applyLink() {
    const urlInput = this._linkEl?.querySelector("[data-link-url]");
    const titleInput = this._linkEl?.querySelector("[data-link-title]");
    const newTabInput = this._linkEl?.querySelector("[data-link-new-tab]");
    const href = urlInput?.value?.trim();

    if (href && this._editor) {
      this._editor.setLink(href);
      // Apply title and target via DOM manipulation
      const sel = window.getSelection();
      if (sel && sel.rangeCount > 0) {
        const anchor = sel.anchorNode?.parentElement?.closest("a[href]");
        if (anchor) {
          if (titleInput?.value) anchor.title = titleInput.value;
          if (newTabInput?.checked) anchor.target = "_blank";
        }
      }
    }
    this._closeLinkDialog();
    this._updateActiveStates();
  },

  // Minimal fallback editor if PhiaEditor is not globally available
  _fallbackEditor() {
    return class FallbackEditor {
      constructor({ element, content, onUpdate, onSelectionChange }) {
        this._el = element;
        this._el.setAttribute("contenteditable", "true");
        if (content) this._el.innerHTML = content;
        this._onUpdate = onUpdate;
        this._onSel = onSelectionChange;
        this._handleInput = () => {
          if (this._onUpdate) this._onUpdate(this._el.innerHTML);
        };
        this._handleSel = () => {
          const sel = window.getSelection();
          if (sel && sel.rangeCount > 0 && this._el.contains(sel.anchorNode)) {
            if (this._onSel) this._onSel();
          }
        };
        this._el.addEventListener("input", this._handleInput);
        document.addEventListener("selectionchange", this._handleSel);
      }
      toggleBold() { document.execCommand("bold"); this._handleInput(); }
      toggleItalic() { document.execCommand("italic"); this._handleInput(); }
      toggleUnderline() { document.execCommand("underline"); this._handleInput(); }
      toggleStrike() { document.execCommand("strikeThrough"); this._handleInput(); }
      toggleCode() { this._handleInput(); }
      setLink(href) { document.execCommand("createLink", false, href); this._handleInput(); }
      unsetLink() { document.execCommand("unlink"); this._handleInput(); }
      setHeading(n) { document.execCommand("formatBlock", false, `<h${n}>`); this._handleInput(); }
      setParagraph() { document.execCommand("formatBlock", false, "<p>"); this._handleInput(); }
      toggleBulletList() { document.execCommand("insertUnorderedList"); this._handleInput(); }
      toggleOrderedList() { document.execCommand("insertOrderedList"); this._handleInput(); }
      toggleBlockquote() { document.execCommand("formatBlock", false, "<blockquote>"); this._handleInput(); }
      toggleCodeBlock() { document.execCommand("formatBlock", false, "<pre>"); this._handleInput(); }
      undo() { document.execCommand("undo"); this._handleInput(); }
      redo() { document.execCommand("redo"); this._handleInput(); }
      isActive() { return false; }
      destroy() {
        this._el.removeEventListener("input", this._handleInput);
        document.removeEventListener("selectionchange", this._handleSel);
      }
    };
  },
};

export default PhiaAdvancedEditor;
