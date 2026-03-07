/**
 * PhiaFloatingMenu — Block-insertion menu at an empty cursor line.
 *
 * Inspired by TipTap's FloatingMenu extension. Shows this panel when the
 * cursor is positioned on an empty block element inside the linked editor.
 * Positions the menu to the left of the cursor using caret coordinates.
 *
 * HTML anatomy:
 *   <div phx-hook="PhiaFloatingMenu" data-editor-id="my-editor" data-trigger="empty_line"
 *        class="hidden fixed ...">
 *     action buttons...
 *   </div>
 *
 * data-trigger values:
 *   - "empty_line" (default): show on empty paragraph/div
 *   - "slash": show after "/" at start of empty block
 *
 * Registration:
 *   import PhiaFloatingMenu from "./hooks/floating_menu"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaFloatingMenu } })
 */
const PhiaFloatingMenu = {
  mounted() {
    this._editorEl = document.getElementById(this.el.dataset.editorId);
    this._trigger = this.el.dataset.trigger || "empty_line";

    this._onSelectionChange = () => this._check();
    this._onKeyup = (e) => {
      // Hide on any character input or Escape
      if (e.key === "Escape") this._hide();
      else this._check();
    };
    this._onClickOutside = (e) => {
      if (!this.el.contains(e.target) && !this._editorEl?.contains(e.target)) {
        this._hide();
      }
    };

    document.addEventListener("selectionchange", this._onSelectionChange);
    if (this._editorEl) {
      this._editorEl.addEventListener("keyup", this._onKeyup);
    }
    document.addEventListener("click", this._onClickOutside);

    // Button clicks inside floating menu
    this._handleButtonClick = (e) => {
      const btn = e.target.closest("[data-action]");
      if (!btn) return;
      const action = btn.dataset.action;
      this._dispatchToEditor(action);
      this._hide();
    };
    this.el.addEventListener("click", this._handleButtonClick);
  },

  destroyed() {
    document.removeEventListener("selectionchange", this._onSelectionChange);
    document.removeEventListener("click", this._onClickOutside);
    if (this._editorEl) {
      this._editorEl.removeEventListener("keyup", this._onKeyup);
    }
    this.el.removeEventListener("click", this._handleButtonClick);
  },

  _check() {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0 || !sel.isCollapsed) {
      this._hide();
      return;
    }

    const anchorNode = sel.anchorNode;
    if (!this._editorEl || !this._editorEl.contains(anchorNode)) {
      this._hide();
      return;
    }

    // Find the block-level element containing the cursor
    let block = anchorNode.nodeType === Node.TEXT_NODE
      ? anchorNode.parentElement
      : anchorNode;

    while (block && block !== this._editorEl && !this._isBlock(block)) {
      block = block.parentElement;
    }

    if (!block || block === this._editorEl) {
      this._hide();
      return;
    }

    const isEmpty = block.innerHTML === "" || block.innerHTML === "<br>";

    if (this._trigger === "empty_line" && isEmpty) {
      this._positionAtBlock(block);
      this._show();
    } else if (this._trigger === "slash" && block.textContent.trimStart().startsWith("/")) {
      this._positionAtBlock(block);
      this._show();
    } else {
      this._hide();
    }
  },

  _isBlock(el) {
    const blockTags = ["P", "DIV", "H1", "H2", "H3", "H4", "H5", "H6",
                       "LI", "BLOCKQUOTE", "PRE"];
    return blockTags.includes(el.tagName);
  },

  _positionAtBlock(block) {
    const rect = block.getBoundingClientRect();
    const menuH = this.el.offsetHeight;

    // Show to the left of the block, vertically centered
    const top = rect.top + window.scrollY + rect.height / 2 - menuH / 2;
    const left = rect.left + window.scrollX - this.el.offsetWidth - 8;

    this.el.style.top = Math.max(8, top) + "px";
    this.el.style.left = Math.max(8, left) + "px";
  },

  _show() {
    this.el.classList.remove("hidden");
  },

  _hide() {
    this.el.classList.add("hidden");
  },

  _dispatchToEditor(action) {
    if (!this._editorEl) return;
    const actionMap = {
      h1: () => document.execCommand("formatBlock", false, "<h1>"),
      h2: () => document.execCommand("formatBlock", false, "<h2>"),
      h3: () => document.execCommand("formatBlock", false, "<h3>"),
      paragraph: () => document.execCommand("formatBlock", false, "<p>"),
      bulletList: () => document.execCommand("insertUnorderedList"),
      orderedList: () => document.execCommand("insertOrderedList"),
      blockquote: () => document.execCommand("formatBlock", false, "<blockquote>"),
      codeBlock: () => document.execCommand("formatBlock", false, "<pre>"),
    };
    if (actionMap[action]) {
      this._editorEl.focus();
      actionMap[action]();
    }
  },
};

export default PhiaFloatingMenu;
