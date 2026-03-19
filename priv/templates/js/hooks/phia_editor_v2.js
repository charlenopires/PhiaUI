/**
 * PhiaEditorV2 — Modern rich text engine for PhiaUI.
 *
 * Replaces document.execCommand() with direct DOM manipulation via
 * Range/Selection APIs. Keeps contenteditable but uses the same
 * approach as TipTap/ProseMirror, Lexical, and Slate.
 *
 * Zero npm dependencies. Built on:
 *   - contenteditable (editable area)
 *   - Range / Selection API (formatting + cursor management)
 *   - MutationObserver (block tracking)
 *   - Snapshot-based undo/redo (PhiaHistory)
 *   - Pattern-based input rules (PhiaInputRules)
 *   - Sanitized paste pipeline (PhiaPasteRules)
 *   - Block operations with UUID tracking (PhiaBlockOps)
 *
 * Registration in app.js:
 *   import PhiaEditorV2 from "./hooks/phia_editor_v2"
 *   // Use directly: new PhiaEditorV2({ element, content, ... })
 *   // Or via window.PhiaEditorV2
 *
 * @module PhiaEditorV2
 */

// =============================================================================
// Utilities
// =============================================================================

/**
 * Generate a UUID v4 string.
 * Uses crypto.randomUUID() where available, falls back to manual generation.
 * @returns {string}
 */
