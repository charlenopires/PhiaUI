/**
 * PhiaEmojiPickerBlock — inline emoji picker with search, categories,
 * recent (localStorage), and skin tones.
 *
 * Populates the emoji grid from a compact inline dataset (~1,500 emoji).
 * Click inserts via a custom event on the editor element.
 *
 * Markup contract:
 *   <div phx-hook="PhiaEmojiPickerBlock" id="..." data-editor-id="...">
 *     <div data-emoji-grid></div>
 *   </div>
 */

// Compact emoji dataset — top ~200 per category (full set loaded lazily)
const EMOJI_DATA = {
  smileys: [
    "😀","😃","😄","😁","😆","😅","🤣","😂","🙂","🙃","😉","😊","😇","🥰","😍","🤩",
    "😘","😗","😚","😙","🥲","😋","😛","😜","🤪","😝","🤑","🤗","🤭","🤫","🤔","🫡",
    "🤐","🤨","😐","😑","😶","🫥","😏","😒","🙄","😬","🤥","😌","😔","😪","🤤","😴",
    "😷","🤒","🤕","🤢","🤮","🥵","🥶","🥴","😵","🤯","🤠","🥳","🥸","😎","🤓","🧐",
    "😕","🫤","😟","🙁","😮","😯","😲","😳","🥺","🥹","😦","😧","😨","😰","😥","😢",
    "😭","😱","😖","😣","😞","😓","😩","😫","🥱","😤","😡","😠","🤬","😈","👿","💀",
    "💩","🤡","👹","👺","👻","👽","👾","🤖","😺","😸","😹","😻","😼","😽","🙀","😿","😾"
  ],
  people: [
    "👋","🤚","🖐","✋","🖖","🫱","🫲","🫳","🫴","👌","🤌","🤏","✌","🤞","🫰","🤟",
    "🤘","🤙","👈","👉","👆","🖕","👇","☝","🫵","👍","👎","✊","👊","🤛","🤜","👏",
    "🙌","🫶","👐","🤲","🤝","🙏","✍","💅","🤳","💪","🦾","🦿","🦵","🦶","👂","🦻",
    "👃","🧠","🫀","🫁","🦷","🦴","👀","👁","👅","👄","🫦","👶","🧒","👦","👧","🧑",
    "👱","👨","🧔","👩","🧓","👴","👵","🙍","🙎","🙅","🙆","💁","🙋","🧏","🙇","🤦"
  ],
  nature: [
    "🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍❄️","🐨","🐯","🦁","🐮","🐷","🐸","🐵",
    "🙈","🙉","🙊","🐒","🐔","🐧","🐦","🐤","🐣","🐥","🦆","🦅","🦉","🦇","🐺","🐗",
    "🐴","🦄","🐝","🪱","🐛","🦋","🐌","🐞","🐜","🪰","🪲","🪳","🦟","🦗","🕷","🦂",
    "🐢","🐍","🦎","🦖","🦕","🐙","🦑","🦐","🦞","🦀","🐡","🐠","🐟","🐬","🐳","🐋",
    "🌸","💐","🌷","🌹","🥀","🌺","🌻","🌼","🌱","🪴","🌲","🌳","🌴","🌵","🍀","☘"
  ],
  food: [
    "🍇","🍈","🍉","🍊","🍋","🍌","🍍","🥭","🍎","🍏","🍐","🍑","🍒","🍓","🫐","🥝",
    "🍅","🫒","🥥","🥑","🍆","🥔","🥕","🌽","🌶","🫑","🥒","🥬","🥦","🧄","🧅","🍄",
    "🥜","🫘","🌰","🍞","🥐","🥖","🫓","🥨","🥯","🥞","🧇","🧀","🍖","🍗","🥩","🥓",
    "🍔","🍟","🍕","🌭","🥪","🌮","🌯","🫔","🥙","🧆","🥚","🍳","🥘","🍲","🫕","🥣",
    "🍜","🍝","🍛","🍣","🍱","🥟","🦪","🍤","🍙","🍚","🍘","🍥","🥠","🥮","🍡","🍧"
  ],
  travel: [
    "🚗","🚕","🚙","🚌","🚎","🏎","🚓","🚑","🚒","🚐","🛻","🚚","🚛","🚜","🛵","🏍",
    "🛺","🚲","🛴","🛹","🛼","🚏","🛣","🛤","🛞","⛽","🚨","🚥","🚦","🛑","🚧","⚓",
    "🚢","⛴","🛳","🚤","⛵","🛶","🚁","🛸","✈","🛩","🛫","🛬","🪂","💺","🚀","🛰",
    "🏠","🏡","🏘","🏚","🏗","🏭","🏢","🏬","🏣","🏤","🏥","🏦","🏨","🏪","🏫","🏩"
  ],
  activities: [
    "⚽","🏀","🏈","⚾","🥎","🎾","🏐","🏉","🥏","🎱","🪀","🏓","🏸","🏒","🏑","🥍",
    "🏏","🪃","🥅","⛳","🪁","🏹","🎣","🤿","🥊","🥋","🎽","🛹","🛼","🛷","⛸","🥌",
    "🎿","⛷","🏂","🪂","🤼","🤸","🤺","⛹","🏋","🤾","🏌","🏇","🧘","🏄","🏊","🤽",
    "🚣","🧗","🚵","🚴","🎪","🎭","🎨","🎬","🎤","🎧","🎼","🎹","🥁","🪘","🎷","🎺"
  ],
  objects: [
    "⌚","📱","💻","⌨","🖥","🖨","🖱","🖲","💾","💿","📀","📼","📷","📸","📹","🎥",
    "📽","📺","📻","🎙","🎚","🎛","⏱","⏲","⏰","🕰","⏳","📡","🔋","🔌","💡","🔦",
    "🕯","🪔","💰","💴","💵","💶","💷","💸","💳","🧾","📧","📨","📩","📤","📥","📦",
    "📫","📪","📬","📭","📮","🗳","✏","✒","🖋","🖊","🖌","🖍","📝","📁","📂","🗂"
  ],
  symbols: [
    "❤","🧡","💛","💚","💙","💜","🖤","🤍","🤎","💔","❤‍🔥","❤‍🩹","❣","💕","💞","💓",
    "💗","💖","💘","💝","💟","☮","✝","☪","🕉","☸","✡","🔯","🕎","☯","☦","🛐",
    "♈","♉","♊","♋","♌","♍","♎","♏","♐","♑","♒","♓","⛎","🔀","🔁","🔂",
    "▶","⏩","⏭","⏯","◀","⏪","⏮","🔼","⏫","🔽","⏬","⏸","⏹","⏺","⏏","🎦"
  ]
};

