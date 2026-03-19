/**
 * PhiaTrackChanges — change tracking engine for the rich text editor.
 *
 * Three modes: Editing (no tracking), Suggesting (wraps changes in
 * <ins>/<del>), Viewing (read-only with change decorations).
 *
 * Inserts are wrapped in <ins class="phia-tc-ins">, deletes in
 * <del class="phia-tc-del">. Accept/reject via DOM manipulation.
 *
 * Markup contract:
 *   <div phx-hook="PhiaTrackChanges" id="..." data-editor-id="..."
 *        data-mode="suggesting" data-author="User Name" data-author-color="#3b82f6">
 *     <div data-rich-content>...</div>
 *   </div>
 */
const PhiaTrackChanges = {
  mounted() {
    this._editorId = this.el.dataset.editorId || this.el.id;
    this._contentEl = this.el.querySelector("[data-rich-content]");
    this._mode = this.el.dataset.mode || "editing"; // editing | suggesting | viewing
    this._author = this.el.dataset.author || "Anonymous";
    this._authorColor = this.el.dataset.authorColor || "#3b82f6";
    this._changeCounter = 0;

    if (this._contentEl) {
      this._bindModeEvents();
    }

    // Server-driven mode changes
    this.handleEvent(`tc:mode:${this.el.id}`, ({ mode }) => {
      this._setMode(mode);
    });

    // Accept/reject from server
    this.handleEvent(`tc:accept:${this.el.id}`, ({ change_id }) => {
      this._acceptChange(change_id);
    });

    this.handleEvent(`tc:reject:${this.el.id}`, ({ change_id }) => {
      this._rejectChange(change_id);
    });

    this.handleEvent(`tc:accept-all:${this.el.id}`, () => {
      this._acceptAll();
    });

    this.handleEvent(`tc:reject-all:${this.el.id}`, () => {
      this._rejectAll();
    });
  },

  destroyed() {
    this._unbindModeEvents();
  },

  _setMode(mode) {
    this._mode = mode;
    this._unbindModeEvents();
    this._bindModeEvents();

    if (mode === "viewing" && this._contentEl) {
      this._contentEl.setAttribute("contenteditable", "false");
    } else if (this._contentEl) {
      this._contentEl.setAttribute("contenteditable", "true");
    }

    this.el.dataset.mode = mode;
  },

  _bindModeEvents() {
    if (this._mode !== "suggesting" || !this._contentEl) return;

    this._onBeforeInput = (e) => this._handleBeforeInput(e);
    this._onKeyDown = (e) => this._handleKeyDown(e);

    this._contentEl.addEventListener("beforeinput", this._onBeforeInput);
    this._contentEl.addEventListener("keydown", this._onKeyDown);
  },

  _unbindModeEvents() {
    if (this._contentEl) {
      if (this._onBeforeInput) this._contentEl.removeEventListener("beforeinput", this._onBeforeInput);
      if (this._onKeyDown) this._contentEl.removeEventListener("keydown", this._onKeyDown);
    }
  },

  _handleBeforeInput(e) {
    if (this._mode !== "suggesting") return;

    const sel = window.getSelection();
    if (!sel.rangeCount) return;

    if (e.inputType === "insertText" || e.inputType === "insertParagraph") {
      // Don't prevent — but wrap the inserted text in <ins> after
      requestAnimationFrame(() => this._wrapLatestInsertion());
    } else if (e.inputType === "deleteContentBackward" || e.inputType === "deleteContentForward") {
      e.preventDefault();
      this._markDeletion(sel);
    }
  },

  _handleKeyDown(e) {
    if (this._mode !== "suggesting") return;

    // Prevent cut in suggesting mode — mark as deletion instead
    if ((e.ctrlKey || e.metaKey) && e.key === "x") {
      e.preventDefault();
      const sel = window.getSelection();
      if (sel.rangeCount) {
        this._markDeletion(sel);
      }
    }
  },

  _wrapLatestInsertion() {
    const sel = window.getSelection();
    if (!sel.rangeCount) return;

    const node = sel.anchorNode;
    if (!node || !this._contentEl.contains(node)) return;

    // Check if already inside an <ins>
    if (node.parentElement && node.parentElement.closest("ins.phia-tc-ins")) return;

    // Find the text node and wrap recent text
    if (node.nodeType === Node.TEXT_NODE && node.textContent) {
      const ins = document.createElement("ins");
      ins.className = "phia-tc-ins";
      ins.dataset.changeId = this._nextChangeId();
      ins.dataset.author = this._author;
      ins.dataset.timestamp = new Date().toISOString();
      ins.style.borderBottom = `2px solid ${this._authorColor}`;

      // Wrap the text node
      const parent = node.parentNode;
      parent.insertBefore(ins, node);
      ins.appendChild(node);

      // Restore cursor at end
      const range = document.createRange();
      range.setStartAfter(ins);
      range.collapse(true);
      sel.removeAllRanges();
      sel.addRange(range);
    }
  },

  _markDeletion(sel) {
    const range = sel.getRangeAt(0);
    if (range.collapsed) {
      // Backspace on collapsed selection — select previous character
      const newRange = range.cloneRange();
      newRange.setStart(range.startContainer, Math.max(0, range.startOffset - 1));
      sel.removeAllRanges();
      sel.addRange(newRange);
    }

    const selectedRange = sel.getRangeAt(0);
    if (selectedRange.collapsed) return;

    const contents = selectedRange.extractContents();
    const del = document.createElement("del");
    del.className = "phia-tc-del";
    del.dataset.changeId = this._nextChangeId();
    del.dataset.author = this._author;
    del.dataset.timestamp = new Date().toISOString();
    del.style.textDecoration = "line-through";
    del.style.color = "var(--color-destructive, #ef4444)";
    del.style.opacity = "0.7";
    del.appendChild(contents);

    selectedRange.insertNode(del);

    // Move cursor after the <del>
    const newRange = document.createRange();
    newRange.setStartAfter(del);
    newRange.collapse(true);
    sel.removeAllRanges();
    sel.addRange(newRange);

    this._pushChangeEvent("deletion", del.dataset.changeId);
  },

  _acceptChange(changeId) {
    const el = this._contentEl.querySelector(`[data-change-id="${changeId}"]`);
    if (!el) return;

    if (el.tagName === "INS") {
      // Accept insertion: unwrap <ins>, keep content
      const parent = el.parentNode;
      while (el.firstChild) parent.insertBefore(el.firstChild, el);
      el.remove();
    } else if (el.tagName === "DEL") {
      // Accept deletion: remove the <del> and its content
      el.remove();
    }

    this._pushChangeEvent("accepted", changeId);
  },

  _rejectChange(changeId) {
    const el = this._contentEl.querySelector(`[data-change-id="${changeId}"]`);
    if (!el) return;

    if (el.tagName === "INS") {
      // Reject insertion: remove <ins> and its content
      el.remove();
    } else if (el.tagName === "DEL") {
      // Reject deletion: unwrap <del>, keep content
      const parent = el.parentNode;
      while (el.firstChild) parent.insertBefore(el.firstChild, el);
      el.remove();
    }

    this._pushChangeEvent("rejected", changeId);
  },

  _acceptAll() {
    const changes = this._contentEl.querySelectorAll(".phia-tc-ins, .phia-tc-del");
    changes.forEach((el) => {
      const id = el.dataset.changeId;
      if (el.tagName === "INS") {
        const parent = el.parentNode;
        while (el.firstChild) parent.insertBefore(el.firstChild, el);
        el.remove();
      } else if (el.tagName === "DEL") {
        el.remove();
      }
    });
    this._pushChangeEvent("accepted_all", null);
  },

  _rejectAll() {
    const changes = this._contentEl.querySelectorAll(".phia-tc-ins, .phia-tc-del");
    changes.forEach((el) => {
      if (el.tagName === "INS") {
        el.remove();
      } else if (el.tagName === "DEL") {
        const parent = el.parentNode;
        while (el.firstChild) parent.insertBefore(el.firstChild, el);
        el.remove();
      }
    });
    this._pushChangeEvent("rejected_all", null);
  },

  _nextChangeId() {
    this._changeCounter++;
    return `tc-${this.el.id}-${this._changeCounter}-${Date.now()}`;
  },

  _pushChangeEvent(action, changeId) {
    this.pushEvent("track-changes:update", {
      editor_id: this._editorId,
      action,
      change_id: changeId
    });
  }
};

export default PhiaTrackChanges;