function generateUUID() {
  if (typeof crypto !== "undefined" && typeof crypto.randomUUID === "function") {
    return crypto.randomUUID();
  }
  // Fallback for older browsers
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    const v = c === "x" ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

/**
 * Escape HTML special characters for safe insertion.
 * @param {string} str
 * @returns {string}
 */
function escapeHTML(str) {
  const div = document.createElement("div");
  div.appendChild(document.createTextNode(str));
  return div.innerHTML;
}

/**
 * Check if the user prefers reduced motion.
 * @returns {boolean}
 */
function prefersReducedMotion() {
  return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
}

/**
 * Set of block-level tag names used throughout the editor.
 * @type {Set<string>}
 */
const BLOCK_TAGS = new Set([
  "P", "H1", "H2", "H3", "H4", "H5", "H6",
  "BLOCKQUOTE", "PRE", "UL", "OL", "LI",
  "DIV", "FIGURE", "FIGCAPTION", "HR", "TABLE",
  "THEAD", "TBODY", "TR", "TD", "TH",
  "DETAILS", "SUMMARY", "SECTION", "ASIDE",
]);

/**
 * Set of allowed tags for paste sanitization.
 * @type {Set<string>}
 */
const PASTE_ALLOWLIST = new Set([
  "B", "STRONG", "I", "EM", "U", "S", "A",
  "P", "H1", "H2", "H3", "H4", "H5", "H6",
  "UL", "OL", "LI", "BR", "BLOCKQUOTE",
  "PRE", "CODE", "TABLE", "TR", "TD", "TH",
  "THEAD", "TBODY", "IMG", "FIGURE", "FIGCAPTION",
  "SUP", "SUB", "MARK", "SPAN", "DIV",
  "HR", "DETAILS", "SUMMARY",
]);

/**
 * Allowed attributes per tag for paste sanitization.
 * @type {Object<string, Set<string>>}
 */
const PASTE_ALLOWED_ATTRS = {
  A: new Set(["href", "title", "target", "rel"]),
  IMG: new Set(["src", "alt", "width", "height"]),
  TD: new Set(["colspan", "rowspan"]),
  TH: new Set(["colspan", "rowspan"]),
  SPAN: new Set(["style", "class"]),
  MARK: new Set(["style", "class", "data-color"]),
};

// =============================================================================
// PhiaHistory — Snapshot-based undo/redo
// =============================================================================

/**
 * Snapshot-based undo/redo system storing {html, selectionRange} tuples.
 * Debounced batching: 300ms idle creates a new snapshot.
 * Maximum 100 entries to bound memory usage.
 */
class PhiaHistory {
  /**
   * @param {Object} opts
   * @param {number} [opts.maxEntries=100] - Maximum history stack size
   * @param {number} [opts.debounceMs=300] - Idle time before creating new snapshot
   */
  constructor({ maxEntries = 100, debounceMs = 300 } = {}) {
    /** @private */
    this._stack = [];
    /** @private */
    this._pointer = -1;
    /** @private */
    this._maxEntries = maxEntries;
    /** @private */
    this._debounceMs = debounceMs;
    /** @private */
    this._timer = null;
    /** @private */
    this._lastPushedHTML = null;
  }

  /**
   * Push a snapshot onto the history stack.
   * Debounced: only commits after idle period. Duplicate HTML is ignored.
   * @param {string} html - Current editor HTML
   * @param {Object|null} selectionRange - Serialized selection {startPath, startOffset, endPath, endOffset}
   */
  push(html, selectionRange) {
    if (this._timer) clearTimeout(this._timer);
    this._timer = setTimeout(() => {
      this._commit(html, selectionRange);
    }, this._debounceMs);
  }

  /**
   * Force an immediate snapshot without debouncing.
   * @param {string} html
   * @param {Object|null} selectionRange
   */
  pushImmediate(html, selectionRange) {
    if (this._timer) clearTimeout(this._timer);
    this._commit(html, selectionRange);
  }

  /** @private */
  _commit(html, selectionRange) {
    // Skip duplicate snapshots
    if (html === this._lastPushedHTML) return;
    this._lastPushedHTML = html;

    // Truncate any redo entries beyond pointer
    this._stack = this._stack.slice(0, this._pointer + 1);

    // Push new snapshot
    this._stack.push({ html, selectionRange });
    this._pointer = this._stack.length - 1;

    // Enforce max entries
    if (this._stack.length > this._maxEntries) {
      const excess = this._stack.length - this._maxEntries;
      this._stack.splice(0, excess);
      this._pointer -= excess;
    }
  }

  /**
   * Undo: move pointer back one step.
   * @returns {{ html: string, selectionRange: Object|null }|null}
   */
  undo() {
    if (!this.canUndo()) return null;
    this._pointer--;
    return this._stack[this._pointer];
  }

  /**
   * Redo: move pointer forward one step.
   * @returns {{ html: string, selectionRange: Object|null }|null}
   */
  redo() {
    if (!this.canRedo()) return null;
    this._pointer++;
    return this._stack[this._pointer];
  }

  /**
   * Whether undo is available.
   * @returns {boolean}
   */
  canUndo() {
    return this._pointer > 0;
  }

  /**
   * Whether redo is available.
   * @returns {boolean}
   */
  canRedo() {
    return this._pointer < this._stack.length - 1;
  }

  /**
   * Clear the entire history stack.
   */
  clear() {
    this._stack = [];
    this._pointer = -1;
    this._lastPushedHTML = null;
    if (this._timer) clearTimeout(this._timer);
  }

  /**
   * Destroy the history instance, clearing timers.
   */
  destroy() {
    if (this._timer) clearTimeout(this._timer);
    this._stack = [];
  }
}

// =============================================================================
// PhiaInputRules — Pattern-based input rules
// =============================================================================

/**
 * Runs on every `input` event, pattern-matching typed text against rules.
 * Supports markdown-like shortcuts and smart typography.
 * IME guard: skips processing during CJK composition.
 */
class PhiaInputRules {
  /**
   * @param {HTMLElement} element - The contenteditable element
   * @param {PhiaEditorV2} editor - The editor instance for command dispatch
   */
  constructor(element, editor) {
    /** @private */
    this._el = element;
    /** @private */
    this._editor = editor;
    /** @private */
    this._rules = [];
    /** @private */
    this._composing = false;

    this._initDefaultRules();
    this._initSmartTypography();

    // IME composition tracking
    /** @private */
    this._onCompositionStart = () => { this._composing = true; };
    /** @private */
    this._onCompositionEnd = () => { this._composing = false; };

    this._el.addEventListener("compositionstart", this._onCompositionStart);
    this._el.addEventListener("compositionend", this._onCompositionEnd);
  }

  /**
   * Add a custom input rule.
   * @param {{ regex: RegExp, handler: function(match: Array, range: Range): void }} rule
   */
  addRule(rule) {
    this._rules.push(rule);
  }

  /**
   * Process an input event. Called by the editor on each input.
   * @param {InputEvent} e
   */
  process(e) {
    if (this._composing) return;
    if (e && e.isComposing) return;

    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;
    if (!sel.isCollapsed) return;

    const range = sel.getRangeAt(0);
    const textNode = range.startContainer;
    if (textNode.nodeType !== Node.TEXT_NODE) return;
    if (!this._el.contains(textNode)) return;

    const text = textNode.textContent;
    const offset = range.startOffset;

    // Text up to cursor for block rules
    const textBefore = text.substring(0, offset);

    for (const rule of this._rules) {
      const match = textBefore.match(rule.regex);
      if (match) {
        const handled = rule.handler(match, range, textNode, textBefore);
        if (handled !== false) return; // Stop on first match
      }
    }
  }

  /** @private */
  _initDefaultRules() {
    // Heading rules: # Space at start of block
    for (let level = 6; level >= 1; level--) {
      const prefix = "#".repeat(level);
      const regex = new RegExp(`^${prefix}\\s$`);
      this._rules.push({
        regex,
        handler: (match, range, textNode) => {
          return this._convertBlockPrefix(match[0], `h${level}`, textNode, range);
        },
      });
    }

    // Bullet list: - or * at start
    this._rules.push({
      regex: /^[-*]\s$/,
      handler: (match, range, textNode) => {
        return this._convertToList("ul", match[0], textNode, range);
      },
    });

    // Ordered list: 1. at start
    this._rules.push({
      regex: /^\d+\.\s$/,
      handler: (match, range, textNode) => {
        return this._convertToList("ol", match[0], textNode, range);
      },
    });

    // Blockquote: > at start
    this._rules.push({
      regex: /^>\s$/,
      handler: (match, range, textNode) => {
        return this._convertBlockPrefix(match[0], "blockquote", textNode, range);
      },
    });

    // Horizontal rule: ---
    this._rules.push({
      regex: /^---$/,
      handler: (match, range, textNode) => {
        const block = this._getBlockParent(textNode);
        if (!block) return false;

        const hr = document.createElement("hr");
        const p = document.createElement("p");
        p.innerHTML = "<br>";

        block.replaceWith(hr);
        hr.after(p);

        // Move cursor to the new paragraph
        const newRange = document.createRange();
        newRange.setStart(p, 0);
        newRange.collapse(true);
        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(newRange);

        this._editor._fireUpdate();
        return true;
      },
    });

    // Code block: ``` at start
    this._rules.push({
      regex: /^```$/,
      handler: (match, range, textNode) => {
        const block = this._getBlockParent(textNode);
        if (!block) return false;

        const pre = document.createElement("pre");
        const code = document.createElement("code");
        code.innerHTML = "<br>";
        pre.appendChild(code);

        block.replaceWith(pre);

        const newRange = document.createRange();
        newRange.setStart(code, 0);
        newRange.collapse(true);
        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(newRange);

        this._editor._fireUpdate();
        return true;
      },
    });

    // Task list: [] at start
    this._rules.push({
      regex: /^\[\]\s$/,
      handler: (match, range, textNode) => {
        const block = this._getBlockParent(textNode);
        if (!block) return false;

        const ul = document.createElement("ul");
        ul.setAttribute("data-type", "taskList");
        ul.style.listStyle = "none";
        ul.style.paddingLeft = "0";

        const li = document.createElement("li");
        li.setAttribute("data-type", "taskItem");
        li.setAttribute("data-checked", "false");

        const checkbox = document.createElement("input");
        checkbox.type = "checkbox";
        checkbox.style.marginRight = "0.5em";
        checkbox.addEventListener("change", () => {
          li.setAttribute("data-checked", checkbox.checked ? "true" : "false");
          this._editor._fireUpdate();
        });

        const textSpan = document.createElement("span");
        textSpan.setAttribute("contenteditable", "true");
        textSpan.innerHTML = "<br>";

        li.appendChild(checkbox);
        li.appendChild(textSpan);
        ul.appendChild(li);

        block.replaceWith(ul);

        const newRange = document.createRange();
        newRange.setStart(textSpan, 0);
        newRange.collapse(true);
        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(newRange);

        this._editor._fireUpdate();
        return true;
      },
    });

    // Inline bold: **text**
    this._rules.push({
      regex: /\*\*(.+?)\*\*$/,
      handler: (match, range, textNode, textBefore) => {
        return this._wrapInlineMark(match, textNode, range, textBefore, "strong");
      },
    });

    // Inline italic: *text*
    this._rules.push({
      regex: /(?<!\*)\*([^\*]+?)\*$/,
      handler: (match, range, textNode, textBefore) => {
        return this._wrapInlineMark(match, textNode, range, textBefore, "em");
      },
    });

    // Inline code: `text`
    this._rules.push({
      regex: /`([^`]+?)`$/,
      handler: (match, range, textNode, textBefore) => {
        return this._wrapInlineMark(match, textNode, range, textBefore, "code");
      },
    });
  }

  /** @private */
  _initSmartTypography() {
    // Smart open/close double quotes
    this._rules.push({
      regex: /"$/,
      handler: (match, range, textNode, textBefore) => {
        const charBefore = textBefore.length > 1 ? textBefore[textBefore.length - 2] : "";
        const isOpen = !charBefore || /\s/.test(charBefore);
        const replacement = isOpen ? "\u201C" : "\u201D"; // Left or right double quote
        return this._replaceLastChar(textNode, range, replacement);
      },
    });

    // Em dash: -- at end
    this._rules.push({
      regex: /--$/,
      handler: (match, range, textNode) => {
        const offset = range.startOffset;
        textNode.textContent =
          textNode.textContent.substring(0, offset - 2) +
          "\u2014" +
          textNode.textContent.substring(offset);
        const newRange = document.createRange();
        newRange.setStart(textNode, offset - 1);
        newRange.collapse(true);
        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(newRange);
        return true;
      },
    });

    // Ellipsis: ...
    this._rules.push({
      regex: /\.\.\.$/,
      handler: (match, range, textNode) => {
        const offset = range.startOffset;
        textNode.textContent =
          textNode.textContent.substring(0, offset - 3) +
          "\u2026" +
          textNode.textContent.substring(offset);
        const newRange = document.createRange();
        newRange.setStart(textNode, offset - 2);
        newRange.collapse(true);
        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(newRange);
        return true;
      },
    });

    // Copyright: (c) or (C)
    this._rules.push({
      regex: /\(c\)$/i,
      handler: (match, range, textNode) => {
        return this._replaceTrailing(textNode, range, 3, "\u00A9");
      },
    });

    // Trademark: (tm) or (TM)
    this._rules.push({
      regex: /\(tm\)$/i,
      handler: (match, range, textNode) => {
        return this._replaceTrailing(textNode, range, 4, "\u2122");
      },
    });

    // Registered: (r) or (R)
    this._rules.push({
      regex: /\(r\)$/i,
      handler: (match, range, textNode) => {
        return this._replaceTrailing(textNode, range, 3, "\u00AE");
      },
    });
  }

  /** @private */
  _replaceLastChar(textNode, range, replacement) {
    const offset = range.startOffset;
    textNode.textContent =
      textNode.textContent.substring(0, offset - 1) +
      replacement +
      textNode.textContent.substring(offset);
    const newRange = document.createRange();
    newRange.setStart(textNode, offset);
    newRange.collapse(true);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(newRange);
    return true;
  }

  /** @private */
  _replaceTrailing(textNode, range, count, replacement) {
    const offset = range.startOffset;
    textNode.textContent =
      textNode.textContent.substring(0, offset - count) +
      replacement +
      textNode.textContent.substring(offset);
    const newRange = document.createRange();
    newRange.setStart(textNode, offset - count + replacement.length);
    newRange.collapse(true);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(newRange);
    return true;
  }

  /** @private */
  _getBlockParent(node) {
    let current = node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    while (current && current !== this._el) {
      if (BLOCK_TAGS.has(current.tagName)) return current;
      current = current.parentElement;
    }
    return null;
  }

  /** @private */
  _convertBlockPrefix(matchText, tagName, textNode, range) {
    const block = this._getBlockParent(textNode);
    if (!block) return false;

    // Only convert if the text is at the start of the block
    const blockText = block.textContent;
    if (!blockText.startsWith(matchText)) return false;

    const newEl = document.createElement(tagName);
    const remaining = blockText.substring(matchText.length);
    newEl.textContent = remaining || "";
    if (!remaining) newEl.innerHTML = "<br>";

    // Assign block ID
    newEl.setAttribute("data-block-id", generateUUID());

    block.replaceWith(newEl);

    // Place cursor at start of new element
    const newRange = document.createRange();
    if (newEl.firstChild) {
      newRange.setStart(newEl.firstChild, 0);
    } else {
      newRange.setStart(newEl, 0);
    }
    newRange.collapse(true);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._editor._fireUpdate();
    return true;
  }

  /** @private */
  _convertToList(listType, matchText, textNode, range) {
    const block = this._getBlockParent(textNode);
    if (!block) return false;

    const blockText = block.textContent;
    if (!blockText.startsWith(matchText)) return false;

    const list = document.createElement(listType);
    const li = document.createElement("li");
    const remaining = blockText.substring(matchText.length);
    li.textContent = remaining || "";
    if (!remaining) li.innerHTML = "<br>";
    li.setAttribute("data-block-id", generateUUID());
    list.appendChild(li);
    list.setAttribute("data-block-id", generateUUID());

    block.replaceWith(list);

    const newRange = document.createRange();
    if (li.firstChild) {
      newRange.setStart(li.firstChild, 0);
    } else {
      newRange.setStart(li, 0);
    }
    newRange.collapse(true);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._editor._fireUpdate();
    return true;
  }

  /** @private */
  _wrapInlineMark(match, textNode, range, textBefore, tag) {
    const fullMatch = match[0];
    const content = match[1];
    const offset = range.startOffset;
    const matchStart = textBefore.lastIndexOf(fullMatch);

    if (matchStart < 0) return false;

    const before = textNode.textContent.substring(0, matchStart);
    const after = textNode.textContent.substring(offset);

    // Build new nodes: textBefore + <tag>content</tag> + textAfter
    const parent = textNode.parentNode;
    const frag = document.createDocumentFragment();

    if (before) {
      frag.appendChild(document.createTextNode(before));
    }

    const markEl = document.createElement(tag);
    markEl.textContent = content;
    frag.appendChild(markEl);

    // Add a zero-width space after mark so cursor can escape
    const afterNode = document.createTextNode(after || "\u200B");
    frag.appendChild(afterNode);

    parent.replaceChild(frag, textNode);

    // Place cursor after the mark
    const newRange = document.createRange();
    newRange.setStart(afterNode, after ? 0 : 1);
    newRange.collapse(true);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._editor._fireUpdate();
    return true;
  }

  /**
   * Destroy the input rules instance, removing event listeners.
   */
  destroy() {
    this._el.removeEventListener("compositionstart", this._onCompositionStart);
    this._el.removeEventListener("compositionend", this._onCompositionEnd);
    this._rules = [];
  }
}

// =============================================================================
// PhiaPasteRules — Sanitized paste pipeline
// =============================================================================

/**
 * Handles paste events with a multi-step pipeline:
 * 1. URL pasted on selected text -> wrap in anchor
 * 2. text/html in clipboard -> sanitize through allowlist
 * 3. Image data in clipboard -> fire editor:paste-image event
 * 4. Markdown patterns detected -> convert to rich text
 * 5. Fallback: sanitized plain text
 */
class PhiaPasteRules {
  /**
   * @param {HTMLElement} element - The contenteditable element
   * @param {PhiaEditorV2} editor - The editor instance
   */
  constructor(element, editor) {
    /** @private */
    this._el = element;
    /** @private */
    this._editor = editor;
  }

  /**
   * Process a paste event through the pipeline.
   * @param {ClipboardEvent} e
   */
  process(e) {
    e.preventDefault();

    const clipboardData = e.clipboardData;
    if (!clipboardData) return;

    const sel = window.getSelection();
    const hasSelection = sel && !sel.isCollapsed;
    const plainText = clipboardData.getData("text/plain") || "";
    const htmlText = clipboardData.getData("text/html") || "";

    // Step 1: URL pasted onto selected text -> wrap in link
    if (hasSelection && this._isURL(plainText)) {
      this._wrapSelectionInLink(plainText);
      return;
    }

    // Step 2: Image data in clipboard -> fire custom event
    if (clipboardData.items) {
      for (let i = 0; i < clipboardData.items.length; i++) {
        const item = clipboardData.items[i];
        if (item.type.startsWith("image/")) {
          const file = item.getAsFile();
          if (file) {
            this._el.dispatchEvent(
              new CustomEvent("editor:paste-image", {
                bubbles: true,
                detail: { file, type: item.type },
              })
            );
            return;
          }
        }
      }
    }

    // Step 3: HTML in clipboard -> sanitize and insert
    if (htmlText) {
      const sanitized = this._sanitizeHTML(htmlText);
      this._insertHTMLAtCursor(sanitized);
      return;
    }

    // Step 4: Detect markdown patterns in plain text
    if (this._hasMarkdownPatterns(plainText)) {
      const converted = this._markdownToHTML(plainText);
      this._insertHTMLAtCursor(converted);
      return;
    }

    // Step 5: Fallback -> sanitized plain text
    this._insertPlainText(plainText);
  }

  /** @private */
  _isURL(text) {
    if (!text) return false;
    const trimmed = text.trim();
    try {
      const url = new URL(trimmed);
      return url.protocol === "http:" || url.protocol === "https:";
    } catch {
      return false;
    }
  }

  /** @private */
  _wrapSelectionInLink(url) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    const range = sel.getRangeAt(0);
    const selectedText = range.toString();

    const link = document.createElement("a");
    link.href = url;
    link.target = "_blank";
    link.rel = "noopener noreferrer";
    link.textContent = selectedText;

    range.deleteContents();
    range.insertNode(link);

    // Move cursor after the link
    const newRange = document.createRange();
    newRange.setStartAfter(link);
    newRange.collapse(true);
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._editor._fireUpdate();
  }

  /** @private */
  _sanitizeHTML(html) {
    const template = document.createElement("template");
    template.innerHTML = html;
    const frag = template.content;

    this._sanitizeNode(frag);
    const div = document.createElement("div");
    div.appendChild(frag.cloneNode(true));
    return div.innerHTML;
  }

  /** @private */
  _sanitizeNode(node) {
    const toRemove = [];

    for (const child of node.childNodes) {
      if (child.nodeType === Node.ELEMENT_NODE) {
        if (!PASTE_ALLOWLIST.has(child.tagName)) {
          // Replace disallowed tags with their text content
          const text = document.createTextNode(child.textContent);
          toRemove.push({ node: child, replacement: text });
        } else {
          // Remove disallowed attributes
          const allowed = PASTE_ALLOWED_ATTRS[child.tagName] || new Set();
          const attrs = Array.from(child.attributes);
          for (const attr of attrs) {
            if (!allowed.has(attr.name)) {
              child.removeAttribute(attr.name);
            }
          }
          // Recursively sanitize children
          this._sanitizeNode(child);
        }
      } else if (child.nodeType === Node.COMMENT_NODE) {
        toRemove.push({ node: child, replacement: null });
      }
    }

    for (const { node: target, replacement } of toRemove) {
      if (replacement) {
        target.parentNode.replaceChild(replacement, target);
      } else {
        target.parentNode.removeChild(target);
      }
    }
  }

  /** @private */
  _hasMarkdownPatterns(text) {
    if (!text) return false;
    // Detect common markdown markers
    return /^#{1,6}\s|^\s*[-*+]\s|^\s*\d+\.\s|^\s*>/m.test(text) ||
           /\*\*.+?\*\*|`.+?`|\[.+?\]\(.+?\)/.test(text);
  }

  /** @private */
  _markdownToHTML(text) {
    let html = escapeHTML(text);

    // Convert line-by-line block patterns
    html = html.split("\n").map((line) => {
      // Headings
      const headingMatch = line.match(/^(#{1,6})\s+(.+)$/);
      if (headingMatch) {
        const level = headingMatch[1].length;
        return `<h${level}>${headingMatch[2]}</h${level}>`;
      }
      // Bullet list items
      if (/^\s*[-*+]\s+(.+)$/.test(line)) {
        const content = line.replace(/^\s*[-*+]\s+/, "");
        return `<li>${content}</li>`;
      }
      // Ordered list items
      if (/^\s*\d+\.\s+(.+)$/.test(line)) {
        const content = line.replace(/^\s*\d+\.\s+/, "");
        return `<li>${content}</li>`;
      }
      // Blockquote
      if (/^\s*>\s+(.+)$/.test(line)) {
        const content = line.replace(/^\s*>\s+/, "");
        return `<blockquote>${content}</blockquote>`;
      }
      // Horizontal rule
      if (/^---+$/.test(line.trim())) {
        return "<hr>";
      }
      // Regular paragraph
      return line ? `<p>${line}</p>` : "";
    }).join("");

    // Wrap consecutive <li> in <ul>
    html = html.replace(/(<li>.*?<\/li>)+/g, (match) => `<ul>${match}</ul>`);

    // Inline patterns
    html = html.replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>");
    html = html.replace(/\*(.+?)\*/g, "<em>$1</em>");
    html = html.replace(/`(.+?)`/g, "<code>$1</code>");
    html = html.replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2">$1</a>');

    return html;
  }

  /** @private */
  _insertHTMLAtCursor(html) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    const range = sel.getRangeAt(0);
    range.deleteContents();

    const template = document.createElement("template");
    template.innerHTML = html;
    const frag = template.content;

    // Track last inserted node for cursor positioning
    const lastChild = frag.lastChild;
    range.insertNode(frag);

    if (lastChild) {
      const newRange = document.createRange();
      newRange.setStartAfter(lastChild);
      newRange.collapse(true);
      sel.removeAllRanges();
      sel.addRange(newRange);
    }

    this._editor._fireUpdate();
  }

  /** @private */
  _insertPlainText(text) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    const range = sel.getRangeAt(0);
    range.deleteContents();

    // Convert newlines to <br> and insert as HTML
    const lines = text.split("\n");
    const frag = document.createDocumentFragment();

    lines.forEach((line, i) => {
      if (line) {
        frag.appendChild(document.createTextNode(line));
      }
      if (i < lines.length - 1) {
        frag.appendChild(document.createElement("br"));
      }
    });

    const lastNode = frag.lastChild;
    range.insertNode(frag);

    if (lastNode) {
      const newRange = document.createRange();
      newRange.setStartAfter(lastNode);
      newRange.collapse(true);
      sel.removeAllRanges();
      sel.addRange(newRange);
    }

    this._editor._fireUpdate();
  }

  /**
   * Destroy the paste rules instance.
   */
  destroy() {
    // No event listeners owned by this class (editor binds paste)
  }
}

// =============================================================================
// PhiaBlockOps — Block-level operations with UUID tracking
// =============================================================================

/**
 * Manages block-level elements within the editor.
 * Assigns data-block-id (UUID) to every block-level element.
 * Uses MutationObserver to track new blocks.
 */
class PhiaBlockOps {
  /**
   * @param {HTMLElement} element - The contenteditable element
   * @param {PhiaEditorV2} editor - The editor instance
   */
  constructor(element, editor) {
    /** @private */
    this._el = element;
    /** @private */
    this._editor = editor;
    /** @private */
    this._observer = null;

    this._assignBlockIds();
    this._startObserving();
  }

  /**
   * Get the block element at the current cursor position.
   * @returns {HTMLElement|null}
   */
  getBlockAtCursor() {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return null;

    let node = sel.anchorNode;
    if (!node || !this._el.contains(node)) return null;

    let el = node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    while (el && el !== this._el) {
      if (el.parentElement === this._el && BLOCK_TAGS.has(el.tagName)) {
        return el;
      }
      // Also check for top-level div/p/etc. that are direct children
      if (el.parentElement === this._el) return el;
      el = el.parentElement;
    }
    return null;
  }

  /**
   * Move a block (by ID) to before another block (by ID).
   * @param {string} blockId - The block to move
   * @param {string} beforeId - The target block to insert before (null = append to end)
   * @returns {boolean} Whether the move was successful
   */
  moveBlock(blockId, beforeId) {
    const block = this._el.querySelector(`[data-block-id="${blockId}"]`);
    if (!block) return false;

    if (beforeId) {
      const target = this._el.querySelector(`[data-block-id="${beforeId}"]`);
      if (!target) return false;
      this._el.insertBefore(block, target);
    } else {
      this._el.appendChild(block);
    }

    this._editor._fireUpdate();
    return true;
  }

  /**
   * Delete a block by its ID.
   * @param {string} blockId
   * @returns {boolean}
   */
  deleteBlock(blockId) {
    const block = this._el.querySelector(`[data-block-id="${blockId}"]`);
    if (!block) return false;

    block.remove();

    // Ensure editor is never empty
    if (!this._el.firstChild) {
      const p = document.createElement("p");
      p.innerHTML = "<br>";
      p.setAttribute("data-block-id", generateUUID());
      this._el.appendChild(p);
    }

    this._editor._fireUpdate();
    return true;
  }

  /**
   * Convert a block to a different type.
   * @param {string} blockId
   * @param {string} type - Target tag name (e.g., "p", "h2", "blockquote")
   * @returns {boolean}
   */
  convertBlock(blockId, type) {
    const block = this._el.querySelector(`[data-block-id="${blockId}"]`);
    if (!block) return false;

    const newEl = document.createElement(type);
    // Preserve content and block ID
    while (block.firstChild) {
      newEl.appendChild(block.firstChild);
    }
    newEl.setAttribute("data-block-id", blockId);

    // Copy inline styles if relevant
    if (block.style.textAlign) {
      newEl.style.textAlign = block.style.textAlign;
    }

    block.replaceWith(newEl);

    this._editor._fireUpdate();
    return true;
  }

  /**
   * Insert a new block after the specified block.
   * @param {string} blockId - The block to insert after
   * @param {string} type - Tag name for the new block (default "p")
   * @returns {HTMLElement|null} The new block element
   */
  insertBlockAfter(blockId, type = "p") {
    const block = this._el.querySelector(`[data-block-id="${blockId}"]`);
    if (!block) return null;

    const newEl = document.createElement(type);
    newEl.innerHTML = "<br>";
    newEl.setAttribute("data-block-id", generateUUID());

    block.after(newEl);

    // Move cursor into new block
    const range = document.createRange();
    range.setStart(newEl, 0);
    range.collapse(true);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);

    this._editor._fireUpdate();
    return newEl;
  }

  /**
   * Get an ordered list of all blocks with their IDs, types, and text previews.
   * @returns {Array<{id: string, type: string, text: string}>}
   */
  getBlockList() {
    const blocks = [];
    for (const child of this._el.children) {
      const id = child.getAttribute("data-block-id") || "";
      blocks.push({
        id,
        type: child.tagName.toLowerCase(),
        text: (child.textContent || "").substring(0, 80),
      });
    }
    return blocks;
  }

  /** @private */
  _assignBlockIds() {
    for (const child of this._el.children) {
      if (!child.getAttribute("data-block-id")) {
        child.setAttribute("data-block-id", generateUUID());
      }
    }
  }

  /** @private */
  _startObserving() {
    this._observer = new MutationObserver((mutations) => {
      let needsIds = false;
      for (const mutation of mutations) {
        for (const added of mutation.addedNodes) {
          if (added.nodeType === Node.ELEMENT_NODE && !added.getAttribute("data-block-id")) {
            if (added.parentElement === this._el || BLOCK_TAGS.has(added.tagName)) {
              added.setAttribute("data-block-id", generateUUID());
              needsIds = true;
            }
          }
        }
      }
    });

    this._observer.observe(this._el, {
      childList: true,
      subtree: true,
    });
  }

  /**
   * Destroy the block ops, disconnecting the observer.
   */
  destroy() {
    if (this._observer) {
      this._observer.disconnect();
      this._observer = null;
    }
  }
}

// =============================================================================
// PhiaEditorV2 — Main editor class
// =============================================================================

/**
 * Modern rich text editor engine using Range/Selection APIs.
 *
 * Replaces document.execCommand() with direct DOM manipulation.
 * Zero npm dependencies. Compatible with Phoenix LiveView hooks.
 *
 * @example
 * const editor = new PhiaEditorV2({
 *   element: document.getElementById("editor"),
 *   content: "<p>Hello world</p>",
 *   placeholder: "Start writing...",
 *   onUpdate: (html) => console.log(html),
 *   onSelectionChange: () => console.log("selection changed"),
 * });
 */
class PhiaEditorV2 {
  /**
   * Create a new PhiaEditorV2 instance.
   * @param {Object} opts
   * @param {HTMLElement} opts.element - The element to make editable
   * @param {string} [opts.content=""] - Initial HTML content
   * @param {string} [opts.placeholder=""] - Placeholder text
   * @param {function(string):void} [opts.onUpdate] - Called on content change with HTML
   * @param {function():void} [opts.onSelectionChange] - Called on selection change
   */
  constructor({ element, content = "", placeholder = "", onUpdate = null, onSelectionChange = null }) {
    if (!element) throw new Error("PhiaEditorV2: element is required");

    /** @private */
    this._el = element;
    /** @private */
    this._onUpdate = onUpdate;
    /** @private */
    this._onSelectionChange = onSelectionChange;
    /** @private */
    this._destroyed = false;
    /** @private */
    this._reducedMotion = prefersReducedMotion();

    // Make element editable
    this._el.setAttribute("contenteditable", "true");
    this._el.setAttribute("role", "textbox");
    this._el.setAttribute("aria-multiline", "true");
    this._el.setAttribute("spellcheck", "true");
    this._el.classList.add("phia-editor-v2");

    // Placeholder
    if (placeholder) {
      this._el.setAttribute("data-placeholder", placeholder);
    }

    // Set initial content
    if (content) {
      this._el.innerHTML = content;
    } else {
      this._el.innerHTML = "<p><br></p>";
    }
    this._updateEmptyClass();

    // Initialize subsystems
    /** @private */
    this._history = new PhiaHistory({ maxEntries: 100, debounceMs: 300 });
    /** @private */
    this._inputRules = new PhiaInputRules(this._el, this);
    /** @private */
    this._pasteRules = new PhiaPasteRules(this._el, this);
    /** @private */
    this._blockOps = new PhiaBlockOps(this._el, this);

    // Save initial state
    this._history.pushImmediate(this._el.innerHTML, this._serializeSelection());

    // Bind event handlers (stored for cleanup)
    /** @private */
    this._handleInput = (e) => this._onInput(e);
    /** @private */
    this._handleKeydown = (e) => this._onKeydown(e);
    /** @private */
    this._handlePaste = (e) => this._pasteRules.process(e);
    /** @private */
    this._handleSelectionChange = () => this._onSelectionChanged();
    /** @private */
    this._handleFocus = () => this._updateEmptyClass();
    /** @private */
    this._handleBlur = () => this._updateEmptyClass();

    this._el.addEventListener("input", this._handleInput);
    this._el.addEventListener("keydown", this._handleKeydown);
    this._el.addEventListener("paste", this._handlePaste);
    this._el.addEventListener("focus", this._handleFocus);
    this._el.addEventListener("blur", this._handleBlur);
    document.addEventListener("selectionchange", this._handleSelectionChange);

    this._setupKeyboardShortcuts();
  }

  // ===========================================================================
  // Core API
  // ===========================================================================

  /**
   * Get the current HTML content of the editor.
   * @returns {string}
   */
  getHTML() {
    return this._el.innerHTML;
  }

  /**
   * Replace the entire editor content.
   * @param {string} html
   */
  setContent(html) {
    this._el.innerHTML = html || "<p><br></p>";
    this._blockOps._assignBlockIds();
    this._updateEmptyClass();
    this._history.pushImmediate(this._el.innerHTML, null);
    this._fireUpdate();
  }

  /**
   * Insert HTML at the current cursor position.
   * @param {string} html
   */
  insertHTML(html) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) {
      this._el.focus();
    }

    const range = this._getCurrentRange();
    if (!range) return;

    range.deleteContents();

    const template = document.createElement("template");
    template.innerHTML = html;
    const frag = template.content;
    const lastChild = frag.lastChild;

    range.insertNode(frag);

    if (lastChild) {
      const newRange = document.createRange();
      newRange.setStartAfter(lastChild);
      newRange.collapse(true);
      sel.removeAllRanges();
      sel.addRange(newRange);
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Insert plain text at the current cursor position.
   * @param {string} text
   */
  insertText(text) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) {
      this._el.focus();
    }

    const range = this._getCurrentRange();
    if (!range) return;

    range.deleteContents();
    const textNode = document.createTextNode(text);
    range.insertNode(textNode);

    const newRange = document.createRange();
    newRange.setStartAfter(textNode);
    newRange.collapse(true);
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Focus the editor element.
   */
  focus() {
    this._el.focus();
  }

  /**
   * Destroy the editor, removing all event listeners and subsystems.
   */
  destroy() {
    if (this._destroyed) return;
    this._destroyed = true;

    this._el.removeEventListener("input", this._handleInput);
    this._el.removeEventListener("keydown", this._handleKeydown);
    this._el.removeEventListener("paste", this._handlePaste);
    this._el.removeEventListener("focus", this._handleFocus);
    this._el.removeEventListener("blur", this._handleBlur);
    document.removeEventListener("selectionchange", this._handleSelectionChange);

    this._history.destroy();
    this._inputRules.destroy();
    this._pasteRules.destroy();
    this._blockOps.destroy();

    this._el.removeAttribute("contenteditable");
    this._el.classList.remove("phia-editor-v2");
  }

  // ===========================================================================
  // Inline Format Commands — Range/Selection based (no execCommand)
  // ===========================================================================

  /**
   * Toggle bold formatting on the current selection.
   */
  toggleBold() {
    this._toggleInlineMark("strong", "b");
  }

  /**
   * Toggle italic formatting on the current selection.
   */
  toggleItalic() {
    this._toggleInlineMark("em", "i");
  }

  /**
   * Toggle underline formatting on the current selection.
   */
  toggleUnderline() {
    this._toggleInlineMark("u");
  }

  /**
   * Toggle strikethrough formatting on the current selection.
   */
  toggleStrike() {
    this._toggleInlineMark("s", "strike");
  }

  /**
   * Toggle inline code formatting on the current selection.
   */
  toggleCode() {
    this._toggleInlineMark("code");
  }

  /**
   * Toggle superscript formatting on the current selection.
   */
  toggleSuperscript() {
    this._toggleInlineMark("sup");
  }

  /**
   * Toggle subscript formatting on the current selection.
   */
  toggleSubscript() {
    this._toggleInlineMark("sub");
  }

  /**
   * Remove all inline formatting from the current selection.
   */
  clearFormatting() {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    const range = sel.getRangeAt(0);
    if (range.collapsed) return;

    // Extract the selected content
    const frag = range.extractContents();
    // Get plain text
    const text = frag.textContent;
    const textNode = document.createTextNode(text);
    range.insertNode(textNode);

    // Restore selection around the text
    const newRange = document.createRange();
    newRange.selectNode(textNode);
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Toggle highlight (background color) on the current selection.
   * @param {string} [color="#fef08a"] - The highlight color
   */
  toggleHighlight(color = "#fef08a") {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    if (this.isActive("highlight")) {
      this._unwrapClosest("mark");
    } else if (!sel.isCollapsed) {
      const range = sel.getRangeAt(0);
      const mark = document.createElement("mark");
      mark.style.backgroundColor = color;
      mark.setAttribute("data-color", color);
      try {
        range.surroundContents(mark);
      } catch {
        // surroundContents fails when selection crosses element boundaries
        const frag = range.extractContents();
        mark.appendChild(frag);
        range.insertNode(mark);
      }
      const newRange = document.createRange();
      newRange.selectNodeContents(mark);
      sel.removeAllRanges();
      sel.addRange(newRange);
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Set text color on the current selection.
   * @param {string} color - CSS color value
   */
  setColor(color) {
    this._wrapInSpanWithStyle("color", color);
  }

  /**
   * Set background highlight color on the current selection.
   * @param {string} color - CSS color value
   */
  setHighlight(color) {
    this._wrapInSpanWithStyle("backgroundColor", color);
  }

  /**
   * Set font family on the current selection.
   * @param {string} font - CSS font-family value
   */
  setFontFamily(font) {
    this._wrapInSpanWithStyle("fontFamily", font);
  }

  /**
   * Set font size on the current selection.
   * @param {string} size - CSS font-size value (e.g., "16px", "1.2em")
   */
  setFontSize(size) {
    this._wrapInSpanWithStyle("fontSize", size);
  }

  /**
   * Set line height on the current block.
   * @param {string} val - CSS line-height value (e.g., "1.5", "2")
   */
  setLineHeight(val) {
    const block = this._getBlockAtCursor();
    if (block) {
      block.style.lineHeight = val;
      this._pushHistory();
      this._fireUpdate();
    }
  }

  /**
   * Set letter spacing on the current selection.
   * @param {string} val - CSS letter-spacing value (e.g., "0.05em")
   */
  setLetterSpacing(val) {
    this._wrapInSpanWithStyle("letterSpacing", val);
  }

  /**
   * Toggle small caps on the current selection.
   */
  toggleSmallCaps() {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    const node = sel.anchorNode;
    const element = node && node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    if (element && element.style && element.style.fontVariant === "small-caps") {
      element.style.fontVariant = "";
      if (!element.style.cssText.trim() && element.tagName === "SPAN") {
        this._unwrapElement(element);
      }
    } else {
      this._wrapInSpanWithStyle("fontVariant", "small-caps");
    }
  }

  /**
   * Toggle drop cap on the current block.
   */
  toggleDropCap() {
    const block = this._getBlockAtCursor();
    if (!block) return;

    if (block.classList.contains("phia-drop-cap")) {
      block.classList.remove("phia-drop-cap");
    } else {
      block.classList.add("phia-drop-cap");
    }
    this._pushHistory();
    this._fireUpdate();
  }

  // ===========================================================================
  // Block-level Commands — Direct DOM manipulation
  // ===========================================================================

  /**
   * Set the current block to a heading of the given level.
   * @param {number} level - Heading level (1-6)
   */
  setHeading(level) {
    if (level < 1 || level > 6) return;
    this._convertCurrentBlock(`h${level}`);
  }

  /**
   * Set the current block to a paragraph.
   */
  setParagraph() {
    this._convertCurrentBlock("p");
  }

  /**
   * Toggle bullet list on the current block.
   */
  toggleBulletList() {
    this._toggleList("ul");
  }

  /**
   * Toggle ordered list on the current block.
   */
  toggleOrderedList() {
    this._toggleList("ol");
  }

  /**
   * Toggle blockquote on the current block.
   */
  toggleBlockquote() {
    const block = this._getBlockAtCursor();
    if (!block) return;

    if (block.tagName === "BLOCKQUOTE") {
      // Unwrap blockquote to paragraph
      const p = document.createElement("p");
      while (block.firstChild) {
        p.appendChild(block.firstChild);
      }
      p.setAttribute("data-block-id", block.getAttribute("data-block-id") || generateUUID());
      block.replaceWith(p);
      this._setCursorIn(p);
    } else {
      const bq = document.createElement("blockquote");
      bq.setAttribute("data-block-id", generateUUID());
      block.replaceWith(bq);
      bq.appendChild(block);
      this._setCursorIn(block);
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Toggle code block on the current block.
   */
  toggleCodeBlock() {
    const block = this._getBlockAtCursor();
    if (!block) return;

    if (block.tagName === "PRE" || (block.parentElement && block.parentElement.tagName === "PRE")) {
      // Unwrap pre/code to paragraph
      const pre = block.tagName === "PRE" ? block : block.parentElement;
      const p = document.createElement("p");
      p.textContent = pre.textContent;
      p.setAttribute("data-block-id", pre.getAttribute("data-block-id") || generateUUID());
      pre.replaceWith(p);
      this._setCursorIn(p);
    } else {
      const pre = document.createElement("pre");
      const code = document.createElement("code");
      code.textContent = block.textContent;
      pre.appendChild(code);
      pre.setAttribute("data-block-id", block.getAttribute("data-block-id") || generateUUID());
      block.replaceWith(pre);
      this._setCursorIn(code);
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Insert a horizontal rule at the current cursor position.
   */
  insertHorizontalRule() {
    const block = this._getBlockAtCursor();
    if (!block) return;

    const hr = document.createElement("hr");
    hr.setAttribute("data-block-id", generateUUID());

    const p = document.createElement("p");
    p.innerHTML = "<br>";
    p.setAttribute("data-block-id", generateUUID());

    block.after(hr);
    hr.after(p);

    this._setCursorIn(p);
    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Insert a table at the current cursor position.
   * @param {number} [rows=3] - Number of rows
   * @param {number} [cols=3] - Number of columns
   */
  insertTable(rows = 3, cols = 3) {
    const table = document.createElement("table");
    table.style.borderCollapse = "collapse";
    table.style.width = "100%";
    table.setAttribute("data-block-id", generateUUID());

    for (let r = 0; r < rows; r++) {
      const tr = document.createElement("tr");
      for (let c = 0; c < cols; c++) {
        const cell = document.createElement(r === 0 ? "th" : "td");
        cell.style.border = "1px solid #d1d5db";
        cell.style.padding = "0.5em 0.75em";
        cell.innerHTML = "&nbsp;";
        tr.appendChild(cell);
      }
      table.appendChild(tr);
    }

    const block = this._getBlockAtCursor();
    if (block) {
      block.after(table);
    } else {
      this._el.appendChild(table);
    }

    // Insert paragraph after table for continued editing
    const p = document.createElement("p");
    p.innerHTML = "<br>";
    p.setAttribute("data-block-id", generateUUID());
    table.after(p);

    // Focus first cell
    const firstCell = table.querySelector("th, td");
    if (firstCell) {
      this._setCursorIn(firstCell);
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Set text alignment on the current block.
   * @param {string} alignment - "left", "center", "right", or "justify"
   */
  setTextAlign(alignment) {
    const block = this._getBlockAtCursor();
    if (!block) return;

    block.style.textAlign = alignment === "left" ? "" : alignment;
    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Set a link on the current selection.
   * @param {string} href - The URL
   */
  setLink(href) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    if (sel.isCollapsed) return;

    const range = sel.getRangeAt(0);
    const link = document.createElement("a");
    link.href = href;
    link.target = "_blank";
    link.rel = "noopener noreferrer";

    try {
      range.surroundContents(link);
    } catch {
      const frag = range.extractContents();
      link.appendChild(frag);
      range.insertNode(link);
    }

    const newRange = document.createRange();
    newRange.selectNodeContents(link);
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Remove the link at the current cursor position.
   */
  unsetLink() {
    this._unwrapClosest("a");
    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Indent the current block (increase nesting in lists, or add margin).
   */
  indent() {
    const block = this._getBlockAtCursor();
    if (!block) return;

    // If in a list, wrap in a sub-list
    if (block.tagName === "LI") {
      const parent = block.parentElement;
      const prev = block.previousElementSibling;
      if (prev && prev.tagName === "LI") {
        // Move this LI into a nested list inside the previous LI
        let subList = prev.querySelector("ul, ol");
        if (!subList) {
          subList = document.createElement(parent.tagName.toLowerCase());
          prev.appendChild(subList);
        }
        subList.appendChild(block);
        this._setCursorIn(block);
      }
    } else {
      // Non-list: increase margin
      const currentMargin = parseInt(block.style.marginLeft, 10) || 0;
      block.style.marginLeft = `${currentMargin + 40}px`;
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Outdent the current block (decrease nesting in lists, or reduce margin).
   */
  outdent() {
    const block = this._getBlockAtCursor();
    if (!block) return;

    // If in a nested list, move out one level
    if (block.tagName === "LI") {
      const parent = block.parentElement;
      if (parent && parent.parentElement && parent.parentElement.tagName === "LI") {
        const grandparent = parent.parentElement.parentElement;
        const parentLI = parent.parentElement;
        // Move this LI after the parent LI
        grandparent.insertBefore(block, parentLI.nextSibling);
        // Clean up empty sub-list
        if (parent.children.length === 0) {
          parent.remove();
        }
        this._setCursorIn(block);
      }
    } else {
      const currentMargin = parseInt(block.style.marginLeft, 10) || 0;
      const newMargin = Math.max(0, currentMargin - 40);
      block.style.marginLeft = newMargin ? `${newMargin}px` : "";
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Insert a callout/admonition block.
   * @param {string} [variant="info"] - Callout variant: "info", "warning", "success", "error"
   */
  insertCallout(variant = "info") {
    const colors = {
      info: { bg: "#eff6ff", border: "#3b82f6", icon: "\u2139\uFE0F" },
      warning: { bg: "#fffbeb", border: "#f59e0b", icon: "\u26A0\uFE0F" },
      success: { bg: "#f0fdf4", border: "#22c55e", icon: "\u2705" },
      error: { bg: "#fef2f2", border: "#ef4444", icon: "\u274C" },
    };
    const c = colors[variant] || colors.info;

    const aside = document.createElement("aside");
    aside.setAttribute("data-block-id", generateUUID());
    aside.setAttribute("data-callout", variant);
    aside.style.cssText = `border-left: 4px solid ${c.border}; background: ${c.bg}; padding: 1em 1em 1em 1.25em; border-radius: 0.25em; margin: 1em 0;`;

    const title = document.createElement("p");
    title.innerHTML = `<strong>${c.icon} ${variant.charAt(0).toUpperCase() + variant.slice(1)}</strong>`;
    aside.appendChild(title);

    const body = document.createElement("p");
    body.innerHTML = "<br>";
    aside.appendChild(body);

    const block = this._getBlockAtCursor();
    if (block) {
      block.after(aside);
    } else {
      this._el.appendChild(aside);
    }

    this._setCursorIn(body);
    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Insert a collapsible details/summary block.
   * @param {string} [summary="Details"] - The summary text
   */
  insertDetails(summary = "Details") {
    const details = document.createElement("details");
    details.setAttribute("data-block-id", generateUUID());
    details.style.cssText = "border: 1px solid #e5e7eb; border-radius: 0.25em; padding: 0.5em 1em; margin: 1em 0;";
    details.setAttribute("open", "");

    const summaryEl = document.createElement("summary");
    summaryEl.style.cssText = "cursor: pointer; font-weight: 600;";
    summaryEl.textContent = summary;
    details.appendChild(summaryEl);

    const body = document.createElement("p");
    body.innerHTML = "<br>";
    details.appendChild(body);

    const block = this._getBlockAtCursor();
    if (block) {
      block.after(details);
    } else {
      this._el.appendChild(details);
    }

    this._setCursorIn(body);
    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Insert a multi-column layout.
   * @param {number} [count=2] - Number of columns (2-4)
   */
  insertColumns(count = 2) {
    count = Math.max(2, Math.min(4, count));

    const wrapper = document.createElement("div");
    wrapper.setAttribute("data-block-id", generateUUID());
    wrapper.setAttribute("data-columns", String(count));
    wrapper.style.cssText = `display: grid; grid-template-columns: repeat(${count}, 1fr); gap: 1em; margin: 1em 0;`;

    for (let i = 0; i < count; i++) {
      const col = document.createElement("div");
      col.setAttribute("data-block-id", generateUUID());
      col.style.cssText = "border: 1px dashed #d1d5db; padding: 0.75em; border-radius: 0.25em; min-height: 3em;";
      const p = document.createElement("p");
      p.innerHTML = "<br>";
      col.appendChild(p);
      wrapper.appendChild(col);
    }

    const block = this._getBlockAtCursor();
    if (block) {
      block.after(wrapper);
    } else {
      this._el.appendChild(wrapper);
    }

    // Focus first column
    const firstP = wrapper.querySelector("p");
    if (firstP) this._setCursorIn(firstP);

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Insert an embed (iframe wrapper) for a URL.
   * @param {string} url - The URL to embed
   */
  insertEmbed(url) {
    const figure = document.createElement("figure");
    figure.setAttribute("data-block-id", generateUUID());
    figure.setAttribute("data-embed", "true");
    figure.style.cssText = "margin: 1em 0; position: relative;";

    const wrapper = document.createElement("div");
    wrapper.style.cssText = "position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; border-radius: 0.5em;";
    wrapper.setAttribute("contenteditable", "false");

    const iframe = document.createElement("iframe");
    iframe.src = url;
    iframe.style.cssText = "position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0;";
    iframe.setAttribute("allowfullscreen", "");
    iframe.setAttribute("loading", "lazy");

    wrapper.appendChild(iframe);
    figure.appendChild(wrapper);

    const caption = document.createElement("figcaption");
    caption.style.cssText = "text-align: center; color: #6b7280; font-size: 0.875em; margin-top: 0.5em;";
    caption.setAttribute("contenteditable", "true");
    caption.innerHTML = "<br>";
    figure.appendChild(caption);

    const block = this._getBlockAtCursor();
    if (block) {
      block.after(figure);
    } else {
      this._el.appendChild(figure);
    }

    // Paragraph after embed
    const p = document.createElement("p");
    p.innerHTML = "<br>";
    p.setAttribute("data-block-id", generateUUID());
    figure.after(p);

    this._setCursorIn(p);
    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Insert a mention node.
   * @param {string} id - The mention target ID
   * @param {string} label - The display label
   */
  insertMention(id, label) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    const range = sel.getRangeAt(0);
    range.deleteContents();

    const mention = document.createElement("span");
    mention.setAttribute("data-mention", id);
    mention.setAttribute("contenteditable", "false");
    mention.className = "phia-mention";
    mention.style.cssText = "color: #3b82f6; background: #eff6ff; padding: 0.125em 0.25em; border-radius: 0.25em; font-weight: 500;";
    mention.textContent = `@${label}`;

    // Add space after mention for cursor escape
    const space = document.createTextNode("\u00A0");

    range.insertNode(space);
    range.insertNode(mention);

    const newRange = document.createRange();
    newRange.setStartAfter(space);
    newRange.collapse(true);
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Insert a task list (checkbox list).
   */
  insertTaskList() {
    const ul = document.createElement("ul");
    ul.setAttribute("data-type", "taskList");
    ul.setAttribute("data-block-id", generateUUID());
    ul.style.listStyle = "none";
    ul.style.paddingLeft = "0";

    const li = document.createElement("li");
    li.setAttribute("data-type", "taskItem");
    li.setAttribute("data-checked", "false");
    li.setAttribute("data-block-id", generateUUID());

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.style.marginRight = "0.5em";
    checkbox.addEventListener("change", () => {
      li.setAttribute("data-checked", checkbox.checked ? "true" : "false");
      this._fireUpdate();
    });

    const textSpan = document.createElement("span");
    textSpan.setAttribute("contenteditable", "true");
    textSpan.innerHTML = "<br>";

    li.appendChild(checkbox);
    li.appendChild(textSpan);
    ul.appendChild(li);

    const block = this._getBlockAtCursor();
    if (block) {
      block.after(ul);
    } else {
      this._el.appendChild(ul);
    }

    this._setCursorIn(textSpan);
    this._pushHistory();
    this._fireUpdate();
  }

  // ===========================================================================
  // History Commands
  // ===========================================================================

  /**
   * Undo the last change.
   */
  undo() {
    const snapshot = this._history.undo();
    if (!snapshot) return;

    this._el.innerHTML = snapshot.html;
    this._blockOps._assignBlockIds();
    this._restoreSelection(snapshot.selectionRange);
    this._updateEmptyClass();
    this._fireUpdate();
  }

  /**
   * Redo the last undone change.
   */
  redo() {
    const snapshot = this._history.redo();
    if (!snapshot) return;

    this._el.innerHTML = snapshot.html;
    this._blockOps._assignBlockIds();
    this._restoreSelection(snapshot.selectionRange);
    this._updateEmptyClass();
    this._fireUpdate();
  }

  // ===========================================================================
  // Query API
  // ===========================================================================

  /**
   * Check if the given format/mark/node type is active at the current selection.
   * @param {string} mark - The format name (e.g., "bold", "italic", "h1", "bulletList")
   * @returns {boolean}
   */
  isActive(mark) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return false;

    const node = sel.anchorNode;
    if (!node) return false;

    const element = node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    if (!element || !this._el.contains(element)) return false;

    switch (mark) {
      case "bold":
        return !!element.closest("strong, b");
      case "italic":
        return !!element.closest("em, i");
      case "underline":
        return !!element.closest("u");
      case "strike":
        return !!element.closest("s, strike, del");
      case "code":
        return !!element.closest("code") && !element.closest("pre");
      case "superscript":
        return !!element.closest("sup");
      case "subscript":
        return !!element.closest("sub");
      case "link":
        return !!element.closest("a[href]");
      case "highlight":
        return !!element.closest("mark");
      case "h1": return !!element.closest("h1");
      case "h2": return !!element.closest("h2");
      case "h3": return !!element.closest("h3");
      case "h4": return !!element.closest("h4");
      case "h5": return !!element.closest("h5");
      case "h6": return !!element.closest("h6");
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
      case "taskList":
        return !!element.closest('[data-type="taskList"]');
      case "smallCaps": {
        const span = element.closest("span");
        return span ? span.style.fontVariant === "small-caps" : false;
      }
      case "dropCap": {
        const block = this._getBlockAtCursor();
        return block ? block.classList.contains("phia-drop-cap") : false;
      }
      default:
        return false;
    }
  }

  // ===========================================================================
  // Block Operations (delegated to PhiaBlockOps)
  // ===========================================================================

  /**
   * Get the block element at the current cursor position.
   * @returns {HTMLElement|null}
   */
  getBlockAtCursor() {
    return this._blockOps.getBlockAtCursor();
  }

  /**
   * Move a block before another block.
   * @param {string} blockId
   * @param {string} beforeId
   * @returns {boolean}
   */
  moveBlock(blockId, beforeId) {
    return this._blockOps.moveBlock(blockId, beforeId);
  }

  /**
   * Get the list of all blocks in the editor.
   * @returns {Array<{id: string, type: string, text: string}>}
   */
  getBlockList() {
    return this._blockOps.getBlockList();
  }

  // ===========================================================================
  // Input Rules (delegated to PhiaInputRules)
  // ===========================================================================

  /**
   * Add a custom input rule.
   * @param {{ regex: RegExp, handler: function }} rule
   */
  addInputRule(rule) {
    this._inputRules.addRule(rule);
  }

  // ===========================================================================
  // Utility Methods
  // ===========================================================================

  /**
   * Get the plain text content of the editor.
   * @returns {string}
   */
  getText() {
    return this._el.textContent || "";
  }

  /**
   * Get word count statistics.
   * @returns {{ words: number, chars: number, pages: number, reading_time: number }}
   */
  getWordCount() {
    const text = this.getText().trim();
    const words = text ? text.split(/\s+/).length : 0;
    const chars = text.length;
    const pages = Math.max(1, Math.ceil(words / 250));
    const reading_time = words > 0 ? Math.max(1, Math.ceil(words / 200)) : 0;
    return { words, chars, pages, reading_time };
  }

  /**
   * Get the document outline (headings).
   * @returns {Array<{level: number, text: string, id: string}>}
   */
  getOutline() {
    const headings = [];
    const els = this._el.querySelectorAll("h1, h2, h3, h4, h5, h6");
    els.forEach((el, i) => {
      if (!el.id) el.id = `heading-${i}`;
      headings.push({
        level: parseInt(el.tagName.charAt(1), 10),
        text: el.textContent,
        id: el.id,
      });
    });
    return headings;
  }

  // ===========================================================================
  // Private — Inline mark toggle via Range/Selection
  // ===========================================================================

  /**
   * Toggle an inline mark (wrap/unwrap) using Range/Selection API.
   * @private
   * @param {string} tag - Primary tag name (e.g., "strong")
   * @param {string} [altTag] - Alternative tag name to detect (e.g., "b")
   */
  _toggleInlineMark(tag, altTag) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    const range = sel.getRangeAt(0);

    // Check if mark is active
    const selector = altTag ? `${tag}, ${altTag}` : tag;
    const node = sel.anchorNode;
    const element = node && node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    const existingMark = element ? element.closest(selector) : null;

    if (existingMark && this._el.contains(existingMark)) {
      // Unwrap the mark
      if (range.collapsed) {
        // No selection: unwrap the entire mark element
        this._unwrapElement(existingMark);
      } else {
        // Selection exists: remove mark from selected portion
        this._unwrapMarkInRange(range, tag, altTag);
      }
    } else if (!range.collapsed) {
      // Wrap selected text in the mark
      const markEl = document.createElement(tag);
      try {
        range.surroundContents(markEl);
      } catch {
        // surroundContents fails when selection crosses element boundaries
        // Fall back to extractContents + re-insert
        const frag = range.extractContents();
        markEl.appendChild(frag);
        range.insertNode(markEl);
      }
      // Restore selection around the new mark
      const newRange = document.createRange();
      newRange.selectNodeContents(markEl);
      sel.removeAllRanges();
      sel.addRange(newRange);
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Unwrap a mark element, replacing it with its children.
   * @private
   * @param {HTMLElement} element
   */
  _unwrapElement(element) {
    const parent = element.parentNode;
    if (!parent) return;

    const frag = document.createDocumentFragment();
    while (element.firstChild) {
      frag.appendChild(element.firstChild);
    }
    parent.replaceChild(frag, element);
    // Normalize adjacent text nodes
    parent.normalize();
  }

  /**
   * Remove a mark tag from within a given range.
   * Handles partial selections across mark boundaries.
   * @private
   * @param {Range} range
   * @param {string} tag
   * @param {string} [altTag]
   */
  _unwrapMarkInRange(range, tag, altTag) {
    const frag = range.extractContents();
    const walker = document.createTreeWalker(frag, NodeFilter.SHOW_ELEMENT);
    const toUnwrap = [];

    let current = walker.currentNode;
    while (current) {
      if (current.tagName && (current.tagName.toLowerCase() === tag || (altTag && current.tagName.toLowerCase() === altTag))) {
        toUnwrap.push(current);
      }
      current = walker.nextNode();
    }

    for (const el of toUnwrap) {
      this._unwrapElement(el);
    }

    range.insertNode(frag);
  }

  /**
   * Unwrap the closest ancestor matching a tag name around the cursor.
   * @private
   * @param {string} tag
   */
  _unwrapClosest(tag) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    const node = sel.anchorNode;
    const element = node && node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    const target = element ? element.closest(tag) : null;

    if (target && this._el.contains(target)) {
      this._unwrapElement(target);
    }
  }

  /**
   * Wrap the current selection in a span with an inline style.
   * @private
   * @param {string} property - CSS property name (camelCase)
   * @param {string} value - CSS property value
   */
  _wrapInSpanWithStyle(property, value) {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;

    const range = sel.getRangeAt(0);
    if (range.collapsed) {
      // For collapsed selection, check if we are inside a span with this style
      const node = sel.anchorNode;
      const element = node && node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
      if (element && element.tagName === "SPAN" && element.style[property]) {
        element.style[property] = value;
        this._pushHistory();
        this._fireUpdate();
        return;
      }
      return;
    }

    const span = document.createElement("span");
    span.style[property] = value;

    try {
      range.surroundContents(span);
    } catch {
      const frag = range.extractContents();
      span.appendChild(frag);
      range.insertNode(span);
    }

    const newRange = document.createRange();
    newRange.selectNodeContents(span);
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._pushHistory();
    this._fireUpdate();
  }

  // ===========================================================================
  // Private — Block-level helpers
  // ===========================================================================

  /**
   * Get the closest block-level ancestor of the cursor.
   * @private
   * @returns {HTMLElement|null}
   */
  _getBlockAtCursor() {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return null;

    let node = sel.anchorNode;
    if (!node || !this._el.contains(node)) return null;

    let el = node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    while (el && el !== this._el) {
      if (el.parentElement === this._el && BLOCK_TAGS.has(el.tagName)) return el;
      if (el.parentElement === this._el) return el;
      el = el.parentElement;
    }
    return null;
  }

  /**
   * Convert the current block to a different tag.
   * @private
   * @param {string} tagName
   */
  _convertCurrentBlock(tagName) {
    const block = this._getBlockAtCursor();
    if (!block) return;

    // If already the target type, do nothing
    if (block.tagName.toLowerCase() === tagName.toLowerCase()) return;

    // If inside a list item, convert the LI content type differently
    if (block.tagName === "LI") {
      const parent = block.parentElement;
      const newEl = document.createElement(tagName);
      while (block.firstChild) {
        newEl.appendChild(block.firstChild);
      }
      newEl.setAttribute("data-block-id", block.getAttribute("data-block-id") || generateUUID());
      // Replace the list if it only has one item, otherwise just this item
      if (parent.children.length === 1) {
        parent.replaceWith(newEl);
      } else {
        block.replaceWith(newEl);
      }
      this._setCursorIn(newEl);
    } else {
      const newEl = document.createElement(tagName);
      while (block.firstChild) {
        newEl.appendChild(block.firstChild);
      }
      newEl.setAttribute("data-block-id", block.getAttribute("data-block-id") || generateUUID());
      if (block.style.textAlign) {
        newEl.style.textAlign = block.style.textAlign;
      }
      block.replaceWith(newEl);
      this._setCursorIn(newEl);
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Toggle a list type (UL or OL).
   * @private
   * @param {string} listTag - "ul" or "ol"
   */
  _toggleList(listTag) {
    const block = this._getBlockAtCursor();
    if (!block) return;

    const listTagUpper = listTag.toUpperCase();

    // If currently in a list of the same type, unwrap
    if (block.tagName === "LI" && block.parentElement && block.parentElement.tagName === listTagUpper) {
      const parent = block.parentElement;
      // Convert each LI to P
      const items = Array.from(parent.children);
      const frag = document.createDocumentFragment();
      for (const li of items) {
        const p = document.createElement("p");
        while (li.firstChild) {
          p.appendChild(li.firstChild);
        }
        p.setAttribute("data-block-id", li.getAttribute("data-block-id") || generateUUID());
        frag.appendChild(p);
      }
      parent.replaceWith(frag);
      // Focus first created paragraph
      const firstP = frag.firstChild || this._el.firstChild;
      if (firstP) this._setCursorIn(firstP);
    }
    // If in a list of different type, switch type
    else if (block.tagName === "LI" && block.parentElement) {
      const parent = block.parentElement;
      const newList = document.createElement(listTag);
      newList.setAttribute("data-block-id", parent.getAttribute("data-block-id") || generateUUID());
      while (parent.firstChild) {
        newList.appendChild(parent.firstChild);
      }
      parent.replaceWith(newList);
      this._setCursorIn(block);
    }
    // Not in a list: wrap current block in a list
    else {
      const list = document.createElement(listTag);
      list.setAttribute("data-block-id", generateUUID());
      const li = document.createElement("li");
      li.setAttribute("data-block-id", block.getAttribute("data-block-id") || generateUUID());
      while (block.firstChild) {
        li.appendChild(block.firstChild);
      }
      list.appendChild(li);
      block.replaceWith(list);
      this._setCursorIn(li);
    }

    this._pushHistory();
    this._fireUpdate();
  }

  /**
   * Place cursor at the start of an element.
   * @private
   * @param {HTMLElement} el
   */
  _setCursorIn(el) {
    const range = document.createRange();
    if (el.firstChild) {
      range.setStart(el.firstChild, 0);
    } else {
      range.setStart(el, 0);
    }
    range.collapse(true);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);
  }

  // ===========================================================================
  // Private — Selection serialization for undo/redo
  // ===========================================================================

  /**
   * Serialize the current selection to a path-based representation.
   * @private
   * @returns {Object|null}
   */
  _serializeSelection() {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return null;

    const range = sel.getRangeAt(0);
    if (!this._el.contains(range.startContainer)) return null;

    try {
      return {
        startPath: this._getNodePath(range.startContainer),
        startOffset: range.startOffset,
        endPath: this._getNodePath(range.endContainer),
        endOffset: range.endOffset,
      };
    } catch {
      return null;
    }
  }

  /**
   * Restore a serialized selection.
   * @private
   * @param {Object|null} selectionRange
   */
  _restoreSelection(selectionRange) {
    if (!selectionRange) return;

    try {
      const startNode = this._resolveNodePath(selectionRange.startPath);
      const endNode = this._resolveNodePath(selectionRange.endPath);
      if (!startNode || !endNode) return;

      const range = document.createRange();
      range.setStart(startNode, Math.min(selectionRange.startOffset, startNode.length || startNode.childNodes.length));
      range.setEnd(endNode, Math.min(selectionRange.endOffset, endNode.length || endNode.childNodes.length));

      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    } catch {
      // Silently fail on invalid paths (DOM may have changed)
    }
  }

  /**
   * Get an array of child indices from the editor root to a node.
   * @private
   * @param {Node} node
   * @returns {number[]}
   */
  _getNodePath(node) {
    const path = [];
    let current = node;
    while (current && current !== this._el) {
      const parent = current.parentNode;
      if (!parent) break;
      const index = Array.from(parent.childNodes).indexOf(current);
      path.unshift(index);
      current = parent;
    }
    return path;
  }

  /**
   * Resolve a path array to a DOM node.
   * @private
   * @param {number[]} path
   * @returns {Node|null}
   */
  _resolveNodePath(path) {
    let node = this._el;
    for (const index of path) {
      if (!node.childNodes || index >= node.childNodes.length) return null;
      node = node.childNodes[index];
    }
    return node;
  }

  // ===========================================================================
  // Private — Event handlers
  // ===========================================================================

  /**
   * Get the current selection range within the editor.
   * @private
   * @returns {Range|null}
   */
  _getCurrentRange() {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return null;
    const range = sel.getRangeAt(0);
    if (!this._el.contains(range.commonAncestorContainer)) return null;
    return range;
  }

  /** @private */
  _onInput(e) {
    // Run input rules
    this._inputRules.process(e);
    this._updateEmptyClass();
    this._pushHistory();
    this._fireUpdate();
  }

  /** @private */
  _onSelectionChanged() {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;
    const node = sel.anchorNode;
    if (!node || !this._el.contains(node)) return;

    if (this._onSelectionChange) {
      this._onSelectionChange();
    }
  }

  /** @private */
  _updateEmptyClass() {
    const text = this._el.textContent || "";
    const isEmpty = !text.trim() && !this._el.querySelector("img, hr, table, iframe");
    this._el.classList.toggle("is-empty", isEmpty);
  }

  /** @private */
  _pushHistory() {
    this._history.push(this._el.innerHTML, this._serializeSelection());
  }

  /**
   * Fire the onUpdate callback.
   * @private (called by subsystems too, hence underscore naming)
   */
  _fireUpdate() {
    if (this._onUpdate) {
      this._onUpdate(this.getHTML());
    }
  }

  // ===========================================================================
  // Private — Keyboard shortcuts
  // ===========================================================================

  /** @private */
  _setupKeyboardShortcuts() {
    /** @private */
    this._shortcuts = new Map();

    // Standard formatting
    this._registerShortcut("b", false, () => this.toggleBold());
    this._registerShortcut("i", false, () => this.toggleItalic());
    this._registerShortcut("u", false, () => this.toggleUnderline());

    // Heading levels: Ctrl+Shift+1-6
    for (let i = 1; i <= 6; i++) {
      this._registerShortcut(String(i), true, () => this.setHeading(i));
    }

    // Text alignment: Ctrl+Shift+E/L/R
    this._registerShortcut("l", true, () => this.setTextAlign("left"));
    this._registerShortcut("e", true, () => this.setTextAlign("center"));
    this._registerShortcut("r", true, () => this.setTextAlign("right"));

    // Lists: Ctrl+Shift+7 ordered, Ctrl+Shift+8 bullet
    this._registerShortcut("7", true, () => this.toggleOrderedList());
    this._registerShortcut("8", true, () => this.toggleBulletList());

    // Blockquote: Ctrl+Shift+B
    this._registerShortcut("b", true, () => this.toggleBlockquote());

    // Code block: Ctrl+/
    this._registerShortcut("/", false, () => this.toggleCodeBlock());

    // Highlight: Ctrl+Shift+H
    this._registerShortcut("h", true, () => this.toggleHighlight());

    // Strikethrough: Ctrl+Shift+X
    this._registerShortcut("x", true, () => this.toggleStrike());

    // Undo: Ctrl+Z
    this._registerShortcut("z", false, () => this.undo());
    // Redo: Ctrl+Shift+Z
    this._registerShortcut("z", true, () => this.redo());
  }

  /**
   * Register a keyboard shortcut.
   * @private
   * @param {string} key - The key (lowercase)
   * @param {boolean} shift - Whether Shift must be held
   * @param {function} handler - The handler function
   */
  _registerShortcut(key, shift, handler) {
    const id = `${shift ? "shift+" : ""}${key}`;
    this._shortcuts.set(id, handler);
  }

  /** @private */
  _onKeydown(e) {
    const mod = e.ctrlKey || e.metaKey;

    // Tab / Shift+Tab for indent/outdent in list context
    if (e.key === "Tab") {
      const block = this._getBlockAtCursor();
      if (block && (block.tagName === "LI" || block.closest("li"))) {
        e.preventDefault();
        if (e.shiftKey) {
          this.outdent();
        } else {
          this.indent();
        }
        return;
      }
    }

    if (!mod) return;

    const key = e.key.toLowerCase();
    const shift = e.shiftKey;

    // Look up shortcut with shift first (more specific), then without
    const shiftId = `shift+${key}`;
    const plainId = key;

    if (shift && this._shortcuts.has(shiftId)) {
      e.preventDefault();
      this._shortcuts.get(shiftId)();
      return;
    }

    if (!shift && this._shortcuts.has(plainId)) {
      e.preventDefault();
      this._shortcuts.get(plainId)();
      return;
    }

    // Link shortcut: Ctrl+K (not in shortcuts map to avoid collision handling)
    if (key === "k" && !shift) {
      e.preventDefault();
      this._el.dispatchEvent(
        new CustomEvent("editor:link-request", { bubbles: true })
      );
    }
  }
}

// =============================================================================
// Exports
// =============================================================================

// Set on window for global access (used by LiveView hooks)
if (typeof window !== "undefined") {
  window.PhiaEditorV2 = PhiaEditorV2;
}

export { PhiaHistory, PhiaInputRules, PhiaPasteRules, PhiaBlockOps };
export default PhiaEditorV2;