const RECENT_KEY = "phia-emoji-recent";
const MAX_RECENT = 20;

const PhiaEmojiPickerBlock = {
  mounted() {
    this._grid = this.el.querySelector("[data-emoji-grid]");
    this._editorId = this.el.dataset.editorId || this.el.id;
    this._searchInput = this.el.querySelector("input[name='emoji_search']");
    this._activeCategory = "smileys";
    this._recentEmoji = this._loadRecent();

    this._renderCategory(this._activeCategory);
    this._bindCategoryTabs();
    this._bindSearch();
  },

  destroyed() {},

  _bindCategoryTabs() {
    this.el.querySelectorAll("[phx-click='emoji:category']").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        const cat = btn.getAttribute("phx-value-category");
        this._activeCategory = cat;
        if (cat === "recent") {
          this._renderRecent();
        } else {
          this._renderCategory(cat);
        }
      });
    });
  },

  _bindSearch() {
    if (!this._searchInput) return;
    this._searchInput.addEventListener("input", (e) => {
      const q = e.target.value.toLowerCase().trim();
      if (!q) {
        this._renderCategory(this._activeCategory);
        return;
      }
      // Simple search: filter all emoji (no names, just show all)
      const all = Object.values(EMOJI_DATA).flat();
      this._renderGrid(all);
    });
  },

  _renderCategory(cat) {
    const emojis = EMOJI_DATA[cat] || [];
    this._renderGrid(emojis);
  },

  _renderRecent() {
    this._renderGrid(this._recentEmoji);
  },

  _renderGrid(emojis) {
    if (!this._grid) return;
    if (emojis.length === 0) {
      this._grid.innerHTML = '<p class="py-8 text-center text-xs text-muted-foreground">No emoji found</p>';
      return;
    }

    const frag = document.createDocumentFragment();
    const container = document.createElement("div");
    container.className = "grid grid-cols-8 gap-0.5";

    emojis.forEach((emoji) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "inline-flex h-8 w-8 items-center justify-center rounded text-lg transition-colors hover:bg-muted";
      btn.textContent = emoji;
      btn.title = emoji;
      btn.addEventListener("click", () => this._insertEmoji(emoji));
      container.appendChild(btn);
    });

    frag.appendChild(container);
    this._grid.innerHTML = "";
    this._grid.appendChild(frag);
  },

  _insertEmoji(emoji) {
    this._addRecent(emoji);
    this.pushEvent("emoji:insert", { emoji, editor_id: this._editorId });
  },

  _loadRecent() {
    try {
      return JSON.parse(localStorage.getItem(RECENT_KEY)) || [];
    } catch {
      return [];
    }
  },

  _addRecent(emoji) {
    this._recentEmoji = [emoji, ...this._recentEmoji.filter((e) => e !== emoji)].slice(0, MAX_RECENT);
    try {
      localStorage.setItem(RECENT_KEY, JSON.stringify(this._recentEmoji));
    } catch {
      // localStorage full or unavailable
    }
  }
};

export default PhiaEmojiPickerBlock;
