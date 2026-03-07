// PhiaEmojiPicker — emoji grid with category tabs and search.
// Fires pushEvent(on_pick, { emoji: "..." }) on selection.

const EMOJI_CATEGORIES = [
  {
    name: "Smileys",
    icon: "😊",
    emojis: ["😀","😁","😂","🤣","😃","😄","😅","😆","😉","😊","😋","😎","😍","🥰","😘","😗","😙","😚","🙂","🤗","🤩","🤔","🤨","😐","😑","😶","🙄","😏","😣","😥","😮","🤐","😯","😪","😫","🥱","😴","😌","😛","😜","😝","🤤","😒","😓","😔","😕","🙃","🤑","😲","🙁","😖","😞","😟","😤","😢","😭","😦","😧","😨","😩","🤯","😬","😰","😱","🥵","🥶","😳","🤪","😵","🥴","😠","😡","🤬","😷","🤒","🤕","🤢","🤮","🤧","😇","🥳","🥺","🤠","🤡","🤥","🤫","🤭","🧐","🤓"],
  },
  {
    name: "Gestures",
    icon: "👋",
    emojis: ["👋","🤚","✋","🖐","👌","🤌","🤏","✌","🤞","🤟","🤘","🤙","👈","👉","👆","🖕","👇","☝","👍","👎","✊","👊","🤛","🤜","👏","🙌","👐","🤲","🙏","✍","💪","🦾","🦿","🦵","🦶","👂","🦻","👃","🫀","🫁","🧠","🦷","🦴","👀","👁","👅","👄","🫦"],
  },
  {
    name: "Animals",
    icon: "🐶",
    emojis: ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐨","🐯","🦁","🐮","🐷","🐸","🐵","🙈","🙉","🙊","🐔","🐧","🐦","🐤","🦆","🦅","🦉","🦇","🐺","🐗","🐴","🦄","🐝","🐛","🦋","🐌","🐞","🐜","🕷","🦂","🐢","🐍","🦎","🦖","🦕","🐙","🦑","🦐","🦞","🦀","🐡","🐠","🐟","🐬","🐳","🐋","🦈","🐊","🐅","🐆","🦓","🦍","🦧","🐘","🦛","🦏","🐪","🐫","🦒","🦘","🐃","🐂","🐄","🐎","🐖","🐏","🐑","🦙","🐐","🦌","🐕","🐩","🦮","🐕‍🦺","🐈","🐈‍⬛","🐓","🦃","🦤","🦚","🦜","🦢","🕊","🐇","🦝","🦨","🦡","🦦","🦥","🐁","🐀","🐿","🦔"],
  },
  {
    name: "Food",
    icon: "🍎",
    emojis: ["🍎","🍐","🍊","🍋","🍌","🍉","🍇","🍓","🫐","🍈","🍒","🍑","🥭","🍍","🥥","🥝","🍅","🍆","🥑","🥦","🥬","🥒","🌶","🫑","🧄","🧅","🥔","🌽","🥕","🫛","🧆","🥙","🧇","🥞","🧈","🍳","🥚","🍽","🍖","🍗","🥩","🥓","🌭","🍔","🍟","🍕","🫓","🥪","🥗","🧆","🌮","🌯","🥙","🧆","🥚","🍳","🥘","🍲","🫕","🥫","🧂","🍱","🍘","🍙","🍚","🍛","🍜","🍝","🍠","🍢","🍣","🍤","🍥","🥮","🍡","🧁","🍦","🍧","🍨","🍩","🍪","🎂","🍰","🍫","🍬","🍭","🍮","🍯","🍼","🥛","☕","🫖","🍵","🧃","🥤","🧋","🍶","🍺","🍻","🥂","🍷","🥃","🍸","🍹","🧉","🍾"],
  },
  {
    name: "Objects",
    icon: "💡",
    emojis: ["💡","🔦","🕯","🪔","🧯","🛢","💰","💵","💴","💶","💷","💸","💳","🪙","💹","📈","📉","📊","📋","📁","📂","🗂","📅","📆","🗒","🗓","📇","📌","📍","✂","🗃","🗄","🗑","🔒","🔓","🔏","🔐","🔑","🗝","🔨","🪓","⛏","⚒","🛠","🗡","⚔","🔫","🪃","🏹","🛡","🪚","🔧","🪛","🔩","⚙","🗜","⚖","🦯","🔗","⛓","🪝","🧲","🪜","⚗","🧪","🧫","🧬","🔬","🔭","📡","💉","🩸","💊","🩹","🩺","🩻","🚪","🛗","🪞","🪟","🛏","🛋","🪑","🚿","🛁","🪠","🚽","🪤","🪒","🧴","🧷","🧹","🧺","🧻","🧼","🫧","🪣","🧽","🪥","🛒"],
  },
  {
    name: "Symbols",
    icon: "❤️",
    emojis: ["❤","🧡","💛","💚","💙","💜","🖤","🤍","🤎","💔","❣","💕","💞","💓","💗","💖","💘","💝","💟","☮","✝","☪","🕉","☸","✡","🔯","🕎","☯","☦","🛐","⛎","♈","♉","♊","♋","♌","♍","♎","♏","♐","♑","♒","♓","🆔","⚛","🉑","☢","☣","📴","📳","🈶","🈚","🈸","🈺","🈷","✴","🆚","💮","🉐","㊙","㊗","🈴","🈵","🈹","🈲","🅰","🅱","🆎","🆑","🅾","🆘","❌","⭕","🛑","⛔","📛","🚫","💯","💢","♨","🚷","🚯","🚳","🚱","🔞","📵","🚭","❗","❕","❓","❔","‼","⁉","🔅","🔆","〽","⚠","🚸","🔱","⚜","🔰","♻","✅","🈯","💹","❇","✳","❎","🌐","💠","Ⓜ","🌀","💤","🏧","🚾","♿","🅿","🈳","🈹","🛗","🚰","🚹","🚺","🚻","🚼","🛂","🛃","🛄","🛅"],
  },
];

