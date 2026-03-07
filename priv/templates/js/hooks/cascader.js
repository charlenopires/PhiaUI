/**
 * PhiaCascader — multi-level cascading select hook.
 *
 * Reads initial options from `data-options` (JSON array of
 * `{label, value, children}` objects). Renders drill-down panels
 * inside `[data-cascader-panels]`.
 *
 * State:
 *   - `selectedPath`: array of {value, label} for each chosen level
 *
 * Events sent to LiveView:
 *   - `cascader-select`: `%{path: [value1, value2, ...]}` on complete selection
 *
 * Reads `data-value` (JSON array) to restore pre-selected path on mount.
 */
export const PhiaCascader = {
  mounted() {
    this.trigger = this.el.querySelector("[data-cascader-trigger]");
    this.panels = this.el.querySelector("[data-cascader-panels]");
    this.display = this.el.querySelector("[data-cascader-display]");
    this.hiddenInput = this.el.querySelector("[data-cascader-input]");

    this.options = JSON.parse(this.el.dataset.options || "[]");
    this.selectedPath = JSON.parse(this.el.dataset.value || "[]");

    this.open = false;

    // Click on trigger toggles the panel
    this._onTriggerClick = (e) => {
      e.stopPropagation();
      this._toggle();
    };
    this.trigger?.addEventListener("click", this._onTriggerClick);

    // Close on outside click
    this._onDocClick = (e) => {
      if (!this.el.contains(e.target)) this._close();
    };
    document.addEventListener("click", this._onDocClick);

    // Build initial panels if there's a pre-selected path
    if (this.selectedPath.length > 0) {
      this._updateDisplay();
    }
  },

  destroyed() {
    this.trigger?.removeEventListener("click", this._onTriggerClick);
    document.removeEventListener("click", this._onDocClick);
  },

  _toggle() {
    if (this.open) {
      this._close();
    } else {
      this._openPanels();
    }
  },

  _openPanels() {
    this.panels.innerHTML = "";
    this._renderLevel(this.options, 0);
    this.panels.classList.remove("hidden");
    this.open = true;
  },

  _close() {
    this.panels.classList.add("hidden");
    this.panels.innerHTML = "";
    this.open = false;
  },

  _renderLevel(options, level) {
    if (!options || options.length === 0) return;

    const ul = document.createElement("ul");
    ul.className = "min-w-[160px] max-h-60 overflow-auto p-1 border-r border-border last:border-0";
    ul.dataset.cascaderLevel = level;

    options.forEach((opt) => {
      const li = document.createElement("li");
      li.className =
        "flex cursor-pointer items-center justify-between rounded px-3 py-2 text-sm " +
        "hover:bg-accent hover:text-accent-foreground";
      li.dataset.cascaderItem = "true";
      li.dataset.level = level;
      li.dataset.value = opt.value;

      // Highlight if this value is in the selected path at this level
      if (this.selectedPath[level] === opt.value) {
        li.classList.add("bg-accent", "text-accent-foreground");
      }

      const label = document.createElement("span");
      label.textContent = opt.label;
      li.appendChild(label);

      // Arrow indicator if has children
      if (opt.children && opt.children.length > 0) {
        const arrow = document.createElement("span");
        arrow.textContent = "›";
        arrow.className = "ml-2 text-muted-foreground text-xs";
        li.appendChild(arrow);
      }

      li.addEventListener("click", (e) => {
        e.stopPropagation();
        this._selectItem(opt, level);
      });

      ul.appendChild(li);
    });

    this.panels.appendChild(ul);
  },

  _selectItem(opt, level) {
    // Truncate path to current level and set this selection
    this.selectedPath = this.selectedPath.slice(0, level);
    this.selectedPath.push(opt.value);

    // Remove panels deeper than current level
    const panelsAtLevel = this.panels.querySelectorAll("ul");
    panelsAtLevel.forEach((ul, idx) => {
      if (idx > level) ul.remove();
    });

    // Highlight selected item in current level
    const currentLevelUl = panelsAtLevel[level];
    if (currentLevelUl) {
      currentLevelUl.querySelectorAll("li").forEach((li) => {
        li.classList.remove("bg-accent", "text-accent-foreground");
        if (li.dataset.value === opt.value) {
          li.classList.add("bg-accent", "text-accent-foreground");
        }
      });
    }

    // Render next level if children exist
    if (opt.children && opt.children.length > 0) {
      this._renderLevel(opt.children, level + 1);
    } else {
      // Leaf selection — close panels and notify LiveView
      this._updateDisplay();
      this._close();
      if (this.hiddenInput) {
        this.hiddenInput.value = this.selectedPath[this.selectedPath.length - 1] || "";
      }
      this.pushEvent("cascader-select", { path: this.selectedPath });
    }

    this._updateDisplay();
  },

  _updateDisplay() {
    if (!this.display) return;

    if (this.selectedPath.length === 0) {
      // Restore placeholder text from initial render — leave as-is
      return;
    }

    // Build label from path by finding matching options
    const labels = this._pathLabels(this.options, this.selectedPath, 0);
    this.display.textContent = labels.join(" / ");
    this.display.classList.remove("text-muted-foreground");
    this.display.classList.add("text-foreground");
  },

  _pathLabels(options, path, level) {
    if (level >= path.length || !options) return [];
    const targetValue = path[level];
    const match = options.find((o) => o.value === targetValue);
    if (!match) return [targetValue];
    const rest = this._pathLabels(match.children || [], path, level + 1);
    return [match.label, ...rest];
  },
};
