/**
 * PhiaCodeHighlight — regex-based syntax highlighting for code blocks.
 *
 * Tokenizes 6 languages (JavaScript, Python, Elixir, HTML, CSS, JSON)
 * and wraps tokens in <span class="phia-hl-*">. Re-highlights on input.
 * Language detection from data-language or first-line heuristics.
 *
 * Markup contract:
 *   <pre phx-hook="PhiaCodeHighlight" id="..." data-language="javascript">
 *     <code>...</code>
 *   </pre>
 */

const LANG_RULES = {
  javascript: [
    { type: "comment", regex: /\/\/.*$/gm },
    { type: "comment", regex: /\/\*[\s\S]*?\*\//gm },
    { type: "string", regex: /`(?:[^`\\]|\\.)*`/gm },
    { type: "string", regex: /"(?:[^"\\]|\\.)*"/gm },
    { type: "string", regex: /'(?:[^'\\]|\\.)*'/gm },
    { type: "keyword", regex: /\b(?:const|let|var|function|return|if|else|for|while|do|switch|case|break|continue|new|this|class|extends|import|export|from|default|async|await|try|catch|finally|throw|typeof|instanceof|in|of|yield|null|undefined|true|false)\b/g },
    { type: "builtin", regex: /\b(?:console|document|window|Array|Object|String|Number|Boolean|Map|Set|Promise|Math|JSON|Date|RegExp|Error)\b/g },
    { type: "number", regex: /\b(?:0x[\da-fA-F]+|0b[01]+|0o[0-7]+|\d+\.?\d*(?:e[+-]?\d+)?)\b/g },
    { type: "function", regex: /\b([a-zA-Z_$][\w$]*)\s*(?=\()/g },
    { type: "operator", regex: /[+\-*/%=<>!&|^~?:]+/g },
    { type: "punctuation", regex: /[{}()[\];,.]/g }
  ],
  python: [
    { type: "comment", regex: /#.*$/gm },
    { type: "string", regex: /"""[\s\S]*?"""/gm },
    { type: "string", regex: /'''[\s\S]*?'''/gm },
    { type: "string", regex: /"(?:[^"\\]|\\.)*"/gm },
    { type: "string", regex: /'(?:[^'\\]|\\.)*'/gm },
    { type: "keyword", regex: /\b(?:def|class|if|elif|else|for|while|return|import|from|as|try|except|finally|raise|with|yield|lambda|pass|break|continue|and|or|not|is|in|True|False|None|global|nonlocal|assert|del|async|await)\b/g },
    { type: "builtin", regex: /\b(?:print|len|range|int|str|float|list|dict|tuple|set|type|isinstance|hasattr|getattr|setattr|super|property|staticmethod|classmethod|enumerate|zip|map|filter|sorted|reversed|any|all|min|max|sum|abs|round|input|open|id|dir|help)\b/g },
    { type: "number", regex: /\b(?:0x[\da-fA-F]+|0b[01]+|0o[0-7]+|\d+\.?\d*(?:e[+-]?\d+)?j?)\b/g },
    { type: "decorator", regex: /@\w+/g },
    { type: "function", regex: /\b([a-zA-Z_]\w*)\s*(?=\()/g }
  ],
  elixir: [
    { type: "comment", regex: /#.*$/gm },
    { type: "string", regex: /"""[\s\S]*?"""/gm },
    { type: "string", regex: /"(?:[^"\\]|\\.)*"/gm },
    { type: "string", regex: /~[a-zA-Z]\[[\s\S]*?\]/gm },
    { type: "string", regex: /~[a-zA-Z]"[\s\S]*?"/gm },
    { type: "atom", regex: /:[a-zA-Z_]\w*/g },
    { type: "keyword", regex: /\b(?:def|defp|defmodule|defstruct|defprotocol|defimpl|defmacro|defguard|do|end|if|else|unless|cond|case|when|with|fn|raise|rescue|try|catch|after|for|in|import|alias|use|require|quote|unquote|receive|send|spawn|self|super|true|false|nil|and|or|not)\b/g },
    { type: "builtin", regex: /\b(?:IO|Enum|Map|List|String|Kernel|Agent|GenServer|Supervisor|Task|Stream|File|Path|Logger|Phoenix|Ecto|Jason)\b/g },
    { type: "number", regex: /\b(?:0x[\da-fA-F]+|0b[01]+|0o[0-7]+|\d+\.?\d*(?:e[+-]?\d+)?)\b/g },
    { type: "module", regex: /\b[A-Z]\w*(?:\.[A-Z]\w*)*/g },
    { type: "operator", regex: /\|>|<>|=>|->|<-|\+\+|--|&&|\|\||!|=~|~>|<~>|<~|\.\.|[+\-*/%=<>!&|^]+/g },
    { type: "function", regex: /\b([a-z_]\w*[?!]?)\s*(?=[\(/])/g }
  ],
  html: [
    { type: "comment", regex: /<!--[\s\S]*?-->/gm },
    { type: "tag", regex: /<\/?[a-zA-Z][\w-]*(?:\s|>|\/)/g },
    { type: "attribute", regex: /\b[a-zA-Z-]+(?==)/g },
    { type: "string", regex: /"[^"]*"/gm },
    { type: "string", regex: /'[^']*'/gm },
    { type: "punctuation", regex: /[<>\/=]/g }
  ],
  css: [
    { type: "comment", regex: /\/\*[\s\S]*?\*\//gm },
    { type: "selector", regex: /[.#]?[a-zA-Z][\w-]*(?=\s*[{,:])/g },
    { type: "property", regex: /[\w-]+(?=\s*:)/g },
    { type: "string", regex: /"[^"]*"/gm },
    { type: "string", regex: /'[^']*'/gm },
    { type: "number", regex: /\b\d+\.?\d*(?:px|em|rem|%|vh|vw|deg|s|ms)?\b/g },
    { type: "keyword", regex: /@(?:media|keyframes|import|font-face|supports|property|layer|theme|custom-variant)\b/g },
    { type: "builtin", regex: /\b(?:var|calc|min|max|clamp|rgb|rgba|hsl|hsla|oklch|url)\b/g },
    { type: "punctuation", regex: /[{}();:,]/g }
  ],
  json: [
    { type: "string", regex: /"(?:[^"\\]|\\.)*"/gm },
    { type: "number", regex: /\b-?\d+\.?\d*(?:e[+-]?\d+)?\b/g },
    { type: "keyword", regex: /\b(?:true|false|null)\b/g },
    { type: "punctuation", regex: /[{}[\]:,]/g }
  ]
};

function detectLanguage(text) {
  const first = text.trim().split("\n")[0] || "";
  if (first.startsWith("<!") || first.startsWith("<html") || first.startsWith("<div")) return "html";
  if (first.startsWith("{") || first.startsWith("[")) return "json";
  if (first.includes("defmodule") || first.includes("def ") || first.includes("|>")) return "elixir";
  if (first.includes("def ") || first.includes("import ") || first.includes("class ")) {
    if (first.includes("self") || first.includes(":")) return "python";
  }
  if (first.startsWith("@") && (first.includes("media") || first.includes("keyframes"))) return "css";
  return "javascript";
}

function escapeHtml(str) {
  return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function highlight(code, lang) {
  const rules = LANG_RULES[lang];
  if (!rules) return escapeHtml(code);

  // Collect all token positions
  const tokens = [];
  rules.forEach((rule) => {
    const re = new RegExp(rule.regex.source, rule.regex.flags);
    let match;
    while ((match = re.exec(code)) !== null) {
      tokens.push({ start: match.index, end: match.index + match[0].length, type: rule.type, text: match[0] });
    }
  });

  // Sort by position, then by length (longest first for overlaps)
  tokens.sort((a, b) => a.start - b.start || b.end - a.end);

  // Remove overlapping tokens (first match wins)
  const filtered = [];
  let lastEnd = 0;
  tokens.forEach((t) => {
    if (t.start >= lastEnd) {
      filtered.push(t);
      lastEnd = t.end;
    }
  });

  // Build highlighted HTML
  let result = "";
  let pos = 0;
  filtered.forEach((t) => {
    if (t.start > pos) {
      result += escapeHtml(code.slice(pos, t.start));
    }
    result += `<span class="phia-hl-${t.type}">${escapeHtml(t.text)}</span>`;
    pos = t.end;
  });
  if (pos < code.length) {
    result += escapeHtml(code.slice(pos));
  }

  return result;
}

const PhiaCodeHighlight = {
  mounted() {
    this._code = this.el.querySelector("code");
    if (!this._code) return;

    this._lang = this.el.dataset.language || detectLanguage(this._code.textContent);
    this._highlight();

    // Re-highlight on input (if contenteditable)
    if (this._code.getAttribute("contenteditable") === "true") {
      this._code.addEventListener("input", () => {
        requestAnimationFrame(() => this._highlight());
      });
    }

    // Observe text changes from external updates
    this._observer = new MutationObserver(() => {
      if (!this._highlighting) {
        requestAnimationFrame(() => this._highlight());
      }
    });
    this._observer.observe(this._code, { childList: true, characterData: true, subtree: true });
  },

  destroyed() {
    if (this._observer) this._observer.disconnect();
  },

  _highlight() {
    if (!this._code) return;
    this._highlighting = true;

    // Save cursor position
    const sel = window.getSelection();
    let offset = 0;
    if (sel.rangeCount > 0 && this._code.contains(sel.anchorNode)) {
      const range = sel.getRangeAt(0);
      const pre = range.cloneRange();
      pre.selectNodeContents(this._code);
      pre.setEnd(range.startContainer, range.startOffset);
      offset = pre.toString().length;
    }

    const text = this._code.textContent;
    this._code.innerHTML = highlight(text, this._lang);

    // Restore cursor
    if (offset > 0 && document.activeElement === this._code) {
      this._restoreCursor(offset);
    }

    this._highlighting = false;
  },

  _restoreCursor(offset) {
    const walker = document.createTreeWalker(this._code, NodeFilter.SHOW_TEXT);
    let count = 0;
    let node;
    while ((node = walker.nextNode())) {
      if (count + node.length >= offset) {
        const range = document.createRange();
        range.setStart(node, offset - count);
        range.collapse(true);
        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
        break;
      }
      count += node.length;
    }
  }
};

export default PhiaCodeHighlight;
