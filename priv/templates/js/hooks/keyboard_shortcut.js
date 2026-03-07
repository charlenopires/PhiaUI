// PhiaKeyShortcut — captures key combinations and formats them as "Ctrl+Shift+K".
// Fires pushEvent(on_change, { shortcut: "..." }) on each capture.

const PhiaKeyShortcut = {
  mounted() {
    this.onChangeName = this.el.dataset.onchange || null;
    this.recording = false;

    this._onContainerClick = () => this._startRecording();
    this._onKeydown = (e) => this._capture(e);
    this._onBlur = () => this._stopRecording();

    this.el.addEventListener("click", this._onContainerClick);
    this.el.addEventListener("focus", this._onContainerClick);
    this.el.addEventListener("blur", this._onBlur);

    // Clear button
    const clearBtn = this.el.querySelector("[data-shortcut-clear]");
    if (clearBtn) {
      clearBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        this._setShortcut(null);
      });
    }
  },

  updated() {
    // Re-wire clear button after re-render
    const clearBtn = this.el.querySelector("[data-shortcut-clear]");
    if (clearBtn && !clearBtn._phiaKsBound) {
      clearBtn._phiaKsBound = true;
      clearBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        this._setShortcut(null);
      });
    }
  },

  destroyed() {
    document.removeEventListener("keydown", this._onKeydown);
  },

  _startRecording() {
    if (this.recording) return;
    this.recording = true;
    this.el.setAttribute("data-recording", "true");
    this.el.style.outline = "2px solid var(--color-ring, #6366f1)";
    document.addEventListener("keydown", this._onKeydown);
  },

  _stopRecording() {
    this.recording = false;
    this.el.removeAttribute("data-recording");
    this.el.style.outline = "";
    document.removeEventListener("keydown", this._onKeydown);
  },

  _capture(e) {
    if (!this.recording) return;
    e.preventDefault();
    e.stopPropagation();

    // Ignore lone modifier keys
    if (["Control", "Shift", "Alt", "Meta", "CapsLock"].includes(e.key)) return;

    const parts = [];
    if (e.ctrlKey) parts.push("Ctrl");
    if (e.metaKey) parts.push("Meta");
    if (e.altKey) parts.push("Alt");
    if (e.shiftKey) parts.push("Shift");

    // Format the main key
    let key = e.key;
    if (key === " ") key = "Space";
    else if (key.length === 1) key = key.toUpperCase();
    parts.push(key);

    const shortcut = parts.join("+");
    this._setShortcut(shortcut);
    this._stopRecording();
  },

  _setShortcut(shortcut) {
    // Update hidden input
    const input = this.el.querySelector("[data-shortcut-input]");
    if (input) input.value = shortcut || "";

    // Update display (server re-render will handle this via phx event)
    if (this.onChangeName) {
      this.pushEvent(this.onChangeName, { shortcut: shortcut || "" });
    }
  },
};

export default PhiaKeyShortcut;
