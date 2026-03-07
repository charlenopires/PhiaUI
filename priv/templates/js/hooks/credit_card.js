// PhiaCreditCard — formats card number (4×4), expiry (MM/YY), auto-advances fields.

const PhiaCreditCard = {
  mounted() {
    this._wireNumber();
    this._wireExpiry();
    this._wireCvv();
  },

  _wireNumber() {
    const el = this.el.querySelector("[data-cc-number]");
    if (!el) return;
    el.addEventListener("input", () => {
      let v = el.value.replace(/\D/g, "").slice(0, 16);
      // Format as "XXXX XXXX XXXX XXXX"
      v = v.replace(/(.{4})/g, "$1 ").trim();
      el.value = v;
      // Auto-advance when full (19 chars with spaces)
      if (v.replace(/\s/g, "").length >= 16) {
        const expiry = this.el.querySelector("[data-cc-expiry]");
        if (expiry) expiry.focus();
      }
    });

    el.addEventListener("keydown", (e) => {
      if (e.key === "Backspace" && el.value.endsWith(" ")) {
        el.value = el.value.slice(0, -1);
      }
    });
  },

  _wireExpiry() {
    const el = this.el.querySelector("[data-cc-expiry]");
    if (!el) return;
    el.addEventListener("input", () => {
      let v = el.value.replace(/\D/g, "").slice(0, 4);
      if (v.length >= 2) {
        v = v.slice(0, 2) + "/" + v.slice(2);
      }
      el.value = v;
      if (v.replace(/\D/g, "").length >= 4) {
        const cvv = this.el.querySelector("[data-cc-cvv]");
        if (cvv) cvv.focus();
      }
    });

    el.addEventListener("keydown", (e) => {
      if (e.key === "Backspace" && el.value === "") {
        const num = this.el.querySelector("[data-cc-number]");
        if (num) num.focus();
      }
    });
  },

  _wireCvv() {
    const el = this.el.querySelector("[data-cc-cvv]");
    if (!el) return;
    el.addEventListener("input", () => {
      el.value = el.value.replace(/\D/g, "").slice(0, 4);
      if (el.value.length >= 3) {
        const cardholder = this.el.querySelector("[data-cc-cardholder]");
        if (cardholder) cardholder.focus();
      }
    });

    el.addEventListener("keydown", (e) => {
      if (e.key === "Backspace" && el.value === "") {
        const exp = this.el.querySelector("[data-cc-expiry]");
        if (exp) exp.focus();
      }
    });
  },
};

export default PhiaCreditCard;
