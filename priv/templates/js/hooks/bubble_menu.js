/**
 * PhiaBubbleMenu — Floating toolbar above text selection.
 *
 * Inspired by TipTap's BubbleMenu extension. Listens to `selectionchange` and
 * positions this element above the selected text using getBoundingClientRect().
 * Clamps to viewport edges so the menu never overflows the screen.
 *
 * HTML anatomy:
 *   <div phx-hook="PhiaBubbleMenu" data-editor-id="my-editor" class="hidden fixed ...">
 *     toolbar buttons...
 *   </div>
 *
 * The element starts with `class="hidden"`. The hook removes/adds `hidden`
 * and sets `style.top` / `style.left` based on the selection rect.
 *
 * Registration:
 *   import PhiaBubbleMenu from "./hooks/bubble_menu"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaBubbleMenu } })
 */
const PhiaBubbleMenu = {
  mounted() {
    this._editorEl = document.getElementById(this.el.dataset.editorId);

    this._onSelectionChange = () => this._update();
    document.addEventListener("selectionchange", this._onSelectionChange);

    // Toolbar buttons: propagate actions to the linked editor
    this._handleButtonClick = (e) => {
      const btn = e.target.closest("[data-action]");
      if (!btn) return;
      const action = btn.dataset.action;
      const editorHook = this._getEditorHook();
      if (editorHook) {
        editorHook._dispatchAction(action, null);
      } else {
        // Fallback: dispatch execCommand directly
        const map = {
          bold: () => document.execCommand("bold"),
          italic: () => document.execCommand("italic"),
          underline: () => document.execCommand("underline"),
          strike: () => document.execCommand("strikeThrough"),
          code: () => document.execCommand("insertHTML", false, "<code>" + window.getSelection().toString() + "</code>"),
          link: () => {
            const href = prompt("URL:");
            if (href) document.execCommand("createLink", false, href);
          },
        };
        if (map[action]) map[action]();
      }
      this._update();
    };
    this.el.addEventListener("click", this._handleButtonClick);
  },

  destroyed() {
    document.removeEventListener("selectionchange", this._onSelectionChange);
    this.el.removeEventListener("click", this._handleButtonClick);
  },

  _update() {
    const sel = window.getSelection();

    // No selection or selection collapsed (cursor only) — hide
    if (!sel || sel.isCollapsed || sel.rangeCount === 0) {
      this._hide();
      return;
    }

    // Only show when selection is inside the linked editor
    if (this._editorEl) {
      const anchorNode = sel.anchorNode;
      if (!anchorNode || !this._editorEl.contains(anchorNode)) {
        this._hide();
        return;
      }
    }

    const range = sel.getRangeAt(0);
    const rect = range.getBoundingClientRect();

    if (rect.width === 0 && rect.height === 0) {
      this._hide();
      return;
    }

    this._show(rect);
  },

  _show(selectionRect) {
    const menu = this.el;
    menu.classList.remove("hidden");
    menu.classList.add("phia-bubble-menu-open");

    // Measure menu size (must be visible first)
    const menuW = menu.offsetWidth;
    const menuH = menu.offsetHeight;

    // Position centered above the selection, with 8px gap
    let top = selectionRect.top + window.scrollY - menuH - 8;
    let left = selectionRect.left + window.scrollX + selectionRect.width / 2 - menuW / 2;

    // Clamp to viewport edges (12px margin)
    const margin = 12;
    left = Math.max(margin, Math.min(left, window.innerWidth - menuW - margin));
    top = Math.max(margin + window.scrollY, top);

    menu.style.top = top + "px";
    menu.style.left = left + "px";
  },

  _hide() {
    this.el.classList.add("hidden");
    this.el.classList.remove("phia-bubble-menu-open");
  },

  // Attempt to find the PhiaEditor / PhiaAdvancedEditor hook instance
  _getEditorHook() {
    if (!this._editorEl) return null;
    // LiveView stores hook instances on the element's __view property
    return null; // Direct execCommand fallback is used; hook wiring is done in advanced_editor.js
  },
};

export default PhiaBubbleMenu;
