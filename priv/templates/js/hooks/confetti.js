/**
 * PhiaConfetti — canvas confetti particle burst.
 *
 * HTML anatomy:
 *   <div phx-hook="PhiaConfetti"
 *        data-trigger="mount|click"
 *        data-count="80"
 *        data-colors='["#ff0000","#00ff00","#0000ff"]'
 *        class="relative">
 *     <canvas data-confetti-canvas class="absolute inset-0 w-full h-full pointer-events-none"/>
 *     ...optional slot content...
 *   </div>
 *
 * Respects prefers-reduced-motion (no animation).
 */
const PhiaConfetti = {
  mounted() {
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduced) return;

    this.canvas = this.el.querySelector('[data-confetti-canvas]');
    if (!this.canvas) return;

    this.ctx = this.canvas.getContext('2d');
    const trigger = this.el.dataset.trigger || 'mount';
    const count = parseInt(this.el.dataset.count) || 80;

    let colors;
    try {
      colors = JSON.parse(this.el.dataset.colors || '[]');
    } catch {
      colors = ['#ff0000', '#00ff00', '#0000ff'];
    }

    if (!colors.length) colors = ['#ff0000', '#00ff00', '#0000ff'];

    if (trigger === 'mount') {
      this._burst(count, colors);
    } else {
      this._onClick = () => this._burst(count, colors);
      this.el.addEventListener('click', this._onClick);
    }
  },

  _burst(count, colors) {
    const canvas = this.canvas;
    const ctx = this.ctx;

    canvas.width = canvas.offsetWidth || this.el.offsetWidth;
    canvas.height = canvas.offsetHeight || this.el.offsetHeight;

    const particles = Array.from({ length: count }, () => ({
      x: canvas.width / 2,
      y: canvas.height / 2,
      vx: (Math.random() - 0.5) * 10,
      vy: (Math.random() - 0.9) * 12,
      color: colors[Math.floor(Math.random() * colors.length)],
      w: Math.random() * 8 + 3,
      h: Math.random() * 4 + 2,
      alpha: 1,
      rotation: Math.random() * 360,
      rotSpeed: (Math.random() - 0.5) * 6
    }));

    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      let alive = false;

      particles.forEach(p => {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.25; // gravity
        p.vx *= 0.99; // air resistance
        p.alpha -= 0.01;
        p.rotation += p.rotSpeed;

        if (p.alpha > 0) {
          alive = true;
          ctx.save();
          ctx.globalAlpha = Math.max(p.alpha, 0);
          ctx.fillStyle = p.color;
          ctx.translate(p.x, p.y);
          ctx.rotate(p.rotation * Math.PI / 180);
          ctx.fillRect(-p.w / 2, -p.h / 2, p.w, p.h);
          ctx.restore();
        }
      });

      if (alive) this._raf = requestAnimationFrame(animate);
    };

    if (this._raf) cancelAnimationFrame(this._raf);
    this._raf = requestAnimationFrame(animate);
  },

  destroyed() {
    if (this._raf) cancelAnimationFrame(this._raf);
    if (this._onClick) this.el.removeEventListener('click', this._onClick);
  }
};

export default PhiaConfetti;
