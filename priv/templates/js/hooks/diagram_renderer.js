/**
 * PhiaDiagram — Mermaid subset renderer for flowchart and sequence diagrams.
 *
 * Parses a simple Mermaid-like syntax and renders SVG diagrams. Supports
 * flowchart (graph TD/LR) and sequence diagram basics. No external deps.
 *
 * Markup contract:
 *   <div phx-hook="PhiaDiagram" id="..." data-language="mermaid">
 *     <textarea data-source>...</textarea>
 *     <div data-diagram-preview></div>
 *   </div>
 */
const PhiaDiagram = {
  mounted() {
    this._sourceEl = this.el.querySelector("textarea");
    this._preview = this.el.querySelector("[data-diagram-preview]");
    if (!this._sourceEl || !this._preview) return;

    this._render();
    this._sourceEl.addEventListener("input", () => {
      clearTimeout(this._debounce);
      this._debounce = setTimeout(() => this._render(), 500);
    });
  },

  destroyed() {
    clearTimeout(this._debounce);
  },

  _render() {
    const source = this._sourceEl.value.trim();
    if (!source) {
      this._preview.innerHTML = '<span class="text-xs text-muted-foreground">No diagram source entered</span>';
      return;
    }

    try {
      if (source.startsWith("graph") || source.startsWith("flowchart")) {
        this._renderFlowchart(source);
      } else if (source.startsWith("sequenceDiagram")) {
        this._renderSequence(source);
      } else {
        this._preview.innerHTML = `<pre class="text-xs text-muted-foreground whitespace-pre-wrap">${this._esc(source)}</pre>`;
      }
    } catch (err) {
      this._preview.innerHTML = `<span class="text-xs text-destructive">Parse error: ${this._esc(err.message)}</span>`;
    }
  },

  _esc(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  },

  _renderFlowchart(source) {
    const lines = source.split("\n").map((l) => l.trim()).filter(Boolean);
    const direction = lines[0].includes("LR") ? "LR" : "TD";
    const nodes = new Map();
    const edges = [];

    for (let i = 1; i < lines.length; i++) {
      const line = lines[i].replace(/;$/, "");
      // Parse: A-->B, A-->|label|B, A[Label]-->B[Label]
      const edgeMatch = line.match(/^(\w+)(?:\[([^\]]*)\])?\s*(-+>|=+>|-.->)\s*(?:\|([^|]*)\|)?\s*(\w+)(?:\[([^\]]*)\])?$/);
      if (edgeMatch) {
        const [, fromId, fromLabel, arrow, edgeLabel, toId, toLabel] = edgeMatch;
        if (!nodes.has(fromId)) nodes.set(fromId, { id: fromId, label: fromLabel || fromId });
        if (fromLabel) nodes.get(fromId).label = fromLabel;
        if (!nodes.has(toId)) nodes.set(toId, { id: toId, label: toLabel || toId });
        if (toLabel) nodes.get(toId).label = toLabel;
        edges.push({ from: fromId, to: toId, label: edgeLabel || "", dashed: arrow.includes(".") });
        continue;
      }
      // Standalone node: A[Label]
      const nodeMatch = line.match(/^(\w+)\[([^\]]*)\]$/);
      if (nodeMatch) {
        const [, id, label] = nodeMatch;
        nodes.set(id, { id, label });
      }
    }

    if (nodes.size === 0) {
      this._preview.innerHTML = '<span class="text-xs text-muted-foreground">No nodes found</span>';
      return;
    }

    // Layout: simple grid
    const nodeList = Array.from(nodes.values());
    const nW = 120, nH = 40, gapX = 60, gapY = 60;
    const cols = direction === "LR" ? nodeList.length : Math.ceil(Math.sqrt(nodeList.length));
    const positions = new Map();

    nodeList.forEach((node, i) => {
      const col = direction === "LR" ? i : i % cols;
      const row = direction === "LR" ? 0 : Math.floor(i / cols);
      positions.set(node.id, {
        x: 20 + col * (nW + gapX),
        y: 20 + row * (nH + gapY),
        cx: 20 + col * (nW + gapX) + nW / 2,
        cy: 20 + row * (nH + gapY) + nH / 2
      });
    });

    const svgW = 40 + (direction === "LR" ? nodeList.length : cols) * (nW + gapX);
    const svgH = 40 + (direction === "LR" ? 1 : Math.ceil(nodeList.length / cols)) * (nH + gapY);

    const fg = "var(--color-foreground, #18181b)";
    const mutedFg = "var(--color-muted-foreground, #71717a)";
    const border = "var(--color-border, #e4e4e7)";
    const primary = "var(--color-primary, #3b82f6)";

    let svg = `<svg xmlns="http://www.w3.org/2000/svg" width="100%" viewBox="0 0 ${svgW} ${svgH}" class="max-w-full">`;
    svg += `<defs><marker id="arrow-${this.el.id}" viewBox="0 0 10 10" refX="10" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0 0 L10 5 L0 10 Z" fill="${mutedFg}"/></marker></defs>`;

    // Edges
    edges.forEach((e) => {
      const from = positions.get(e.from);
      const to = positions.get(e.to);
      if (!from || !to) return;
      const dash = e.dashed ? ' stroke-dasharray="5,3"' : "";
      svg += `<line x1="${from.cx}" y1="${from.cy}" x2="${to.cx}" y2="${to.cy}" stroke="${mutedFg}" stroke-width="1.5"${dash} marker-end="url(#arrow-${this.el.id})"/>`;
      if (e.label) {
        const mx = (from.cx + to.cx) / 2;
        const my = (from.cy + to.cy) / 2;
        svg += `<text x="${mx}" y="${my - 6}" text-anchor="middle" font-size="10" fill="${mutedFg}">${this._esc(e.label)}</text>`;
      }
    });

    // Nodes
    nodeList.forEach((node) => {
      const pos = positions.get(node.id);
      svg += `<rect x="${pos.x}" y="${pos.y}" width="${nW}" height="${nH}" rx="6" fill="var(--color-background, #fff)" stroke="${border}" stroke-width="1.5"/>`;
      svg += `<text x="${pos.cx}" y="${pos.cy + 4}" text-anchor="middle" font-size="12" fill="${fg}">${this._esc(node.label)}</text>`;
    });

    svg += "</svg>";
    this._preview.innerHTML = svg;
  },

  _renderSequence(source) {
    const lines = source.split("\n").map((l) => l.trim()).filter(Boolean).slice(1);
    const participants = [];
    const messages = [];

    lines.forEach((line) => {
      const partMatch = line.match(/^participant\s+(\w+)(?:\s+as\s+(.+))?$/);
      if (partMatch) {
        participants.push({ id: partMatch[1], label: partMatch[2] || partMatch[1] });
        return;
      }
      const msgMatch = line.match(/^(\w+)\s*(->>|-->|->)\s*(\w+)\s*:\s*(.+)$/);
      if (msgMatch) {
        const [, from, arrow, to, text] = msgMatch;
        if (!participants.find((p) => p.id === from)) participants.push({ id: from, label: from });
        if (!participants.find((p) => p.id === to)) participants.push({ id: to, label: to });
        messages.push({ from, to, text, dashed: arrow === "-->" });
      }
    });

    const pW = 100, gap = 60, headerH = 40, msgH = 40, pad = 20;
    const svgW = participants.length * (pW + gap) + pad;
    const svgH = headerH + messages.length * msgH + 60;

    const fg = "var(--color-foreground, #18181b)";
    const mutedFg = "var(--color-muted-foreground, #71717a)";
    const border = "var(--color-border, #e4e4e7)";

    let svg = `<svg xmlns="http://www.w3.org/2000/svg" width="100%" viewBox="0 0 ${svgW} ${svgH}" class="max-w-full">`;
    svg += `<defs><marker id="seq-arrow-${this.el.id}" viewBox="0 0 10 10" refX="10" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0 0 L10 5 L0 10 Z" fill="${mutedFg}"/></marker></defs>`;

    // Participants
    participants.forEach((p, i) => {
      const cx = pad + i * (pW + gap) + pW / 2;
      svg += `<rect x="${cx - pW / 2}" y="10" width="${pW}" height="30" rx="4" fill="var(--color-background, #fff)" stroke="${border}" stroke-width="1.5"/>`;
      svg += `<text x="${cx}" y="30" text-anchor="middle" font-size="12" fill="${fg}">${this._esc(p.label)}</text>`;
      svg += `<line x1="${cx}" y1="40" x2="${cx}" y2="${svgH - 10}" stroke="${border}" stroke-width="1" stroke-dasharray="4,3"/>`;
    });

    // Messages
    messages.forEach((msg, i) => {
      const fromIdx = participants.findIndex((p) => p.id === msg.from);
      const toIdx = participants.findIndex((p) => p.id === msg.to);
      if (fromIdx < 0 || toIdx < 0) return;
      const y = headerH + 20 + i * msgH;
      const x1 = pad + fromIdx * (pW + gap) + pW / 2;
      const x2 = pad + toIdx * (pW + gap) + pW / 2;
      const dash = msg.dashed ? ' stroke-dasharray="5,3"' : "";
      svg += `<line x1="${x1}" y1="${y}" x2="${x2}" y2="${y}" stroke="${mutedFg}" stroke-width="1.5"${dash} marker-end="url(#seq-arrow-${this.el.id})"/>`;
      const mx = (x1 + x2) / 2;
      svg += `<text x="${mx}" y="${y - 6}" text-anchor="middle" font-size="10" fill="${mutedFg}">${this._esc(msg.text)}</text>`;
    });

    svg += "</svg>";
    this._preview.innerHTML = svg;
  }
};

export default PhiaDiagram;
