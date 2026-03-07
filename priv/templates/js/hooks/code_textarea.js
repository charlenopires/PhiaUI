/**
 * PhiaCodeTextarea — Code editor textarea with Tab indentation and line numbers.
 *
 * Tab inserts spaces (data-tab-size), Enter carries forward indentation.
 * Syncs line number scroll with textarea scroll.
 *
 * data-tab-size — number of spaces for Tab (default: 2)
 * data-show-line-numbers — "true"|"false"
 */
const PhiaCodeTextarea = {
  mounted() {
    this._tabSize = parseInt(this.el.dataset.tabSize || '2', 10)
    this._showLineNumbers = this.el.dataset.showLineNumbers !== 'false'
    this._lineNumbers = this.el.parentElement
      ? this.el.parentElement.querySelector('ol')
      : null

    this._keyHandler = (e) => this._onKeydown(e)
    this._inputHandler = () => this._updateLineNumbers()
    this._scrollHandler = () => this._syncScroll()

    this.el.addEventListener('keydown', this._keyHandler)
    this.el.addEventListener('input', this._inputHandler)
    this.el.addEventListener('scroll', this._scrollHandler)
    this._updateLineNumbers()
  },

  updated() {
    this._updateLineNumbers()
  },

  destroyed() {
    this.el.removeEventListener('keydown', this._keyHandler)
    this.el.removeEventListener('input', this._inputHandler)
    this.el.removeEventListener('scroll', this._scrollHandler)
  },

  _onKeydown(e) {
    if (e.key === 'Tab') {
      e.preventDefault()
      const spaces = ' '.repeat(this._tabSize)
      const start = this.el.selectionStart
      const end = this.el.selectionEnd
      this.el.value =
        this.el.value.substring(0, start) + spaces + this.el.value.substring(end)
      this.el.selectionStart = this.el.selectionEnd = start + spaces.length
      this._updateLineNumbers()
    } else if (e.key === 'Enter') {
      const pos = this.el.selectionStart
      const before = this.el.value.substring(0, pos)
      const lineStart = before.lastIndexOf('\n') + 1
      const line = before.substring(lineStart)
      const indent = line.match(/^(\s*)/)[1]
      if (indent.length > 0) {
        e.preventDefault()
        const newline = '\n' + indent
        const end = this.el.selectionEnd
        this.el.value =
          this.el.value.substring(0, pos) + newline + this.el.value.substring(end)
        this.el.selectionStart = this.el.selectionEnd = pos + newline.length
        this._updateLineNumbers()
      }
    }
  },

  _updateLineNumbers() {
    if (!this._showLineNumbers || !this._lineNumbers) return
    const lines = (this.el.value.match(/\n/g) || []).length + 1
    const existing = this._lineNumbers.querySelectorAll('li').length
    if (lines > existing) {
      for (let i = existing + 1; i <= lines; i++) {
        const li = document.createElement('li')
        li.className = 'list-none leading-6'
        li.textContent = i
        this._lineNumbers.appendChild(li)
      }
    } else if (lines < existing) {
      const items = this._lineNumbers.querySelectorAll('li')
      for (let i = existing; i > lines; i--) {
        items[i - 1].remove()
      }
    }
  },

  _syncScroll() {
    if (this._lineNumbers) {
      this._lineNumbers.scrollTop = this.el.scrollTop
    }
  },
}

export default PhiaCodeTextarea
