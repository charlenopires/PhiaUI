defmodule PhiaUi.Components.Collapsible do
  @moduledoc """
  Collapsible section component using exclusively `Phoenix.LiveView.JS` — no JS Hooks required.

  A simple show/hide container with accessible trigger and content sub-components.
  State is controlled via the `:open` attr on each sub-component and toggled
  client-side using `Phoenix.LiveView.JS.toggle/1`.

  ## Sub-components

  | Function               | Element  | Purpose                                        |
  |------------------------|----------|------------------------------------------------|
  | `collapsible/1`        | `div`    | Root container — requires unique `:id`         |
  | `collapsible_trigger/1`| `button` | Toggle button with `aria-expanded`/`aria-controls` |
  | `collapsible_content/1`| `div`    | Collapsible content panel, hidden/visible      |

  ## Example — closed by default

      <.collapsible id="faq-1" open={false}>
        <.collapsible_trigger collapsible_id="faq-1" open={false}>
          Can I customise components?
        </.collapsible_trigger>
        <.collapsible_content id="faq-1-content" open={false}>
          Yes — all classes are overridable via the `:class` attr and `cn/1`.
        </.collapsible_content>
      </.collapsible>

  ## Example — open by default

      <.collapsible id="details" open={true}>
        <.collapsible_trigger collapsible_id="details" open={true}>
          Show details
        </.collapsible_trigger>
        <.collapsible_content id="details-content" open={true}>
          This panel starts visible.
        </.collapsible_content>
      </.collapsible>

  ## Server-controlled state

  Pass the LiveView assign directly to all three `:open` attrs to keep the
  rendered HTML in sync with server state:

      <.collapsible id="panel" open={@panel_open}>
        <.collapsible_trigger collapsible_id="panel" open={@panel_open}>
          Toggle
        </.collapsible_trigger>
        <.collapsible_content id="panel-content" open={@panel_open}>
          Content
        </.collapsible_content>
      </.collapsible>
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import PhiaUi.ClassMerger, only: [cn: 1]

  # ---------------------------------------------------------------------------
  # collapsible/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "Unique ID connecting trigger to content via aria-controls"
  )

  attr(:open, :boolean, default: false, doc: "Initial open state")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to root element")

  slot(:inner_block,
    required: true,
    doc: "collapsible_trigger and collapsible_content sub-components"
  )

  @doc """
  Renders a collapsible root container.

  The `:id` is required — it is used by `collapsible_trigger/1` to build
  the `aria-controls` value pointing at `collapsible_content/1`.
  """
  def collapsible(assigns) do
    ~H"""
    <div id={@id} class={cn([@class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # collapsible_trigger/1
  # ---------------------------------------------------------------------------

  attr(:collapsible_id, :string,
    required: true,
    doc: "ID of the parent collapsible — used for aria-controls and phx-click target"
  )

  attr(:open, :boolean,
    default: false,
    doc: "Current open state — controls the aria-expanded attribute"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the button element")

  slot(:inner_block, required: true, doc: "Trigger button content (text, icon, etc.)")

  @doc """
  Renders the collapsible trigger button.

  Uses `Phoenix.LiveView.JS.toggle/1` on `phx-click` to show/hide the content
  panel identified by `collapsible_id <> "-content"`.

  Sets the correct `aria-expanded` and `aria-controls` attributes for
  screen-reader accessibility.
  """
  def collapsible_trigger(assigns) do
    ~H"""
    <button
      type="button"
      aria-expanded={to_string(@open)}
      aria-controls={"#{@collapsible_id}-content"}
      class={cn(["flex items-center justify-between w-full", @class])}
      phx-click={JS.toggle(to: "##{@collapsible_id}-content", display: "block")}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ---------------------------------------------------------------------------
  # collapsible_content/1
  # ---------------------------------------------------------------------------

  attr(:id, :string,
    required: true,
    doc: "ID of the content element — should follow the pattern collapsible_id <> \"-content\""
  )

  attr(:open, :boolean,
    default: false,
    doc: "Initial visibility — true renders visible, false renders hidden"
  )

  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global, doc: "HTML attributes forwarded to the content div")

  slot(:inner_block, required: true, doc: "Content shown when the collapsible is open")

  @doc """
  Renders the collapsible content panel.

  When `open={false}` (default) the panel is hidden via `style="display: none;"`.
  The `phx-click` on `collapsible_trigger/1` calls `JS.toggle/1` on this element
  to toggle visibility without a server round-trip.

  Pass `open={true}` for panels that should start expanded.
  """
  def collapsible_content(assigns) do
    ~H"""
    <div
      id={@id}
      class={cn(["overflow-hidden", @class])}
      style={unless @open, do: "display: none;"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
