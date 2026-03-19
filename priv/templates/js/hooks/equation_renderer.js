/**
 * PhiaEquation — LaTeX subset renderer for inline/block math equations.
 *
 * Renders common LaTeX math notation (fractions, Greek letters, operators,
 * superscripts, subscripts) as formatted HTML. No external deps.
 *
 * Markup contract:
 *   <div phx-hook="PhiaEquation" id="...">
 *     <textarea id="...-input">LaTeX source</textarea>
 *     <div data-equation-preview></div>
 *   </div>
 */

const GREEK = {
  "\\alpha": "\u03B1", "\\beta": "\u03B2", "\\gamma": "\u03B3", "\\delta": "\u03B4",
  "\\epsilon": "\u03B5", "\\zeta": "\u03B6", "\\eta": "\u03B7", "\\theta": "\u03B8",
  "\\iota": "\u03B9", "\\kappa": "\u03BA", "\\lambda": "\u03BB", "\\mu": "\u03BC",
  "\\nu": "\u03BD", "\\xi": "\u03BE", "\\pi": "\u03C0", "\\rho": "\u03C1",
  "\\sigma": "\u03C3", "\\tau": "\u03C4", "\\upsilon": "\u03C5", "\\phi": "\u03C6",
  "\\chi": "\u03C7", "\\psi": "\u03C8", "\\omega": "\u03C9",
  "\\Gamma": "\u0393", "\\Delta": "\u0394", "\\Theta": "\u0398", "\\Lambda": "\u039B",
  "\\Xi": "\u039E", "\\Pi": "\u03A0", "\\Sigma": "\u03A3", "\\Phi": "\u03A6",
  "\\Psi": "\u03A8", "\\Omega": "\u03A9"
};

const SYMBOLS = {
  "\\infty": "\u221E", "\\pm": "\u00B1", "\\mp": "\u2213", "\\times": "\u00D7",
  "\\div": "\u00F7", "\\cdot": "\u22C5", "\\leq": "\u2264", "\\geq": "\u2265",
  "\\neq": "\u2260", "\\approx": "\u2248", "\\equiv": "\u2261", "\\sim": "\u223C",
  "\\subset": "\u2282", "\\supset": "\u2283", "\\subseteq": "\u2286", "\\supseteq": "\u2287",
  "\\in": "\u2208", "\\notin": "\u2209", "\\cup": "\u222A", "\\cap": "\u2229",
  "\\emptyset": "\u2205", "\\forall": "\u2200", "\\exists": "\u2203", "\\neg": "\u00AC",
  "\\wedge": "\u2227", "\\vee": "\u2228", "\\rightarrow": "\u2192", "\\leftarrow": "\u2190",
  "\\Rightarrow": "\u21D2", "\\Leftarrow": "\u21D0", "\\leftrightarrow": "\u2194",
  "\\partial": "\u2202", "\\nabla": "\u2207", "\\sum": "\u2211", "\\prod": "\u220F",
  "\\int": "\u222B", "\\oint": "\u222E", "\\sqrt": "\u221A", "\\to": "\u2192",
  "\\ldots": "\u2026", "\\cdots": "\u22EF", "\\prime": "\u2032"
};

function esc(s) {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function renderLatex(latex) {
  let html = esc(latex);

  // Replace Greek letters and symbols (longest match first)
  const allKeys = [...Object.keys(GREEK), ...Object.keys(SYMBOLS)].sort((a, b) => b.length - a.length);
  allKeys.forEach((key) => {
    const val = GREEK[key] || SYMBOLS[key];
    const escaped = key.replace(/\\/g, "\\\\");
    html = html.replace(new RegExp(escaped + "(?![a-zA-Z])", "g"), `<span class="phia-eq-symbol">${val}</span>`);
  });

  // Fractions: \frac{num}{den}
  html = html.replace(/\\frac\{([^}]*)\}\{([^}]*)\}/g, (_, num, den) => {
    return `<span class="phia-eq-frac"><span class="phia-eq-frac-num">${num}</span><span class="phia-eq-frac-bar"></span><span class="phia-eq-frac-den">${den}</span></span>`;
  });

  // Square root: \sqrt{expr}
  html = html.replace(/\\sqrt\{([^}]*)\}/g, (_, expr) => {
    return `<span class="phia-eq-sqrt"><span class="phia-eq-sqrt-sign">\u221A</span><span class="phia-eq-sqrt-content">${expr}</span></span>`;
  });

  // Superscript: ^{expr} or ^x
  html = html.replace(/\^\{([^}]*)\}/g, '<sup class="phia-eq-sup">$1</sup>');
  html = html.replace(/\^(\w)/g, '<sup class="phia-eq-sup">$1</sup>');

  // Subscript: _{expr} or _x
  html = html.replace(/_\{([^}]*)\}/g, '<sub class="phia-eq-sub">$1</sub>');
  html = html.replace(/_(\w)/g, '<sub class="phia-eq-sub">$1</sub>');

  // \text{...} — upright text
  html = html.replace(/\\text\{([^}]*)\}/g, '<span style="font-style: normal;">$1</span>');

  // \mathbf{...} — bold
  html = html.replace(/\\mathbf\{([^}]*)\}/g, '<strong>$1</strong>');

  // \overline{...}
  html = html.replace(/\\overline\{([^}]*)\}/g, '<span style="text-decoration: overline;">$1</span>');

  // Remove remaining \commands that weren't matched
  html = html.replace(/\\[a-zA-Z]+/g, "");

  // Clean up braces
  html = html.replace(/[{}]/g, "");

  return html;
}

const PhiaEquation = {
  mounted() {
    this._input = this.el.querySelector("textarea");
    this._preview = this.el.querySelector("[data-equation-preview]");
    if (!this._input || !this._preview) return;

    this._render();
    this._input.addEventListener("input", () => {
      clearTimeout(this._debounce);
      this._debounce = setTimeout(() => this._render(), 200);
    });
  },

  destroyed() {
    clearTimeout(this._debounce);
  },

  _render() {
    const latex = this._input.value.trim();
    if (!latex) {
      this._preview.innerHTML = '<span class="text-muted-foreground text-sm">No equation entered</span>';
      return;
    }

    const html = renderLatex(latex);
    this._preview.innerHTML = `<div class="phia-eq-display">${html}</div>`;
  }
};

export default PhiaEquation;
