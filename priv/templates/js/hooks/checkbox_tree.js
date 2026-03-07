/**
 * PhiaCheckboxTree — Sets the .indeterminate JS property on checkboxes.
 *
 * The HTML `indeterminate` attribute cannot be set declaratively.
 * This hook reads data-indeterminate="true" from each input and sets
 * the JS `.indeterminate` property accordingly.
 */
const PhiaCheckboxTree = {
  mounted() {
    this._setIndeterminate()
  },

  updated() {
    this._setIndeterminate()
  },

  _setIndeterminate() {
    const inputs = this.el.querySelectorAll('input[type="checkbox"][data-indeterminate]')
    inputs.forEach((input) => {
      input.indeterminate = input.dataset.indeterminate === 'true'
    })
  },
}

export default PhiaCheckboxTree
