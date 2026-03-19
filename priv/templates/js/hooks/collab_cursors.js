/**
 * PhiaCollabCursors — collaborative cursor overlay hook.
 *
 * Tracks local pointer movements within the hook's container element and
 * pushes debounced position events to the server. Receives remote cursor
 * positions via handleEvent and positions cursor DOM elements using CSS
 * transforms. Adds the `phia-cursor-idle` class after 3 seconds of no
 * movement from a given cursor.
 *
 * Emits:
 *   pushEvent("collab:cursor:move", { x: Number, y: Number })
 *
 * Receives:
 *   handleEvent("collab:cursors:update", { cursors: [{ id, x, y }] })
 *
 * Registration:
 *   import PhiaCollabCursors from "./hooks/collab_cursors"
 *   let liveSocket = new LiveSocket("/live", Socket, {
 *     hooks: { PhiaCollabCursors }
 *   })
 */
const PhiaCollabCursors = {
  mounted() {
    this._cursors = new Map();
    this._idleTimers = new Map();
    this._lastPush = 0;
    this._container = this.el;
    this._reduceMotion = window.matchMedia(
      "(prefers-reduced-motion: reduce)"
    ).matches;

    // Track pointer movements within the container
    this._onPointerMove = (e) => {
      const now = Date.now();
      if (now - this._lastPush < 50) return;
      this._lastPush = now;

      const rect = this._container.getBoundingClientRect();
      this.pushEvent("collab:cursor:move", {
        x: Math.round(e.clientX - rect.left),
        y: Math.round(e.clientY - rect.top),
      });
    };

    // Track pointer leaving the container
    this._onPointerLeave = () => {
      this.pushEvent("collab:cursor:leave", {});
    };

    this._container.addEventListener("pointermove", this._onPointerMove);
    this._container.addEventListener("pointerleave", this._onPointerLeave);

    // Receive cursor updates from server
    this.handleEvent("collab:cursors:update", ({ cursors }) => {
      if (!Array.isArray(cursors)) return;

      cursors.forEach((cursor) => {
        const el = this._container.querySelector(
          `[data-cursor-id="${cursor.id}"]`
        );
        if (!el) return;

        // Apply position via transform
        if (this._reduceMotion) {
          el.style.transform = `translate(${cursor.x}px, ${cursor.y}px)`;
        } else {
          el.style.transition = "transform 80ms linear";
          el.style.transform = `translate(${cursor.x}px, ${cursor.y}px)`;
        }

        // Remove idle state on movement
        el.classList.remove("phia-cursor-idle");

        // Reset idle timer — mark idle after 3 seconds of no updates
        const prevTimer = this._idleTimers.get(cursor.id);
        if (prevTimer) clearTimeout(prevTimer);

        this._idleTimers.set(
          cursor.id,
          setTimeout(() => {
            el.classList.add("phia-cursor-idle");
          }, 3000)
        );

        this._cursors.set(cursor.id, cursor);
      });
    });

    // Handle cursor removal
    this.handleEvent("collab:cursor:remove", ({ id }) => {
      const el = this._container.querySelector(`[data-cursor-id="${id}"]`);
      if (el) {
        el.style.opacity = "0";
        setTimeout(() => {
          el.style.display = "none";
        }, 300);
      }
      this._idleTimers.delete(id);
      this._cursors.delete(id);
    });
  },

  destroyed() {
    if (this._container) {
      this._container.removeEventListener("pointermove", this._onPointerMove);
      this._container.removeEventListener(
        "pointerleave",
        this._onPointerLeave
      );
    }

    // Clear all idle timers
    this._idleTimers.forEach((timer) => clearTimeout(timer));
    this._idleTimers.clear();
    this._cursors.clear();
  },
};

export { PhiaCollabCursors };
export default PhiaCollabCursors;
