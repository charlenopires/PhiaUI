defmodule PhiaUi.Components.Toast do
  @moduledoc """
  Toast notification component with PhiaToast vanilla JS hook.

  The `toast/1` component renders a fixed viewport container once in your
  layout. The `PhiaToast` hook listens for `push_event/3` from the server
  and dynamically creates toast DOM nodes inside the container.

  Sub-components (`toast_title/1`, `toast_description/1`, `toast_action/1`,
  `toast_close/1`) are used for composing the individual toast item markup —
  either rendered statically or as templates in the hook.

  ## Sub-components

  - `toast/1` — fixed viewport container (`phx-hook="PhiaToast"`)
  - `toast_title/1` — toast heading
  - `toast_description/1` — toast body text
  - `toast_action/1` — action button with `phx-click`
  - `toast_close/1` — dismiss button

  ## Setup

  Add once to your root layout (inside `<body>`):

      <.toast id="phia-toast-viewport" />

  Trigger from LiveView:

      push_event(socket, "phia-toast", %{
        title: "Saved!",
        description: "Your changes were saved.",
        variant: "success",
        duration_ms: 4000
      })

  ## Hook setup

      import PhiaToast from "./hooks/toast"
      let liveSocket = new LiveSocket("/live", Socket, {
        hooks: { PhiaToast }
      })

  """

  use Phoenix.Component

  import PhiaUi.ClassMerger, only: [cn: 1]
  import PhiaUi.Components.Icon, only: [icon: 1]

  attr(:id, :string, required: true, doc: "Unique ID for the toast viewport")
  attr(:max_toasts, :integer, default: 5, doc: "Maximum number of toasts displayed at once")

  attr(:variant, :atom,
    default: :default,
    values: [:default, :success, :destructive, :warning],
    doc: "Default variant applied to toasts (hook can override per-toast)"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)

  @doc """
  Renders the toast viewport container.

  Place once in your root layout. The PhiaToast hook dynamically inserts
  toast nodes inside this container when `push_event/3` is received.
  """
  def toast(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="PhiaToast"
      role="status"
      aria-live="polite"
      aria-atomic="false"
      data-max-toasts={@max_toasts}
      data-variant={@variant}
      class={cn([
        "fixed bottom-0 right-0 z-[100] flex max-h-screen flex-col-reverse gap-2 p-4",
        "sm:flex-col md:max-w-[420px]",
        @class
      ])}
      {@rest}
    >
    </div>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders the toast title (heading)."
  def toast_title(assigns) do
    ~H"""
    <div class={cn(["text-sm font-semibold", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders the toast description (body text)."
  def toast_description(assigns) do
    ~H"""
    <div class={cn(["text-sm opacity-90", @class])} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:on_click, :string, required: true, doc: "phx-click event name for the action")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  @doc "Renders an action button inside a toast."
  def toast_action(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@on_click}
      class={cn([
        "inline-flex h-8 shrink-0 items-center justify-center rounded-md border",
        "bg-transparent px-3 text-sm font-medium transition-colors",
        "hover:bg-secondary focus:outline-none focus:ring-1",
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)

  @doc "Renders a dismiss (close) button for a toast."
  def toast_close(assigns) do
    ~H"""
    <button
      type="button"
      aria-label="Close"
      data-toast-close
      class={cn([
        "absolute right-1 top-1 rounded-md p-1 opacity-0 transition-opacity",
        "hover:opacity-100 focus:opacity-100 focus:outline-none",
        @class
      ])}
      {@rest}
    >
      <.icon name="x" size={:sm} />
    </button>
    """
  end
end
