// PhiaTreeSelect — hierarchical dropdown with expand/collapse
// Renders a tree from `data-options` JSON, fires phx events on selection.

const PhiaTreeSelect = {
  mounted() {
    this.options = JSON.parse(this.el.dataset.options || "[]");
    this.value = this.el.dataset.value || null;
    this.onChangeName = this.el.dataset.onchange || null;
    this.open = false;

    this.trigger = this.el.querySelector("[data-tree-trigger]");
    this.panel = this.el.querySelector("[data-tree-panel]");

    if (!this.trigger || !this.panel) return;

    this._onTriggerClick = () => this._toggle();
    this._onDocClick = (e) => {
      if (!this.el.contains(e.target)) this._close();
    };
    this._onKeydown = (e) => {
      if (e.key === "Escape") this._close();
    };

    this.trigger.addEventListener("click", this._onTriggerClick);
    document.addEventListener("click", this._onDocClick);
    document.addEventListener("keydown", this._onKeydown);

    // Wire up tree rows (server-rendered)
    this._wireRows();
    this._wireChevrons();
  },

  updated() {
    this.options = JSON.parse(this.el.dataset.options || "[]");
    this.value = this.el.dataset.value || null;
    this._wireRows();
    this._wireChevrons();
    this._updateTriggerLabel();
  },

  destroyed() {
    document.removeEventListener("click", this._onDocClick);
    document.removeEventListener("keydown", this._onKeydown);
  },

  _toggle() {
    this.open ? this._close() : this._open();
  },

  _open() {
    if (!this.panel) return;
    this.open = true;
    this.panel.classList.remove("hidden");
    this.trigger.setAttribute("aria-expanded", "true");
  },

  _close() {
    if (!this.panel) return;
    this.open = false;
    this.panel.classList.add("hidden");
    this.trigger.setAttribute("aria-expanded", "false");
  },

  _wireRows() {
    const rows = this.el.querySelectorAll("[data-tree-row]");
    rows.forEach((row) => {
      const node = row.closest("[data-tree-node]");
      if (!node) return;
      const val = node.dataset.value;
      // Remove old listener by cloning
      const fresh = row.cloneNode(true);
      row.parentNode.replaceChild(fresh, row);
      fresh.addEventListener("click", (e) => {
        e.stopPropagation();
        const hasChildren = node.dataset.hasChildren === "true";
        if (hasChildren) {
          // Toggle children expansion
          this._toggleChildren(node);
        } else {
          // Select leaf
          this._selectValue(val, node);
        }
      });
    });
  },

  _wireChevrons() {
    // Chevrons on rows with children toggle children panel
    this.el.querySelectorAll("[data-tree-chevron]").forEach((chev) => {
      chev.style.cursor = "pointer";
    });
  },

  _toggleChildren(node) {
    const childrenPanel = node.querySelector("[data-tree-children]");
    const chevron = node.querySelector("[data-tree-chevron]");
    if (!childrenPanel) return;
    const isHidden = childrenPanel.classList.contains("hidden");
    if (isHidden) {
      childrenPanel.classList.remove("hidden");
      if (chevron) chevron.style.transform = "rotate(90deg)";
    } else {
      childrenPanel.classList.add("hidden");
      if (chevron) chevron.style.transform = "";
    }
  },

  _selectValue(val, node) {
    this.value = val;
    // Update hidden input
    const input = this.el.querySelector("[data-tree-input]");
    if (input) input.value = val;
    // Update trigger label
    this._updateTriggerLabel();
    // Fire phx event
    if (this.onChangeName) {
      this.pushEvent(this.onChangeName, { value: val });
    }
    this._close();
    // Highlight active
    this.el.querySelectorAll("[data-tree-row]").forEach((r) => {
      const n = r.closest("[data-tree-node]");
      if (n && n.dataset.value === val) {
        r.classList.add("bg-accent", "font-medium");
      } else {
        r.classList.remove("bg-accent", "font-medium");
      }
    });
  },

  _updateTriggerLabel() {
    const labelEl = this.trigger && this.trigger.querySelector("span");
    if (!labelEl) return;
    const found = this._findLabel(this.options, this.value);
    if (found) {
      labelEl.textContent = found;
      labelEl.classList.remove("text-muted-foreground");
    }
  },

  _findLabel(opts, val) {
    for (const opt of opts) {
      if (opt.value === val) return opt.label;
      if (opt.children) {
        const found = this._findLabel(opt.children, val);
        if (found) return found;
      }
    }
    return null;
  },
};

export default PhiaTreeSelect;
