// PhiaUI Rich Text Editor — PhiaEditor engine + PhiaRichTextEditor hook
//
// Zero npm dependencies. Built on:
//   - contenteditable (editable area)
//   - document.execCommand() (formatting commands + native undo/redo)
//   - Selection API / window.getSelection() (isActive detection)
//   - Phoenix LiveView JS hook (LiveView integration)
//
// Registration in app.js:
//   import PhiaRichTextEditor from "./phia_hooks/rich_text_editor.js"
//   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaRichTextEditor } })

// =============================================================================
// PhiaEditor — vanilla JS rich text engine
// =============================================================================

class PhiaEditor {
  // ---------------------------------------------------------------------------
  // Constructor
  // AC: constructor({ element, content, placeholder, onUpdate, onSelectionChange })
  // ---------------------------------------------------------------------------

  constructor({ element, content = "", placeholder = "", onUpdate = null, onSelectionChange = null }) {
    this._el = element;
    this._onUpdate = onUpdate;
    this._onSelectionChange = onSelectionChange;

    // Make element editable
    this._el.setAttribute("contenteditable", "true");
    this._el.setAttribute("role", "textbox");
    this._el.setAttribute("aria-multiline", "true");

    // Placeholder support via data attribute + is-empty class
    // AC: placeholder via CSS ::before + data-placeholder + class is-empty
    if (placeholder) {
      this._el.setAttribute("data-placeholder", placeholder);
    }

    // Set initial content
    if (content) {
      this._el.innerHTML = content;
    }
    this._updateEmptyClass();

    // Bound handlers stored on `this` for cleanup in destroy()
    // AC: destroy() remove todos os event listeners
    this._handleInput = () => this._onInput();
    this._handleSelectionChange = () => this._onSelectionChanged();
    this._handleKeydown = (e) => this._onKeydown(e);
    this._handlePaste = (e) => this._onPaste(e);

    this._el.addEventListener("input", this._handleInput);
    this._el.addEventListener("keydown", this._handleKeydown);
    this._el.addEventListener("paste", this._handlePaste);
    document.addEventListener("selectionchange", this._handleSelectionChange);
  }

  // ---------------------------------------------------------------------------
  // Inline marks — execCommand-based
  // AC: toggleBold/toggleItalic/toggleUnderline/toggleStrike/toggleCode/setLink/unsetLink
  // ---------------------------------------------------------------------------

  toggleBold() {
    document.execCommand("bold", false, null);
    this._fireUpdate();
  }

  toggleItalic() {
    document.execCommand("italic", false, null);
    this._fireUpdate();
  }

  toggleUnderline() {
    document.execCommand("underline", false, null);
    this._fireUpdate();
  }

  toggleStrike() {
    document.execCommand("strikeThrough", false, null);
    this._fireUpdate();
  }

  // AC: toggleCode → insertHTML with <code>
  toggleCode() {
    if (this.isActive("code")) {
      // Unwrap: replace <code> wrapper with plain text
      const sel = window.getSelection();
      if (!sel || sel.rangeCount === 0) return;
      const range = sel.getRangeAt(0);
      const ancestor = range.commonAncestorContainer;
      const codeEl = ancestor.nodeType === Node.TEXT_NODE
        ? ancestor.parentElement.closest("code")
        : ancestor.closest("code");
      if (codeEl) {
        const text = document.createTextNode(codeEl.textContent);
        codeEl.replaceWith(text);
      }
    } else {
      const sel = window.getSelection();
      if (!sel || sel.rangeCount === 0) return;
      const selectedText = sel.toString();
      document.execCommand("insertHTML", false, `<code>${selectedText}</code>`);
    }
    this._fireUpdate();
  }

  // AC: setLink(href) → execCommand('createLink', href)
  setLink(href) {
    document.execCommand("createLink", false, href);
    this._fireUpdate();
  }

  // AC: unsetLink() → execCommand('unlink')
  unsetLink() {
    document.execCommand("unlink", false, null);
    this._fireUpdate();
  }

  // ---------------------------------------------------------------------------
  // Block nodes — execCommand('formatBlock', ...) based
  // AC: setHeading/setParagraph/toggleBulletList/toggleOrderedList/toggleBlockquote/toggleCodeBlock
  // ---------------------------------------------------------------------------

  // AC: setHeading(level) → execCommand('formatBlock', '<hN>')
  setHeading(level) {
    document.execCommand("formatBlock", false, `<h${level}>`);
    this._fireUpdate();
  }

