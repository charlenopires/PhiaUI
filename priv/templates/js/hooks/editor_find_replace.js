/**
 * PhiaEditorFindReplace — Slide-in search + replace bar for contenteditable editors.
 *
 * Opens on Ctrl/Cmd+F inside the linked editor.
 * Highlights all matches with <mark class="phia-find-mark"> elements.
 * Supports find next/prev, replace single, replace all.
 *
 * HTML anatomy (rendered by editor_find_replace/1):
 *   <div phx-hook="PhiaEditorFindReplace" data-editor-id="my-editor"
 *        data-find-bar class="hidden">
 *     <input data-find-input />
 *     <span data-find-count></span>
 *     <button data-find-prev />
 *     <button data-find-next />
 *     <input data-replace-input />
 *     <button data-replace-one />
 *     <button data-replace-all />
 *     <button data-find-close />
 *   </div>
 *
 * Registration:
 *   import PhiaEditorFindReplace from "./hooks/editor_find_replace"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaEditorFindReplace } })
 */
const PhiaEditorFindReplace = {
  mounted() {
    this._editorEl = document.getElementById(this.el.dataset.editorId);
    this._currentIndex = 0;
    this._marks = [];

    this._findInput = this.el.querySelector("[data-find-input]");
    this._replaceInput = this.el.querySelector("[data-replace-input]");
    this._countEl = this.el.querySelector("[data-find-count]");

    // Ctrl/Cmd+F inside the editor
    this._onEditorKeydown = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === "f") {
        e.preventDefault();
        this._open();
      }
    };

    // Search input events
    this._onFindInput = () => {
      this._highlight(this._findInput?.value || "");
    };

    this._onFindKeydown = (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        e.shiftKey ? this._prev() : this._next();
      } else if (e.key === "Escape") {
        this._close();
      }
    };

    // Button events
    this._onPrev = () => this._prev();
    this._onNext = () => this._next();
    this._onReplaceOne = () => this._replaceCurrent();
    this._onReplaceAll = () => this._replaceAllMatches();
    this._onClose = () => this._close();

    // Wire up
    if (this._editorEl) {
      this._editorEl.addEventListener("keydown", this._onEditorKeydown);
    }
    this._findInput?.addEventListener("input", this._onFindInput);
    this._findInput?.addEventListener("keydown", this._onFindKeydown);

    this.el.querySelector("[data-find-prev]")?.addEventListener("click", this._onPrev);
    this.el.querySelector("[data-find-next]")?.addEventListener("click", this._onNext);
    this.el.querySelector("[data-replace-one]")?.addEventListener("click", this._onReplaceOne);
    this.el.querySelector("[data-replace-all]")?.addEventListener("click", this._onReplaceAll);
    this.el.querySelectorAll("[data-find-close]").forEach(btn =>
      btn.addEventListener("click", this._onClose)
    );
  },

  destroyed() {
    this._clearMarks();
    if (this._editorEl) {
      this._editorEl.removeEventListener("keydown", this._onEditorKeydown);
    }
  },

  _open() {
    this.el.classList.remove("hidden");
    this.el.classList.add("phia-find-bar-open");
    this._findInput?.focus();
    this._findInput?.select();
    if (this._findInput?.value) {
      this._highlight(this._findInput.value);
    }
  },

  _close() {
    this.el.classList.add("hidden");
    this.el.classList.remove("phia-find-bar-open");
    this._clearMarks();
    this._editorEl?.focus();
  },

  _highlight(query) {
    this._clearMarks();
    if (!query || !this._editorEl) {
      this._updateCount(0);
      return;
    }

    const walker = document.createTreeWalker(
      this._editorEl,
      NodeFilter.SHOW_TEXT,
      null
    );

    const matches = [];
    let node;
    while ((node = walker.nextNode())) {
      const text = node.textContent;
      const lowerText = text.toLowerCase();
      const lowerQuery = query.toLowerCase();
      let idx = 0;
      while ((idx = lowerText.indexOf(lowerQuery, idx)) !== -1) {
        matches.push({ node, start: idx, end: idx + query.length });
        idx += query.length;
      }
    }

    // Wrap matches in <mark> from last to first to preserve offsets
    for (let i = matches.length - 1; i >= 0; i--) {
      const { node, start, end } = matches[i];
      try {
        const range = document.createRange();
        range.setStart(node, start);
        range.setEnd(node, end);
        const mark = document.createElement("mark");
        mark.className = "phia-find-mark bg-yellow-200 dark:bg-yellow-700/60 rounded-sm";
        range.surroundContents(mark);
        this._marks.unshift(mark); // prepend to maintain order
      } catch {
        // Skip nodes that can't be wrapped (e.g., cross-element selections)
      }
    }

    this._currentIndex = 0;
    this._updateCount(this._marks.length);
    this._scrollToMark(0);
  },

  _clearMarks() {
    this._marks.forEach(mark => {
      if (mark.parentNode) {
        const text = document.createTextNode(mark.textContent);
        mark.parentNode.replaceChild(text, mark);
      }
    });
    // Normalize text nodes to merge adjacent ones
    this._editorEl?.normalize();
    this._marks = [];
    this._currentIndex = 0;
    this._updateCount(0);
  },

  _next() {
    if (this._marks.length === 0) return;
    this._currentIndex = (this._currentIndex + 1) % this._marks.length;
    this._scrollToMark(this._currentIndex);
    this._updateCount(this._marks.length);
  },

  _prev() {
    if (this._marks.length === 0) return;
    this._currentIndex = (this._currentIndex - 1 + this._marks.length) % this._marks.length;
    this._scrollToMark(this._currentIndex);
    this._updateCount(this._marks.length);
  },

  _scrollToMark(index) {
    const mark = this._marks[index];
    if (!mark) return;
    // Highlight current mark
    this._marks.forEach((m, i) => {
      m.classList.toggle("ring-2", i === index);
      m.classList.toggle("ring-orange-400", i === index);
    });
    mark.scrollIntoView({ block: "nearest", behavior: "smooth" });
  },

  _replaceCurrent() {
    const replaceWith = this._replaceInput?.value || "";
    const mark = this._marks[this._currentIndex];
    if (!mark) return;

    const text = document.createTextNode(replaceWith);
    mark.parentNode?.replaceChild(text, mark);
    this._marks.splice(this._currentIndex, 1);

    if (this._currentIndex >= this._marks.length) {
      this._currentIndex = Math.max(0, this._marks.length - 1);
    }
    this._updateCount(this._marks.length);
    if (this._marks.length > 0) this._scrollToMark(this._currentIndex);
  },

  _replaceAllMatches() {
    const replaceWith = this._replaceInput?.value || "";
    [...this._marks].forEach(mark => {
      if (mark.parentNode) {
        const text = document.createTextNode(replaceWith);
        mark.parentNode.replaceChild(text, mark);
      }
    });
    this._marks = [];
    this._editorEl?.normalize();
    this._currentIndex = 0;
    this._updateCount(0);
  },

  _updateCount(total) {
    if (!this._countEl) return;
    if (total === 0) {
      this._countEl.textContent = "";
    } else {
      this._countEl.textContent = `${this._currentIndex + 1}/${total}`;
    }
  },
};

export default PhiaEditorFindReplace;