const PhiaEmojiPicker = {
  mounted() {
    this.onPickName = this.el.dataset.onpick || null;
    this.open = false;
    this.currentCategory = 0;
    this.searchQuery = "";

    this.trigger = this.el.querySelector("[data-emoji-trigger]");
    this.panel = this.el.querySelector("[data-emoji-panel]");
    this.searchInput = this.el.querySelector("[data-emoji-search]");
    this.tabsEl = this.el.querySelector("[data-emoji-tabs]");
    this.gridEl = this.el.querySelector("[data-emoji-grid]");

    if (!this.trigger || !this.panel) return;

    // Render tabs
    this._renderTabs();
    // Render initial grid
    this._renderGrid();

    this._onTriggerClick = () => this._toggle();
    this._onDocClick = (e) => {
      if (!this.el.contains(e.target)) this._close();
    };
    this._onKeydown = (e) => {
      if (e.key === "Escape") this._close();
    };

    this.trigger.addEventListener("click", this._onTriggerClick);
    document.addEventListener("click", this._onDocClick);
    document.addEventListener("keydown", this._onKeydown);

    if (this.searchInput) {
      this.searchInput.addEventListener("input", () => {
        this.searchQuery = this.searchInput.value.toLowerCase();
        this._renderGrid();
      });
    }
  },

  destroyed() {
    document.removeEventListener("click", this._onDocClick);
    document.removeEventListener("keydown", this._onKeydown);
  },

  _toggle() {
    this.open ? this._close() : this._open();
  },

  _open() {
    this.panel.classList.remove("hidden");
    this.trigger.setAttribute("aria-expanded", "true");
    this.open = true;
    if (this.searchInput) {
      setTimeout(() => this.searchInput.focus(), 50);
    }
  },

  _close() {
    this.panel.classList.add("hidden");
    this.trigger.setAttribute("aria-expanded", "false");
    this.open = false;
  },

  _renderTabs() {
    if (!this.tabsEl) return;
    this.tabsEl.innerHTML = "";
    EMOJI_CATEGORIES.forEach((cat, i) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.textContent = cat.icon;
      btn.title = cat.name;
      btn.className =
        "text-base p-1 rounded hover:bg-accent transition-colors shrink-0";
      if (i === this.currentCategory) {
        btn.className += " bg-accent";
      }
      btn.addEventListener("click", () => {
        this.currentCategory = i;
        this._renderTabs();
        this._renderGrid();
      });
      this.tabsEl.appendChild(btn);
    });
  },

  _renderGrid() {
    if (!this.gridEl) return;
    this.gridEl.innerHTML = "";

    let emojis;
    if (this.searchQuery) {
      // Search across all categories
      emojis = EMOJI_CATEGORIES.flatMap((c) => c.emojis);
    } else {
      emojis = EMOJI_CATEGORIES[this.currentCategory]?.emojis || [];
    }

    const grid = document.createElement("div");
    grid.className = "grid grid-cols-8 gap-0.5";

    emojis.forEach((emoji) => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.textContent = emoji;
      btn.className =
        "text-xl p-1 rounded hover:bg-accent transition-colors cursor-pointer";
      btn.setAttribute("aria-label", emoji);
      btn.addEventListener("click", () => {
        if (this.onPickName) {
          this.pushEvent(this.onPickName, { emoji });
        }
        this._close();
      });
      grid.appendChild(btn);
    });

    this.gridEl.appendChild(grid);
  },
};

export default PhiaEmojiPicker;
