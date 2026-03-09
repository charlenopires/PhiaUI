/**
 * PhiaCodeSnippet — Copy-to-clipboard with "Copied!" visual feedback.
 */
const PhiaCodeSnippet = {
  mounted() {
    this.el.querySelectorAll("[data-copy-btn]").forEach((btn) => {
      btn.addEventListener("click", () => this.copyCode(btn));
    });
  },

  async copyCode(btn) {
    const code = btn.dataset.code;
    if (!code) return;

    try {
      await navigator.clipboard.writeText(code);
    } catch {
      // Fallback for older browsers
      const ta = document.createElement("textarea");
      ta.value = code;
      ta.style.position = "fixed";
      ta.style.opacity = "0";
      document.body.appendChild(ta);
      ta.select();
      document.execCommand("copy");
      document.body.removeChild(ta);
    }

    const copyIcon = btn.querySelector("[data-icon-copy]");
    const checkIcon = btn.querySelector("[data-icon-check]");

    if (copyIcon) copyIcon.classList.add("hidden");
    if (checkIcon) checkIcon.classList.remove("hidden");

    clearTimeout(this._timer);
    this._timer = setTimeout(() => {
      if (copyIcon) copyIcon.classList.remove("hidden");
      if (checkIcon) checkIcon.classList.add("hidden");
    }, 2000);
  },

  destroyed() {
    clearTimeout(this._timer);
  }
};

export default PhiaCodeSnippet;
