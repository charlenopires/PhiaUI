defmodule PhiaUi.Components.LoadingOverlay do
  @moduledoc """
  Loading state components for blocking operations, animated loaders, and
  top-of-page progress indicators.

  Inspired by Mantine LoadingOverlay, Ant Design Spin, and the NProgress
  top-bar pattern used by GitHub, YouTube, and other major SaaS products.

  Pure CSS — no JavaScript hooks required.

  ## Sub-components

  | Component          | Purpose                                                      |
  |--------------------|--------------------------------------------------------------|
  | `loading_overlay/1`| Semi-transparent overlay blocking container/page interactions|
  | `loading_dots/1`   | Three-dot bounce animation (alternative to spinner)          |
  | `loading_bar/1`    | Slim animated top-of-page progress bar (NProgress style)     |

  ## Loading overlay (scoped to a container)

      <div class="relative">
        <.loading_overlay visible={@loading} label="Saving changes..." />
        <.form ...>...</.form>
      </div>

  ## Loading overlay (full screen)

      <.loading_overlay visible={@initializing} fullscreen label="Initializing..." />

  ## Bouncing dots

      <div class="flex items-center gap-2">
        <.loading_dots />
        <span class="text-sm text-muted-foreground">Processing...</span>
      </div>

  ## Top progress bar (root layout)

      <%!-- In root.html.heex, shown while navigating --%>
      <.loading_bar :if={@loading} />
  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Spinner, only: [spinner: 1]

  # ---------------------------------------------------------------------------
  # loading_overlay/1
  # ---------------------------------------------------------------------------

  attr(:visible, :boolean,
    default: true,
    doc: "When `false`, the overlay is not rendered."
  )

  attr(:label, :string,
    default: "Loading...",
    doc: "Accessible label — announced by screen readers and shown below the spinner when `show_label` is true."
  )

  attr(:show_label, :boolean,
    default: false,
    doc: "When `true`, displays the label text below the spinner."
  )

  attr(:fullscreen, :boolean,
    default: false,
    doc: "When `true`, uses `fixed inset-0` to cover the entire viewport. When `false` (default), uses `absolute inset-0` to cover the nearest `position: relative` ancestor."
  )

  attr(:blur, :boolean,
    default: false,
    doc: "When `true`, applies a subtle backdrop blur to the underlying content."
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the overlay.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the overlay `<div>`.")

  @doc """
  Renders a semi-transparent overlay that blocks user interaction during loading.

  For scoped containers (a card, a form section), place this as the first child
  inside a `position: relative` parent. For full-page blocking, set `fullscreen={true}`.

  ## Example

      <%!-- Scoped to a card --%>
      <div class="relative rounded-lg border p-6">
        <.loading_overlay visible={@saving} label="Saving..." show_label />
        <.card_content>...</.card_content>
      </div>

      <%!-- Full-page during initial data load --%>
      <.loading_overlay visible={@loading} fullscreen />
  """
  def loading_overlay(assigns) do
    ~H"""
    <div
      :if={@visible}
      role="status"
      aria-label={@label}
      aria-live="polite"
      class={cn([
        "flex flex-col items-center justify-center gap-3 z-50 bg-background/70",
        @fullscreen && "fixed inset-0",
        !@fullscreen && "absolute inset-0 rounded-[inherit]",
        @blur && "backdrop-blur-sm",
        @class
      ])}
      {@rest}
    >
      <.spinner size={:lg} label={@label} />
      <p :if={@show_label} class="text-sm text-muted-foreground font-medium">{@label}</p>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # loading_dots/1
  # ---------------------------------------------------------------------------

  attr(:size, :atom,
    values: [:sm, :default, :lg],
    default: :default,
    doc: "Size of the dots."
  )

  attr(:label, :string, default: "Loading", doc: "Screen-reader-only label.")
  attr(:class, :string, default: nil, doc: "Additional CSS classes.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the wrapper `<span>`.")

  @doc """
  Renders three animated bouncing dots as a loading indicator.

  Use as an alternative to `Spinner` when a more playful or compact loader
  is appropriate — typing indicators, inline "thinking" states, chat messages.

  Each dot staggers its bounce animation for a fluid wave effect.

  ## Example

      <%!-- Inline beside text --%>
      <div class="flex items-center gap-2 text-muted-foreground">
        <.loading_dots size={:sm} />
        <span class="text-sm">AI is thinking...</span>
      </div>
  """
  def loading_dots(assigns) do
    ~H"""
    <span
      role="status"
      aria-label={@label}
      class={cn(["inline-flex items-center gap-1", @class])}
      {@rest}
    >
      <span class={cn(["rounded-full bg-current animate-bounce motion-reduce:animate-none [animation-delay:-0.3s]", dot_size_class(@size)])}></span>
      <span class={cn(["rounded-full bg-current animate-bounce motion-reduce:animate-none [animation-delay:-0.15s]", dot_size_class(@size)])}></span>
      <span class={cn(["rounded-full bg-current animate-bounce motion-reduce:animate-none", dot_size_class(@size)])}></span>
      <span class="sr-only">{@label}</span>
    </span>
    """
  end

  # ---------------------------------------------------------------------------
  # loading_bar/1
  # ---------------------------------------------------------------------------

  attr(:class, :string, default: nil, doc: "Additional CSS classes for the bar.")
  attr(:rest, :global, doc: "HTML attrs forwarded to the root `<div>`.")

  @doc """
  Renders a slim indeterminate progress bar at the top of the page.

  Inspired by the NProgress library used by GitHub, YouTube, and other apps.
  Place at the very top of the viewport (before the main layout) and toggle
  visibility via a LiveView assign during navigation or long operations.

  The bar runs a shimmer animation indefinitely until removed from the DOM.

  ## Example

      <%!-- In root.html.heex --%>
      <.loading_bar :if={@page_loading} />
      <header>...</header>
      <main>...</main>
  """
  def loading_bar(assigns) do
    ~H"""
    <div
      role="progressbar"
      aria-label="Page loading"
      aria-valuenow="0"
      aria-valuemin="0"
      aria-valuemax="100"
      aria-valuetext="Loading..."
      class={cn([
        "fixed top-0 left-0 right-0 z-[200] h-0.5 bg-primary/20 overflow-hidden",
        @class
      ])}
      {@rest}
    >
      <div class="h-full bg-primary animate-[loading-bar-progress_1.5s_ease-in-out_infinite] motion-reduce:animate-none w-full origin-left"></div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp dot_size_class(:sm), do: "h-1.5 w-1.5"
  defp dot_size_class(:default), do: "h-2 w-2"
  defp dot_size_class(:lg), do: "h-2.5 w-2.5"
end
