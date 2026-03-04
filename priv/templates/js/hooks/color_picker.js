/**
 * PhiaColorPicker — vanilla JS hook for the PhiaUI ColorPicker component.
 *
 * Responsibilities:
 *   - Keeps the `[data-color-value]` span in sync as the user drags the
 *     native colour wheel (both `input` and `change` events).
 *   - Fires a LiveView `pushEvent` to the server whenever the colour changes,
 *     sending `{ value: "#rrggbb" }` under the event name stored in
 *     `data-on-change`.
 *   - Handles swatch button clicks by updating the colour input and triggering
 *     the same `handleChange` flow so the server is notified.
 *
 * HTML anatomy expected:
 *   <div id="..." phx-hook="PhiaColorPicker" data-on-change="event_name">
 *     <input type="color" data-color-input value="#000000" />
 *     <span data-color-value>#000000</span>
 *     <!-- optional swatches -->
 *     <button data-swatch-value="#FF5733">…</button>
 *   </div>
 */
const PhiaColorPicker = {
  mounted() {
    this.input = this.el.querySelector('[data-color-input]');
    this.valueDisplay = this.el.querySelector('[data-color-value]');
    this.onChangeName = this.el.dataset.onChange;

    if (this.input) {
      this.input.addEventListener('input', () => this.handleChange(this.input.value));
      this.input.addEventListener('change', () => this.handleChange(this.input.value));
    }

    this.el.querySelectorAll('[data-swatch-value]').forEach(btn => {
      btn.addEventListener('click', () => {
        const color = btn.dataset.swatchValue;
        if (this.input) this.input.value = color;
        this.handleChange(color);
      });
    });
  },

  handleChange(color) {
    if (this.valueDisplay) this.valueDisplay.textContent = color;
    if (this.onChangeName) {
      this.pushEvent(this.onChangeName, { value: color });
    }
  }
};

export default PhiaColorPicker;
