/**
 * PhiaCollab — LiveView hook for collaborative editing via Phoenix Channels.
 *
 * Uses OT (Operational Transform) delta-based sync over Phoenix Channels.
 * Zero npm dependencies — no Yjs, no ProseMirror, no TipTap.
 *
 * Setup:
 *   import PhiaCollab from "./hooks/phia_collab"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaCollab } })
 *
 * Markup contract:
 *   - Hook root: phx-hook="PhiaCollab", id
 *   - Required attrs: data-doc-id, data-user-name, data-user-color
 *   - Optional: data-channel-topic (default: "editor:collab:<doc-id>")
 */

const PhiaCollab = {
  mounted() {
    this._channel = null;
    this._pendingOps = [];
    this._version = 0;

    const docId = this.el.dataset.docId;
    const userName = this.el.dataset.userName || "Anonymous";
    const userColor = this.el.dataset.userColor || "#6366f1";

    if (!docId) {
      console.warn("[PhiaCollab] No data-doc-id — collaboration disabled");
      return;
    }

    const topic = this.el.dataset.channelTopic || `editor:collab:${docId}`;

    // Join Phoenix Channel for OT sync
    this._channel = this._joinChannel(topic);

    // Store user info on element for other hooks to pick up
    this.el._collabUser = { name: userName, color: userColor };
    this.el._collabDocId = docId;

    if (this._channel) {
      // Handle server broadcasts
      this._channel.on("collab:op", (payload) => {
        this._applyRemoteOp(payload);
      });

      this._channel.on("collab:sync", (payload) => {
        this._handleSync(payload);
      });

      this._channel.on("collab:cursor:updated", (payload) => {
        this.pushEvent("collab:cursor", payload);
      });

      this._channel.on("collab:typing:updated", (payload) => {
        this.pushEvent("collab:typing", payload);
      });
    }
  },

  destroyed() {
    if (this._channel) {
      this._channel.leave();
      this._channel = null;
    }
  },

  // ===========================================================================
  // Channel
  // ===========================================================================

  _joinChannel(topic) {
    const liveSocket = this.liveSocket;
    if (!liveSocket || !liveSocket.socket) {
      console.warn("[PhiaCollab] Cannot access Phoenix socket from LiveSocket");
      return null;
    }

    const channel = liveSocket.socket.channel(topic, {});
    channel
      .join()
      .receive("ok", (resp) => {
        if (resp && resp.version !== undefined) {
          this._version = resp.version;
        }
        if (resp && resp.content) {
          this.pushEvent("collab:init", { content: resp.content, version: this._version });
        }
      })
      .receive("error", (resp) => {
        console.error(`[PhiaCollab] Failed to join ${topic}:`, resp);
      });

    return channel;
  },

  // ===========================================================================
  // OT Operations
  // ===========================================================================

  /**
   * Send a local operation to the server for transformation and broadcast.
   * Called by the editor hook when local content changes.
   */
  sendOp(op) {
    if (!this._channel) return;

    this._pendingOps.push(op);
    this._channel.push("collab:op", {
      op: op,
      version: this._version,
    });
  },

  _applyRemoteOp(payload) {
    const { op, version } = payload;
    this._version = version;
    this.pushEvent("collab:remote_op", { op, version });
  },

  _handleSync(payload) {
    const { content, version } = payload;
    this._version = version;
    this._pendingOps = [];
    this.pushEvent("collab:sync", { content, version });
  },

  // ===========================================================================
  // Cursor & typing
  // ===========================================================================

  sendCursor(cursorData) {
    if (!this._channel) return;
    this._channel.push("collab:cursor:update", {
      cursor: cursorData,
      user_id: this.el._collabUser?.name,
    });
  },

  sendTyping(isTyping) {
    if (!this._channel) return;
    const event = isTyping ? "collab:typing:start" : "collab:typing:stop";
    this._channel.push(event, {
      user_id: this.el._collabUser?.name,
    });
  },
};

export default PhiaCollab;
