// PhiaSuggestionInput — ghost-text suggestion overlay.
// Tab accepts, Esc dismisses.

const PhiaSuggestionInput = {
  mounted() {
    this.input = this.el.querySelector("[data-suggestion-input]");
    this.ghost = this.el.querySelector("[data-suggestion-ghost]");
    if (!this.input) return;

    this._onKeydown = (e) => {
      const suggestion = this.el.dataset.suggestion || "";
      const value = this.input.value;
      if (e.key === "Tab" && suggestion && suggestion.startsWith(value)) {
        e.preventDefault();
        this.input.value = suggestion;
        this._updateGhost(suggestion);
        const acceptEvent = this.el.dataset.onAccept;
        if (acceptEvent) {
          this.pushEvent(acceptEvent, { value: suggestion });
        }
      } else if (e.key === "Escape") {
        this.el.removeAttribute("data-suggestion");
        this._updateGhost("");
      }
    };

    this._onInput = () => {
      this._updateGhost(this.input.value);
    };

    this.input.addEventListener("keydown", this._onKeydown);
    this.input.addEventListener("input", this._onInput);
  },

  updated() {
    this._updateGhost(this.input ? this.input.value : "");
  },

  destroyed() {
    if (this.input) {
      this.input.removeEventListener("keydown", this._onKeydown);
      this.input.removeEventListener("input", this._onInput);
    }
  },

  _updateGhost(currentValue) {
    if (!this.ghost) return;
    const suggestion = this.el.dataset.suggestion || "";
    const spans = this.ghost.querySelectorAll("span");
    if (spans.length >= 2) {
      spans[0].textContent = currentValue; // invisible spacer
      if (suggestion && suggestion.startsWith(currentValue)) {
        spans[1].textContent = suggestion.slice(currentValue.length);
      } else {
        spans[1].textContent = "";
      }
    }
  },
};

export default PhiaSuggestionInput;
