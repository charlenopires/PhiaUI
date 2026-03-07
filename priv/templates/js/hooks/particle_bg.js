/**
 * PhiaParticleBg — canvas floating particle field background.
 *
 * HTML anatomy:
 *   <div phx-hook="PhiaParticleBg"
 *        data-count="50"
 *        data-color="rgba(148,163,184,0.8)"
 *        data-speed="0.5"
 *        data-connect="true"
 *        class="relative overflow-hidden">
 *     <canvas data-particle-canvas class="absolute inset-0 w-full h-full"/>
 *   </div>
 *
 * Respects prefers-reduced-motion (no animation).
 */
const PhiaParticleBg = {
  mounted() {
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduced) return;

    this.canvas = this.el.querySelector('[data-particle-canvas]');
    if (!this.canvas) return;

    this.ctx = this.canvas.getContext('2d');

    this._count = parseInt(this.el.dataset.count) || 50;
    this._color = this.el.dataset.color || 'rgba(148,163,184,0.8)';
    this._speed = parseFloat(this.el.dataset.speed) || 0.5;
    this._connect = this.el.dataset.connect !== 'false';

    this._resize();
    this._particles = this._init();

    this._onResize = () => {
      this._resize();
      this._particles = this._init();
    };

    window.addEventListener('resize', this._onResize);
    this._animate();
  },

  _resize() {
    const el = this.el;
    this.canvas.width = el.offsetWidth || 300;
    this.canvas.height = el.offsetHeight || 200;
  },

  _init() {
    const { width, height } = this.canvas;
    const speed = this._speed;

    return Array.from({ length: this._count }, () => ({
      x: Math.random() * width,
      y: Math.random() * height,
      vx: (Math.random() - 0.5) * speed * 2,
      vy: (Math.random() - 0.5) * speed * 2,
      r: Math.random() * 2 + 1
    }));
  },

  _animate() {
    const ctx = this.ctx;
    const canvas = this.canvas;
    const particles = this._particles;
    const color = this._color;
    const connect = this._connect;
    const maxDist = 120;

    const step = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // Update + draw particles
      particles.forEach(p => {
        p.x += p.vx;
        p.y += p.vy;
        if (p.x < 0 || p.x > canvas.width) p.vx *= -1;
        if (p.y < 0 || p.y > canvas.height) p.vy *= -1;

        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = color;
        ctx.fill();
      });

      // Draw connecting lines
      if (connect) {
        for (let i = 0; i < particles.length; i++) {
          for (let j = i + 1; j < particles.length; j++) {
            const dx = particles[i].x - particles[j].x;
            const dy = particles[i].y - particles[j].y;
            const dist = Math.sqrt(dx * dx + dy * dy);

            if (dist < maxDist) {
              ctx.beginPath();
              ctx.moveTo(particles[i].x, particles[i].y);
              ctx.lineTo(particles[j].x, particles[j].y);
              ctx.strokeStyle = color;
              ctx.globalAlpha = 1 - dist / maxDist;
              ctx.lineWidth = 0.5;
              ctx.stroke();
              ctx.globalAlpha = 1;
            }
          }
        }
      }

      this._raf = requestAnimationFrame(step);
    };

    this._raf = requestAnimationFrame(step);
  },

  destroyed() {
    if (this._raf) cancelAnimationFrame(this._raf);
    if (this._onResize) window.removeEventListener('resize', this._onResize);
  }
};

export default PhiaParticleBg;
