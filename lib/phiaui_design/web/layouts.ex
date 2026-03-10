defmodule PhiaUiDesign.Web.Layouts do
  @moduledoc """
  Inline layout module for the PhiaUI Design tool.

  Both the root layout and the app layout are defined as function
  components here — no external HTML template files are needed,
  keeping the design tool self-contained within the library.

  ## JavaScript strategy

  Since this is a library with no asset build pipeline, we load the
  pre-built IIFE bundles for Phoenix and LiveView via `<script>` tags.
  These expose `window.Phoenix` and `window.LiveView` globals, which
  the inline bootstrap script uses to create the `LiveSocket`.
  """

  use Phoenix.Component

  @doc """
  Root HTML layout.

  Renders the full `<!DOCTYPE html>` document shell including:

  - Meta tags (charset, viewport, CSRF token)
  - Inline CSS for the editor chrome and the active PhiaUI theme
  - Script tags for Phoenix, LiveView, and the editor hooks
  - The inner content slot
  """
  def root(assigns) do
    assigns =
      assign(assigns, :head_css,
        Phoenix.HTML.raw(
          "<style>" <> editor_css() <> "</style>\n<style>" <> theme_css() <> "</style>"
        )
      )

    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="dark">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Phoenix.Controller.get_csrf_token()} />
        <title>PhiaUI Design</title>
        {@head_css}
        <script src="https://cdn.tailwindcss.com">
        </script>
        <script src="/assets/vendor/phoenix/phoenix.min.js">
        </script>
        <script src="/assets/vendor/phoenix_live_view/phoenix_live_view.min.js">
        </script>
        <script defer src="/assets/app.js">
        </script>
      </head>
      <body class="bg-background text-foreground antialiased">
        {@inner_content}
      </body>
    </html>
    """
  end

  @doc """
  App layout — wraps each LiveView render.

  Provides a flash message region and delegates the rest to the
  LiveView's own `render/1`.
  """
  def app(assigns) do
    ~H"""
    <main>
      <.flash_group flash={@flash} />
      {@inner_content}
    </main>
    """
  end

  defp flash_group(assigns) do
    ~H"""
    <div id="flash-group">
      <p
        :if={msg = Phoenix.Flash.get(@flash, :info)}
        class="fixed top-4 right-4 z-50 rounded-lg bg-emerald-500 p-3 text-sm text-white shadow-lg"
        role="alert"
      >
        {msg}
      </p>
      <p
        :if={msg = Phoenix.Flash.get(@flash, :error)}
        class="fixed top-4 right-4 z-50 rounded-lg bg-red-500 p-3 text-sm text-white shadow-lg"
        role="alert"
      >
        {msg}
      </p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Inline CSS
  # ---------------------------------------------------------------------------

  @doc false
  def editor_css do
    ~s"""
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body { font-family: ui-sans-serif, system-ui, sans-serif; overflow: hidden; height: 100vh; }

    .editor-layout {
      display: grid;
      grid-template-columns: 260px 1fr 300px;
      grid-template-rows: 48px 1fr;
      height: 100vh;
    }
    .editor-toolbar {
      grid-column: 1 / -1;
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0 1rem;
      border-bottom: 1px solid hsl(var(--border, 240 5.9% 90%));
      background: hsl(var(--background, 0 0% 100%));
    }
    .editor-left-panel {
      overflow-y: auto;
      border-right: 1px solid hsl(var(--border, 240 5.9% 90%));
      background: hsl(var(--card, 0 0% 100%));
    }
    .editor-canvas {
      overflow: auto;
      background-color: oklch(0.967 0 0);
      background-image: radial-gradient(circle, oklch(0.869 0 0) 1px, transparent 1px);
      background-size: 20px 20px;
      position: relative;
    }
    .dark .editor-canvas {
      background-color: oklch(0.205 0 0);
      background-image: radial-gradient(circle, oklch(0.269 0 0) 1px, transparent 1px);
    }
    .editor-right-panel {
      overflow-y: auto;
      border-left: 1px solid hsl(var(--border, 240 5.9% 90%));
      background: hsl(var(--card, 0 0% 100%));
    }

    .node-wrapper { position: relative; }
    .node-wrapper[data-selected="true"] {
      outline: 2px solid oklch(0.546 0.245 262.881);
      outline-offset: 2px;
      border-radius: 4px;
    }
    .node-wrapper[data-hovered="true"]:not([data-selected="true"]) {
      outline: 1px dashed oklch(0.546 0.245 262.881);
      outline-offset: 2px;
      border-radius: 4px;
    }

    .panel-section {
      padding: 0.75rem;
      border-bottom: 1px solid hsl(var(--border, 240 5.9% 90%));
    }
    .panel-section-title {
      font-size: 0.6875rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: hsl(var(--muted-foreground, 240 3.8% 46.1%));
      margin-bottom: 0.5rem;
    }

    .component-item {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.375rem 0.75rem;
      border-radius: 0.375rem;
      cursor: pointer;
      font-size: 0.8125rem;
      transition: background-color 0.15s;
    }
    .component-item:hover { background: hsl(var(--accent, 240 4.8% 95.9%)); }

    .property-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 0.5rem;
      padding: 0.25rem 0;
    }
    .property-label {
      font-size: 0.75rem;
      color: hsl(var(--muted-foreground, 240 3.8% 46.1%));
      min-width: 80px;
    }
    .property-input {
      flex: 1;
      font-size: 0.75rem;
      padding: 0.25rem 0.5rem;
      border: 1px solid hsl(var(--border, 240 5.9% 90%));
      border-radius: 0.25rem;
      background: hsl(var(--background, 0 0% 100%));
      color: hsl(var(--foreground, 240 10% 3.9%));
    }
    .property-input:focus {
      outline: 2px solid oklch(0.546 0.245 262.881);
      outline-offset: -1px;
    }

    .code-panel pre {
      font-size: 0.75rem;
      line-height: 1.5;
      padding: 0.75rem;
      overflow-x: auto;
      white-space: pre-wrap;
      word-break: break-all;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, monospace;
    }

    .layer-item {
      display: flex;
      align-items: center;
      gap: 0.375rem;
      padding: 0.25rem 0.5rem;
      font-size: 0.8125rem;
      cursor: pointer;
      border-radius: 0.25rem;
    }
    .layer-item:hover { background: hsl(var(--accent, 240 4.8% 95.9%)); }
    .layer-item[data-selected="true"] {
      background: hsl(var(--accent, 240 4.8% 95.9%));
      font-weight: 500;
    }

    .toolbar-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      height: 2rem;
      padding: 0 0.75rem;
      font-size: 0.8125rem;
      font-weight: 500;
      border-radius: 0.375rem;
      border: 1px solid hsl(var(--border, 240 5.9% 90%));
      background: hsl(var(--background, 0 0% 100%));
      color: hsl(var(--foreground, 240 10% 3.9%));
      cursor: pointer;
      transition: background-color 0.15s;
    }
    .toolbar-btn:hover { background: hsl(var(--accent, 240 4.8% 95.9%)); }
    .toolbar-btn:disabled { opacity: 0.5; cursor: not-allowed; }
    .toolbar-btn-primary {
      background: oklch(0.546 0.245 262.881);
      color: white;
      border-color: oklch(0.546 0.245 262.881);
    }
    .toolbar-btn-primary:hover { background: oklch(0.488 0.243 264.376); }

    .tab-btn {
      padding: 0.5rem 1rem;
      font-size: 0.75rem;
      font-weight: 500;
      background: none;
      border: none;
      border-bottom: 2px solid transparent;
      cursor: pointer;
      color: inherit;
    }
    .tab-btn-active { border-bottom-color: oklch(0.546 0.245 262.881); }

    .theme-select {
      font-size: 0.8125rem;
      padding: 0.25rem 0.5rem;
      border-radius: 0.25rem;
      border: 1px solid hsl(var(--border, 240 5.9% 90%));
      background: hsl(var(--background, 0 0% 100%));
      color: hsl(var(--foreground, 240 10% 3.9%));
    }

    .toolbar-separator {
      width: 1px;
      height: 1.5rem;
      background: hsl(var(--border, 240 5.9% 90%));
      margin: 0 0.25rem;
    }

    .empty-state {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100%;
      color: hsl(var(--muted-foreground, 240 3.8% 46.1%));
    }
    .empty-state-inner { text-align: center; }
    .empty-state-title {
      font-size: 1.125rem;
      font-weight: 600;
      margin-bottom: 0.5rem;
    }
    .empty-state-text { font-size: 0.875rem; }

    .canvas-content {
      padding: 2rem;
      max-width: 1200px;
      margin: 0 auto;
    }

    .node-label {
      font-size: 0.6875rem;
      color: hsl(var(--muted-foreground, 240 3.8% 46.1%));
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, monospace;
    }
    .node-placeholder {
      padding: 0.5rem;
      border: 1px dashed hsl(var(--border, 240 5.9% 90%));
      border-radius: 0.375rem;
      min-height: 2.5rem;
    }
    .node-children { padding-left: 1rem; margin-top: 0.5rem; }
    .node-inner-text { font-size: 0.8125rem; margin-left: 0.5rem; }

    .delete-btn {
      width: 100%;
      color: hsl(var(--destructive, 0 84.2% 60.2%));
    }

    .props-empty {
      color: hsl(var(--muted-foreground, 240 3.8% 46.1%));
      font-size: 0.8125rem;
      text-align: center;
      padding: 2rem 1rem;
    }

    .code-tabs {
      display: flex;
      border-bottom: 1px solid hsl(var(--border, 240 5.9% 90%));
    }
    .code-divider {
      border-top: 1px solid hsl(var(--border, 240 5.9% 90%));
    }

    .copy-btn { width: 100%; }

    .component-preview {
      min-height: 1.5rem;
      pointer-events: none;
    }
    .component-preview > * { pointer-events: none; }
    .render-error {
      font-size: 0.6875rem;
      color: hsl(var(--destructive, 0 84.2% 60.2%));
      padding: 0.25rem 0.5rem;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, monospace;
    }

    .template-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 0.75rem;
      padding: 0.75rem;
    }
    .template-card {
      padding: 1rem;
      border: 1px solid hsl(var(--border, 240 5.9% 90%));
      border-radius: 0.5rem;
      cursor: pointer;
      transition: border-color 0.15s, background-color 0.15s;
    }
    .template-card:hover {
      border-color: oklch(0.546 0.245 262.881);
      background: hsl(var(--accent, 240 4.8% 95.9%));
    }
    .template-card-name { font-weight: 600; font-size: 0.875rem; }
    .template-card-desc { font-size: 0.75rem; color: hsl(var(--muted-foreground, 240 3.8% 46.1%)); margin-top: 0.25rem; }

    .viewport-controls {
      display: flex;
      gap: 0.25rem;
      margin-left: 0.5rem;
    }
    .viewport-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 2rem;
      height: 2rem;
      font-size: 0.6875rem;
      border-radius: 0.25rem;
      border: 1px solid hsl(var(--border, 240 5.9% 90%));
      background: hsl(var(--background, 0 0% 100%));
      color: hsl(var(--foreground, 240 10% 3.9%));
      cursor: pointer;
    }
    .viewport-btn:hover { background: hsl(var(--accent, 240 4.8% 95.9%)); }
    .viewport-btn-active {
      background: oklch(0.546 0.245 262.881);
      color: white;
      border-color: oklch(0.546 0.245 262.881);
    }
    .canvas-viewport {
      margin: 0 auto;
      transition: max-width 0.3s ease;
    }

    .modal-backdrop {
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,0.5);
      z-index: 100;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .modal-content {
      background: hsl(var(--card, 0 0% 100%));
      border-radius: 0.75rem;
      width: 90%;
      max-width: 600px;
      max-height: 80vh;
      overflow-y: auto;
      box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
    }
    .modal-header {
      padding: 1rem 1.5rem;
      border-bottom: 1px solid hsl(var(--border, 240 5.9% 90%));
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .modal-title { font-weight: 600; font-size: 1rem; }
    """
  end

  @doc false
  def theme_css do
    theme = PhiaUi.Theme.get!(:zinc)
    PhiaUi.ThemeCSS.generate(theme)
  rescue
    _ -> "/* theme unavailable */"
  end
end
