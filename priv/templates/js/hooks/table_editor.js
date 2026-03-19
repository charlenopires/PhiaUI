/**
 * PhiaTableEditor — interactive table editing for the rich text editor.
 *
 * Features: cell selection (click/shift/drag), Tab navigation, column resize
 * (drag border), row/col add buttons on hover, cell merge. Pushes table
 * mutation events to the server.
 *
 * Markup contract:
 *   <div phx-hook="PhiaTableEditor" id="..." data-editor-id="...">
 *     <table>...</table>
 *   </div>
 */
const PhiaTableEditor = {
  mounted() {
    this._table = this.el.querySelector("table");
    if (!this._table) return;

    this._editorId = this.el.dataset.editorId || this.el.id;
    this._selectedCells = new Set();
    this._isSelecting = false;
    this._startCell = null;
    this._resizing = false;
    this._resizeCol = -1;
    this._resizeStartX = 0;
    this._resizeStartW = 0;

    this._initCellSelection();
    this._initTabNavigation();
    this._initColumnResize();
    this._initHoverControls();
  },

  destroyed() {
    document.removeEventListener("pointermove", this._onResizeMove);
    document.removeEventListener("pointerup", this._onResizeUp);
  },

  // ── Cell Selection ──────────────────────────────────────────────────────

  _initCellSelection() {
    this._table.addEventListener("pointerdown", (e) => {
      const cell = e.target.closest("td, th");
      if (!cell) return;
      if (e.target.closest("[data-resize-handle]")) return;

      e.preventDefault();
      this._isSelecting = true;
      this._startCell = cell;

      if (!e.shiftKey) {
        this._clearSelection();
      }
      this._selectCell(cell);

      const onMove = (ev) => {
        const target = document.elementFromPoint(ev.clientX, ev.clientY);
        const c = target && target.closest("td, th");
        if (c && this._table.contains(c)) {
          this._selectRange(this._startCell, c);
        }
      };

      const onUp = () => {
        this._isSelecting = false;
        document.removeEventListener("pointermove", onMove);
        document.removeEventListener("pointerup", onUp);
      };

      document.addEventListener("pointermove", onMove);
      document.addEventListener("pointerup", onUp);
    });
  },

  _selectCell(cell) {
    cell.classList.add("phia-cell-selected");
    cell.style.outline = "2px solid var(--color-primary, #3b82f6)";
    cell.style.outlineOffset = "-2px";
    this._selectedCells.add(cell);
  },

  _clearSelection() {
    this._selectedCells.forEach((cell) => {
      cell.classList.remove("phia-cell-selected");
      cell.style.outline = "";
      cell.style.outlineOffset = "";
    });
    this._selectedCells.clear();
  },

  _selectRange(start, end) {
    this._clearSelection();
    const sr = start.closest("tr");
    const er = end.closest("tr");
    if (!sr || !er) return;

    const rows = Array.from(this._table.querySelectorAll("tr"));
    const r1 = rows.indexOf(sr);
    const r2 = rows.indexOf(er);
    const c1 = this._cellIndex(start);
    const c2 = this._cellIndex(end);
    const rMin = Math.min(r1, r2);
    const rMax = Math.max(r1, r2);
    const cMin = Math.min(c1, c2);
    const cMax = Math.max(c1, c2);

    for (let r = rMin; r <= rMax; r++) {
      const cells = rows[r].querySelectorAll("td, th");
      for (let c = cMin; c <= cMax && c < cells.length; c++) {
        this._selectCell(cells[c]);
      }
    }
  },

  _cellIndex(cell) {
    return Array.from(cell.parentElement.children).indexOf(cell);
  },

  // ── Tab Navigation ──────────────────────────────────────────────────────

  _initTabNavigation() {
    this._table.addEventListener("keydown", (e) => {
      if (e.key !== "Tab") return;
      e.preventDefault();

      const active = document.activeElement;
      const cell = active && active.closest("td, th");
      if (!cell || !this._table.contains(cell)) return;

      const allCells = Array.from(this._table.querySelectorAll("td, th"));
      const idx = allCells.indexOf(cell);
      const next = e.shiftKey ? idx - 1 : idx + 1;

      if (next >= 0 && next < allCells.length) {
        allCells[next].setAttribute("tabindex", "0");
        allCells[next].focus();
        this._clearSelection();
        this._selectCell(allCells[next]);
      } else if (!e.shiftKey && next >= allCells.length) {
        this._addRow("below");
        requestAnimationFrame(() => {
          const newCells = Array.from(this._table.querySelectorAll("td, th"));
          const last = newCells[newCells.length - 1];
          if (last) {
            last.setAttribute("tabindex", "0");
            last.focus();
          }
        });
      }
    });
  },

  // ── Column Resize ───────────────────────────────────────────────────────

  _initColumnResize() {
    const headerCells = this._table.querySelectorAll("th, thead td");
    headerCells.forEach((cell, idx) => {
      const handle = document.createElement("div");
      handle.dataset.resizeHandle = "true";
      handle.style.cssText = `
        position: absolute; right: -2px; top: 0; bottom: 0; width: 4px;
        cursor: col-resize; z-index: 5; background: transparent;
      `;
      handle.addEventListener("mouseenter", () => {
        handle.style.background = "var(--color-primary, #3b82f6)";
      });
      handle.addEventListener("mouseleave", () => {
        if (!this._resizing) handle.style.background = "transparent";
      });

      cell.style.position = "relative";
      cell.appendChild(handle);

      handle.addEventListener("pointerdown", (e) => {
        e.preventDefault();
        e.stopPropagation();
        this._resizing = true;
        this._resizeCol = idx;
        this._resizeStartX = e.clientX;
        this._resizeStartW = cell.offsetWidth;

        this._onResizeMove = (ev) => {
          const dx = ev.clientX - this._resizeStartX;
          const newW = Math.max(40, this._resizeStartW + dx);
          cell.style.width = `${newW}px`;
          cell.style.minWidth = `${newW}px`;
        };

        this._onResizeUp = () => {
          this._resizing = false;
          handle.style.background = "transparent";
          document.removeEventListener("pointermove", this._onResizeMove);
          document.removeEventListener("pointerup", this._onResizeUp);
        };

        document.addEventListener("pointermove", this._onResizeMove);
        document.addEventListener("pointerup", this._onResizeUp);
      });
    });
  },

  // ── Hover Controls (add row/col) ────────────────────────────────────────

  _initHoverControls() {
    this._addRowBtn = this._createAddButton("row", "+");
    this._addColBtn = this._createAddButton("col", "+");
    this.el.appendChild(this._addRowBtn);
    this.el.appendChild(this._addColBtn);

    this.el.style.position = "relative";

    this.el.addEventListener("mousemove", (e) => {
      const rect = this._table.getBoundingClientRect();
      const bottom = rect.bottom - this.el.getBoundingClientRect().top;
      const right = rect.right - this.el.getBoundingClientRect().left;

      this._addRowBtn.style.top = `${bottom + 4}px`;
      this._addRowBtn.style.left = `${(rect.width / 2) - 12}px`;
      this._addRowBtn.style.display = "flex";

      this._addColBtn.style.top = `${(rect.height / 2) - 12}px`;
      this._addColBtn.style.left = `${right + 4}px`;
      this._addColBtn.style.display = "flex";
    });

    this.el.addEventListener("mouseleave", () => {
      this._addRowBtn.style.display = "none";
      this._addColBtn.style.display = "none";
    });

    this._addRowBtn.addEventListener("click", () => this._addRow("below"));
    this._addColBtn.addEventListener("click", () => this._addCol("right"));
  },

  _createAddButton(type, label) {
    const btn = document.createElement("button");
    btn.type = "button";
    btn.textContent = label;
    btn.setAttribute("aria-label", `Add ${type}`);
    btn.style.cssText = `
      position: absolute; display: none; align-items: center; justify-content: center;
      width: 24px; height: 24px; border-radius: 50%; border: 1px solid var(--color-border, #e5e7eb);
      background: var(--color-background, #fff); color: var(--color-muted-foreground, #6b7280);
      font-size: 14px; cursor: pointer; z-index: 10; transition: all 150ms;
    `;
    btn.addEventListener("mouseenter", () => {
      btn.style.borderColor = "var(--color-primary, #3b82f6)";
      btn.style.color = "var(--color-primary, #3b82f6)";
    });
    btn.addEventListener("mouseleave", () => {
      btn.style.borderColor = "var(--color-border, #e5e7eb)";
      btn.style.color = "var(--color-muted-foreground, #6b7280)";
    });
    return btn;
  },

  _addRow(position) {
    const rows = this._table.querySelectorAll("tr");
    if (rows.length === 0) return;
    const refRow = rows[rows.length - 1];
    const colCount = refRow.querySelectorAll("td, th").length;
    const newRow = document.createElement("tr");

    for (let i = 0; i < colCount; i++) {
      const td = document.createElement("td");
      td.setAttribute("contenteditable", "true");
      td.style.cssText = "padding: 8px 12px; border: 1px solid var(--color-border, #e5e7eb); min-width: 40px;";
      td.innerHTML = "<br>";
      newRow.appendChild(td);
    }

    if (position === "below") {
      refRow.parentNode.insertBefore(newRow, refRow.nextSibling);
    } else {
      refRow.parentNode.insertBefore(newRow, refRow);
    }

    this.pushEvent("table:mutation", { id: this._editorId, action: "add_row", position });
  },

  _addCol(position) {
    const rows = this._table.querySelectorAll("tr");
    rows.forEach((row) => {
      const cells = row.querySelectorAll("td, th");
      const isHeader = row.closest("thead");
      const cell = document.createElement(isHeader ? "th" : "td");
      cell.setAttribute("contenteditable", "true");
      cell.style.cssText = "padding: 8px 12px; border: 1px solid var(--color-border, #e5e7eb); min-width: 40px;";
      cell.innerHTML = "<br>";

      if (position === "right") {
        row.appendChild(cell);
      } else {
        row.insertBefore(cell, cells[0]);
      }
    });

    this.pushEvent("table:mutation", { id: this._editorId, action: "add_col", position });
  },

  // ── Merge Cells ─────────────────────────────────────────────────────────

  mergeCells() {
    if (this._selectedCells.size < 2) return;
    const cells = Array.from(this._selectedCells);
    const first = cells[0];
    const combinedText = cells.map((c) => c.textContent).join(" ");

    cells.slice(1).forEach((c) => c.remove());
    first.textContent = combinedText;
    first.colSpan = cells.length;

    this._clearSelection();
    this._selectCell(first);

    this.pushEvent("table:mutation", { id: this._editorId, action: "merge_cells" });
  }
};

export default PhiaTableEditor;
