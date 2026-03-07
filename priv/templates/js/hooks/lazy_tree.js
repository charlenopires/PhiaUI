/**
 * PhiaLazyTree — Fires push events when tree nodes are expanded.
 *
 * Listens for the `toggle` event on `<details>` elements within the tree.
 * When a node is expanded that has data-loaded="false", fires a push event
 * to the LiveView to load children.
 *
 * data-on-expand — push_event name (default: "tree_expand")
 */
const PhiaLazyTree = {
  mounted() {
    this._onExpand = this.el.dataset.onExpand || 'tree_expand'
    this._handler = (e) => this._onToggle(e)
    this.el.addEventListener('toggle', this._handler, true)
  },

  destroyed() {
    this.el.removeEventListener('toggle', this._handler, true)
  },

  _onToggle(e) {
    const details = e.target
    if (!details.open) return // Only care about expand events

    const li = details.closest('li[data-node-id]')
    if (!li) return

    const loaded = li.dataset.loaded === 'true'
    if (!loaded) {
      this.pushEvent(this._onExpand, { id: li.dataset.nodeId })
    }
  },
}

export default PhiaLazyTree
