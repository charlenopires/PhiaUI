/**
 * PhiaSlashCommand — "/" trigger command palette.
 *
 * Inspired by TipTap's SlashCommand / Notion-style block picker.
 * Activates when the user types "/" at the start of an empty block inside
 * the linked editor. Fuzzy-filters items by label/description on keystroke.
 * Arrow-up/down navigate; Enter selects; Escape closes.
 *
 * HTML anatomy:
 *   <div phx-hook="PhiaSlashCommand"
 *        data-editor-id="my-editor"
 *        data-on-select="block_inserted"
 *        data-items='[{"value":"h1","label":"Heading 1","icon":"H1",...}]'
 *        class="hidden fixed ...">
 *     <input data-slash-search .../>
 *     <div data-slash-list>
 *       <div data-slash-item data-value="h1">...</div>
 *     </div>
 *   </div>
 *
 * Registration:
 *   import PhiaSlashCommand from "./hooks/slash_command"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaSlashCommand } })
 */
const PhiaSlashCommand = {
  mounted() {
    this._editorEl = document.getElementById(this.el.dataset.editorId);
    this._onSelect = this.el.dataset.onSelect;
    this._allItems = this._parseItems();
    this._activeIndex = 0;

    this._searchInput = this.el.querySelector("[data-slash-search]");
    this._list = this.el.querySelector("[data-slash-list]");

    // Listen for "/" key inside the editor
    this._onEditorKeydown = (e) => this._handleEditorKeydown(e);
    this._onEditorKeyup = (e) => this._handleEditorKeyup(e);

    if (this._editorEl) {
      this._editorEl.addEventListener("keydown", this._onEditorKeydown);
      this._editorEl.addEventListener("keyup", this._onEditorKeyup);
    }

    // Search input filtering
    this._onSearchInput = () => this._filter(this._searchInput.value);
    if (this._searchInput) {
      this._searchInput.addEventListener("input", this._onSearchInput);
      this._searchInput.addEventListener("keydown", (e) => this._handleSearchKeydown(e));
    }

    // Item clicks inside the menu
    this._onItemClick = (e) => {
      const item = e.target.closest("[data-slash-item]");
      if (item) this._select(item.dataset.value);
    };
    if (this._list) {
      this._list.addEventListener("click", this._onItemClick);
    }

    // Close on outside click
    this._onOutsideClick = (e) => {
      if (!this.el.contains(e.target) && !this._editorEl?.contains(e.target)) {
        this._hide();
      }
    };
    document.addEventListener("click", this._onOutsideClick);
  },

  destroyed() {
    if (this._editorEl) {
      this._editorEl.removeEventListener("keydown", this._onEditorKeydown);
      this._editorEl.removeEventListener("keyup", this._onEditorKeyup);
    }
    document.removeEventListener("click", this._onOutsideClick);
  },

  _parseItems() {
    try {
      return JSON.parse(this.el.dataset.items || "[]");
    } catch {
      return [];
    }
  },

  _handleEditorKeydown(e) {
    if (!this._isOpen()) return;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      this._moveActive(1);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this._moveActive(-1);
    } else if (e.key === "Enter") {
      e.preventDefault();
      const visibleItems = this._visibleItems();
      if (visibleItems[this._activeIndex]) {
        this._select(visibleItems[this._activeIndex].dataset.value);
      }
    } else if (e.key === "Escape") {
      e.preventDefault();
      this._hide();
    }
  },

  _handleEditorKeyup(e) {
    if (this._isOpen()) return;
    if (e.key === "/") {
      const sel = window.getSelection();
      if (!sel || sel.rangeCount === 0) return;
      const block = this._getCurrentBlock(sel.anchorNode);
      if (block && (block.textContent === "/" || block.textContent.trimStart() === "/")) {
        this._openAt(block);
      }
    }
  },

  _handleSearchKeydown(e) {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      this._moveActive(1);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      this._moveActive(-1);
    } else if (e.key === "Enter") {
      e.preventDefault();
      const visibleItems = this._visibleItems();
      if (visibleItems[this._activeIndex]) {
        this._select(visibleItems[this._activeIndex].dataset.value);
      }
    } else if (e.key === "Escape") {
      this._hide();
    }
  },

  _openAt(block) {
    // Position below/beside the block
    const rect = block.getBoundingClientRect();
    this.el.style.top = (rect.bottom + window.scrollY + 4) + "px";
    this.el.style.left = Math.max(8, rect.left + window.scrollX) + "px";

    this._filter("");
    if (this._searchInput) this._searchInput.value = "";
    this._show();

    // Focus search after a tick
    setTimeout(() => this._searchInput?.focus(), 50);
  },

  _filter(query) {
    const q = query.toLowerCase().trim();
    const items = this._list?.querySelectorAll("[data-slash-item]") || [];
    let first = true;

    items.forEach((item, idx) => {
      const label = (item.textContent || "").toLowerCase();
      const matches = q === "" || label.includes(q);
      item.style.display = matches ? "" : "none";
      if (matches && first) {
        this._activeIndex = idx;
        first = false;
      }
    });

    this._updateActiveHighlight();
  },

  _select(value) {
    // Remove the "/" from the editor
    if (this._editorEl) {
      const sel = window.getSelection();
      if (sel && sel.rangeCount > 0) {
        const block = this._getCurrentBlock(sel.anchorNode);
        if (block && block.textContent.trimStart().startsWith("/")) {
          block.textContent = "";
        }
      }
      this._editorEl.focus();

      // Execute the block action
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
      if (actionMap[value]) actionMap[value]();
    }

    // Push LiveView event
    if (this._onSelect) {
      this.pushEvent(this._onSelect, { value });
    }

    this._hide();
  },

  _moveActive(delta) {
    const visible = this._visibleItems();
    if (visible.length === 0) return;
    this._activeIndex = (this._activeIndex + delta + visible.length) % visible.length;
    this._updateActiveHighlight();
  },

  _visibleItems() {
    return Array.from(this._list?.querySelectorAll("[data-slash-item]") || [])
      .filter(el => el.style.display !== "none");
  },

  _updateActiveHighlight() {
    const visible = this._visibleItems();
    visible.forEach((el, idx) => {
      el.classList.toggle("bg-accent", idx === this._activeIndex);
    });
    // Scroll active item into view
    if (visible[this._activeIndex]) {
      visible[this._activeIndex].scrollIntoView({ block: "nearest" });
    }
  },

  _getCurrentBlock(node) {
    if (!node) return null;
    let el = node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    const blockTags = ["P", "DIV", "H1", "H2", "H3", "H4", "H5", "H6",
                       "LI", "BLOCKQUOTE", "PRE"];
    while (el && !blockTags.includes(el.tagName)) {
      el = el.parentElement;
    }
    return el;
  },

  _isOpen() {
    return !this.el.classList.contains("hidden");
  },

  _show() {
    this.el.classList.remove("hidden");
    this.el.classList.add("phia-slash-menu-open");
  },

  _hide() {
    this.el.classList.add("hidden");
    this.el.classList.remove("phia-slash-menu-open");
    this._activeIndex = 0;
  },
};

export default PhiaSlashCommand;
