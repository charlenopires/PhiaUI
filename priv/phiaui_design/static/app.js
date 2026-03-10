// PhiaUI Design — Editor JavaScript
//
// This script runs AFTER the Phoenix and LiveView IIFE bundles have been
// loaded via <script> tags in the root layout. Those bundles expose:
//
//   window.Phoenix  — { Socket, Channel, ... }
//   window.LiveView — { LiveSocket, ViewHook, ... }
//
// No bundler or build step is needed.

(function () {
  "use strict";

  // ── Hooks ────────────────────────────────────────────────────────────────

  var Hooks = {};

  /**
   * EditorKeyboard — global keyboard shortcuts.
   *
   * Attached to the root editor element. Listens for:
   * - Cmd/Ctrl+Z        → undo
   * - Cmd/Ctrl+Shift+Z  → redo
   * - Delete / Backspace → delete selected node (when not in an input)
   */
  Hooks.EditorKeyboard = {
    mounted: function () {
      var self = this;

      this._handleKeydown = function (e) {
        var isMod = e.metaKey || e.ctrlKey;

        // Undo
        if (isMod && e.key === "z" && !e.shiftKey) {
          e.preventDefault();
          self.pushEvent("undo", {});
          return;
        }

        // Redo
        if (isMod && e.key === "z" && e.shiftKey) {
          e.preventDefault();
          self.pushEvent("redo", {});
          return;
        }

        // Delete / Backspace (only when not focused on a form field)
        if (e.key === "Delete" || e.key === "Backspace") {
          var tag = document.activeElement && document.activeElement.tagName;
          if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") return;

          e.preventDefault();
          var selected = document.querySelector('[data-selected="true"]');
          if (selected && selected.dataset.nodeId) {
            self.pushEvent("delete_node", { id: selected.dataset.nodeId });
          }
        }
      };

      document.addEventListener("keydown", this._handleKeydown);
    },

    destroyed: function () {
      document.removeEventListener("keydown", this._handleKeydown);
    }
  };

  /**
   * CopyClipboard — copies the `data-code` attribute to the system clipboard.
   */
  Hooks.CopyClipboard = {
    mounted: function () {
      var el = this.el;

      el.addEventListener("click", function () {
        var code = el.getAttribute("data-code");
        if (!code || !navigator.clipboard) return;

        navigator.clipboard.writeText(code).then(function () {
          var original = el.textContent;
          el.textContent = "Copied!";
          setTimeout(function () {
            el.textContent = original;
          }, 2000);
        });
      });
    }
  };

  // ── LiveSocket bootstrap ─────────────────────────────────────────────────

  var Socket = window.Phoenix && window.Phoenix.Socket;
  var LiveSocket = window.LiveView && window.LiveView.LiveSocket;

  if (!Socket || !LiveSocket) {
    console.error(
      "[PhiaUI Design] Phoenix or LiveView JS not loaded. " +
      "Ensure the <script> tags for phoenix.min.js and " +
      "phoenix_live_view.min.js are present in the layout."
    );
    return;
  }

  var csrfMeta = document.querySelector("meta[name='csrf-token']");
  var csrfToken = csrfMeta ? csrfMeta.getAttribute("content") : "";

  var liveSocket = new LiveSocket("/live", Socket, {
    hooks: Hooks,
    params: { _csrf_token: csrfToken }
  });

  liveSocket.connect();
  window.liveSocket = liveSocket;
})();
