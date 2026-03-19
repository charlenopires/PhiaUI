/**
 * PhiaFormatPainter — Copy formatting from one selection and apply to another.
 *
 * Flow:
 * 1. User selects formatted text and clicks Format Painter button
 * 2. Hook captures computed styles of selection
 * 3. User selects target text
 * 4. Hook applies captured styles to new selection
 * 5. Deactivates painter mode
 */

const PhiaFormatPainter = {
  mounted() {
    this._active = false;
    this._capturedStyles = null;

    this.handleEvent("format-painter:activate", () => {
      this._activate();
    });

    this.handleEvent("format-painter:deactivate", () => {
      this._deactivate();
    });
  },

  destroyed() {
    this._deactivate();
  },

  _activate() {
    this._active = true;
    this._capturedStyles = this._captureStyles();
    document.body.style.cursor = "crosshair";

    this._mouseUpHandler = () => {
      if (this._active && this._capturedStyles) {
        this._applyStyles();
        this._deactivate();
      }
    };

    document.addEventListener("mouseup", this._mouseUpHandler, { once: true });
  },

  _deactivate() {
    this._active = false;
    this._capturedStyles = null;
    document.body.style.cursor = "";

    if (this._mouseUpHandler) {
      document.removeEventListener("mouseup", this._mouseUpHandler);
      this._mouseUpHandler = null;
    }
  },

  _captureStyles() {
    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return null;

    const node = sel.anchorNode;
    const el = node && node.nodeType === Node.TEXT_NODE ? node.parentElement : node;
    if (!el) return null;

    const computed = window.getComputedStyle(el);
    return {
      fontWeight: computed.fontWeight,
      fontStyle: computed.fontStyle,
      textDecoration: computed.textDecoration,
      fontFamily: computed.fontFamily,
      fontSize: computed.fontSize,
      color: computed.color,
      backgroundColor: computed.backgroundColor,
    };
  },

  _applyStyles() {
    if (!this._capturedStyles) return;
    const s = this._capturedStyles;

    if (parseInt(s.fontWeight, 10) >= 700) document.execCommand("bold", false, null);
    if (s.fontStyle === "italic") document.execCommand("italic", false, null);
    if (s.textDecoration.includes("underline")) document.execCommand("underline", false, null);
    if (s.color && s.color !== "rgb(0, 0, 0)") document.execCommand("foreColor", false, s.color);
    if (s.fontFamily) document.execCommand("fontName", false, s.fontFamily);
  },
};

export default PhiaFormatPainter;
