/**
 * PhiaVirtualTree — Virtual rendering for large tree datasets.
 *
 * Renders only visible rows based on scroll position.
 * Owns the DOM (uses phx-update="ignore" on the host element).
 * Receives node updates via handleEvent("update-nodes").
 *
 * data-nodes — JSON flat list of {id, label, depth, expandable, expanded}
 * data-row-height — height of each row in pixels
 * data-height — container height in pixels
 */
const PhiaVirtualTree = {
  mounted() {
    this._rowHeight = parseInt(this.el.dataset.rowHeight || '32', 10)
    this._nodes = JSON.parse(this.el.dataset.nodes || '[]')
    this._expanded = new Set()
    this._scrollHandler = () => this._render()
    this.el.addEventListener('scroll', this._scrollHandler)

    this.handleEvent('update-nodes', ({ nodes }) => {
      this._nodes = nodes
      this._render()
    })

    this._render()
  },

  destroyed() {
    this.el.removeEventListener('scroll', this._scrollHandler)
  },

  _visibleNodes() {
    return this._nodes.filter((n) => {
      // A node is visible if none of its ancestors are collapsed
      let parentDepth = n.depth - 1
      if (parentDepth < 0) return true
      // Simplified: check if any ancestor is collapsed
      const nodeIdx = this._nodes.indexOf(n)
      for (let i = nodeIdx - 1; i >= 0; i--) {
        const candidate = this._nodes[i]
        if (candidate.depth < n.depth) {
          if (candidate.expandable && !this._expanded.has(candidate.id)) {
            return false
          }
          break
        }
      }
      return true
    })
  },

  _render() {
    const visible = this._visibleNodes()
    const totalHeight = visible.length * this._rowHeight
    const scrollTop = this.el.scrollTop
    const viewHeight = this.el.offsetHeight
    const startIdx = Math.floor(scrollTop / this._rowHeight)
    const endIdx = Math.min(visible.length - 1, Math.ceil((scrollTop + viewHeight) / this._rowHeight))
    const rowH = this._rowHeight

    let html = `<div style="height:${totalHeight}px;position:relative;">`
    for (let i = startIdx; i <= endIdx; i++) {
      const node = visible[i]
      if (!node) continue
      const top = i * rowH
      const indent = node.depth * 16
      const isExpanded = this._expanded.has(node.id)
      html += `
        <div
          role="treeitem"
          aria-expanded="${node.expandable ? isExpanded : undefined}"
          style="position:absolute;top:${top}px;left:0;right:0;height:${rowH}px;display:flex;align-items:center;padding-left:${8 + indent}px;"
          class="hover:bg-accent hover:text-accent-foreground cursor-pointer text-sm px-2"
          data-virtual-id="${node.id}"
        >
          ${node.expandable ? `<span style="margin-right:4px;font-size:10px;transform:rotate(${isExpanded ? 90 : 0}deg);display:inline-block;transition:transform 150ms;">▶</span>` : '<span style="width:14px;display:inline-block;"></span>'}
          <span style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${this._escape(node.label)}</span>
        </div>
      `
    }
    html += '</div>'
    this.el.innerHTML = html

    // Bind click handlers
    this.el.querySelectorAll('[data-virtual-id]').forEach((row) => {
      row.addEventListener('click', () => {
        const id = row.dataset.virtualId
        const node = this._nodes.find((n) => n.id === id)
        if (node && node.expandable) {
          if (this._expanded.has(id)) {
            this._expanded.delete(id)
          } else {
            this._expanded.add(id)
            this.pushEvent('virtual_tree_expand', { id })
          }
          this._render()
        } else {
          this.pushEvent('virtual_tree_select', { id })
        }
      })
    })
  },

  _escape(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
  },
}

export default PhiaVirtualTree