  // AC: setParagraph() → execCommand('formatBlock', '<p>')
  setParagraph() {
    document.execCommand("formatBlock", false, "<p>");
    this._fireUpdate();
  }

  // AC: toggleBulletList() → execCommand('insertUnorderedList')
  toggleBulletList() {
    document.execCommand("insertUnorderedList", false, null);
    this._fireUpdate();
  }

  // AC: toggleOrderedList() → execCommand('insertOrderedList')
  toggleOrderedList() {
    document.execCommand("insertOrderedList", false, null);
    this._fireUpdate();
  }

  // AC: toggleBlockquote() → execCommand('formatBlock', '<blockquote>')
  toggleBlockquote() {
    document.execCommand("formatBlock", false, "<blockquote>");
    this._fireUpdate();
  }

  // AC: toggleCodeBlock() → execCommand('formatBlock', '<pre>')
  toggleCodeBlock() {
    document.execCommand("formatBlock", false, "<pre>");
    this._fireUpdate();
  }

  // ---------------------------------------------------------------------------
  // isActive — DOM tree traversal via Selection API
  // AC: isActive(format, attrs?) detection via parentElement chain + closest block
  // ---------------------------------------------------------------------------

  isActive(format, attrs = {}) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return false;

    const node = sel.anchorNode;
    if (!node) return false;

    const element = node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    if (!element || !this._el.contains(element)) return false;

