/**
 * PhiaTipTapCollab — Yjs collaboration provider using Phoenix Channels.
 *
 * Replaces Hocuspocus (Node.js WebSocket server) with a Phoenix Channel
 * transport for Yjs document synchronization. Works with TipTap's
 * Collaboration and CollaborationCursor extensions.
 *
 * Setup:
 *   npm install yjs @tiptap/extension-collaboration @tiptap/extension-collaboration-cursor
 *
 *   // In app.js:
 *   import * as Y from "yjs"
 *   import { Collaboration } from "@tiptap/extension-collaboration"
 *   import { CollaborationCursor } from "@tiptap/extension-collaboration-cursor"
 *   window.tiptap = { ...window.tiptap, Y, Collaboration, CollaborationCursor }
 *
 *   import PhiaTipTapCollab from "./hooks/tiptap_collab"
 *   let liveSocket = new LiveSocket("/live", Socket, { hooks: { PhiaTipTapCollab } })
 *
 * Markup contract:
 *   - Hook root: phx-hook="PhiaTipTapCollab", id
 *   - Required attrs: data-doc-id, data-user-name, data-user-color
 *   - Optional: data-channel-topic (default: "editor:collab:<doc-id>")
 */

/**
 * PhoenixProvider — Yjs provider backed by a Phoenix Channel.
 *
 * Implements the Yjs sync protocol (sync-step-1, sync-step-2, update)
 * over a Phoenix Channel instead of WebSocket directly.
 */
class PhoenixProvider {
  constructor(channel, yDoc) {
    this._channel = channel;
    this._doc = yDoc;
    this._synced = false;

    // Listen for server messages
    this._channel.on("yjs:sync-step-1", ({ state }) => {
      if (state) {
        // Server has state — send our state vector so it can compute diff
        const sv = window.tiptap.Y.encodeStateVector(this._doc);
        this._channel.push("yjs:sync-step-1", {
          state_vector: this._toBase64(sv),
        });
      }

      // Send our full state as step-2
      const fullState = window.tiptap.Y.encodeStateAsUpdate(this._doc);
      this._channel.push("yjs:sync-step-2", {
        diff: this._toBase64(fullState),
      });
    });

    this._channel.on("yjs:sync-step-2", ({ diff }) => {
      if (diff) {
        const update = this._fromBase64(diff);
        window.tiptap.Y.applyUpdate(this._doc, update);
      }
      this._synced = true;
    });

    this._channel.on("yjs:update", ({ update }) => {
      if (update) {
        const decoded = this._fromBase64(update);
        window.tiptap.Y.applyUpdate(this._doc, decoded);
      }
    });

    // Forward local updates to server
    this._updateHandler = (update, origin) => {
      if (origin !== this) {
        this._channel.push("yjs:update", {
          update: this._toBase64(update),
        });
      }
    };
    this._doc.on("update", this._updateHandler);
  }

  destroy() {
    this._doc.off("update", this._updateHandler);
  }

  _toBase64(uint8Array) {
    let binary = "";
    for (let i = 0; i < uint8Array.length; i++) {
      binary += String.fromCharCode(uint8Array[i]);
    }
    return btoa(binary);
  }

  _fromBase64(base64) {
    const binary = atob(base64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return bytes;
  }
}

const PhiaTipTapCollab = {
  mounted() {
    this._provider = null;
    this._awareness = null;

    if (!window.tiptap || !window.tiptap.Y) {
      console.warn(
        "[PhiaTipTapCollab] Yjs not found on window.tiptap.Y — collaboration disabled"
      );
      return;
    }

    const docId = this.el.dataset.docId;
    const userName = this.el.dataset.userName || "Anonymous";
    const userColor = this.el.dataset.userColor || "#6366f1";
    const topic =
      this.el.dataset.channelTopic || `editor:collab:${docId}`;

    // Create Y.Doc
    const yDoc = new window.tiptap.Y.Doc();

    // Join Phoenix Channel
    const channel = this._joinChannel(topic);

    // Create provider
    this._provider = new PhoenixProvider(channel, yDoc);

    // Store on element for TipTap editor hook to pick up
    this.el._yjsDoc = yDoc;
    this.el._yjsProvider = this._provider;
    this.el._collabUser = { name: userName, color: userColor };

    // Handle awareness updates for cursor broadcasting
    channel.on("awareness:update", (payload) => {
      this.pushEvent("collab:awareness", payload);
    });
  },

  destroyed() {
    if (this._provider) {
      this._provider.destroy();
      this._provider = null;
    }
  },

  _joinChannel(topic) {
    // Access the LiveSocket's Phoenix socket to create a channel
    const liveSocket = this.liveSocket;
    if (!liveSocket || !liveSocket.socket) {
      console.warn("[PhiaTipTapCollab] Cannot access Phoenix socket from LiveSocket");
      return null;
    }

    const channel = liveSocket.socket.channel(topic, {});
    channel
      .join()
      .receive("ok", () => {
        console.log(`[PhiaTipTapCollab] Joined ${topic}`);
      })
      .receive("error", (resp) => {
        console.error(`[PhiaTipTapCollab] Failed to join ${topic}:`, resp);
      });

    return channel;
  },
};

export default PhiaTipTapCollab;
