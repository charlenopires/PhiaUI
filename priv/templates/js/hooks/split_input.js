// PhiaSplitInput — multi-slot input with auto-advance, backspace, and paste.
// Slots are [data-slot] inputs inside the hook root. A [data-split-output]
// hidden input collects the concatenated value.

const PhiaSplitInput = {
  mounted() {
    this.separator = this.el.dataset.separator || "";
    this.output = this.el.querySelector("[data-split-output]");
    this._wireSlots();
  },

  updated() {
    this._wireSlots();
  },

  _wireSlots() {
    const slots = Array.from(this.el.querySelectorAll("[data-slot]"));
    if (!slots.length) return;

    slots.forEach((slot, idx) => {
      // Avoid double-binding
      if (slot._phiaSplitBound) return;
      slot._phiaSplitBound = true;

      slot.addEventListener("input", (e) => {
        const val = slot.value;
        if (val.length >= (parseInt(slot.maxLength, 10) || 1)) {
          // Auto-advance to next slot
          const next = slots[idx + 1];
          if (next) next.focus();
        }
        this._updateOutput(slots);
      });

      slot.addEventListener("keydown", (e) => {
        if (e.key === "Backspace" && slot.value === "") {
          // Go back to previous slot
          const prev = slots[idx - 1];
          if (prev) {
            prev.focus();
            prev.value = "";
            this._updateOutput(slots);
          }
        }
      });

      slot.addEventListener("paste", (e) => {
        e.preventDefault();
        const text = (e.clipboardData || window.clipboardData).getData("text");
        // Distribute pasted chars across slots starting from this one
        const chars = text.replace(/\s/g, "").split("");
        let i = idx;
        for (const ch of chars) {
          if (i >= slots.length) break;
          slots[i].value = ch.slice(0, parseInt(slots[i].maxLength, 10) || 1);
          i++;
        }
        if (slots[i]) slots[i].focus();
        this._updateOutput(slots);
      });
    });
  },

  _updateOutput(slots) {
    const val = slots.map((s) => s.value).join(this.separator);
    if (this.output) this.output.value = val;
  },
};

export default PhiaSplitInput;
