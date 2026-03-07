/**
 * PhiaGridExport — Client-side CSV export for data grids.
 *
 * Reads visible <th> headers and <tr> rows from the target table,
 * builds a CSV, and triggers a browser download via Blob.
 *
 * data-target-id — ID of the data_grid container to export
 * data-filename  — downloaded file name (default: "export.csv")
 */
const PhiaGridExport = {
  mounted() {
    this._handler = () => this._export()
    this.el.addEventListener('click', this._handler)
  },

  destroyed() {
    this.el.removeEventListener('click', this._handler)
  },

  _export() {
    const targetId = this.el.dataset.targetId
    const filename = this.el.dataset.filename || 'export.csv'
    const container = document.getElementById(targetId)
    if (!container) {
      console.warn(`PhiaGridExport: element #${targetId} not found`)
      return
    }

    const table = container.querySelector('table')
    if (!table) {
      console.warn(`PhiaGridExport: no <table> found in #${targetId}`)
      return
    }

    const rows = []

    // Headers — skip hidden columns (data-hidden attr)
    const headers = []
    const headerCells = table.querySelectorAll('thead tr:last-child th')
    const visibleCols = []
    headerCells.forEach((th, i) => {
      if (!th.dataset.hidden) {
        headers.push(this._cellText(th))
        visibleCols.push(i)
      }
    })
    rows.push(headers)

    // Body rows
    const bodyRows = table.querySelectorAll('tbody tr')
    bodyRows.forEach((tr) => {
      const cells = tr.querySelectorAll('td')
      const row = []
      visibleCols.forEach((colIdx) => {
        const cell = cells[colIdx]
        row.push(cell ? this._cellText(cell) : '')
      })
      rows.push(row)
    })

    const csv = rows
      .map((r) => r.map((v) => `"${v.replace(/"/g, '""')}"`).join(','))
      .join('\n')

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  },

  _cellText(el) {
    // Strip HTML, normalize whitespace
    return (el.textContent || el.innerText || '').replace(/\s+/g, ' ').trim()
  },
}

export default PhiaGridExport
