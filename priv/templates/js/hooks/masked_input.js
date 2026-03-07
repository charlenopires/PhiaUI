/**
 * PhiaMaskedInput — pattern-masked text input hook.
 *
 * Reads `data-mask` attribute and applies masking on every `input` event.
 * Mask syntax: `#` = digit, `A` = letter (a-z, A-Z), `*` = any character.
 *
 * Example masks:
 *   "(###) ###-####"   US phone number
 *   "##/##/####"       date (MM/DD/YYYY)
 *   "#### #### #### ####"  credit card
 *   "AAA-###"          alphanumeric code
 */
export const PhiaMaskedInput = {
  mounted() {
    this.mask = this.el.dataset.mask;
    this._onInput = () => this._applyMask();
    this.el.addEventListener("input", this._onInput);

    // Apply mask to any pre-filled value on mount
    if (this.el.value) {
      this._applyMask();
    }
  },

  destroyed() {
    this.el.removeEventListener("input", this._onInput);
  },

  _applyMask() {
    const mask = this.mask;
    if (!mask) return;

    const raw = this.el.value;
    // Extract only the "raw" characters (strip mask literals)
    const digits = this._extractRaw(raw, mask);
    const masked = this._buildMasked(digits, mask);

    // Only update if value actually changed to avoid cursor jump
    if (this.el.value !== masked) {
      const cursorPos = this._computeCursor(masked, raw.length);
      this.el.value = masked;
      this.el.setSelectionRange(cursorPos, cursorPos);
    }
  },

  /** Strip mask literal characters, keep only the raw input characters. */
  _extractRaw(value, mask) {
    const raw = [];
    let maskIdx = 0;

    for (let i = 0; i < value.length && maskIdx < mask.length; i++) {
      const maskChar = mask[maskIdx];
      const inputChar = value[i];

      if (this._isMaskPlaceholder(maskChar)) {
        if (this._matchesMaskChar(inputChar, maskChar)) {
          raw.push(inputChar);
          maskIdx++;
        }
        // Skip invalid characters silently
      } else {
        // Literal mask character: skip if user typed it, advance mask anyway
        if (inputChar === maskChar) {
          // User typed the literal — advance both
          maskIdx++;
        } else {
          // User didn't type literal, advance mask to consume it, re-process inputChar
          maskIdx++;
          i--; // re-try this input char against next mask position
        }
      }
    }

    return raw;
  },

  /** Build the masked value by inserting raw chars into the mask pattern. */
  _buildMasked(rawChars, mask) {
    let result = "";
    let rawIdx = 0;

    for (let i = 0; i < mask.length; i++) {
      if (rawIdx >= rawChars.length) break;

      const maskChar = mask[i];

      if (this._isMaskPlaceholder(maskChar)) {
        result += rawChars[rawIdx++];
      } else {
        result += maskChar;
        // Auto-insert literals only if there are more raw chars to place
        if (rawIdx < rawChars.length) {
          // keep iterating
        }
      }
    }

    return result;
  },

  /** Determine if a mask character is a placeholder slot. */
  _isMaskPlaceholder(char) {
    return char === "#" || char === "A" || char === "*";
  },

  /** Check whether an input character matches the mask slot type. */
  _matchesMaskChar(inputChar, maskChar) {
    if (maskChar === "#") return /\d/.test(inputChar);
    if (maskChar === "A") return /[a-zA-Z]/.test(inputChar);
    if (maskChar === "*") return true;
    return false;
  },

  /** Compute the new cursor position after masking. */
  _computeCursor(maskedValue, oldCursor) {
    return Math.min(oldCursor, maskedValue.length);
  },
};