    switch (format) {
      // Marks — walk parentElement chain checking tag names
      case "bold":
        return !!element.closest("strong, b");
      case "italic":
        return !!element.closest("em, i");
      case "underline":
        return !!element.closest("u");
      case "strike":
        return !!element.closest("s, strike");
      case "code":
        return !!element.closest("code");
      case "link":
        return !!element.closest("a[href]");

      // Nodes — check closest block element tag
      case "h1":
        return !!element.closest("h1");
      case "h2":
        return !!element.closest("h2");
      case "h3":
        return !!element.closest("h3");
      case "bulletList":
        return !!element.closest("ul");
      case "orderedList":
        return !!element.closest("ol");
      case "blockquote":
        return !!element.closest("blockquote");
      case "codeBlock":
        return !!element.closest("pre");
      case "paragraph":
        return !!element.closest("p");

      default:
        return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Content accessors
  // AC: getHTML() + setContent(html)
  // ---------------------------------------------------------------------------

  getHTML() {
    return this._el.innerHTML;
  }

  setContent(html) {
    this._el.innerHTML = html;
    this._updateEmptyClass();
    this._fireUpdate();
  }

  // ---------------------------------------------------------------------------
  // Undo / Redo
  // AC: undo()/redo() via execCommand
  // ---------------------------------------------------------------------------

  undo() {
    document.execCommand("undo", false, null);
    this._fireUpdate();
  }

  redo() {
    document.execCommand("redo", false, null);
    this._fireUpdate();
  }

  // ---------------------------------------------------------------------------
  // destroy — remove all event listeners (no memory leaks)
  // AC: destroy() removes todos os event listeners
  // ---------------------------------------------------------------------------

  destroy() {
    this._el.removeEventListener("input", this._handleInput);
    this._el.removeEventListener("keydown", this._handleKeydown);
    this._el.removeEventListener("paste", this._handlePaste);
    document.removeEventListener("selectionchange", this._handleSelectionChange);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  // AC: placeholder via is-empty class
  _updateEmptyClass() {
    const isEmpty = this._el.innerHTML === "" || this._el.innerHTML === "<br>";
    this._el.classList.toggle("is-empty", isEmpty);
  }

  _onInput() {
    this._updateEmptyClass();
    this._fireUpdate();
  }

  _fireUpdate() {
    if (this._onUpdate) {
      this._onUpdate(this.getHTML());
    }
  }

  _onSelectionChanged() {
    // Only fire when selection is inside this editor
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;
    const node = sel.anchorNode;
    if (!node || !this._el.contains(node)) return;

    if (this._onSelectionChange) {
      this._onSelectionChange();
    }
  }

  // AC: keyboard shortcuts Ctrl/Cmd+B, I, U, Z, Shift+Z
  _onKeydown(e) {
    const mod = e.ctrlKey || e.metaKey;
    if (!mod) return;

    switch (e.key.toLowerCase()) {
      case "b":
        e.preventDefault();
        this.toggleBold();
        break;
      case "i":
        e.preventDefault();
        this.toggleItalic();
        break;
      case "u":
        e.preventDefault();
        this.toggleUnderline();
        break;
      case "z":
        e.preventDefault();
        if (e.shiftKey) {
          this.redo();
        } else {
          this.undo();
        }
        break;
    }
  }

  // Sanitize paste to plain text to avoid bringing in external HTML garbage
  _onPaste(e) {
    e.preventDefault();
    const text = e.clipboardData ? e.clipboardData.getData("text/plain") : "";
    document.execCommand("insertText", false, text);
  }
}

// =============================================================================
// PhiaRichTextEditor — LiveView hook
// AC: mounted() + destroyed() lifecycle, bind [data-action] buttons,
//     update hidden input via onUpdate, update is-active classes via onSelectionChange
// =============================================================================

const PhiaRichTextEditor = {
  mounted() {
    // Find the editable area and hidden input scoped to this.el
    this._editorEl = this.el.querySelector("[data-phia-editor]");
    this._hiddenInput = this.el.querySelector("input[type=hidden]");

    if (!this._editorEl) return;

    const initialContent = this._editorEl.getAttribute("data-content") || "";
    const placeholder = this._editorEl.getAttribute("data-placeholder") || "";

    // Instantiate the PhiaEditor engine
    this._editor = new PhiaEditor({
      element: this._editorEl,
      content: initialContent,
      placeholder,
      onUpdate: (html) => {
        if (this._hiddenInput) {
          this._hiddenInput.value = html;
          // Dispatch input event so LiveView detects the change
          this._hiddenInput.dispatchEvent(new Event("input", { bubbles: true }));
        }
      },
      onSelectionChange: () => {
        this._updateActiveStates();
      },
    });

    // Bind toolbar buttons — [data-action] → editor command
    this._buttons = Array.from(this.el.querySelectorAll("[data-action]"));
    this._handleButtonClick = (e) => {
      const btn = e.currentTarget;
      const action = btn.getAttribute("data-action");
      const value = btn.getAttribute("data-value");
      this._dispatchAction(action, value);
    };
    this._buttons.forEach((btn) => {
      btn.addEventListener("click", this._handleButtonClick);
    });

    // Initial active state update
    this._updateActiveStates();
  },

  destroyed() {
    if (this._editor) {
      this._editor.destroy();
    }
    // Remove toolbar button listeners
    if (this._buttons) {
      this._buttons.forEach((btn) => {
        btn.removeEventListener("click", this._handleButtonClick);
      });
    }
  },

  // Map data-action values to PhiaEditor commands
  _dispatchAction(action, value) {
    if (!this._editor) return;

    switch (action) {
      case "bold":          this._editor.toggleBold(); break;
      case "italic":        this._editor.toggleItalic(); break;
      case "underline":     this._editor.toggleUnderline(); break;
      case "strike":        this._editor.toggleStrike(); break;
      case "code":          this._editor.toggleCode(); break;
      case "link":
        const href = prompt("URL:");
        if (href) this._editor.setLink(href);
        break;
      case "unlink":        this._editor.unsetLink(); break;
      case "h1":            this._editor.setHeading(1); break;
      case "h2":            this._editor.setHeading(2); break;
      case "h3":            this._editor.setHeading(3); break;
      case "paragraph":     this._editor.setParagraph(); break;
      case "bulletList":    this._editor.toggleBulletList(); break;
      case "orderedList":   this._editor.toggleOrderedList(); break;
      case "blockquote":    this._editor.toggleBlockquote(); break;
      case "codeBlock":     this._editor.toggleCodeBlock(); break;
      case "undo":          this._editor.undo(); break;
      case "redo":          this._editor.redo(); break;
    }

    // Re-focus editor after toolbar click
    this._editorEl.focus();
    this._updateActiveStates();
  },

  // Toggle `is-active` class on toolbar buttons based on current selection
  _updateActiveStates() {
    if (!this._editor || !this._buttons) return;

    this._buttons.forEach((btn) => {
      const action = btn.getAttribute("data-action");
      const isActive = this._editor.isActive(action);
      btn.classList.toggle("is-active", isActive);
      btn.setAttribute("aria-pressed", isActive ? "true" : "false");
    });
  },
};

export { PhiaEditor };
export default PhiaRichTextEditor;
